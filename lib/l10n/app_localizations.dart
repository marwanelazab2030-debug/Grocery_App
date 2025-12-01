import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Khodarkom'**
  String get appTitle;

  /// Greeting text shown on profile screen header
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String profileGreeting(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @myOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrdersLabel;

  /// No description provided for @addressesLabel.
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get addressesLabel;

  /// No description provided for @favoritesLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languagePickerTitle;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @createProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get createProfileTitle;

  /// No description provided for @createProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name and choose your preferred language to continue.'**
  String get createProfileSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @languageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageFieldLabel;

  /// No description provided for @saveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButtonLabel;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved ✅'**
  String get saveSuccess;

  /// Error shown when saving profile fails
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveError(String error);

  /// No description provided for @invalidSessionError.
  ///
  /// In en, this message translates to:
  /// **'Session is invalid. Please try again.'**
  String get invalidSessionError;

  /// No description provided for @emptyNameError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name.'**
  String get emptyNameError;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// No description provided for @genericErrorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get genericErrorLoadingData;

  /// No description provided for @currencyValue.
  ///
  /// In en, this message translates to:
  /// **'{value} SAR'**
  String currencyValue(String value);

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'{price} SAR /\n{unit}'**
  String pricePerUnit(String price, String unit);

  /// No description provided for @quantityWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Qty: {quantity} {unit}'**
  String quantityWithUnit(String quantity, String unit);

  /// No description provided for @homeCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get homeCategoryAll;

  /// No description provided for @homeCategoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get homeCategoryVegetables;

  /// No description provided for @homeCategoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get homeCategoryFruits;

  /// No description provided for @homeCategoryDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get homeCategoryDates;

  /// No description provided for @homeCategoryEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get homeCategoryEggs;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for products...'**
  String get homeSearchHint;

  /// No description provided for @homeBestPricesTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s best prices'**
  String get homeBestPricesTitle;

  /// No description provided for @homeNoProductsMessage.
  ///
  /// In en, this message translates to:
  /// **'No products in this category.'**
  String get homeNoProductsMessage;

  /// No description provided for @homeAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get homeAddedToCart;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'My Cart'**
  String get cartTitle;

  /// No description provided for @cartCouponHint.
  ///
  /// In en, this message translates to:
  /// **'Have a discount code?'**
  String get cartCouponHint;

  /// No description provided for @cartApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get cartApplyButton;

  /// No description provided for @cartCheckoutButton.
  ///
  /// In en, this message translates to:
  /// **'Proceed to payment'**
  String get cartCheckoutButton;

  /// No description provided for @cartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty!'**
  String get cartEmptyTitle;

  /// No description provided for @cartEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start adding fresh products to enjoy the best prices.'**
  String get cartEmptySubtitle;

  /// No description provided for @cartEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get cartEmptyAction;

  /// No description provided for @subtotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotalLabel;

  /// No description provided for @deliveryFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFeeLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @addressesTitle.
  ///
  /// In en, this message translates to:
  /// **'My addresses'**
  String get addressesTitle;

  /// No description provided for @selectDeliveryAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Select delivery address'**
  String get selectDeliveryAddressTitle;

  /// No description provided for @addressUnknownValue.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get addressUnknownValue;

  /// No description provided for @addressUnknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown address'**
  String get addressUnknownLabel;

  /// No description provided for @addressUseForPayment.
  ///
  /// In en, this message translates to:
  /// **'This address will be used for payment'**
  String get addressUseForPayment;

  /// No description provided for @addressSelectBeforeContinue.
  ///
  /// In en, this message translates to:
  /// **'Please select an address before continuing'**
  String get addressSelectBeforeContinue;

  /// No description provided for @goToPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Go to payment'**
  String get goToPaymentButton;

  /// No description provided for @addNewAddressButton.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get addNewAddressButton;

  /// No description provided for @noAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'No addresses yet'**
  String get noAddressesTitle;

  /// No description provided for @noAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your address to make delivery easier'**
  String get noAddressesSubtitle;

  /// No description provided for @addAddressCta.
  ///
  /// In en, this message translates to:
  /// **'Add a new address'**
  String get addAddressCta;

  /// No description provided for @addressTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressTypeHome;

  /// No description provided for @addressTypeWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressTypeWork;

  /// No description provided for @addressTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get addressTypeFamily;

  /// No description provided for @addressTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressTypeOther;

  /// No description provided for @addressTypeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressTypeUnknown;

  /// No description provided for @addressTypeCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Another address'**
  String get addressTypeCustomLabel;

  /// No description provided for @addressCustomTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter address type'**
  String get addressCustomTypeHint;

  /// No description provided for @addressStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Street name'**
  String get addressStreetHint;

  /// No description provided for @addressBuildingHint.
  ///
  /// In en, this message translates to:
  /// **'Building / apartment number'**
  String get addressBuildingHint;

  /// No description provided for @addressLandmarkHint.
  ///
  /// In en, this message translates to:
  /// **'Landmark (optional)'**
  String get addressLandmarkHint;

  /// No description provided for @addressSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Address saved successfully'**
  String get addressSavedMessage;

  /// No description provided for @addressUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Address updated'**
  String get addressUpdatedMessage;

  /// No description provided for @addressFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get addressFormEditTitle;

  /// No description provided for @addressFormAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter address details'**
  String get addressFormAddTitle;

  /// No description provided for @addressConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get addressConfirmButton;

  /// No description provided for @addressUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update address'**
  String get addressUpdateButton;

  /// No description provided for @orderDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailsTitle;

  /// No description provided for @orderLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading order'**
  String get orderLoadError;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderNotFound;

  /// No description provided for @orderProductsSection.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get orderProductsSection;

  /// No description provided for @orderNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId}'**
  String orderNumberLabel(String orderId);

  /// No description provided for @orderSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get orderSummaryLabel;

  /// No description provided for @orderStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Order received'**
  String get orderStatusReceived;

  /// No description provided for @orderStatusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get orderStatusOnTheWay;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @myOrdersLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get myOrdersLoginRequired;

  /// No description provided for @ordersTabCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get ordersTabCurrent;

  /// No description provided for @ordersTabPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get ordersTabPast;

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get ordersLoadError;

  /// No description provided for @orderNumberPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order '**
  String get orderNumberPrefix;

  /// No description provided for @ordersTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get ordersTotalLabel;

  /// No description provided for @ordersActionReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get ordersActionReorder;

  /// No description provided for @ordersActionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get ordersActionDetails;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderStatusOutForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get orderStatusOutForDelivery;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusCompleted;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @ordersEmptyCurrent.
  ///
  /// In en, this message translates to:
  /// **'You don’t have current orders'**
  String get ordersEmptyCurrent;

  /// No description provided for @ordersEmptyPast.
  ///
  /// In en, this message translates to:
  /// **'You don’t have past orders'**
  String get ordersEmptyPast;

  /// No description provided for @ordersEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Once you place an order, you’ll see its history here.'**
  String get ordersEmptyHint;

  /// No description provided for @paymentCartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get paymentCartEmpty;

  /// No description provided for @paymentCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error while creating the order'**
  String get paymentCreationError;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentTitle;

  /// No description provided for @paymentMethodMada.
  ///
  /// In en, this message translates to:
  /// **'Mada'**
  String get paymentMethodMada;

  /// No description provided for @paymentMethodCod.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get paymentMethodCod;

  /// No description provided for @paymentConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm payment'**
  String get paymentConfirmButton;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search favorites...'**
  String get favoritesSearchHint;

  /// No description provided for @favoritesAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get favoritesAddToCart;

  /// No description provided for @favoritesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You have no favorite products yet'**
  String get favoritesEmptyTitle;

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add the products you love here for quick access'**
  String get favoritesEmptySubtitle;

  /// No description provided for @favoritesEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get favoritesEmptyAction;

  /// No description provided for @productFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productFallbackName;

  /// No description provided for @productDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescriptionLabel;

  /// No description provided for @productDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No description available for this product.'**
  String get productDescriptionEmpty;

  /// No description provided for @productAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get productAddToCart;

  /// No description provided for @phoneWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Khodarkom'**
  String get phoneWelcomeTitle;

  /// No description provided for @phoneWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to start'**
  String get phoneWelcomeSubtitle;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumberLabel;

  /// No description provided for @phoneInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Saudi mobile number (9 digits starting with 5).'**
  String get phoneInvalidInput;

  /// No description provided for @phoneVerifyError.
  ///
  /// In en, this message translates to:
  /// **'Verification failed: {message}'**
  String phoneVerifyError(String message);

  /// No description provided for @phoneGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String phoneGenericError(String error);

  /// No description provided for @phoneContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get phoneContinueButton;

  /// No description provided for @phoneAgreementPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to '**
  String get phoneAgreementPrefix;

  /// No description provided for @phoneTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get phoneTermsLabel;

  /// No description provided for @phoneAndConnector.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get phoneAndConnector;

  /// No description provided for @phonePrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get phonePrivacyLabel;

  /// No description provided for @otpAutofillSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verified automatically!'**
  String get otpAutofillSuccess;

  /// No description provided for @otpResendError.
  ///
  /// In en, this message translates to:
  /// **'Error while resending: {message}'**
  String otpResendError(String message);

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'The code you entered is incorrect.'**
  String get otpInvalidCode;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otpTitle;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get otpSubtitle;

  /// No description provided for @otpInfoText.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to your phone number.'**
  String get otpInfoText;

  /// No description provided for @otpResendAfter.
  ///
  /// In en, this message translates to:
  /// **'Resend after {time}'**
  String otpResendAfter(String time);

  /// No description provided for @otpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResendButton;

  /// No description provided for @otpEnterFullCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full code (6 digits).'**
  String get otpEnterFullCode;

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerifyButton;

  /// No description provided for @unitKilo.
  ///
  /// In en, this message translates to:
  /// **'Kilo'**
  String get unitKilo;

  /// No description provided for @unitBox.
  ///
  /// In en, this message translates to:
  /// **'Box'**
  String get unitBox;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitPiece;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'Kg'**
  String get unitKg;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unitGram;

  /// No description provided for @unitHaba.
  ///
  /// In en, this message translates to:
  /// **'Piece'**
  String get unitHaba;

  /// No description provided for @unitRabta.
  ///
  /// In en, this message translates to:
  /// **'Bundle'**
  String get unitRabta;

  /// No description provided for @unitKis.
  ///
  /// In en, this message translates to:
  /// **'Bag'**
  String get unitKis;

  /// No description provided for @bottomNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// No description provided for @bottomNavCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get bottomNavCart;

  /// No description provided for @bottomNavOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get bottomNavOrders;

  /// No description provided for @bottomNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// No description provided for @orderIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Order ID copied to clipboard'**
  String get orderIdCopied;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
