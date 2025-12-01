import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  LanguageController({Locale? initialLocale})
    : _locale = initialLocale ?? const Locale('ar');

  static const _storageKey = 'selected_language_code';

  Locale _locale;
  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }
}

class LanguageScope extends InheritedNotifier<LanguageController> {
  const LanguageScope({
    super.key,
    required LanguageController controller,
    required Widget child,
  }) : _controller = controller,
       super(notifier: controller, child: child);

  final LanguageController _controller;

  static LanguageController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LanguageScope>();
    assert(scope != null, 'LanguageScope not found in context');
    return scope!._controller;
  }

  @override
  bool updateShouldNotify(LanguageScope oldWidget) =>
      oldWidget._controller != _controller;
}

