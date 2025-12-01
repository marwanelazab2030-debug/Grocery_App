import 'product_details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';
import 'package:khodarkom_app/utils/product_localization.dart';

const Color kPrimaryColor = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  TextStyle get kDisplayFont => GoogleFonts.cairo();

  // ---------------- Logic Helpers ----------------
  Future<void> _addToCart(Map<String, dynamic> product, double price) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🔥 Smart Fix: Fetch fresh data from masterProducts to ensure we have localized names
    // This handles cases where the favorite item is old and lacks name_ar/name_en
    final masterDoc = await FirebaseFirestore.instance
        .collection('masterProducts')
        .doc(product['id'])
        .get();

    final freshData = masterDoc.exists ? (masterDoc.data() as Map<String, dynamic>) : product;
    
    // Merge fresh data but keep the ID
    final dataToSave = {
      ...freshData,
      'id': product['id'], // Ensure ID is preserved
    };

    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['id']);

    final existing = await cartRef.get();
    if (existing.exists) {
      final currentQty = (existing['quantity'] ?? 1) + 1;
      await cartRef.update({
        'quantity': currentQty,
        'name': dataToSave['name'],
        'name_ar': dataToSave['name_ar'] ?? '',
        'name_en': dataToSave['name_en'] ?? '',
        'imageUrl': dataToSave['imageUrl'],
        'price': price,
        'unit': dataToSave['unit'],
      });
    } else {
      await cartRef.set({
        'name': dataToSave['name'],
        'name_ar': dataToSave['name_ar'] ?? '',
        'name_en': dataToSave['name_en'] ?? '',
        'unit': dataToSave['unit'],
        'imageUrl': dataToSave['imageUrl'],
        'price': price,
        'quantity': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 🔥 Self-Healing: Update the favorite document with fresh data too
    if (masterDoc.exists) {
       await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product['id'])
        .update({
          'name_ar': dataToSave['name_ar'] ?? '',
          'name_en': dataToSave['name_en'] ?? '',
          'description_ar': dataToSave['description_ar'] ?? '',
          'description_en': dataToSave['description_en'] ?? '',
          // Update other fields if needed, but names are critical for localization
       });
    }
  }

  Future<void> _updateQuantity(String productId, int newQty) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    if (newQty <= 0) {
      await cartRef.delete();
    } else {
      await cartRef.update({'quantity': newQty});
    }
  }

  Future<void> _removeFromFavorites(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: _buildAppBar(strings, isArabic),
      body: user == null
          ? _buildEmpty(context)
          : _buildContent(user, strings, isArabic),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations strings, bool isArabic) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: !_isSearching
          ? Text(
              strings.favoritesTitle,
              style: kDisplayFont.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
          : TextField(
              controller: _searchController,
              autofocus: true,
              style: kDisplayFont.copyWith(color: Colors.black),
              decoration: InputDecoration(
                hintText: strings.favoritesSearchHint,
                hintStyle: kDisplayFont.copyWith(color: Colors.grey.shade500),
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
            ),
      leading: IconButton(
        icon: Icon(
          isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Symbols.close : Symbols.search),
          color: Colors.black,
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              _searchController.clear();
              _searchQuery = '';
            });
          },
        ),
      ],
    );
  }

  Widget _buildContent(User user, AppLocalizations strings, bool isArabic) {
    // 🚀 Optimization 1: Fetch Cart ONCE at the top level
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots(),
      builder: (context, cartSnapshot) {
        // Map<ProductId, Quantity>
        final Map<String, int> cartQuantities = {};
        if (cartSnapshot.hasData) {
          for (var doc in cartSnapshot.data!.docs) {
            cartQuantities[doc.id] = (doc.data() as Map<String, dynamic>)['quantity'] ?? 0;
          }
        }

        // 🚀 Optimization 2: Fetch Favorites
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, favSnapshot) {
            if (favSnapshot.hasError) {
              return Center(
                child: Text(
                  strings.genericErrorLoadingData,
                  style: GoogleFonts.cairo(color: Colors.red),
                ),
              );
            }
            if (!favSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final allFavorites = favSnapshot.data!.docs;
            final query = _searchQuery.toLowerCase();
            
            // Filter in memory (dataset is usually small for favorites)
            final favorites = allFavorites.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final displayName = localizedProductName(
                data,
                isArabic: isArabic,
              ).toLowerCase();
              return displayName.contains(query);
            }).toList();

            if (favorites.isEmpty) return _buildEmpty(context);

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                // 🟢 Dynamic Height: Matches Home Screen Logic
                mainAxisExtent: (MediaQuery.of(context).size.width / 2) + 110,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favDoc = favorites[index];
                final favData = favDoc.data() as Map<String, dynamic>;
                final productId = favDoc.id;
                final qty = cartQuantities[productId] ?? 0;

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('masterProducts')
                      .doc(productId)
                      .snapshots(),
                  builder: (context, productSnap) {
                    final productData = productSnap.hasData && productSnap.data!.exists
                        ? (productSnap.data!.data() as Map<String, dynamic>)
                        : favData;

                    // 🔥 Fix: Preserve price from favorites if masterProducts doesn't have it
                    // masterProducts usually doesn't have dynamic prices (they are in dailyPrices)
                    var price = favData['price'];
                    if (productData.containsKey('price') && productData['price'] != null) {
                       final p = double.tryParse(productData['price'].toString()) ?? 0.0;
                       if (p > 0) price = p;
                    }

                    // Merge fresh data with favorite data (preserving ID and Price)
                    final mergedData = {
                      ...favData, // Start with saved data (has price)
                      ...productData, // Overlay fresh data (names, images)
                      'id': productId,
                      'price': price, // Ensure correct price is used
                    };

                    return _FavoriteItemCard(
                      productId: productId,
                      data: mergedData,
                      quantity: qty,
                      isArabic: isArabic,
                      strings: strings,
                      onAddToCart: (price) => _addToCart({
                        'id': productId,
                        ...mergedData,
                      }, price),
                      onUpdateQuantity: (newQty) => _updateQuantity(productId, newQty),
                      onRemoveFavorite: () => _removeFromFavorites(productId),
                    );
                  }
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
              ),
              // 🚀 Optimization 4: Cached Image for Empty State
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: 'https://cdn-icons-png.flaticon.com/512/1041/1041916.png',
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              strings.favoritesEmptyTitle,
              style: kDisplayFont.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.favoritesEmptySubtitle,
              textAlign: TextAlign.center,
              style: kDisplayFont.copyWith(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  strings.favoritesEmptyAction,
                  style: kDisplayFont.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧱 Extracted Clean Component
// -----------------------------------------------------------------------------

class _FavoriteItemCard extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> data;
  final int quantity;
  final bool isArabic;
  final AppLocalizations strings;
  final Function(double) onAddToCart;
  final Function(int) onUpdateQuantity;
  final VoidCallback onRemoveFavorite;

  const _FavoriteItemCard({
    required this.productId,
    required this.data,
    required this.quantity,
    required this.isArabic,
    required this.strings,
    required this.onAddToCart,
    required this.onUpdateQuantity,
    required this.onRemoveFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final localizedName = localizedProductName(data, isArabic: isArabic);
    final displayName = localizedName.isNotEmpty ? localizedName : (data['name']?.toString() ?? '');
    
    final priceVal = (data['price'] is num)
        ? (data['price'] as num).toDouble()
        : double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: {
                'id': productId,
                'name': data['name'],
                'name_ar': data['name_ar'],
                'name_en': data['name_en'],
                'unit': data['unit'],
                'imageUrl': data['imageUrl'],
                'price': data['price']?.toString(),
                'description_ar': data['description_ar'] ?? '',
                'description_en': data['description_en'] ?? '',
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.025), // 🟢 Match Home Padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Image + Heart
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: data['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey.shade200),
                        errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: onRemoveFavorite,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.favorite,
                          size: 20,
                          color: Colors.red,
                          fill: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 🧾 Info + cart control
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 14, // 🟢 Match Home Font Size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          strings.pricePerUnit(
                            priceVal.toString(), // Use raw price for display if needed, or format
                            strings.translateUnit(data['unit']?.toString() ?? '-'),
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),

                    // 🛒 Add to Cart OR Quantity Control
                    if (quantity > 0)
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // 🟢 Match Home Color
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add, color: kPrimaryColor, size: 18),
                              onPressed: () => onUpdateQuantity(quantity + 1),
                            ),
                            Text(
                              quantity.toString(),
                              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.black54, size: 18),
                              onPressed: () => onUpdateQuantity(quantity - 1),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor.withOpacity(0.15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero, // 🟢 Match Home Padding
                          ),
                          onPressed: () => onAddToCart(priceVal),
                          icon: const Icon(
                            Symbols.shopping_cart,
                            size: 18,
                            color: kPrimaryColor,
                          ),
                          label: Text(
                            strings.favoritesAddToCart,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
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
