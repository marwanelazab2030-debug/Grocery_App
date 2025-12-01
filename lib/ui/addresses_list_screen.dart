import 'add_address_screen.dart';
import 'edit_address_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';


const Color brandGreen = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class AddressesListScreen extends StatefulWidget {
  final bool fromCheckout; // ✅ true if opened from Cart to choose address
  const AddressesListScreen({super.key, this.fromCheckout = false});


  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  // 🔥 Elite Performance: Memoize stream & use ValueNotifier for selection
  late final Stream<QuerySnapshot> _addressesStream;
  final ValueNotifier<String?> _selectedAddressNotifier = ValueNotifier(null);
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _addressesStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      _addressesStream = const Stream.empty();
    }
  }

  @override
  void dispose() {
    _selectedAddressNotifier.dispose();
    super.dispose();
  }

  void _handleAddressSelection(String id, AppLocalizations strings) {
    _selectedAddressNotifier.value = id;
  }

  void _onConfirmSelection(BuildContext context, AppLocalizations strings) {
    final selectedId = _selectedAddressNotifier.value;
    if (widget.fromCheckout) {
      if (selectedId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.addressUseForPayment,
                style: GoogleFonts.tajawal()),
            backgroundColor: brandGreen,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentMethodScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.addressSelectBeforeContinue,
                style: GoogleFonts.tajawal()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddAddressScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;
    
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.fromCheckout ? strings.selectDeliveryAddressTitle : strings.addressesTitle,
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _addressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: brandGreen));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const _AddressEmptyState();
          }

          final addresses = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final doc = addresses[index];
                      final id = doc.id;
                      final data = doc.data() as Map<String, dynamic>;
                      
                      return _AddressItemTile(
                        key: ValueKey(id),
                        id: id,
                        data: data,
                        docRef: doc.reference,
                        strings: strings,
                        isArabic: isArabic,
                        selectedAddressNotifier: _selectedAddressNotifier,
                        fromCheckout: widget.fromCheckout,
                        onTap: () => _handleAddressSelection(id, strings),
                      );
                    },
                  ),
                ),

                // ✅ Add new / Confirm button
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _onConfirmSelection(context, strings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        widget.fromCheckout ? strings.goToPaymentButton : strings.addNewAddressButton,
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🔥 Elite Performance: Extracted & Optimized Tile
class _AddressItemTile extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final DocumentReference docRef;
  final AppLocalizations strings;
  final bool isArabic;
  final ValueNotifier<String?> selectedAddressNotifier;
  final bool fromCheckout;
  final VoidCallback onTap;

  const _AddressItemTile({
    super.key,
    required this.id,
    required this.data,
    required this.docRef,
    required this.strings,
    required this.isArabic,
    required this.selectedAddressNotifier,
    required this.fromCheckout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final street = (data['street'] ?? '').toString();
    final building = (data['building'] ?? '').toString();
    final rawLabel = (data['type'] ?? data['label'] ?? '').toString();
    final label = _AddressHelper._localizedTypeLabel(rawLabel, strings);
    final addressLine = _AddressHelper._formatAddressLine(street, building, strings, isArabic);

    return ValueListenableBuilder<String?>(
      valueListenable: selectedAddressNotifier,
      builder: (context, selectedId, child) {
        final isSelected = selectedId == id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? brandGreen : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: brandGreen.withOpacity(0.1),
              highlightColor: brandGreen.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 📍 Location icon
                    Icon(
                      Icons.location_on,
                      color: isSelected ? brandGreen : Colors.grey.shade400,
                      size: 28,
                    ),
                    const SizedBox(width: 10),

                    // 🏷️ Address info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic ? TextAlign.right : TextAlign.left,
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            addressLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: isArabic ? TextAlign.right : TextAlign.left,
                            style: GoogleFonts.tajawal(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!fromCheckout) ...[
                      // ✏️ Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey, size: 22),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditAddressScreen(
                                addressRef: docRef as DocumentReference<Map<String, dynamic>>,
                              ),
                            ),
                          );
                        },
                      ),

                      // �️ Delete
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                        onPressed: () async {
                          await docRef.delete();
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🌿 Extracted Empty State
class _AddressEmptyState extends StatelessWidget {
  const _AddressEmptyState();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              strings.noAddressesTitle,
              style: GoogleFonts.tajawal(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              strings.noAddressesSubtitle,
              style: GoogleFonts.tajawal(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddAddressScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                strings.addAddressCta,
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🛠️ Static Helper Class
class _AddressHelper {
  static String _localizedTypeLabel(String raw, AppLocalizations strings) {
    final value = raw.trim();
    if (value.isEmpty) return strings.addressUnknownLabel;
    final lower = value.toLowerCase();
    switch (value) {
      case 'المنزل':
        return strings.addressTypeHome;
      case 'العمل':
        return strings.addressTypeWork;
      case 'الأهل':
        return strings.addressTypeFamily;
      case 'أخرى':
        return strings.addressTypeOther;
      case 'غير محدد':
        return strings.addressTypeUnknown;
      case 'عنوان آخر':
        return strings.addressTypeCustomLabel;
    }
    switch (lower) {
      case 'home':
        return strings.addressTypeHome;
      case 'work':
        return strings.addressTypeWork;
      case 'family':
        return strings.addressTypeFamily;
      case 'other':
        return strings.addressTypeOther;
      case 'not specified':
      case 'unknown':
        return strings.addressTypeUnknown;
      case 'another address':
        return strings.addressTypeCustomLabel;
    }
    return value;
  }

  static String _formatAddressLine(String street, String building,
      AppLocalizations strings, bool isArabic) {
    final trimmedStreet = street.trim();
    final trimmedBuilding = building.trim();
    final parts = <String>[];

    if (trimmedStreet.isNotEmpty) {
      parts.add(trimmedStreet);
    }
    if (trimmedBuilding.isNotEmpty) {
      parts.add(trimmedBuilding);
    }

    if (parts.isEmpty) {
      return strings.addressUnknownValue;
    }

    final separator = isArabic ? '، ' : ', ';
    return parts.join(separator);
  }
}
