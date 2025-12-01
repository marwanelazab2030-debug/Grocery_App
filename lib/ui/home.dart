import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/utils/product_localization.dart';

import 'cart_screen.dart';
import 'profile_screen.dart';
import 'product_details.dart';
import 'my_orders_screen.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/skeleton_banners.dart';
import 'widgets/skeleton_categories.dart';
import 'widgets/skeleton_products.dart';

// --- 🔹 Colors ---
const Color kPrimaryColor = Color(0xFF3bb54a);
const Color kBackgroundLight = Color(0xFFf6f8f6);
const Color kChipUnselectedLight = Color(0xFFFFFFFF);
const Color kChipUnselectedTextLight = Color(0xFF1f2937);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    CartScreen(),
    MyOrdersScreen(showBack: false),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// -------------------------------
// 🔹 HomeContent (Optimized)
// -------------------------------
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // 🔥 Elite Performance: Granular State Management
  final ValueNotifier<String> _selectedCategoryNotifier = ValueNotifier('all');
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<Map<String, int>> _cartItemsNotifier = ValueNotifier({});
  final ValueNotifier<Set<String>> _favoritesNotifier = ValueNotifier({});

  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  StreamSubscription? _cartSubscription;
  StreamSubscription? _favSubscription;

  // Memoized Streams
  late final Stream<QuerySnapshot> _bannersStream;
  late final Stream<QuerySnapshot> _productsStream;
  late final Stream<QuerySnapshot> _pricesStream;

  @override
  void initState() {
    super.initState();
    _setupStreams();
    _setupUserListeners();
    _precacheImages();
  }

  void _setupStreams() {
    _bannersStream = db.collection('banners').orderBy('createdAt', descending: true).snapshots();
    _productsStream = db.collection('masterProducts').orderBy('createdAt', descending: true).snapshots();
    _pricesStream = db.collection('dailyPrices').snapshots();
  }

  void _setupUserListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Listen to Cart
      _cartSubscription = db.collection('users').doc(user.uid).collection('cart').snapshots().listen((snapshot) {
        final Map<String, int> items = {};
        for (var doc in snapshot.docs) {
          items[doc.id] = (doc['quantity'] ?? 1) as int;
        }
        _cartItemsNotifier.value = items;
      });

      // Listen to Favorites
      _favSubscription = db.collection('users').doc(user.uid).collection('favorites').snapshots().listen((snapshot) {
        final Set<String> ids = {};
        for (var doc in snapshot.docs) {
          ids.add(doc.id);
        }
        _favoritesNotifier.value = ids;
      });
    }
  }

  void _precacheImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(const AssetImage('assets/icons/categories.png'), context);
      precacheImage(const AssetImage('assets/icons/vegetable.png'), context);
      precacheImage(const AssetImage('assets/icons/fruit.png'), context);
      precacheImage(const AssetImage('assets/icons/dates.png'), context);
      precacheImage(const AssetImage('assets/icons/egg.png'), context);
    });
  }

  @override
  void dispose() {
    _selectedCategoryNotifier.dispose();
    _searchQueryNotifier.dispose();
    _cartItemsNotifier.dispose();
    _favoritesNotifier.dispose();
    _searchController.dispose();
    _cartSubscription?.cancel();
    _favSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          // 🔹 Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _searchQueryNotifier.value = value.trim(),
                style: GoogleFonts.cairo(color: kChipUnselectedTextLight),
                decoration: InputDecoration(
                  hintText: strings.homeSearchHint,
                  hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 12.0),
                    child: Icon(Symbols.search, color: Colors.grey.shade500),
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Banners
          SliverToBoxAdapter(
            child: _BannersSection(stream: _bannersStream, strings: strings),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 🔹 Categories
          SliverToBoxAdapter(
            child: _CategoriesSection(
              selectedCategoryNotifier: _selectedCategoryNotifier,
              strings: strings,
            ),
          ),

          // 🔹 Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.homeBestPricesTitle,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/favorites'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset('assets/icons/fav1.png', width: 26, height: 26),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Product Grid
          _ProductGrid(
            productsStream: _productsStream,
            pricesStream: _pricesStream,
            searchQueryNotifier: _searchQueryNotifier,
            selectedCategoryNotifier: _selectedCategoryNotifier,
            cartItemsNotifier: _cartItemsNotifier,
            favoritesNotifier: _favoritesNotifier,
            strings: strings,
          ),

          // Bottom Padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
        ],
      ),
    );
  }
}

// -------------------------------
// 🔹 Banners Section
// -------------------------------
class _BannersSection extends StatelessWidget {
  final Stream<QuerySnapshot> stream;
  final AppLocalizations strings;

  const _BannersSection({required this.stream, required this.strings});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                strings.genericErrorLoadingData,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) return const BannersSkeleton();

          final banners = snapshot.data!.docs;
          if (banners.isEmpty) return const SizedBox.shrink();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            cacheExtent: 200.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index].data() as Map<String, dynamic>;
              return Container(
                width: 320,
                margin: const EdgeInsetsDirectional.only(end: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: CachedNetworkImage(
                    imageUrl: (banner['imageUrl'] ?? '') as String,
                    fit: BoxFit.cover,
                    memCacheWidth: 640, // 🔥 Optimize banner memory
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------
// 🔹 Categories Section
// -------------------------------
class _CategoriesSection extends StatelessWidget {
  final ValueNotifier<String> selectedCategoryNotifier;
  final AppLocalizations strings;

  const _CategoriesSection({
    required this.selectedCategoryNotifier,
    required this.strings,
  });

  static const Map<String, String> categories = {
    'all': 'assets/icons/categories.png',
    'vegetables': 'assets/icons/vegetable.png',
    'fruits': 'assets/icons/fruit.png',
    'dates': 'assets/icons/dates.png',
    'eggs': 'assets/icons/egg.png',
  };

  String _categoryLabel(String category) {
    switch (category) {
      case 'all': return strings.homeCategoryAll;
      case 'vegetables': return strings.homeCategoryVegetables;
      case 'fruits': return strings.homeCategoryFruits;
      case 'dates': return strings.homeCategoryDates;
      case 'eggs': return strings.homeCategoryEggs;
      default: return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final double dynamicHeight = 50.0 + (textScale > 1 ? (textScale * 10) : 5);

    return SizedBox(
      height: dynamicHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final entry = categories.entries.elementAt(index);
          final catName = entry.key;

          return ValueListenableBuilder<String>(
            valueListenable: selectedCategoryNotifier,
            builder: (context, selectedCategory, _) {
              final bool isSelected = selectedCategory == catName;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => selectedCategoryNotifier.value = catName,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      _categoryLabel(catName),
                      style: GoogleFonts.tajawal(
                        fontSize: 15,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------
// 🔹 Product Grid
// -------------------------------
class _ProductGrid extends StatelessWidget {
  final Stream<QuerySnapshot> productsStream;
  final Stream<QuerySnapshot> pricesStream;
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<String> selectedCategoryNotifier;
  final ValueNotifier<Map<String, int>> cartItemsNotifier;
  final ValueNotifier<Set<String>> favoritesNotifier;
  final AppLocalizations strings;

  const _ProductGrid({
    required this.productsStream,
    required this.pricesStream,
    required this.searchQueryNotifier,
    required this.selectedCategoryNotifier,
    required this.cartItemsNotifier,
    required this.favoritesNotifier,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: productsStream,
      builder: (context, productsSnap) {
        if (productsSnap.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                strings.genericErrorLoadingData,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            ),
          );
        }
        if (!productsSnap.hasData) return const SliverToBoxAdapter(child: ProductsSkeleton());

        return StreamBuilder<QuerySnapshot>(
          stream: pricesStream,
          builder: (context, pricesSnap) {
            if (pricesSnap.hasError) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    strings.genericErrorLoadingData,
                    style: GoogleFonts.cairo(color: Colors.red),
                  ),
                ),
              );
            }
            if (!pricesSnap.hasData) {
              return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
            }

            // Calculate Prices
            final Map<String, double> minByProduct = {};
            for (final stallDoc in pricesSnap.data!.docs) {
              final data = stallDoc.data() as Map<String, dynamic>;
              final prices = (data['prices'] ?? {}) as Map<String, dynamic>;
              prices.forEach((productId, value) {
                final v = (value is num) ? value.toDouble() : double.tryParse('$value') ?? 0.0;
                if (v > 0) {
                  final current = minByProduct[productId];
                  if (current == null || v < current) {
                    minByProduct[productId] = v;
                  }
                }
              });
            }

            return ValueListenableBuilder<String>(
              valueListenable: selectedCategoryNotifier,
              builder: (context, selectedCategory, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: searchQueryNotifier,
                  builder: (context, searchQuery, _) {
                    // Filter Products
                    final products = productsSnap.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['name'] ?? '').toString();
                      final category = (data['category'] ?? '').toString();

                      String targetCategory = selectedCategory;
                      if (selectedCategory == 'vegetables') targetCategory = 'خضار';
                      else if (selectedCategory == 'fruits') targetCategory = 'فواكه';
                      else if (selectedCategory == 'dates') targetCategory = 'تمور';
                      else if (selectedCategory == 'eggs') targetCategory = 'بيض';

                      final categoryMatch = selectedCategory == 'all' || category == targetCategory;
                      final searchMatch = searchQuery.isEmpty || name.toLowerCase().contains(searchQuery.toLowerCase());
                      return categoryMatch && searchMatch;
                    }).toList();

                    if (products.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Center(
                            child: Text(strings.homeNoProductsMessage,
                                style: GoogleFonts.cairo(color: Colors.grey)),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12.0,
                          mainAxisSpacing: 12.0,
                          // 🟢 Dynamic Height: Image (Width/2) + Fixed Content Height (~110px)
                          // This prevents huge gaps on larger screens and fits perfectly on phones.
                          mainAxisExtent: (MediaQuery.of(context).size.width / 2) + 110, 
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final doc = products[index];
                            final product = doc.data() as Map<String, dynamic>;
                            final productId = doc.id;
                            final price = minByProduct[productId];

                            if (price == null || price == 0) return const SizedBox.shrink();

                            return _ProductCard(
                              productId: productId,
                              product: product,
                              price: price,
                              cartItemsNotifier: cartItemsNotifier,
                              favoritesNotifier: favoritesNotifier,
                              strings: strings,
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// -------------------------------
// 🔹 Product Card (Optimized)
// -------------------------------
class _ProductCard extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> product;
  final double price;
  final ValueNotifier<Map<String, int>> cartItemsNotifier;
  final ValueNotifier<Set<String>> favoritesNotifier;
  final AppLocalizations strings;

  const _ProductCard({
    required this.productId,
    required this.product,
    required this.price,
    required this.cartItemsNotifier,
    required this.favoritesNotifier,
    required this.strings,
  });

  Future<void> _addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final existing = await cartRef.get();
    if (existing.exists) {
      final currentQty = (existing['quantity'] ?? 1) + 1;
      await cartRef.update({
        'quantity': currentQty,
        'name': product['name'],
        'name_ar': product['name_ar'] ?? '',
        'name_en': product['name_en'] ?? '',
        'imageUrl': product['imageUrl'],
        'price': price,
        'unit': product['unit'],
      });
    } else {
      await cartRef.set({
        'name': product['name'],
        'name_ar': product['name_ar'] ?? '',
        'name_en': product['name_en'] ?? '',
        'unit': product['unit'],
        'imageUrl': product['imageUrl'],
        'price': price,
        'quantity': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(strings.homeAddedToCart,
                    style: GoogleFonts.cairo(color: Colors.white)),
              ],
            ),
            backgroundColor: kPrimaryColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updateQuantity(int change) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    final doc = await cartRef.get();
    if (!doc.exists) return;

    final currentQty = (doc['quantity'] ?? 1) + change;
    if (currentQty <= 0) {
      await cartRef.delete();
    } else {
      await cartRef.update({'quantity': currentQty});
    }
  }

  Future<void> _toggleFavorite(bool isFav) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    if (isFav) {
      await favRef.delete();
    } else {
      await favRef.set({
        'productId': productId,
        'name': product['name'],
        'name_ar': product['name_ar'] ?? '',
        'name_en': product['name_en'] ?? '',
        'unit': product['unit'],
        'imageUrl': product['imageUrl'],
        'price': price,
        'description_ar': product['description_ar'] ?? '',
        'description_en': product['description_en'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabicLocale = Localizations.localeOf(context).languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: {
                'id': productId,
                'name': product['name'],
                'name_ar': product['name_ar'],
                'name_en': product['name_en'],
                'unit': product['unit'],
                'imageUrl': product['imageUrl'],
                'price': price.toStringAsFixed(2),
                'description_ar': product['description_ar'] ?? '',
                'description_en': product['description_en'] ?? '',
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🖼️ Product image section
              AspectRatio(
                aspectRatio: 1.0, 
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: (product['imageUrl'] ?? '') as String,
                          fit: BoxFit.cover,
                          memCacheWidth: 300, 
                          placeholder: (context, url) => Container(color: Colors.grey.shade200),
                          errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable: favoritesNotifier,
                        builder: (context, favorites, _) {
                          final isFav = favorites.contains(productId);
                          return GestureDetector(
                            onTap: () => _toggleFavorite(isFav),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey.shade500,
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 🏷️ Product info + add/remove buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name & Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final name = localizedProductName(
                              product,
                              isArabic: isArabicLocale,
                            );
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 2),
                        Builder(
                          builder: (context) {
                            final unit = strings.translateUnit((product['unit'] ?? '').toString());
                            final priceStr = strings.pricePerUnit(
                              price.toStringAsFixed(2),
                              unit,
                            );
                            return Text(
                              priceStr,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            );
                          }
                        ),
                      ],
                    ),

                    // 🟢 Add to Cart Button (Bottom)
                    ValueListenableBuilder<Map<String, int>>(
                      valueListenable: cartItemsNotifier,
                      builder: (context, cartItems, _) {
                        final cartQty = cartItems[productId] ?? 0;
                        final isInCart = cartQty > 0;

                        if (!isInCart) {
                          return SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor.withOpacity(0.15),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () => _addToCart(context),
                              icon: const Icon(
                                Symbols.shopping_cart,
                                size: 18,
                                color: kPrimaryColor,
                              ),
                              label: Text(
                                strings.favoritesAddToCart, // Using same string as Favorites
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () => _updateQuantity(-1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '$cartQty',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: kPrimaryColor, size: 18),
                                  onPressed: () => _updateQuantity(1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
