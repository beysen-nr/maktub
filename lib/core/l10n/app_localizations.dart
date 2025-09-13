import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @welcome.
  ///
  /// In kk, this message translates to:
  /// **'maktub-қа қош келдіңіз!'**
  String get welcome;

  /// No description provided for @welcomeDesc.
  ///
  /// In kk, this message translates to:
  /// **'біз сізге пайдалы боламыз деп үміттенеміз'**
  String get welcomeDesc;

  /// No description provided for @confirm.
  ///
  /// In kk, this message translates to:
  /// **'растау'**
  String get confirm;

  /// No description provided for @continueB.
  ///
  /// In kk, this message translates to:
  /// **'жалғастыру'**
  String get continueB;

  /// No description provided for @loginToProfile.
  ///
  /// In kk, this message translates to:
  /// **'профильге кіру'**
  String get loginToProfile;

  /// No description provided for @login.
  ///
  /// In kk, this message translates to:
  /// **'Кіру'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In kk, this message translates to:
  /// **'шығу'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In kk, this message translates to:
  /// **'тіркелу'**
  String get register;

  /// No description provided for @loginWelcome.
  ///
  /// In kk, this message translates to:
  /// **'қош келдіңіз,'**
  String get loginWelcome;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In kk, this message translates to:
  /// **'телефон нөмірін енгізіңіз'**
  String get enterPhoneNumber;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In kk, this message translates to:
  /// **'нөмір жүйеде тіркелмеген'**
  String get phoneNotRegistered;

  /// No description provided for @enterTheNumberCorrectly.
  ///
  /// In kk, this message translates to:
  /// **'нөмірді дұрыс еңгізіңіз'**
  String get enterTheNumberCorrectly;

  /// No description provided for @enterTheIINCorrectly.
  ///
  /// In kk, this message translates to:
  /// **'ЖСН-ді дұрыс еңгізіңіз'**
  String get enterTheIINCorrectly;

  /// No description provided for @ownerNotIdentified.
  ///
  /// In kk, this message translates to:
  /// **'жеке кәсіпкерлік иесі анықталмады'**
  String get ownerNotIdentified;

  /// No description provided for @iPNotDefined.
  ///
  /// In kk, this message translates to:
  /// **'жеке кәсіпкерлік анықталмады'**
  String get iPNotDefined;

  /// No description provided for @weWillOnContact.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің өтінішіңіз қабылданды. \nБіз жақын арада хабарласамыз.'**
  String get weWillOnContact;

  /// No description provided for @phoneNumberExplanation.
  ///
  /// In kk, this message translates to:
  /// **'біз сіздің нөміріңізді жеке кабинетті растау үшін қолданамыз'**
  String get phoneNumberExplanation;

  /// No description provided for @whatsappCodeSent.
  ///
  /// In kk, this message translates to:
  /// **'сіздің нөміріңізге WhatsApp арқылы код жіберілді'**
  String get whatsappCodeSent;

  /// No description provided for @enterCode.
  ///
  /// In kk, this message translates to:
  /// **'Кодты енгізіңіз'**
  String get enterCode;

  /// No description provided for @notRegisteredYet.
  ///
  /// In kk, this message translates to:
  /// **'сіз әлі Maktub-та жоқсыз ба?'**
  String get notRegisteredYet;

  /// No description provided for @enterIin.
  ///
  /// In kk, this message translates to:
  /// **'ЖСН енгізіңіз'**
  String get enterIin;

  /// No description provided for @iinExplanation.
  ///
  /// In kk, this message translates to:
  /// **'сіздің ЖСН жеке кәсіпкерлікті растау үшін қажет'**
  String get iinExplanation;

  /// No description provided for @ownerIin.
  ///
  /// In kk, this message translates to:
  /// **'иесінің ЖСН'**
  String get ownerIin;

  /// No description provided for @owner.
  ///
  /// In kk, this message translates to:
  /// **'жеке кәсіпкерлік иесі'**
  String get owner;

  /// No description provided for @businessName.
  ///
  /// In kk, this message translates to:
  /// **'жеке кәсіпкерлік атауы'**
  String get businessName;

  /// No description provided for @supplierQuestion.
  ///
  /// In kk, this message translates to:
  /// **'сіз өнім сатушысыз ба?'**
  String get supplierQuestion;

  /// No description provided for @registerOrganization.
  ///
  /// In kk, this message translates to:
  /// **'ұйымыңызды тіркеңіз'**
  String get registerOrganization;

  /// No description provided for @weWillContact.
  ///
  /// In kk, this message translates to:
  /// **'біз сізбен кері байланысқа шығып, ұйымыңызды сервиске сатушы ретінде тіркейміз'**
  String get weWillContact;

  /// No description provided for @weWillContactCustomer.
  ///
  /// In kk, this message translates to:
  /// **'біз сізбен кері байланысқа шығып, ұйымыңызды сервиске тіркейміз'**
  String get weWillContactCustomer;

  /// No description provided for @organizationIinBin.
  ///
  /// In kk, this message translates to:
  /// **'ұйымның ЖСН/БСН'**
  String get organizationIinBin;

  /// No description provided for @organizationName.
  ///
  /// In kk, this message translates to:
  /// **'ұйым атауы'**
  String get organizationName;

  /// No description provided for @contactPhoneNumber.
  ///
  /// In kk, this message translates to:
  /// **'байланыс нөмірі'**
  String get contactPhoneNumber;

  /// No description provided for @productType.
  ///
  /// In kk, this message translates to:
  /// **'тауар түрі'**
  String get productType;

  /// No description provided for @similarProducts.
  ///
  /// In kk, this message translates to:
  /// **'ұқсас тауарлар'**
  String get similarProducts;

  /// No description provided for @preferredTime.
  ///
  /// In kk, this message translates to:
  /// **'сізге ыңғайлы уақыт'**
  String get preferredTime;

  /// No description provided for @send.
  ///
  /// In kk, this message translates to:
  /// **'жіберу'**
  String get send;

  /// No description provided for @enterTheConfirmationCode.
  ///
  /// In kk, this message translates to:
  /// **'растау үшін кодты енгізіңіз'**
  String get enterTheConfirmationCode;

  /// No description provided for @customer.
  ///
  /// In kk, this message translates to:
  /// **'өнім алушы'**
  String get customer;

  /// No description provided for @organizationIsLegal.
  ///
  /// In kk, this message translates to:
  /// **'сіздің ұйымыңыз заңды тұлға боп табылады. сіз өзіңізді қалай таныстырғыңыз келеді?'**
  String get organizationIsLegal;

  /// No description provided for @supplierSale.
  ///
  /// In kk, this message translates to:
  /// **'өнім сатушы'**
  String get supplierSale;

  /// No description provided for @cityChanged.
  ///
  /// In kk, this message translates to:
  /// **'қала ауысты'**
  String get cityChanged;

  /// No description provided for @productsType.
  ///
  /// In kk, this message translates to:
  /// **'өнім түрі'**
  String get productsType;

  /// No description provided for @orders.
  ///
  /// In kk, this message translates to:
  /// **'тапсырыстар'**
  String get orders;

  /// No description provided for @regSupplierDesc.
  ///
  /// In kk, this message translates to:
  /// **'біз сатушымен байланысқа шығып, ұйымды сервиске тіркейміз, \n сіз тіркеген әр сатушыдан сізге 10000₸ жеңілдік сыйлаймыз'**
  String get regSupplierDesc;

  /// No description provided for @noOrders.
  ///
  /// In kk, this message translates to:
  /// **'cізде тапсырыстар жоқ'**
  String get noOrders;

  /// No description provided for @aboutOrder.
  ///
  /// In kk, this message translates to:
  /// **'тапсырыс жайлы'**
  String get aboutOrder;

  /// No description provided for @info.
  ///
  /// In kk, this message translates to:
  /// **'ақпарат'**
  String get info;

  /// No description provided for @chooseLanguage.
  ///
  /// In kk, this message translates to:
  /// **'тілді таңдаңыз'**
  String get chooseLanguage;

  /// No description provided for @apply.
  ///
  /// In kk, this message translates to:
  /// **'растау'**
  String get apply;

  /// No description provided for @maktubLoginInfo.
  ///
  /// In kk, this message translates to:
  /// **'мекенжайды сақтау, промокодты қолдану және \nең тиімді бағамен тауар алу үшін профильге кіріңіз'**
  String get maktubLoginInfo;

  /// No description provided for @errorTryLater.
  ///
  /// In kk, this message translates to:
  /// **'қате орын алды, біраздан кейін көріңіз'**
  String get errorTryLater;

  /// No description provided for @fillAddressData.
  ///
  /// In kk, this message translates to:
  /// **'жеткізу мекенжайын толтырыңыз'**
  String get fillAddressData;

  /// No description provided for @addAddress.
  ///
  /// In kk, this message translates to:
  /// **'адрес қосу'**
  String get addAddress;

  /// No description provided for @chooseAddress.
  ///
  /// In kk, this message translates to:
  /// **'жеткізу адресін таңдаңыз'**
  String get chooseAddress;

  /// No description provided for @noAddress.
  ///
  /// In kk, this message translates to:
  /// **'адресіңізді таппадық'**
  String get noAddress;

  /// No description provided for @chooseRegion.
  ///
  /// In kk, this message translates to:
  /// **'қалаңызды таңдаңыз'**
  String get chooseRegion;

  /// No description provided for @deliveryAddress.
  ///
  /// In kk, this message translates to:
  /// **'жеткізу адресі'**
  String get deliveryAddress;

  /// No description provided for @deliveryHere.
  ///
  /// In kk, this message translates to:
  /// **'осында жеткізу'**
  String get deliveryHere;

  /// No description provided for @accountWasBeenBlocked.
  ///
  /// In kk, this message translates to:
  /// **'Сіздің аккаунтыңыз бұғатталған, анығырақ білу үшін @maktubSupport телеграм желісіне жазыңыз'**
  String get accountWasBeenBlocked;

  /// No description provided for @entryNumber.
  ///
  /// In kk, this message translates to:
  /// **'телефон нөмірін еңгізіңіз'**
  String get entryNumber;

  /// No description provided for @weUseYourNumber.
  ///
  /// In kk, this message translates to:
  /// **'біз сіздің нөміріңізді жеке кабинетті растау үшін қолданамыз'**
  String get weUseYourNumber;

  /// No description provided for @dontHaveMaktub.
  ///
  /// In kk, this message translates to:
  /// **'сізде maktub жоқ па?'**
  String get dontHaveMaktub;

  /// No description provided for @codeViaWhatsapp.
  ///
  /// In kk, this message translates to:
  /// **'сізге WhatsApp арқылы код келеді'**
  String get codeViaWhatsapp;

  /// No description provided for @entryIIN.
  ///
  /// In kk, this message translates to:
  /// **'ЖСН еңгізіңіз'**
  String get entryIIN;

  /// No description provided for @weUseYourIIN.
  ///
  /// In kk, this message translates to:
  /// **'біз сіздің ЖСН-ді жеке кәсіпкерлігіңізді растау үшін қолданамыз'**
  String get weUseYourIIN;

  /// No description provided for @areYouSupplier.
  ///
  /// In kk, this message translates to:
  /// **'сіз өнім сатушысыз ба?'**
  String get areYouSupplier;

  /// No description provided for @cart.
  ///
  /// In kk, this message translates to:
  /// **'себет'**
  String get cart;

  /// No description provided for @home.
  ///
  /// In kk, this message translates to:
  /// **'басты'**
  String get home;

  /// No description provided for @clearCart.
  ///
  /// In kk, this message translates to:
  /// **'босату'**
  String get clearCart;

  /// No description provided for @searchInMaktub.
  ///
  /// In kk, this message translates to:
  /// **'maktub ішінде іздеу'**
  String get searchInMaktub;

  /// No description provided for @reasonablePrice.
  ///
  /// In kk, this message translates to:
  /// **'ең тиімді баға'**
  String get reasonablePrice;

  /// No description provided for @onlyOnOurService.
  ///
  /// In kk, this message translates to:
  /// **'тек қана бізде'**
  String get onlyOnOurService;

  /// No description provided for @theBiggestDiscount.
  ///
  /// In kk, this message translates to:
  /// **'ең үлкен жеңілдік'**
  String get theBiggestDiscount;

  /// No description provided for @onlyForYou.
  ///
  /// In kk, this message translates to:
  /// **'тек қана сізге'**
  String get onlyForYou;

  /// No description provided for @letsRejoiceTogether.
  ///
  /// In kk, this message translates to:
  /// **'қуанайық бірге'**
  String get letsRejoiceTogether;

  /// No description provided for @youAndWeToo.
  ///
  /// In kk, this message translates to:
  /// **'сіз де және біз де'**
  String get youAndWeToo;

  /// No description provided for @error.
  ///
  /// In kk, this message translates to:
  /// **'ақау шықты,өтініш, техникалық қолдауға хабарлаңыз'**
  String get error;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In kk, this message translates to:
  /// **'себетіңіз бос екен'**
  String get yourCartIsEmpty;

  /// No description provided for @maybeWeWillFillYourBasket.
  ///
  /// In kk, this message translates to:
  /// **'бәлкім себетіңізді толтырамыз?'**
  String get maybeWeWillFillYourBasket;

  /// No description provided for @seeCatalog.
  ///
  /// In kk, this message translates to:
  /// **'каталог қарау'**
  String get seeCatalog;

  /// No description provided for @inThePackage.
  ///
  /// In kk, this message translates to:
  /// **'қорапта '**
  String get inThePackage;

  /// No description provided for @minOrderAmount.
  ///
  /// In kk, this message translates to:
  /// **'мин. тапсырыс – '**
  String get minOrderAmount;

  /// No description provided for @minCountOfProduct.
  ///
  /// In kk, this message translates to:
  /// **'минималды тауар саны: '**
  String get minCountOfProduct;

  /// No description provided for @catalogOfSupplier.
  ///
  /// In kk, this message translates to:
  /// **'жеткізушінің каталогы'**
  String get catalogOfSupplier;

  /// No description provided for @makeOrder.
  ///
  /// In kk, this message translates to:
  /// **'тапсырыс жасау'**
  String get makeOrder;

  /// No description provided for @inOneCopy.
  ///
  /// In kk, this message translates to:
  /// **'бір данада '**
  String get inOneCopy;

  /// No description provided for @description.
  ///
  /// In kk, this message translates to:
  /// **'сипаттама'**
  String get description;

  /// No description provided for @allSuppliersAndPrices.
  ///
  /// In kk, this message translates to:
  /// **'барлық сатушы мен бағалар'**
  String get allSuppliersAndPrices;

  /// No description provided for @orderSuccessfullyMaked.
  ///
  /// In kk, this message translates to:
  /// **'Тапсырыс сәтті жасалды'**
  String get orderSuccessfullyMaked;

  /// No description provided for @allProducts.
  ///
  /// In kk, this message translates to:
  /// **'барлық тауарлар'**
  String get allProducts;

  /// No description provided for @day.
  ///
  /// In kk, this message translates to:
  /// **'Күні'**
  String get day;

  /// No description provided for @pointDesc.
  ///
  /// In kk, this message translates to:
  /// **'нүктеге дейін жету жолы?'**
  String get pointDesc;

  /// No description provided for @quantity.
  ///
  /// In kk, this message translates to:
  /// **'дана'**
  String get quantity;

  /// No description provided for @discountOfPromo.
  ///
  /// In kk, this message translates to:
  /// **'Промокод жеңілдігі: '**
  String get discountOfPromo;

  /// No description provided for @enterPromo.
  ///
  /// In kk, this message translates to:
  /// **'промокод еңгізіңіз'**
  String get enterPromo;

  /// No description provided for @order.
  ///
  /// In kk, this message translates to:
  /// **'Тапсырыс'**
  String get order;

  /// No description provided for @totalSum.
  ///
  /// In kk, this message translates to:
  /// **'Жалпы сома: '**
  String get totalSum;

  /// No description provided for @applyOrder.
  ///
  /// In kk, this message translates to:
  /// **'Қабылдау'**
  String get applyOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In kk, this message translates to:
  /// **'Бас тарту'**
  String get cancelOrder;

  /// No description provided for @rateOrder.
  ///
  /// In kk, this message translates to:
  /// **'Бағаңызды қалдырыңыз'**
  String get rateOrder;

  /// No description provided for @expenseInvoice.
  ///
  /// In kk, this message translates to:
  /// **'Шығыс шот-фактурасы'**
  String get expenseInvoice;

  /// No description provided for @writeReview.
  ///
  /// In kk, this message translates to:
  /// **'Пікіріңізді жазыңыз...'**
  String get writeReview;

  /// No description provided for @thanksForReview.
  ///
  /// In kk, this message translates to:
  /// **'Пікір қалдырғаныңызға рақмет!\nБіз сіздің пікіріңізді ескереміз!'**
  String get thanksForReview;

  /// No description provided for @sendReview.
  ///
  /// In kk, this message translates to:
  /// **'Жіберу'**
  String get sendReview;

  /// No description provided for @codeForDelivery.
  ///
  /// In kk, this message translates to:
  /// **'кодты экспедиторға айтыңыз'**
  String get codeForDelivery;

  /// No description provided for @reasonOfCancel.
  ///
  /// In kk, this message translates to:
  /// **'бас тарту себебі?'**
  String get reasonOfCancel;

  /// No description provided for @productQuality.
  ///
  /// In kk, this message translates to:
  /// **'тауар сапасына сай емес'**
  String get productQuality;

  /// No description provided for @ownDiscration.
  ///
  /// In kk, this message translates to:
  /// **'өз қалауым бойынша'**
  String get ownDiscration;

  /// No description provided for @deliveryAsked.
  ///
  /// In kk, this message translates to:
  /// **'жеткізуші сұрады'**
  String get deliveryAsked;

  /// No description provided for @employees.
  ///
  /// In kk, this message translates to:
  /// **'Қызметкерлер'**
  String get employees;

  /// No description provided for @onlyYou.
  ///
  /// In kk, this message translates to:
  /// **'әзірше сіз ғана'**
  String get onlyYou;

  /// No description provided for @receiver.
  ///
  /// In kk, this message translates to:
  /// **'қабылдаушы'**
  String get receiver;

  /// No description provided for @addEmployee.
  ///
  /// In kk, this message translates to:
  /// **'қызметкерді қосу'**
  String get addEmployee;

  /// No description provided for @weUseEmployeePhone.
  ///
  /// In kk, this message translates to:
  /// **'біз қызметкердің нөмірін жеке кабинетті растау үшін қолданамыз'**
  String get weUseEmployeePhone;

  /// No description provided for @myData.
  ///
  /// In kk, this message translates to:
  /// **'менің деректерім'**
  String get myData;

  /// No description provided for @fullName.
  ///
  /// In kk, this message translates to:
  /// **'аты-жөні'**
  String get fullName;

  /// No description provided for @privateEntrepreneurship.
  ///
  /// In kk, this message translates to:
  /// **'жеке кәсіпкерлік'**
  String get privateEntrepreneurship;

  /// No description provided for @phoneNumber.
  ///
  /// In kk, this message translates to:
  /// **'телефон нөмірі'**
  String get phoneNumber;

  /// No description provided for @supplier.
  ///
  /// In kk, this message translates to:
  /// **'жеткізуші'**
  String get supplier;

  /// No description provided for @maybeYouSearch.
  ///
  /// In kk, this message translates to:
  /// **'бәлкім сіздің іздегеніңіз'**
  String get maybeYouSearch;

  /// No description provided for @price.
  ///
  /// In kk, this message translates to:
  /// **'баға: '**
  String get price;

  /// No description provided for @inCart.
  ///
  /// In kk, this message translates to:
  /// **'себетте '**
  String get inCart;

  /// No description provided for @all.
  ///
  /// In kk, this message translates to:
  /// **'барлығы'**
  String get all;

  /// No description provided for @thisListIsEmpty.
  ///
  /// In kk, this message translates to:
  /// **'бұл тізім бос екен'**
  String get thisListIsEmpty;

  /// No description provided for @registerYourSupplierAndGetDiscounts.
  ///
  /// In kk, this message translates to:
  /// **'өз жеткізушілеріңізді тіркеп, \nолардан жеңілдік алыңыз'**
  String get registerYourSupplierAndGetDiscounts;

  /// No description provided for @registerSupplier.
  ///
  /// In kk, this message translates to:
  /// **'жеткізушіні тіркеу'**
  String get registerSupplier;

  /// No description provided for @onTheWay.
  ///
  /// In kk, this message translates to:
  /// **'жолда'**
  String get onTheWay;

  /// No description provided for @cancelled.
  ///
  /// In kk, this message translates to:
  /// **'бас тартылды'**
  String get cancelled;

  /// No description provided for @delivered.
  ///
  /// In kk, this message translates to:
  /// **'жеткізілді'**
  String get delivered;

  /// No description provided for @inProcessing.
  ///
  /// In kk, this message translates to:
  /// **'өңделуде'**
  String get inProcessing;

  /// No description provided for @month_jan.
  ///
  /// In kk, this message translates to:
  /// **'қаңтар'**
  String get month_jan;

  /// No description provided for @month_feb.
  ///
  /// In kk, this message translates to:
  /// **'ақпан'**
  String get month_feb;

  /// No description provided for @month_mar.
  ///
  /// In kk, this message translates to:
  /// **'наурыз'**
  String get month_mar;

  /// No description provided for @month_apr.
  ///
  /// In kk, this message translates to:
  /// **'сәуір'**
  String get month_apr;

  /// No description provided for @month_may.
  ///
  /// In kk, this message translates to:
  /// **'мамыр'**
  String get month_may;

  /// No description provided for @month_jun.
  ///
  /// In kk, this message translates to:
  /// **'маусым'**
  String get month_jun;

  /// No description provided for @month_jul.
  ///
  /// In kk, this message translates to:
  /// **'шілде'**
  String get month_jul;

  /// No description provided for @month_aug.
  ///
  /// In kk, this message translates to:
  /// **'тамыз'**
  String get month_aug;

  /// No description provided for @month_sep.
  ///
  /// In kk, this message translates to:
  /// **'қыркүйек'**
  String get month_sep;

  /// No description provided for @month_oct.
  ///
  /// In kk, this message translates to:
  /// **'қазан'**
  String get month_oct;

  /// No description provided for @month_nov.
  ///
  /// In kk, this message translates to:
  /// **'қараша'**
  String get month_nov;

  /// No description provided for @month_dec.
  ///
  /// In kk, this message translates to:
  /// **'желтоқсан'**
  String get month_dec;

  /// No description provided for @weekday_mon.
  ///
  /// In kk, this message translates to:
  /// **'дүйсенбі'**
  String get weekday_mon;

  /// No description provided for @weekday_tue.
  ///
  /// In kk, this message translates to:
  /// **'сейсенбі'**
  String get weekday_tue;

  /// No description provided for @weekday_wed.
  ///
  /// In kk, this message translates to:
  /// **'сәрсенбі'**
  String get weekday_wed;

  /// No description provided for @weekday_thu.
  ///
  /// In kk, this message translates to:
  /// **'бейсенбі'**
  String get weekday_thu;

  /// No description provided for @weekday_fri.
  ///
  /// In kk, this message translates to:
  /// **'жұма'**
  String get weekday_fri;

  /// No description provided for @weekday_sat.
  ///
  /// In kk, this message translates to:
  /// **'сенбі'**
  String get weekday_sat;

  /// No description provided for @weekday_sun.
  ///
  /// In kk, this message translates to:
  /// **'жексенбі'**
  String get weekday_sun;

  /// No description provided for @contactUs.
  ///
  /// In kk, this message translates to:
  /// **'Бізбен байланысу'**
  String get contactUs;

  /// No description provided for @forContact.
  ///
  /// In kk, this message translates to:
  /// **'Байланыс үшін'**
  String get forContact;

  /// No description provided for @returnPolicy.
  ///
  /// In kk, this message translates to:
  /// **'Тауарды қайтару саясаты'**
  String get returnPolicy;

  /// No description provided for @privacyPolicy.
  ///
  /// In kk, this message translates to:
  /// **'Құпиялық саясаты'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In kk, this message translates to:
  /// **'Пайдаланушы келісімі'**
  String get termsOfUse;

  /// No description provided for @returnProduct.
  ///
  /// In kk, this message translates to:
  /// **'Тауарды қайтару'**
  String get returnProduct;

  /// No description provided for @languageSettings.
  ///
  /// In kk, this message translates to:
  /// **'Тіл баптаулары'**
  String get languageSettings;

  /// No description provided for @deleteAccount.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунтты жою'**
  String get deleteAccount;

  /// No description provided for @accountDeletion.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунт жою'**
  String get accountDeletion;

  /// No description provided for @logoutFromAccount.
  ///
  /// In kk, this message translates to:
  /// **'Аккаунттан шығу'**
  String get logoutFromAccount;

  /// No description provided for @accountDeleteInstruction.
  ///
  /// In kk, this message translates to:
  /// **'Сіз расымен де аккантты жойғыңыз келеді ме? \n'**
  String get accountDeleteInstruction;

  /// No description provided for @contactTelegramInfo.
  ///
  /// In kk, this message translates to:
  /// **'Сіз бізбен әрдайым @maktubSupport telegram желісінде байланыса аласыз.\nСізге жауап 1 күн ішінде келеді, тіпті демалыс күндері де!\n\nМәселенің тез шешілуі үшін мән-жайды толық жазыңыз.\nБіз көмектесуге дайынбыз!'**
  String get contactTelegramInfo;

  /// No description provided for @productReturnDescription.
  ///
  /// In kk, this message translates to:
  /// **'Егер сіз тауардың сыртқы түріне немесе жарамдылық мерзіміне қанағаттанбасаңыз, тауарды қабылдау кезінде тапсырыстан бас тарта аласыз.\n\nЕгер үлкен ақау болса, @maktubSupport telegram желісінде жеткізушіге арыз қалдыра аласыз.\n\nБіз тауар сапасына үлкен мән береміз, сіздің пікіріңіз біз үшін маңызды!'**
  String get productReturnDescription;

  /// No description provided for @logoutConfirmation.
  ///
  /// In kk, this message translates to:
  /// **'Сіз шынымен аккаунттан шыққыңыз келе ме?'**
  String get logoutConfirmation;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
