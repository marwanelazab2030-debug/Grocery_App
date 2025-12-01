// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Khodarkom';

  @override
  String profileGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get myOrdersLabel => 'My Orders';

  @override
  String get addressesLabel => 'My Addresses';

  @override
  String get favoritesLabel => 'Favorites';

  @override
  String get languageLabel => 'Language';

  @override
  String get languagePickerTitle => 'Choose language';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get createProfileTitle => 'Create your profile';

  @override
  String get createProfileSubtitle => 'Enter your full name and choose your preferred language to continue.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Enter your full name';

  @override
  String get languageFieldLabel => 'Language';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get saveSuccess => 'Saved ✅';

  @override
  String saveError(String error) {
    return 'Save failed: $error';
  }

  @override
  String get invalidSessionError => 'Session is invalid. Please try again.';

  @override
  String get emptyNameError => 'Please enter your full name.';

  @override
  String get defaultUserName => 'User';

  @override
  String get genericErrorLoadingData => 'Error loading data';

  @override
  String currencyValue(String value) {
    return '$value SAR';
  }

  @override
  String pricePerUnit(String price, String unit) {
    return '$price SAR /\n$unit';
  }

  @override
  String quantityWithUnit(String quantity, String unit) {
    return 'Qty: $quantity $unit';
  }

  @override
  String get homeCategoryAll => 'All';

  @override
  String get homeCategoryVegetables => 'Vegetables';

  @override
  String get homeCategoryFruits => 'Fruits';

  @override
  String get homeCategoryDates => 'Dates';

  @override
  String get homeCategoryEggs => 'Eggs';

  @override
  String get homeSearchHint => 'Search for products...';

  @override
  String get homeBestPricesTitle => 'Today’s best prices';

  @override
  String get homeNoProductsMessage => 'No products in this category.';

  @override
  String get homeAddedToCart => 'Added to cart';

  @override
  String get cartTitle => 'My Cart';

  @override
  String get cartCouponHint => 'Have a discount code?';

  @override
  String get cartApplyButton => 'Apply';

  @override
  String get cartCheckoutButton => 'Proceed to payment';

  @override
  String get cartEmptyTitle => 'Your cart is empty!';

  @override
  String get cartEmptySubtitle => 'Start adding fresh products to enjoy the best prices.';

  @override
  String get cartEmptyAction => 'Start shopping';

  @override
  String get subtotalLabel => 'Subtotal';

  @override
  String get deliveryFeeLabel => 'Delivery fee';

  @override
  String get totalLabel => 'Total';

  @override
  String get addressesTitle => 'My addresses';

  @override
  String get selectDeliveryAddressTitle => 'Select delivery address';

  @override
  String get addressUnknownValue => 'Not specified';

  @override
  String get addressUnknownLabel => 'Unknown address';

  @override
  String get addressUseForPayment => 'This address will be used for payment';

  @override
  String get addressSelectBeforeContinue => 'Please select an address before continuing';

  @override
  String get goToPaymentButton => 'Go to payment';

  @override
  String get addNewAddressButton => 'Add new address';

  @override
  String get noAddressesTitle => 'No addresses yet';

  @override
  String get noAddressesSubtitle => 'Add your address to make delivery easier';

  @override
  String get addAddressCta => 'Add a new address';

  @override
  String get addressTypeHome => 'Home';

  @override
  String get addressTypeWork => 'Work';

  @override
  String get addressTypeFamily => 'Family';

  @override
  String get addressTypeOther => 'Other';

  @override
  String get addressTypeUnknown => 'Other';

  @override
  String get addressTypeCustomLabel => 'Another address';

  @override
  String get addressCustomTypeHint => 'Enter address type';

  @override
  String get addressStreetHint => 'Street name';

  @override
  String get addressBuildingHint => 'Building / apartment number';

  @override
  String get addressLandmarkHint => 'Landmark (optional)';

  @override
  String get addressSavedMessage => 'Address saved successfully';

  @override
  String get addressUpdatedMessage => 'Address updated';

  @override
  String get addressFormEditTitle => 'Edit address';

  @override
  String get addressFormAddTitle => 'Enter address details';

  @override
  String get addressConfirmButton => 'Confirm location';

  @override
  String get addressUpdateButton => 'Update address';

  @override
  String get orderDetailsTitle => 'Order details';

  @override
  String get orderLoadError => 'Error loading order';

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderProductsSection => 'Products';

  @override
  String orderNumberLabel(String orderId) {
    return 'Order #$orderId';
  }

  @override
  String get orderSummaryLabel => 'Summary';

  @override
  String get orderStatusReceived => 'Order received';

  @override
  String get orderStatusOnTheWay => 'On the way';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get myOrdersLoginRequired => 'Please log in';

  @override
  String get ordersTabCurrent => 'Current';

  @override
  String get ordersTabPast => 'Past';

  @override
  String get ordersLoadError => 'Error loading orders';

  @override
  String get orderNumberPrefix => 'Order ';

  @override
  String get ordersTotalLabel => 'Total';

  @override
  String get ordersActionReorder => 'Reorder';

  @override
  String get ordersActionDetails => 'Details';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String get orderStatusOutForDelivery => 'Out for delivery';

  @override
  String get orderStatusCompleted => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get ordersEmptyCurrent => 'You don’t have current orders';

  @override
  String get ordersEmptyPast => 'You don’t have past orders';

  @override
  String get ordersEmptyHint => 'Once you place an order, you’ll see its history here.';

  @override
  String get paymentCartEmpty => 'Cart is empty';

  @override
  String get paymentCreationError => 'Error while creating the order';

  @override
  String get paymentTitle => 'Payment method';

  @override
  String get paymentMethodMada => 'Mada';

  @override
  String get paymentMethodCod => 'Cash on delivery';

  @override
  String get paymentConfirmButton => 'Confirm payment';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesSearchHint => 'Search favorites...';

  @override
  String get favoritesAddToCart => 'Add to cart';

  @override
  String get favoritesEmptyTitle => 'You have no favorite products yet';

  @override
  String get favoritesEmptySubtitle => 'Add the products you love here for quick access';

  @override
  String get favoritesEmptyAction => 'Browse products';

  @override
  String get productFallbackName => 'Product';

  @override
  String get productDescriptionLabel => 'Description';

  @override
  String get productDescriptionEmpty => 'No description available for this product.';

  @override
  String get productAddToCart => 'Add to cart';

  @override
  String get phoneWelcomeTitle => 'Welcome to Khodarkom';

  @override
  String get phoneWelcomeSubtitle => 'Enter your phone number to start';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneInvalidInput => 'Please enter a valid Saudi mobile number (9 digits starting with 5).';

  @override
  String phoneVerifyError(String message) {
    return 'Verification failed: $message';
  }

  @override
  String phoneGenericError(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get phoneContinueButton => 'Continue';

  @override
  String get phoneAgreementPrefix => 'By continuing you agree to ';

  @override
  String get phoneTermsLabel => 'Terms of Service';

  @override
  String get phoneAndConnector => ' and ';

  @override
  String get phonePrivacyLabel => 'Privacy Policy';

  @override
  String get otpAutofillSuccess => 'Verified automatically!';

  @override
  String otpResendError(String message) {
    return 'Error while resending: $message';
  }

  @override
  String get otpInvalidCode => 'The code you entered is incorrect.';

  @override
  String get otpTitle => 'Verification code';

  @override
  String get otpSubtitle => 'Enter the verification code';

  @override
  String get otpInfoText => 'A 6-digit code was sent to your phone number.';

  @override
  String otpResendAfter(String time) {
    return 'Resend after $time';
  }

  @override
  String get otpResendButton => 'Resend code';

  @override
  String get otpEnterFullCode => 'Please enter the full code (6 digits).';

  @override
  String get otpVerifyButton => 'Verify';

  @override
  String get unitKilo => 'Kilo';

  @override
  String get unitBox => 'Box';

  @override
  String get unitPiece => 'Piece';

  @override
  String get unitKg => 'Kg';

  @override
  String get unitGram => 'Gram';

  @override
  String get unitHaba => 'Piece';

  @override
  String get unitRabta => 'Bundle';

  @override
  String get unitKis => 'Bag';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavCart => 'Cart';

  @override
  String get bottomNavOrders => 'Orders';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get orderIdCopied => 'Order ID copied to clipboard';
}
