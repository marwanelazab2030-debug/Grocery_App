import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khodarkom_app/ui/add_address_screen.dart';
import 'package:khodarkom_app/ui/addresses_list_screen.dart';
import 'package:khodarkom_app/ui/my_orders_screen.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF3BB54A);
const Color kBackgroundLight = Color(0xFFF7F8FA);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 🔥 Elite Performance: Use ValueNotifier to isolate rebuilds
  final ValueNotifier<String?> _firstNameNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // 🔥 Optimization: Use get() with source options if needed, but standard get is fine here.
      // We could also cache this locally if needed.
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists && mounted) {
        final fullName = doc.data()?['name'] as String?;
        if (fullName != null) {
          _firstNameNotifier.value = fullName.split(' ').first;
        }
      }
    }
  }

  void _showLanguagePicker() {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final selectedCode = languageController.locale.languageCode;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: brandGreen, size: 22),
                  const SizedBox(width: 6),
                  Text(
                    strings.languagePickerTitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                flag: "🇸🇦",
                label: strings.languageArabic,
                isSelected: selectedCode == 'ar',
                onTap: () {
                  languageController.setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
              _LanguageOption(
                flag: "🇬🇧",
                label: strings.languageEnglish,
                isSelected: selectedCode == 'en',
                onTap: () {
                  languageController.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final currentLanguageLabel = languageController.isArabic
        ? strings.languageArabic
        : strings.languageEnglish;

    return Scaffold(
      backgroundColor: kBackgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header with Zero-Cost Rebuild
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
              child: Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _firstNameNotifier,
                  builder: (context, firstName, _) {
                    return Text(
                      strings.profileGreeting(firstName ?? '...'),
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 🔹 Section title
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                strings.settingsTitle,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // 🔹 Settings list
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ProfileOptionTile(
                      icon: Icons.receipt_long,
                      label: strings.myOrdersLabel,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MyOrdersScreen(showBack: true),
                          ),
                        );
                      },
                    ),
                    ProfileOptionTile(
                      icon: Icons.location_on,
                      label: strings.addressesLabel,
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        // 🔍 Check Firestore for existing addresses
                        final addressesSnapshot = await FirebaseFirestore
                            .instance
                            .collection('users')
                            .doc(user.uid)
                            .collection('addresses')
                            .limit(1) // 🔥 Optimization: Limit to 1 just to check existence
                            .get();

                        if (!context.mounted) return;

                        if (addressesSnapshot.docs.isEmpty) {
                          // ➕ No addresses yet → go to AddAddressScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAddressScreen(),
                            ),
                          );
                        } else {
                          // 📋 Addresses exist → go to AddressesListScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddressesListScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    ProfileOptionTile(
                      icon: Icons.favorite,
                      label: strings.favoritesLabel,
                      onTap: () {
                        Navigator.pushNamed(context, '/favorites');
                      },
                    ),
                    ProfileOptionTile(
                      icon: Icons.language,
                      label: strings.languageLabel,
                      trailing: Text(
                        currentLanguageLabel,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      onTap: _showLanguagePicker,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔥 Elite Performance: Extracted Widget for Const Correctness & Caching
class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          // 🔥 Premium Feel: Custom splash color
          splashColor: brandGreen.withOpacity(0.1),
          highlightColor: brandGreen.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: brandGreen, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                const SizedBox(width: 8), // Spacing for trailing
                const Icon(Icons.chevron_right, color: Colors.grey), // Standard direction icon
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 22, height: 1.3),
      ),
      title: Text(
        label,
        style: GoogleFonts.tajawal(fontSize: 16),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: brandGreen)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
