// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'خضاركم';

  @override
  String profileGreeting(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get myOrdersLabel => 'طلباتي';

  @override
  String get addressesLabel => 'عناويني';

  @override
  String get favoritesLabel => 'المفضلة';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languagePickerTitle => 'اختر اللغة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get createProfileTitle => 'إنشاء ملفك الشخصي';

  @override
  String get createProfileSubtitle => 'أدخل اسمك الكامل واختر اللغة المفضلة للمتابعة.';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get fullNameHint => 'ادخل اسمك الكامل';

  @override
  String get languageFieldLabel => 'اللغة';

  @override
  String get saveButtonLabel => 'حفظ';

  @override
  String get saveSuccess => 'تم الحفظ ✅';

  @override
  String saveError(String error) {
    return 'فشل الحفظ: $error';
  }

  @override
  String get invalidSessionError => 'الجلسة غير صالحة. حاول مرة أخرى.';

  @override
  String get emptyNameError => 'اكتب اسمك الكامل.';

  @override
  String get defaultUserName => 'مستخدم';

  @override
  String get genericErrorLoadingData => 'حدث خطأ أثناء تحميل البيانات';

  @override
  String currencyValue(String value) {
    return '$value ر.س';
  }

  @override
  String pricePerUnit(String price, String unit) {
    return '$price ر.س / $unit';
  }

  @override
  String quantityWithUnit(String quantity, String unit) {
    return 'الكمية: $quantity $unit';
  }

  @override
  String get homeCategoryAll => 'الكل';

  @override
  String get homeCategoryVegetables => 'خضار';

  @override
  String get homeCategoryFruits => 'فواكه';

  @override
  String get homeCategoryDates => 'تمور';

  @override
  String get homeCategoryEggs => 'بيض';

  @override
  String get homeSearchHint => 'ابحث عن منتجات...';

  @override
  String get homeBestPricesTitle => 'أفضل أسعار اليوم';

  @override
  String get homeNoProductsMessage => 'لا توجد منتجات في هذا التصنيف.';

  @override
  String get homeAddedToCart => 'تمت الإضافة إلى السلة';

  @override
  String get cartTitle => 'سلّتي';

  @override
  String get cartCouponHint => 'لديك كوبون خصم؟';

  @override
  String get cartApplyButton => 'تطبيق';

  @override
  String get cartCheckoutButton => 'المتابعة للدفع';

  @override
  String get cartEmptyTitle => 'سلّتك فارغة!';

  @override
  String get cartEmptySubtitle => 'ابدأ بإضافة منتجات طازجة للاستمتاع بأفضل الأسعار!';

  @override
  String get cartEmptyAction => 'ابدأ التسوق';

  @override
  String get subtotalLabel => 'المجموع الفرعي';

  @override
  String get deliveryFeeLabel => 'رسوم التوصيل';

  @override
  String get totalLabel => 'المجموع الكلي';

  @override
  String get addressesTitle => 'عناويني';

  @override
  String get selectDeliveryAddressTitle => 'اختر عنوان التوصيل';

  @override
  String get addressUnknownValue => 'غير محدد';

  @override
  String get addressUnknownLabel => 'عنوان غير معروف';

  @override
  String get addressUseForPayment => 'سيتم استخدام هذا العنوان للدفع';

  @override
  String get addressSelectBeforeContinue => 'الرجاء اختيار عنوان قبل المتابعة';

  @override
  String get goToPaymentButton => 'اذهب للدفع';

  @override
  String get addNewAddressButton => 'إضافة عنوان جديد';

  @override
  String get noAddressesTitle => 'لا توجد عناوين بعد';

  @override
  String get noAddressesSubtitle => 'أضف عنوانك لتسهيل عملية التوصيل';

  @override
  String get addAddressCta => 'إضافة عنوان جديد';

  @override
  String get addressTypeHome => 'المنزل';

  @override
  String get addressTypeWork => 'العمل';

  @override
  String get addressTypeFamily => 'الأهل';

  @override
  String get addressTypeOther => 'أخرى';

  @override
  String get addressTypeUnknown => 'غير محدد';

  @override
  String get addressTypeCustomLabel => 'عنوان آخر';

  @override
  String get addressCustomTypeHint => 'اكتب نوع العنوان';

  @override
  String get addressStreetHint => 'اسم الشارع';

  @override
  String get addressBuildingHint => 'رقم المبنى / الشقة';

  @override
  String get addressLandmarkHint => 'معلم بارز (اختياري)';

  @override
  String get addressSavedMessage => 'تم حفظ العنوان بنجاح';

  @override
  String get addressUpdatedMessage => 'تم تحديث العنوان';

  @override
  String get addressFormEditTitle => 'تعديل العنوان';

  @override
  String get addressFormAddTitle => 'أدخل تفاصيل العنوان';

  @override
  String get addressConfirmButton => 'تأكيد الموقع';

  @override
  String get addressUpdateButton => 'تحديث العنوان';

  @override
  String get orderDetailsTitle => 'تفاصيل الطلب';

  @override
  String get orderLoadError => 'حدث خطأ أثناء تحميل الطلب';

  @override
  String get orderNotFound => 'لم يتم العثور على هذا الطلب';

  @override
  String get orderProductsSection => 'المنتجات';

  @override
  String orderNumberLabel(String orderId) {
    return 'طلب رقم #$orderId';
  }

  @override
  String get orderSummaryLabel => 'المجموع';

  @override
  String get orderStatusReceived => 'تم الاستلام';

  @override
  String get orderStatusOnTheWay => 'قيد التوصيل';

  @override
  String get orderStatusDelivered => 'تم التوصيل';

  @override
  String get myOrdersLoginRequired => 'الرجاء تسجيل الدخول';

  @override
  String get ordersTabCurrent => 'الحالية';

  @override
  String get ordersTabPast => 'السابقة';

  @override
  String get ordersLoadError => 'حدث خطأ أثناء تحميل الطلبات';

  @override
  String get orderNumberPrefix => 'طلب رقم ';

  @override
  String get ordersTotalLabel => 'الإجمالي';

  @override
  String get ordersActionReorder => 'إعادة الطلب';

  @override
  String get ordersActionDetails => 'عرض التفاصيل';

  @override
  String get orderStatusPreparing => 'جاري التجهيز';

  @override
  String get orderStatusOutForDelivery => 'قيد التوصيل';

  @override
  String get orderStatusCompleted => 'تم التوصيل';

  @override
  String get orderStatusCancelled => 'ملغي';

  @override
  String get ordersEmptyCurrent => 'لا يوجد لديك طلبات حالية';

  @override
  String get ordersEmptyPast => 'لا يوجد لديك طلبات سابقة';

  @override
  String get ordersEmptyHint => 'بمجرد تقديم الطلب، ستتمكن من رؤية سجله هنا.';

  @override
  String get paymentCartEmpty => 'السلة فارغة';

  @override
  String get paymentCreationError => 'حدث خطأ أثناء إنشاء الطلب';

  @override
  String get paymentTitle => 'طريقة الدفع';

  @override
  String get paymentMethodMada => 'مدى';

  @override
  String get paymentMethodCod => 'الدفع عند الاستلام';

  @override
  String get paymentConfirmButton => 'تأكيد الدفع';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesSearchHint => 'ابحث في المفضلة...';

  @override
  String get favoritesAddToCart => 'أضف للسلة';

  @override
  String get favoritesEmptyTitle => 'ليس لديك أي منتجات مفضلة بعد';

  @override
  String get favoritesEmptySubtitle => 'أضف المنتجات التي تحبها هنا لسهولة الوصول إليها';

  @override
  String get favoritesEmptyAction => 'تصفح المنتجات';

  @override
  String get productFallbackName => 'المنتج';

  @override
  String get productDescriptionLabel => 'الوصف';

  @override
  String get productDescriptionEmpty => 'لا يوجد وصف متاح لهذا المنتج';

  @override
  String get productAddToCart => 'أضف إلى السلة';

  @override
  String get phoneWelcomeTitle => 'أهلاً بك في خضاركم';

  @override
  String get phoneWelcomeSubtitle => 'ادخل رقم جوالك للبدء';

  @override
  String get phoneNumberLabel => 'رقم الجوال';

  @override
  String get phoneInvalidInput => 'الرجاء إدخال رقم جوال سعودي صحيح (9 أرقام تبدأ بـ 5).';

  @override
  String phoneVerifyError(String message) {
    return 'فشل التحقق: $message';
  }

  @override
  String phoneGenericError(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get phoneContinueButton => 'متابعة';

  @override
  String get phoneAgreementPrefix => 'بالمتابعة أنت توافق على ';

  @override
  String get phoneTermsLabel => 'شروط الخدمة';

  @override
  String get phoneAndConnector => ' و ';

  @override
  String get phonePrivacyLabel => 'سياسة الخصوصية';

  @override
  String get otpAutofillSuccess => 'تم التحقق تلقائيًا!';

  @override
  String otpResendError(String message) {
    return 'حدث خطأ أثناء إعادة الإرسال: $message';
  }

  @override
  String get otpInvalidCode => 'الكود الذي أدخلته غير صحيح.';

  @override
  String get otpTitle => 'رمز التحقق';

  @override
  String get otpSubtitle => 'أدخل رمز التحقق';

  @override
  String get otpInfoText => 'تم إرسال رمز مكون من 6 أرقام إلى رقم هاتفك.';

  @override
  String otpResendAfter(String time) {
    return 'إعادة الإرسال بعد $time';
  }

  @override
  String get otpResendButton => 'إعادة إرسال الرمز';

  @override
  String get otpEnterFullCode => 'الرجاء إدخال الكود كاملاً (6 أرقام).';

  @override
  String get otpVerifyButton => 'تحقق';

  @override
  String get unitKilo => 'كيلو';

  @override
  String get unitBox => 'صندوق';

  @override
  String get unitPiece => 'قطعة';

  @override
  String get unitKg => 'كجم';

  @override
  String get unitGram => 'جرام';

  @override
  String get unitHaba => 'حبة';

  @override
  String get unitRabta => 'ربطة';

  @override
  String get unitKis => 'كيس';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavCart => 'السلة';

  @override
  String get bottomNavOrders => 'الطلبات';

  @override
  String get bottomNavProfile => 'حسابي';

  @override
  String get orderIdCopied => 'تم نسخ رقم الطلب';
}
