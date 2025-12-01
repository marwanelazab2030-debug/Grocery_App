import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF2BBA5A);

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameCtrl = TextEditingController();
  
  // 🚀 Optimization 1: ValueNotifiers for granular rebuilds
  final ValueNotifier<bool> _saving = ValueNotifier(false);
  late final ValueNotifier<String> _lang;

  bool _langInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_langInitialized) {
      final controller = LanguageScope.of(context);
      // Initialize notifier with current locale
      _lang = ValueNotifier(controller.locale.languageCode);
      _langInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _saving.dispose();
    if (_langInitialized) _lang.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || name.length < 2) {
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(strings.emptyNameError, style: GoogleFonts.tajawal()),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            strings.invalidSessionError,
            style: GoogleFonts.tajawal(),
          ),
        ),
      );
      return;
    }

    _saving.value = true;
    
    try {
      final phone = user.phoneNumber ?? '';
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
        'language': _lang.value, 
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(strings.saveSuccess, style: GoogleFonts.tajawal()),
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(strings.saveError('$e'), style: GoogleFonts.tajawal()),
        ),
      );
    } finally {
      if (mounted) _saving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      // 🚀 Optimization 2: AutofillGroup for Name Suggestion
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(), // 🚀 Micro-Opt: Dismiss Keyboard
        child: AutofillGroup(
          child: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                
                // � Optimization 3: Extracted Static Widgets
                _Header(strings: strings),
                
                const SizedBox(height: 28),
                
                Text(
                  strings.fullNameLabel,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                
                _NameInput(controller: _nameCtrl),
                
                const SizedBox(height: 22),
                
                Text(
                  strings.languageFieldLabel,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                
                // 🚀 Optimization 4: Isolated Language Selector Rebuilds
                ValueListenableBuilder<String>(
                  valueListenable: _lang,
                  builder: (context, currentLang, child) {
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _LangChip(
                              label: '${strings.languageEnglish} 🇬🇧',
                              active: currentLang == 'en',
                              onTap: () {
                                _lang.value = 'en';
                                languageController.setLocale(const Locale('en'));
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _LangChip(
                              label: '${strings.languageArabic} 🇸🇦',
                              active: currentLang == 'ar',
                              onTap: () {
                                _lang.value = 'ar';
                                languageController.setLocale(const Locale('ar'));
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // 🚀 Optimization 5: Isolated Save Button Rebuilds
                ValueListenableBuilder<bool>(
                  valueListenable: _saving,
                  builder: (context, isSaving, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const RepaintBoundary( // 🚀 Micro-Opt: Isolate Spinner
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                strings.saveButtonLabel,
                                style: GoogleFonts.tajawal(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧱 Extracted Components
// -----------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final AppLocalizations strings;
  const _Header({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.createProfileTitle,
          style: GoogleFonts.tajawal(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.createProfileSubtitle,
          style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}

class _NameInput extends StatelessWidget {
  final TextEditingController controller;
  const _NameInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.name], // 🚀 Autofill Hint
        style: GoogleFonts.tajawal(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: strings.fullNameHint,
          hintStyle: GoogleFonts.tajawal(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _LangChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? brandGreen : const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
