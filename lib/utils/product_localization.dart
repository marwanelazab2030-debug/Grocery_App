import 'package:khodarkom_app/l10n/app_localizations.dart';

String _stringValue(dynamic value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  return value.toString().trim();
}

String _localizedField(
  Map<String, dynamic> data, {
  required String baseKey,
  required String arabicKey,
  required String englishKey,
  required bool isArabic,
}) {
  final fallback = _stringValue(data[baseKey]);
  if (isArabic) {
    final ar = _stringValue(data[arabicKey]);
    if (ar.isNotEmpty) return ar;
    if (fallback.isNotEmpty) return fallback;
    final en = _stringValue(data[englishKey]);
    if (en.isNotEmpty) return en;
  } else {
    final en = _stringValue(data[englishKey]);
    if (en.isNotEmpty) return en;
    if (fallback.isNotEmpty) return fallback;
    final ar = _stringValue(data[arabicKey]);
    if (ar.isNotEmpty) return ar;
  }
  return '';
}

String localizedProductName(Map<String, dynamic> data,
        {required bool isArabic}) =>
    _localizedField(
      data,
      baseKey: 'name',
      arabicKey: 'name_ar',
      englishKey: 'name_en',
      isArabic: isArabic,
    );

String localizedProductDescription(Map<String, dynamic> data,
        {required bool isArabic}) =>
    _localizedField(
      data,
      baseKey: 'description',
      arabicKey: 'description_ar',
      englishKey: 'description_en',
      isArabic: isArabic,
    );

extension AppLocalizationsExt on AppLocalizations {
  String translateUnit(String unitKey) {
    final key = unitKey.toLowerCase().trim();
    switch (key) {
      case 'kilo':
        return unitKilo;
      case 'box':
        return unitBox;
      case 'piece':
        return unitPiece;
      case 'kg':
        return unitKg;
      case 'gram':
        return unitGram;
      case 'haba':
        return unitHaba;
      case 'rabta':
        return unitRabta;
      case 'kis':
        return unitKis;
      default:
        return unitKey;
    }
  }
}
