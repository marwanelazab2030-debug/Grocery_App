import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/utils/product_localization.dart';

const Color kPrimaryColor = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF6F8F6);

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  
  // 🔥 Elite Performance: Isolate favorite state to prevent full screen rebuilds
  final ValueNotifier<bool> _isFavoriteNotifier = ValueNotifier(false);

  static final TextStyle _kDisplayFont = GoogleFonts.cairo();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _isFavoriteNotifier.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('favorites')
          .doc(widget.product['id'])
          .get();
      if (mounted) {
        _isFavoriteNotifier.value = doc.exists;
      }
    } catch (_) {
      // Handle error silently or log
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> product) async {
    if (user == null) return;
    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(product['id']);

    final isFav = _isFavoriteNotifier.value;

    // Optimistic update
    _isFavoriteNotifier.value = !isFav;

    try {
      if (isFav) {
        await favRef.delete();
      } else {
        await favRef.set({
          ...product,
          'name_ar': product['name_ar'] ?? '',
          'name_en': product['name_en'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Revert if failed
      if (mounted) _isFavoriteNotifier.value = isFav;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('masterProducts')
          .doc(widget.product['id'])
          .snapshots(),
      builder: (context, snapshot) {
        // Use stream data if available, otherwise fallback to widget.product
        final liveData = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)
            : null;
            
        // 🟢 Fix: Merge live data but PRESERVE the price passed from Home
        // masterProducts often lacks the daily price, so we must fallback to widget.product['price']
        final Map<String, dynamic> product = {
          ...widget.product, // Base: contains correct Price
          ...(liveData ?? {}), // Overlay: contains fresh Name/Image/Desc
        };

        // If liveData overwrote price with null, restore it
        if (product['price'] == null) {
           product['price'] = widget.product['price'];
        }
        
        // Ensure ID is preserved
        product['id'] = widget.product['id'];

        final localizedName = localizedProductName(product, isArabic: isArabic);
        final displayName = localizedName.isNotEmpty ? localizedName : strings.productFallbackName;
        
        final localizedDescription = localizedProductDescription(product, isArabic: isArabic);
        final productDescription = localizedDescription.isNotEmpty
            ? localizedDescription
            : strings.productDescriptionEmpty;

        return Scaffold(
          backgroundColor: kBackgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                isArabic ? Symbols.arrow_forward_ios : Symbols.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              displayName,
              style: _kDisplayFont.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            actions: [
              // 🔥 Optimization: Only rebuilds the icon when favorite changes
              ValueListenableBuilder<bool>(
                valueListenable: _isFavoriteNotifier,
                builder: (context, isFavorite, child) {
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Symbols.favorite : Symbols.favorite_border,
                      color: Colors.red,
                      fill: isFavorite ? 1 : 0,
                    ),
                    onPressed: () => _toggleFavorite(product),
                  );
                },
              ),
            ],
          ),

          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Product image
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: product['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    // 🔥 Optimization: Cache image at reasonable size to save memory
                    memCacheWidth: 1000, 
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(color: Colors.grey.shade300),
                  ),
                ),

                // 🧾 Info box
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏷️ Name & Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: _kDisplayFont.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            strings.pricePerUnit(
                              product['price']?.toString() ?? '-',
                              strings.translateUnit(product['unit']?.toString() ?? ''),
                            ),
                            style: _kDisplayFont.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🧄 Description
                      Text(strings.productDescriptionLabel,
                          style: _kDisplayFont.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black)),
                      const SizedBox(height: 6),
                      Text(
                        productDescription,
                        style: _kDisplayFont.copyWith(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🛒 Cart Control (Isolated)
                      _CartControlWidget(
                        productId: product['id'],
                        product: product,
                        strings: strings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

// 🔥 Elite Performance: Extracted & Isolated Cart Logic
class _CartControlWidget extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> product;
  final AppLocalizations strings;

  const _CartControlWidget({
    required this.productId,
    required this.product,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('cart')
          .doc(productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              strings.genericErrorLoadingData,
              style: GoogleFonts.cairo(color: Colors.red),
            ),
          );
        }
        
        final exists = snapshot.hasData && snapshot.data!.exists;
        final quantity = exists ? (snapshot.data!['quantity'] ?? 1) : 1;

        if (!exists) {
          // 🔹 Add to cart button
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Symbols.shopping_cart, color: Colors.white),
              label: Text(
                strings.productAddToCart,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              onPressed: () => _addToCart(context),
            ),
          );
        }

        // 🔹 Quantity control
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onPressed: () => _updateQuantity(context, quantity - 1),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 40),
                alignment: Alignment.center,
                child: Text(
                  '$quantity',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                color: kPrimaryColor,
                onPressed: () => _updateQuantity(context, quantity + 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .set({
      'name': product['name'],
      'name_ar': product['name_ar'] ?? '',
      'name_en': product['name_en'] ?? '',
      'unit': product['unit'],
      'imageUrl': product['imageUrl'],
      'price': double.tryParse(product['price'] ?? '0') ?? 0,
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
              Text(strings.homeAddedToCart, style: GoogleFonts.cairo(color: Colors.white)),
            ],
          ),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateQuantity(BuildContext context, int newQuantity) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId);

    if (newQuantity > 0) {
      await ref.update({'quantity': newQuantity});
    } else {
      await ref.delete();
    }
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color ?? Colors.black87, size: 24),
        ),
      ),
    );
  }
}
