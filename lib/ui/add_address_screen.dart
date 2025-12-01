import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class AddAddressScreen extends StatefulWidget {
  /// If `addressRef` is provided => we are editing this document.
  final DocumentReference<Map<String, dynamic>>? addressRef;
  /// Prefill values for edit mode (pass the doc.data()).
  final Map<String, dynamic>? initialData;

  const AddAddressScreen({
    super.key,
    this.addressRef,
    this.initialData,
  });

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  GoogleMapController? _mapController;
  LatLng _center = const LatLng(26.3927, 50.1972); // Dammam default
  LatLng? _selectedLocation;

  final TextEditingController streetCtrl = TextEditingController();
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController landmarkCtrl = TextEditingController();
  final TextEditingController customTypeCtrl = TextEditingController();

  // 🔥 Elite Performance: Use ValueNotifier to isolate form updates from Map
  final ValueNotifier<String?> _selectedTypeNotifier = ValueNotifier(null);

  bool get isEditing => widget.addressRef != null;
  static const List<String> _presetTypeValues = [
    'المنزل',
    'العمل',
    'الأهل',
    'أخرى',
    'غير محدد',
    'عنوان آخر',
    'Home',
    'Work',
    'Family',
    'Other',
    'Not specified',
    'Another address',
  ];

  @override
  void initState() {
    super.initState();

    // If editing, prefill all fields + map position
    final data = widget.initialData;
    if (data != null) {
      final type = (data['type'] ?? 'غير محدد') as String?;
      streetCtrl.text   = (data['street'] ?? '') as String;
      buildingCtrl.text = (data['building'] ?? '') as String;
      landmarkCtrl.text = (data['landmark'] ?? '') as String;

      final lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble()
                                            : double.tryParse('${data['latitude']}');
      final lng = (data['longitude'] is num) ? (data['longitude'] as num).toDouble()
                                             : double.tryParse('${data['longitude']}');
      if (lat != null && lng != null) {
        _center = LatLng(lat, lng);
        _selectedLocation = _center;
      }

      // if type is custom (not in fixed set), show it in custom field
      if (type != null && !_presetTypeValues.contains(type)) {
        customTypeCtrl.text = type;
        _selectedTypeNotifier.value = 'أخرى';
      } else {
        _selectedTypeNotifier.value = type;
      }

      // move camera after map builds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
      });
    } else {
      _determinePosition(); // fresh add flow
    }
  }

  @override
  void dispose() {
    _selectedTypeNotifier.dispose();
    streetCtrl.dispose();
    buildingCtrl.dispose();
    landmarkCtrl.dispose();
    customTypeCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    
    // 🔥 Optimization: Don't call setState here. Just update local vars and animate.
    // The Map widget doesn't need to rebuild to show the new camera position.
    _center = LatLng(pos.latitude, pos.longitude);
    _selectedLocation = _center;
    
    _mapController?.animateCamera(CameraUpdate.newLatLng(_center));
  }

  Future<void> _saveAddress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selectedType = _selectedTypeNotifier.value;
    final addressType = selectedType == 'أخرى'
        ? (customTypeCtrl.text.trim().isEmpty ? 'عنوان آخر' : customTypeCtrl.text.trim())
        : (selectedType ?? 'غير محدد');

    final payload = <String, dynamic>{
      'type': addressType,
      'street': streetCtrl.text.trim(),
      'building': buildingCtrl.text.trim(),
      'landmark': landmarkCtrl.text.trim(),
      'latitude': _selectedLocation?.latitude ?? _center.latitude,
      'longitude': _selectedLocation?.longitude ?? _center.longitude,
      if (!isEditing) 'createdAt': FieldValue.serverTimestamp(),
      // keep createdAt when editing
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isEditing) {
      await widget.addressRef!.update(payload);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .add(payload);
    }

    if (!mounted) return;
    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            isEditing
                ? strings.addressUpdatedMessage
                : strings.addressSavedMessage,
            style: GoogleFonts.tajawal()),
        backgroundColor: brandGreen,
      ),
    );
    Navigator.pop(context, true); // ✅ returns “true” to Cart only when confirmed
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
      // 🔥 Optimization: ResizeToAvoidBottomInset handles keyboard, 
      // but we use a custom stack layout so we manage it manually below.
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 🗺️ Map fills background - ISOLATED (No Rebuilds on keyboard/form interaction)
          Positioned.fill(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(target: _center, zoom: 14),
              onMapCreated: (controller) => _mapController = controller,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onCameraMove: (pos) => _selectedLocation = pos.target,
              // Optimization: Disable gestures if not needed to improve scrolling performance
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: false,
              zoomGesturesEnabled: true,
            ),
          ),

          // 🏗️ UI Overlay - Rebuilds on layout changes (keyboard)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;
                final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
                
                // Responsive height calculation
                final formHeight = screenHeight * 0.50; 
                final pinOffset = (screenHeight - formHeight) / 2.4;

                return Stack(
                  children: [
                    // 🔙 Back button (RTL)
                    Positioned(
                      top: 40,
                      right: isArabic ? 16 : null,
                      left: isArabic ? null : 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        elevation: 3,
                        onPressed: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            isArabic ? Icons.arrow_back_ios : Icons.arrow_back,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // 📍 Center pin — always above bottom card
                    Positioned(
                      top: pinOffset,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: brandGreen, size: 48),
                          Container(width: 2, height: 20, color: brandGreen),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: brandGreen.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📌 My Location button (responsive position)
                    Positioned(
                      bottom: formHeight + 16,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'myLoc',
                        backgroundColor: Colors.white,
                        elevation: 3,
                        onPressed: _determinePosition,
                        child: const Icon(Icons.my_location, color: Colors.black),
                      ),
                    ),

                    // 🧾 Bottom address form
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: formHeight + (viewInsetsBottom > 0 ? viewInsetsBottom * 0.5 : 0), // Adjust slightly for keyboard
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          20,
                          16,
                          viewInsetsBottom + 20,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: isArabic
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Text(
                                  isEditing
                                      ? strings.addressFormEditTitle
                                      : strings.addressFormAddTitle,
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              
                              // 🔥 Optimization: Isolated Chips Rebuild
                              AddressTypeSelector(
                                strings: strings,
                                isArabic: isArabic,
                                selectedTypeNotifier: _selectedTypeNotifier,
                              ),

                              // 🔥 Optimization: Conditional Custom Field (Listening to Notifier)
                              ValueListenableBuilder<String?>(
                                valueListenable: _selectedTypeNotifier,
                                builder: (context, selectedType, child) {
                                  if (selectedType == 'أخرى') {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: AddressInputField(
                                        controller: customTypeCtrl,
                                        label: strings.addressCustomTypeHint,
                                        icon: Icons.edit,
                                        textAlign: textAlign,
                                        textDirection: textDirection,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),

                              const SizedBox(height: 12),
                              AddressInputField(
                                controller: streetCtrl,
                                label: strings.addressStreetHint,
                                icon: Icons.signpost,
                                textAlign: textAlign,
                                textDirection: textDirection,
                              ),
                              const SizedBox(height: 12),
                              AddressInputField(
                                controller: buildingCtrl,
                                label: strings.addressBuildingHint,
                                icon: Icons.location_city,
                                textAlign: textAlign,
                                textDirection: textDirection,
                              ),
                              const SizedBox(height: 12),
                              AddressInputField(
                                controller: landmarkCtrl,
                                label: strings.addressLandmarkHint,
                                icon: Icons.place_outlined,
                                textAlign: textAlign,
                                textDirection: textDirection,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _saveAddress,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: brandGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    isEditing
                                        ? strings.addressUpdateButton
                                        : strings.addressConfirmButton,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 Elite Performance: Extracted Input Field (Const Correctness)
class AddressInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextAlign textAlign;
  final TextDirection textDirection;

  const AddressInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.textAlign,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      textDirection: textDirection,
      style: GoogleFonts.tajawal(fontSize: 16),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade500),
        suffixIcon: Icon(icon, color: brandGreen),
        filled: true,
        fillColor: kBackgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

// 🔥 Elite Performance: Extracted Type Selector (Isolated State)
class AddressTypeSelector extends StatelessWidget {
  final AppLocalizations strings;
  final bool isArabic;
  final ValueNotifier<String?> selectedTypeNotifier;

  const AddressTypeSelector({
    super.key,
    required this.strings,
    required this.isArabic,
    required this.selectedTypeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'value': 'المنزل', 'label': strings.addressTypeHome},
      {'value': 'العمل', 'label': strings.addressTypeWork},
      {'value': 'الأهل', 'label': strings.addressTypeFamily},
      {'value': 'أخرى', 'label': strings.addressTypeOther},
    ];

    return ValueListenableBuilder<String?>(
      valueListenable: selectedTypeNotifier,
      builder: (context, selectedType, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
          children: types.map((type) {
            final bool selected = selectedType == type['value'];
            return ChoiceChip(
              label: Text(
                type['label']!,
                style: GoogleFonts.tajawal(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: selected,
              showCheckmark: false, // 🟢 Disable checkmark to prevent resizing
              selectedColor: brandGreen,
              backgroundColor: kBackgroundLight,
              onSelected: (v) {
                selectedTypeNotifier.value = v ? type['value'] : null;
              },
            );
          }).toList(),
        );
      },
    );
  }
}
