import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khodarkom_app/l10n/app_localizations.dart';
import 'package:khodarkom_app/language_controller.dart';

const Color brandGreen = Color(0xFF2BBA5A);

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  
  // 🚀 Optimization 1: ValueNotifiers for zero-cost state updates
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<bool> _canResend = ValueNotifier(false);
  
  late String _verificationId;

  // 🚀 Optimization 2: Static Theme (Created once, not every build)
  static final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
  );

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _pinFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _isLoading.dispose();
    _canResend.dispose();
    super.dispose();
  }

  Future<void> _resendCode() async {
    _pinController.clear();
    _isLoading.value = true;
    _canResend.value = false; // Hide button immediately

    // Force re-enable for testing if needed, or remove in prod
    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: false);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 90),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            final strings = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(strings.otpAutofillSuccess, style: GoogleFonts.tajawal()),
              ),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          _isLoading.value = false;
          _canResend.value = true; // Show button again on failure
          final strings = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(strings.otpResendError(e.message ?? ''), style: GoogleFonts.tajawal()),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            _isLoading.value = false;
            _verificationId = verificationId;
            // The timer widget will auto-restart when we rebuild it or we can use a key.
            // A simpler way is to just let the user know.
            // Actually, to restart the timer, we can just update the state of the parent 
            // or use a GlobalKey on the timer. 
            // For simplicity and performance, we'll just let the timer run its course or 
            // we can force a rebuild of the timer part.
            // Let's use a UniqueKey to force the timer to restart!
            setState(() {}); 
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
        _canResend.value = true;
      }
    }
  }

  Future<void> _verifyOtp(String pin) async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: pin,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await (await SharedPreferences.getInstance()).setBool('isLoggedIn', true);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;
        _isLoading.value = false;

        if (doc.exists && (doc.data()?['name'] ?? '').toString().isNotEmpty) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/create-profile');
        }
      }
    } on FirebaseAuthException {
      if (mounted) {
        _isLoading.value = false;
        _pinController.clear();
        final strings = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(strings.otpInvalidCode, style: GoogleFonts.tajawal()),
          ),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FAF8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_back_ios_new : Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(strings.otpTitle,
            style: GoogleFonts.tajawal(
                color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                strings.otpSubtitle,
                style: GoogleFonts.tajawal(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                strings.otpInfoText,
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // 🚀 Optimization 3: Const Pinput with Static Theme
              Directionality(
                textDirection: TextDirection.ltr, 
                child: Pinput(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(color: brandGreen),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme,
                  onCompleted: (pin) => _verifyOtp(pin),
                  autofillHints: const [AutofillHints.oneTimeCode],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              
              const SizedBox(height: 32),

              // 🚀 Optimization 4: Isolated Timer Widget (RepaintBoundary + Drift-Proof)
              // We use a UniqueKey to force it to restart when we setState (e.g. after resend)
              ValueListenableBuilder<bool>(
                valueListenable: _canResend,
                builder: (context, canResend, child) {
                  if (canResend) return const SizedBox.shrink();
                  
                  return _DriftProofTimer(
                    key: UniqueKey(), // Restarts timer on rebuild
                    durationSeconds: 90,
                    onFinished: () => _canResend.value = true,
                    builder: (context, timeLeft) {
                      return Text(
                        strings.otpResendAfter(timeLeft),
                        style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
                      );
                    },
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _canResend,
                builder: (context, canResend, child) {
                  return TextButton(
                    onPressed: canResend ? _resendCode : null,
                    child: Text(
                      strings.otpResendButton,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: canResend ? brandGreen : Colors.grey[500],
                        fontWeight: canResend ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),

              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: CircularProgressIndicator(color: brandGreen),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const Spacer(),
              
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_pinController.text.length == 6) {
                                _verifyOtp(_pinController.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(strings.otpEnterFullCode,
                                        style: GoogleFonts.tajawal()),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(strings.otpVerifyButton,
                          style: GoogleFonts.tajawal(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🧱 Isolated Drift-Proof Timer Widget
// -----------------------------------------------------------------------------

class _DriftProofTimer extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onFinished;
  final Widget Function(BuildContext context, String timeLeft) builder;

  const _DriftProofTimer({
    super.key,
    required this.durationSeconds,
    required this.onFinished,
    required this.builder,
  });

  @override
  State<_DriftProofTimer> createState() => _DriftProofTimerState();
}

class _DriftProofTimerState extends State<_DriftProofTimer> {
  late DateTime _endTime;
  late Timer _timer;
  String _timeLeft = '';

  @override
  void initState() {
    super.initState();
    // 🧠 The "Atomic Clock" Logic:
    // We calculate the exact time this timer SHOULD end.
    _endTime = DateTime.now().add(Duration(seconds: widget.durationSeconds));
    
    _updateTime(); // Initial update
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final difference = _endTime.difference(now).inSeconds;

    if (difference <= 0) {
      _timer.cancel();
      widget.onFinished();
    } else {
      if (mounted) {
        setState(() {
          final minutes = (difference ~/ 60).toString().padLeft(2, '0');
          final seconds = (difference % 60).toString().padLeft(2, '0');
          _timeLeft = '$minutes:$seconds';
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ RepaintBoundary: The GPU Fence
    // This ensures that when this text updates, ONLY this tiny box is repainted.
    return RepaintBoundary(
      child: widget.builder(context, _timeLeft),
    );
  }
}
