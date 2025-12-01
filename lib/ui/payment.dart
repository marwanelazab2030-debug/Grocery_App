import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = "mada";

  Future<void> placeOrder() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final db = FirebaseFirestore.instance;

    // -------- GET USER CART --------
    final cartSnap = await db
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .get();

    final strings = AppLocalizations.of(context)!;
    if (cartSnap.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.paymentCartEmpty)),
      );
      return;
    }

    // -------- GENERATE ORDER ID --------
    final orderId = "KHO-${DateTime.now().millisecondsSinceEpoch}";

    // -------- CALCULATE TOTAL --------
double subtotal = 0;
final cartItems = cartSnap.docs.map((doc) {
  final data = doc.data();
  subtotal += (data['price'] * data['quantity']);
  return data;
}).toList();

// Delivery fee (same as Cart screen)
const double deliveryFee = 10.0;

// 👇 FINAL CORRECT TOTAL
double total = subtotal + deliveryFee;


    // -------- CREATE ORDER OBJECT --------
    final orderData = {
      "orderId": orderId,
      "userId": user.uid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
      "paymentMethod": selectedMethod,
      "items": cartItems,
      "subtotal": subtotal,       // (optional)
      "deliveryFee": deliveryFee, // (optional)
      "total": total,             // 👈 FIXED HERE
};

    // -------- SAVE TO MAIN ORDERS COLLECTION --------
    await db.collection('orders').doc(orderId).set(orderData);

    // -------- SAVE COPY UNDER USER ORDERS --------
    await db
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(orderId)
        .set(orderData);

    // -------- CLEAR CART --------
    for (final doc in cartSnap.docs) {
      await doc.reference.delete();
    }

    // -------- GO TO SUCCESS PAGE --------
    Navigator.pushNamed(context, "/order_success");

  } catch (e) {
    print("ORDER ERROR: $e");
    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.paymentCreationError)),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(56),
  child: SafeArea(
    child: Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔥 لو عربي → رجوع يمين
          // 🔥 لو إنجليزي → رجوع يسار
          IconButton(
            icon: Icon(
              isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          Expanded(
            child: Center(
              child: Text(
                strings.paymentTitle,
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2923),
                ),
              ),
            ),
          ),

          // 🔥 حل ذكي: صندوق فارغ يحافظ على العنوان بالمنتصف
          const SizedBox(width: 48),
        ],
      ),
    ),
  ),
),


      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.015,
        ),
        child: Column(
          children: [
            _modernTile(
              id: "mada",
              label: strings.paymentMethodMada,
              icon: "assets/icons/mada.png",
            ),

            SizedBox(height: height * 0.015),

            _modernTile(
              id: "visa",
              label: "Visa",
              icon: "assets/icons/visa.svg",
            ),

            SizedBox(height: height * 0.015),

            _modernTile(
              id: "apple",
              label: "Apple Pay",
              icon: "assets/icons/applepay.png",
            ),

            SizedBox(height: height * 0.015),

            _modernTile(
              id: "stcpay",
              label: "STC Pay",
              icon: "assets/icons/stcpay.svg",
            ),

            SizedBox(height: height * 0.015),

            _modernTile(
              id: "cod",
              label: strings.paymentMethodCod,
              icon: "assets/icons/cod.png",
              isIconPNG: false,
              iconWidget: const Icon(Icons.payments, size: 28),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          width * 0.04,
          8,
          width * 0.04,
          bottomPadding + 10,
        ),
        child: SizedBox(
          width: width,
          height: height * 0.065,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3BB54A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              placeOrder();
            },
            child: Text(
              strings.paymentConfirmButton,
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ Modern Payment Card
  Widget _modernTile({
    required String id,
    required String label,
    required String icon,
    bool isIconPNG = true,
    Widget? iconWidget,
  }) {
    final selected = selectedMethod == id;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMethod = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF3BB54A) : Colors.black12,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: icon.endsWith(".svg")
    ? SvgPicture.asset(
        icon,
        height: 26,
      )
    : Image.asset(
        icon,
        height: 26,
      ),

            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                label,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Radio<String>(
              value: id,
              groupValue: selectedMethod,
              activeColor: const Color(0xFF3BB54A),
              onChanged: (_) {
                setState(() => selectedMethod = id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
