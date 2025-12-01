import 'home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:khodarkom_app/ui/add_address_screen.dart';
import 'package:khodarkom_app/ui/addresses_list_screen.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/utils/product_localization.dart';


const Color kPrimaryColor = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final TextEditingController couponController = TextEditingController();

  static const double deliveryFee = 10.0;

  TextStyle get kDisplayFont => GoogleFonts.cairo();

  CollectionReference<Map<String, dynamic>> get cartRef =>
      db.collection('users').doc(user?.uid).collection('cart');

  Future<void> updateQuantity(String id, int delta) async {
    if (user == null) return;
    final ref = cartRef.doc(id);
    final doc = await ref.get();
    if (!doc.exists) return;
    final current = (doc['quantity'] ?? 1) + delta;
    if (current <= 0) {
      await ref.delete();
    } else {
      await ref.update({'quantity': current});
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (user == null) {
      return _EmptyCart(onShop: () => _goHome(context));
    }

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          strings.cartTitle,
          style: kDisplayFont.copyWith(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ✅ Show filled or empty cart dynamically
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                strings.genericErrorLoadingData,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;
          if (items.isEmpty) {
            return _EmptyCart(onShop: () => _goHome(context));
          }

          double subtotal = 0;
          for (final doc in items) {
            final data = doc.data();
            final price = (data['price'] ?? 0).toDouble();
            final qty = (data['quantity'] ?? 1).toInt();
            subtotal += price * qty;
          }
          final total = subtotal + deliveryFee;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                itemCount: items.length + 2, // Items + Coupon + Summary
                itemBuilder: (context, index) {
                  // 1. Cart Items
                  if (index < items.length) {
                    final item = items[index];
                    final data = item.data();
                    final id = item.id;
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('masterProducts')
                          .doc(id)
                          .snapshots(),
                      builder: (context, productSnap) {
                        final productData = productSnap.hasData && productSnap.data!.exists
                            ? (productSnap.data!.data() as Map<String, dynamic>)
                            : data;

                        final localizedName = localizedProductName(productData, isArabic: isArabic);
                        final name = localizedName.isNotEmpty
                            ? localizedName
                            : (productData['name']?.toString() ?? '');
                        
                        // Use fresh unit if available, otherwise fallback
                        final unit = productData['unit'] ?? data['unit'] ?? '';
                        final image = productData['imageUrl'] ?? data['imageUrl'] ?? '';

                        // 🔥 Fix: Ensure price comes from the cart item (which has the price at add time)
                        // masterProducts usually doesn't have the price, so don't let it overwrite with 0/null
                        final price = (data['price'] ?? 0).toDouble();
                        final qty = (data['quantity'] ?? 1).toInt();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: image,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 64, 
                                    height: 64, 
                                    color: Colors.grey.shade200
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 64, 
                                    height: 64, 
                                    color: Colors.grey.shade200
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name,
                                        style: kDisplayFont.copyWith(
                                            fontWeight: FontWeight.bold, fontSize: 15)),
                                    const SizedBox(height: 4),
                                    Text(
                                      strings.pricePerUnit(price.toStringAsFixed(2), strings.translateUnit(unit)),
                                      style: kDisplayFont.copyWith(
                                          fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: kPrimaryColor, size: 20),
                                      onPressed: () => updateQuantity(id, 1),
                                    ),
                                    Text(
                                      '$qty',
                                      style: kDisplayFont.copyWith(
                                          fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 20),
                                      onPressed: () => updateQuantity(id, -1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    );
                  }

                  // 2. Coupon Section
                  if (index == items.length) {
                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: couponController,
                              style: kDisplayFont.copyWith(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: strings.cartCouponHint,
                                hintStyle:
                                    kDisplayFont.copyWith(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: kPrimaryColor.withOpacity(0.15),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(strings.cartApplyButton,
                                style: kDisplayFont.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor)),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Order Summary
                  return Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _row(strings.subtotalLabel, strings.currencyValue(subtotal.toStringAsFixed(2))),
                        const SizedBox(height: 8),
                        _row(strings.deliveryFeeLabel, strings.currencyValue(deliveryFee.toStringAsFixed(2))),
                        const Divider(height: 24, thickness: 1, indent: 2, endIndent: 2),
                        _rowBold(strings.totalLabel, strings.currencyValue(total.toStringAsFixed(2)),
                            valueColor: kPrimaryColor),
                      ],
                    ),
                  );
                },
              ),

              // Bottom checkout button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final addressSnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('addresses')
                            .get();

                        if (addressSnapshot.docs.isEmpty) {
                          // 🟢 No addresses → go to AddAddressScreen first
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                          );

                          // ✅ Only go to AddressesListScreen if user actually confirmed address
                          if (result == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AddressesListScreen(fromCheckout: true)),
                            );
                          }

                        } else {
                          // 🟢 Has addresses → go directly to choose one for checkout
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddressesListScreen(fromCheckout: true)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        strings.cartCheckoutButton,
                        style: kDisplayFont.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String title, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: kDisplayFont.copyWith(color: Colors.grey.shade600, fontSize: 14)),
          Text(value,
              style: kDisplayFont.copyWith(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      );

  Widget _rowBold(String title, String value, {Color valueColor = Colors.black}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: kDisplayFont.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value,
              style: kDisplayFont.copyWith(
                  color: valueColor, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      );
}

// 🛒 Empty cart screen (unchanged)
class _EmptyCart extends StatelessWidget {
  final VoidCallback onShop;
  const _EmptyCart({required this.onShop});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://cdn-icons-png.flaticon.com/512/2038/2038854.png",
              width: 180,
              height: 180,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 30),
            Text(strings.cartEmptyTitle,
                style: GoogleFonts.cairo(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 6),
            Text(strings.cartEmptySubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onShop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(strings.cartEmptyAction,
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
