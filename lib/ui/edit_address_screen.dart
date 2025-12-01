import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class EditAddressScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> addressRef;

  const EditAddressScreen({super.key, required this.addressRef});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snap = await widget.addressRef.get();
    if (snap.exists) {
      final data = snap.data()!;
      streetCtrl.text = data['street'] ?? '';
      buildingCtrl.text = data['building'] ?? '';
      landmarkCtrl.text = data['landmark'] ?? '';
    }
    setState(() => _loading = false);
  }

  Future<void> _saveChanges() async {
    await widget.addressRef.update({
      'street': streetCtrl.text.trim(),
      'building': buildingCtrl.text.trim(),
      'landmark': landmarkCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(strings.addressUpdatedMessage, style: GoogleFonts.tajawal()),
        backgroundColor: brandGreen,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isArabic = languageController.isArabic;
    final textAlign = isArabic ? TextAlign.right : TextAlign.left;
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Text(strings.addressFormEditTitle,
            style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black)),
        leading: IconButton(
          icon: Icon(
            isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: brandGreen))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  _buildField(streetCtrl, strings.addressStreetHint,
                      Icons.signpost, textAlign, textDirection),
                  const SizedBox(height: 14),
                  _buildField(buildingCtrl, strings.addressBuildingHint,
                      Icons.location_city, textAlign, textDirection),
                  const SizedBox(height: 14),
                  _buildField(landmarkCtrl, strings.addressLandmarkHint,
                      Icons.place_outlined, textAlign, textDirection),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(strings.addressUpdateButton,
                          style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      IconData icon, TextAlign align, TextDirection direction) {
    return TextField(
      controller: controller,
      textAlign: align,
      textDirection: direction,
      decoration: InputDecoration(
        hintText: label,
        suffixIcon: Icon(icon, color: brandGreen),
        filled: true,
        fillColor: kBackgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: brandGreen, width: 1.5),
        ),
      ),
    );
  }
}
