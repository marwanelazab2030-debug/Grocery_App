import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khodarkom_app/ui/otp_screen.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF2BBA5A);

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  // 🚀 Optimization 1: ValueNotifier for granular rebuilds (Zero-Cost Rebuilds)
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    _phoneController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    // 1. Validation
    if (_phoneController.text.isEmpty || _phoneController.text.length < 9) {
      if (!mounted) return;
      final strings = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
            backgroundColor: Colors.red,
            content: Text(strings.phoneInvalidInput, style: GoogleFonts.tajawal())),
      );
      return;
    }

    // 2. Start Loading (Only notifies listeners, doesn't rebuild whole screen)
    _isLoading.value = true;

    final String phoneNumber = '+966${_phoneController.text.trim()}';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification logic if needed
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          final strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text(strings.phoneVerifyError(e.message ?? ''), style: GoogleFonts.tajawal())),
          );
          _isLoading.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          _isLoading.value = false;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId, phoneNumber: phoneNumber),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
        final strings = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(strings.phoneGenericError('$e'), style: GoogleFonts.tajawal())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final languageController = LanguageScope.of(context);
    final isRTL = languageController.isArabic;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      // 🚀 Optimization 2: AutofillGroup for OS-level phone suggestions
      body: AutofillGroup(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 130),
                  
                  // 🚀 Optimization 3: Extracted static widgets to const
                  const _HeaderLogo(),
                  
                  const SizedBox(height: 40),
                  
                  _WelcomeText(strings: strings),
                  
                  const SizedBox(height: 48),
                  
                  Align(
                    alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      strings.phoneNumberLabel,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _PhoneInput(
                    controller: _phoneController, 
                    onSubmitted: (_) => _sendOtp(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 🚀 Optimization 1 (Usage): Only this button rebuilds!
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (context, isLoading, child) {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _sendOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  strings.phoneContinueButton,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _FooterTerms(strings: strings),
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
// 🧱 Extracted Components for Performance (Memory & Rebuild Optimization)
// -----------------------------------------------------------------------------

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  @override
  Widget build(BuildContext context) {
    return Text(
      // Note: Hardcoded app name here as it's the brand logo
      "\u062E\u0636\u0627\u0631\u0643\u0645", 
      textAlign: TextAlign.center,
      style: GoogleFonts.tajawal(
        fontSize: 56,
        fontWeight: FontWeight.w900,
        height: 0.95,
        color: brandGreen,
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final AppLocalizations strings;
  const _WelcomeText({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          strings.phoneWelcomeTitle,
          style: GoogleFonts.tajawal(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.phoneWelcomeSubtitle,
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;

  const _PhoneInput({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // Static Country Code - Never Rebuilds
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            decoration: const BoxDecoration(
              color: brandGreen,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  '🇸🇦',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  '+966',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              // 🚀 Optimization 4: Input Formatters & Action
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              onSubmitted: onSubmitted,
              autofillHints: const [AutofillHints.telephoneNumber], 
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: '5X XXX XXXX',
                hintStyle: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterTerms extends StatelessWidget {
  final AppLocalizations strings;
  const _FooterTerms({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          strings.phoneAgreementPrefix,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to terms screen
          },
          child: Text(
            strings.phoneTermsLabel,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: brandGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          strings.phoneAndConnector,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: Navigate to privacy screen
          },
          child: Text(
            strings.phonePrivacyLabel,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: brandGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}