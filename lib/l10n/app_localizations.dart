import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
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
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'FlyNow'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navFlights.
  ///
  /// In es, this message translates to:
  /// **'Vuelos'**
  String get navFlights;

  /// No description provided for @navStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get navStatus;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @scanHint.
  ///
  /// In es, this message translates to:
  /// **'Apunta la cámara a un pase de abordar para agregarlo.'**
  String get scanHint;

  /// No description provided for @scanLabel.
  ///
  /// In es, this message translates to:
  /// **'Escanear pase de abordar'**
  String get scanLabel;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @filters.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filters;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get share;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @stepFare.
  ///
  /// In es, this message translates to:
  /// **'Tarifa'**
  String get stepFare;

  /// No description provided for @stepPassengers.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros'**
  String get stepPassengers;

  /// No description provided for @stepSeats.
  ///
  /// In es, this message translates to:
  /// **'Asientos'**
  String get stepSeats;

  /// No description provided for @stepPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get stepPayment;

  /// No description provided for @continueLabel.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skip;

  /// No description provided for @labelFrom.
  ///
  /// In es, this message translates to:
  /// **'DESDE'**
  String get labelFrom;

  /// No description provided for @labelTo.
  ///
  /// In es, this message translates to:
  /// **'HACIA'**
  String get labelTo;

  /// No description provided for @labelFlight.
  ///
  /// In es, this message translates to:
  /// **'VUELO'**
  String get labelFlight;

  /// No description provided for @labelClass.
  ///
  /// In es, this message translates to:
  /// **'CLASE'**
  String get labelClass;

  /// No description provided for @labelSeats.
  ///
  /// In es, this message translates to:
  /// **'ASIENTOS'**
  String get labelSeats;

  /// No description provided for @labelSeat.
  ///
  /// In es, this message translates to:
  /// **'ASIENTO'**
  String get labelSeat;

  /// No description provided for @labelFare.
  ///
  /// In es, this message translates to:
  /// **'TARIFA'**
  String get labelFare;

  /// No description provided for @labelBestFare.
  ///
  /// In es, this message translates to:
  /// **'MEJOR TARIFA'**
  String get labelBestFare;

  /// No description provided for @labelGate.
  ///
  /// In es, this message translates to:
  /// **'PUERTA'**
  String get labelGate;

  /// No description provided for @labelDate.
  ///
  /// In es, this message translates to:
  /// **'FECHA'**
  String get labelDate;

  /// No description provided for @labelBoarding.
  ///
  /// In es, this message translates to:
  /// **'EMBARQUE'**
  String get labelBoarding;

  /// No description provided for @labelPassenger.
  ///
  /// In es, this message translates to:
  /// **'PASAJERO'**
  String get labelPassenger;

  /// No description provided for @labelReservation.
  ///
  /// In es, this message translates to:
  /// **'RESERVA'**
  String get labelReservation;

  /// No description provided for @labelBoardingPass.
  ///
  /// In es, this message translates to:
  /// **'PASE DE ABORDAR'**
  String get labelBoardingPass;

  /// No description provided for @labelBookingCode.
  ///
  /// In es, this message translates to:
  /// **'CÓDIGO DE RESERVA'**
  String get labelBookingCode;

  /// No description provided for @labelNextTrip.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMO VIAJE'**
  String get labelNextTrip;

  /// No description provided for @perPerson.
  ///
  /// In es, this message translates to:
  /// **'por persona'**
  String get perPerson;

  /// No description provided for @labelTerminal.
  ///
  /// In es, this message translates to:
  /// **'TERMINAL'**
  String get labelTerminal;

  /// No description provided for @labelOnePassenger.
  ///
  /// In es, this message translates to:
  /// **'1 PASAJERO'**
  String get labelOnePassenger;

  /// No description provided for @checkInOpenPill.
  ///
  /// In es, this message translates to:
  /// **'Check-in abierto'**
  String get checkInOpenPill;

  /// No description provided for @splashTagline.
  ///
  /// In es, this message translates to:
  /// **'Vuela mejor, reserva más rápido'**
  String get splashTagline;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus viajes y pases de abordar te esperan'**
  String get loginSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get passwordHint;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @rememberMe.
  ///
  /// In es, this message translates to:
  /// **'Recordarme'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// No description provided for @orContinueWith.
  ///
  /// In es, this message translates to:
  /// **'O continúa con'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In es, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta'**
  String get createAccount;

  /// No description provided for @signingIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciando sesión'**
  String get signingIn;

  /// No description provided for @preparingTickets.
  ///
  /// In es, this message translates to:
  /// **'Preparando tus boletos'**
  String get preparingTickets;

  /// No description provided for @greeting.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes, Michael'**
  String get greeting;

  /// No description provided for @whereTo.
  ///
  /// In es, this message translates to:
  /// **'¿A dónde vas?'**
  String get whereTo;

  /// No description provided for @tripOneWay.
  ///
  /// In es, this message translates to:
  /// **'Solo ida'**
  String get tripOneWay;

  /// No description provided for @tripRound.
  ///
  /// In es, this message translates to:
  /// **'Ida y vuelta'**
  String get tripRound;

  /// No description provided for @tripMulti.
  ///
  /// In es, this message translates to:
  /// **'Multidestino'**
  String get tripMulti;

  /// No description provided for @fromBox.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get fromBox;

  /// No description provided for @toBox.
  ///
  /// In es, this message translates to:
  /// **'Hacia'**
  String get toBox;

  /// No description provided for @swapAirports.
  ///
  /// In es, this message translates to:
  /// **'Intercambiar aeropuertos'**
  String get swapAirports;

  /// No description provided for @departure.
  ///
  /// In es, this message translates to:
  /// **'Ida'**
  String get departure;

  /// No description provided for @returnLabel.
  ///
  /// In es, this message translates to:
  /// **'Vuelta'**
  String get returnLabel;

  /// No description provided for @addDate.
  ///
  /// In es, this message translates to:
  /// **'Agregar fecha'**
  String get addDate;

  /// No description provided for @passengersLabel.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros'**
  String get passengersLabel;

  /// No description provided for @oneAdult.
  ///
  /// In es, this message translates to:
  /// **'1 adulto'**
  String get oneAdult;

  /// No description provided for @classLabel.
  ///
  /// In es, this message translates to:
  /// **'Clase'**
  String get classLabel;

  /// No description provided for @economy.
  ///
  /// In es, this message translates to:
  /// **'Económica'**
  String get economy;

  /// No description provided for @searchFlights.
  ///
  /// In es, this message translates to:
  /// **'Buscar vuelos'**
  String get searchFlights;

  /// No description provided for @popularRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas populares'**
  String get popularRoutes;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get seeAll;

  /// No description provided for @searchingFlights.
  ///
  /// In es, this message translates to:
  /// **'Buscando vuelos'**
  String get searchingFlights;

  /// No description provided for @selectFlightTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu vuelo'**
  String get selectFlightTitle;

  /// No description provided for @flightDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vuelo'**
  String get flightDate;

  /// No description provided for @calendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendar;

  /// No description provided for @refreshing.
  ///
  /// In es, this message translates to:
  /// **'Actualizando'**
  String get refreshing;

  /// No description provided for @faresUpdated.
  ///
  /// In es, this message translates to:
  /// **'Tarifas actualizadas'**
  String get faresUpdated;

  /// No description provided for @fareTitle.
  ///
  /// In es, this message translates to:
  /// **'Tarifa'**
  String get fareTitle;

  /// No description provided for @chooseFare.
  ///
  /// In es, this message translates to:
  /// **'Elige tu tarifa'**
  String get chooseFare;

  /// No description provided for @fareSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Económica · por pasajero, solo ida'**
  String get fareSubtitle;

  /// No description provided for @mostPopular.
  ///
  /// In es, this message translates to:
  /// **'Más elegida'**
  String get mostPopular;

  /// No description provided for @fareFootnote.
  ///
  /// In es, this message translates to:
  /// **'Las tarifas son por pasajero, sin impuestos ni tasas de aeropuerto. Los asientos que te asignamos siempre son gratis.'**
  String get fareFootnote;

  /// No description provided for @whoTravels.
  ///
  /// In es, this message translates to:
  /// **'¿Quién viaja?'**
  String get whoTravels;

  /// No description provided for @passportHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tus datos tal como aparecen en tu pasaporte'**
  String get passportHint;

  /// No description provided for @passengerOne.
  ///
  /// In es, this message translates to:
  /// **'Pasajero 1 · Adulto · Tú'**
  String get passengerOne;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @nationality.
  ///
  /// In es, this message translates to:
  /// **'Nacionalidad'**
  String get nationality;

  /// No description provided for @passport.
  ///
  /// In es, this message translates to:
  /// **'Pasaporte'**
  String get passport;

  /// No description provided for @expires.
  ///
  /// In es, this message translates to:
  /// **'Vence'**
  String get expires;

  /// No description provided for @contactData.
  ///
  /// In es, this message translates to:
  /// **'Datos de contacto'**
  String get contactData;

  /// No description provided for @contactSub.
  ///
  /// In es, this message translates to:
  /// **'Aquí llegan tus boletos y avisos del vuelo'**
  String get contactSub;

  /// No description provided for @emailField.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get emailField;

  /// No description provided for @mobileField.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get mobileField;

  /// No description provided for @passportNote.
  ///
  /// In es, this message translates to:
  /// **'Los datos del pasaporte solo se envían a la aerolínea y a migraciones.'**
  String get passportNote;

  /// No description provided for @seatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Asientos'**
  String get seatsTitle;

  /// No description provided for @aircraftClass.
  ///
  /// In es, this message translates to:
  /// **'Boeing 787 · Económica'**
  String get aircraftClass;

  /// No description provided for @noSeat.
  ///
  /// In es, this message translates to:
  /// **'Sin asiento'**
  String get noSeat;

  /// No description provided for @rowsRange.
  ///
  /// In es, this message translates to:
  /// **'Filas 1–16'**
  String get rowsRange;

  /// No description provided for @cabinFront.
  ///
  /// In es, this message translates to:
  /// **'Cabina delantera · 41 de 64 libres'**
  String get cabinFront;

  /// No description provided for @legendFree.
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get legendFree;

  /// No description provided for @legendChosen.
  ///
  /// In es, this message translates to:
  /// **'Elegido'**
  String get legendChosen;

  /// No description provided for @legendTaken.
  ///
  /// In es, this message translates to:
  /// **'Ocupado'**
  String get legendTaken;

  /// No description provided for @legendExtra.
  ///
  /// In es, this message translates to:
  /// **'Más espacio'**
  String get legendExtra;

  /// No description provided for @wc.
  ///
  /// In es, this message translates to:
  /// **'WC'**
  String get wc;

  /// No description provided for @exitLabel.
  ///
  /// In es, this message translates to:
  /// **'SALIDA'**
  String get exitLabel;

  /// No description provided for @rowsMore.
  ///
  /// In es, this message translates to:
  /// **'Filas 17–32'**
  String get rowsMore;

  /// No description provided for @extrasTitle.
  ///
  /// In es, this message translates to:
  /// **'Extras para el viaje'**
  String get extrasTitle;

  /// No description provided for @extrasSub.
  ///
  /// In es, this message translates to:
  /// **'Se agregan a todos los vuelos del viaje'**
  String get extrasSub;

  /// No description provided for @initialsPassenger.
  ///
  /// In es, this message translates to:
  /// **'AP'**
  String get initialsPassenger;

  /// No description provided for @reviewPay.
  ///
  /// In es, this message translates to:
  /// **'Revisa y paga'**
  String get reviewPay;

  /// No description provided for @oneWay.
  ///
  /// In es, this message translates to:
  /// **'Solo ida'**
  String get oneWay;

  /// No description provided for @changeLabel.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get changeLabel;

  /// No description provided for @addPromo.
  ///
  /// In es, this message translates to:
  /// **'Agregar código promocional'**
  String get addPromo;

  /// No description provided for @priceDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del precio'**
  String get priceDetail;

  /// No description provided for @taxesLine.
  ///
  /// In es, this message translates to:
  /// **'Impuestos y tasas'**
  String get taxesLine;

  /// No description provided for @seatsLine.
  ///
  /// In es, this message translates to:
  /// **'Asientos'**
  String get seatsLine;

  /// No description provided for @included.
  ///
  /// In es, this message translates to:
  /// **'Incluido'**
  String get included;

  /// No description provided for @totalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @securePayment.
  ///
  /// In es, this message translates to:
  /// **'Pago seguro y cifrado · se cobra en USD'**
  String get securePayment;

  /// No description provided for @confirmingBooking.
  ///
  /// In es, this message translates to:
  /// **'Confirmando tu reserva'**
  String get confirmingBooking;

  /// No description provided for @visaLine.
  ///
  /// In es, this message translates to:
  /// **'Visa •••• 4242'**
  String get visaLine;

  /// No description provided for @visaExpiry.
  ///
  /// In es, this message translates to:
  /// **'Vence 08/29'**
  String get visaExpiry;

  /// No description provided for @bookingConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Reserva confirmada'**
  String get bookingConfirmed;

  /// No description provided for @bookingCode.
  ///
  /// In es, this message translates to:
  /// **'Código de reserva'**
  String get bookingCode;

  /// No description provided for @totalPaid.
  ///
  /// In es, this message translates to:
  /// **'Total pagado'**
  String get totalPaid;

  /// No description provided for @passengerSingle.
  ///
  /// In es, this message translates to:
  /// **'Pasajero'**
  String get passengerSingle;

  /// No description provided for @addToCalendar.
  ///
  /// In es, this message translates to:
  /// **'Agregar al calendario'**
  String get addToCalendar;

  /// No description provided for @viewTrip.
  ///
  /// In es, this message translates to:
  /// **'Ver viaje'**
  String get viewTrip;

  /// No description provided for @backHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get backHome;

  /// No description provided for @copyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get copyCode;

  /// No description provided for @tripDetail.
  ///
  /// In es, this message translates to:
  /// **'Detalle del viaje'**
  String get tripDetail;

  /// No description provided for @confirmedChip.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get confirmedChip;

  /// No description provided for @actCheckIn.
  ///
  /// In es, this message translates to:
  /// **'Check-in'**
  String get actCheckIn;

  /// No description provided for @actBoardingPass.
  ///
  /// In es, this message translates to:
  /// **'Pase de abordar'**
  String get actBoardingPass;

  /// No description provided for @actAfterCheckIn.
  ///
  /// In es, this message translates to:
  /// **'Tras el check-in'**
  String get actAfterCheckIn;

  /// No description provided for @actOpen.
  ///
  /// In es, this message translates to:
  /// **'Abierto'**
  String get actOpen;

  /// No description provided for @actFlightStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado del vuelo'**
  String get actFlightStatus;

  /// No description provided for @actAddBaggage.
  ///
  /// In es, this message translates to:
  /// **'Agregar maleta'**
  String get actAddBaggage;

  /// No description provided for @actChangeSeat.
  ///
  /// In es, this message translates to:
  /// **'Cambiar asiento'**
  String get actChangeSeat;

  /// No description provided for @actFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get actFree;

  /// No description provided for @actTicket.
  ///
  /// In es, this message translates to:
  /// **'Boleto'**
  String get actTicket;

  /// No description provided for @actPdf.
  ///
  /// In es, this message translates to:
  /// **'PDF'**
  String get actPdf;

  /// No description provided for @actOneFlight.
  ///
  /// In es, this message translates to:
  /// **'1 vuelo'**
  String get actOneFlight;

  /// No description provided for @actShareTrip.
  ///
  /// In es, this message translates to:
  /// **'Compartir viaje'**
  String get actShareTrip;

  /// No description provided for @actItinerary.
  ///
  /// In es, this message translates to:
  /// **'Itinerario'**
  String get actItinerary;

  /// No description provided for @actCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actCancel;

  /// No description provided for @actSmallFee.
  ///
  /// In es, this message translates to:
  /// **'Pequeño cargo'**
  String get actSmallFee;

  /// No description provided for @checkInOpenTitle.
  ///
  /// In es, this message translates to:
  /// **'Check-in abierto'**
  String get checkInOpenTitle;

  /// No description provided for @checkInDone.
  ///
  /// In es, this message translates to:
  /// **'Check-in listo. Tu pase de abordar ya está disponible.'**
  String get checkInDone;

  /// No description provided for @myFlights.
  ///
  /// In es, this message translates to:
  /// **'Mis vuelos'**
  String get myFlights;

  /// No description provided for @doCheckIn.
  ///
  /// In es, this message translates to:
  /// **'Hacer check-in'**
  String get doCheckIn;

  /// No description provided for @segUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get segUpcoming;

  /// No description provided for @segPast.
  ///
  /// In es, this message translates to:
  /// **'Pasados'**
  String get segPast;

  /// No description provided for @segCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cancelados'**
  String get segCancelled;

  /// No description provided for @pastToast.
  ///
  /// In es, this message translates to:
  /// **'2 viajes pasados: Cusco y Buenos Aires.'**
  String get pastToast;

  /// No description provided for @cancelledToast.
  ///
  /// In es, this message translates to:
  /// **'1 viaje cancelado y reembolsado.'**
  String get cancelledToast;

  /// No description provided for @flightStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de vuelos'**
  String get flightStatus;

  /// No description provided for @byFlightNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de vuelo'**
  String get byFlightNumber;

  /// No description provided for @byRoute.
  ///
  /// In es, this message translates to:
  /// **'Ruta'**
  String get byRoute;

  /// No description provided for @flightNumberHint.
  ///
  /// In es, this message translates to:
  /// **'Número de vuelo, ej. GA 159'**
  String get flightNumberHint;

  /// No description provided for @yesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get tomorrow;

  /// No description provided for @checkStatus.
  ///
  /// In es, this message translates to:
  /// **'Consultar estado'**
  String get checkStatus;

  /// No description provided for @liveBoard.
  ///
  /// In es, this message translates to:
  /// **'Tablero en vivo'**
  String get liveBoard;

  /// No description provided for @updatedNow.
  ///
  /// In es, this message translates to:
  /// **'Actualizado recién'**
  String get updatedNow;

  /// No description provided for @yourFlights.
  ///
  /// In es, this message translates to:
  /// **'Tus vuelos'**
  String get yourFlights;

  /// No description provided for @liveForTrips.
  ///
  /// In es, this message translates to:
  /// **'En vivo para cada viaje que tienes'**
  String get liveForTrips;

  /// No description provided for @departsInLabel.
  ///
  /// In es, this message translates to:
  /// **'Sale en'**
  String get departsInLabel;

  /// No description provided for @onTime.
  ///
  /// In es, this message translates to:
  /// **'A tiempo'**
  String get onTime;

  /// No description provided for @statusToast.
  ///
  /// In es, this message translates to:
  /// **'GA 159 está a tiempo. Puerta A9.'**
  String get statusToast;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @flyFrom.
  ///
  /// In es, this message translates to:
  /// **'Vuela desde {city} · {code}'**
  String flyFrom(String city, String code);

  /// No description provided for @statTrips.
  ///
  /// In es, this message translates to:
  /// **'Viajes hechos'**
  String get statTrips;

  /// No description provided for @statCities.
  ///
  /// In es, this message translates to:
  /// **'Ciudades'**
  String get statCities;

  /// No description provided for @statUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximos'**
  String get statUpcoming;

  /// No description provided for @groupAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get groupAccount;

  /// No description provided for @personalData.
  ///
  /// In es, this message translates to:
  /// **'Datos personales'**
  String get personalData;

  /// No description provided for @savedPassengers.
  ///
  /// In es, this message translates to:
  /// **'Pasajeros guardados'**
  String get savedPassengers;

  /// No description provided for @paymentMethods.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get paymentMethods;

  /// No description provided for @travelDocs.
  ///
  /// In es, this message translates to:
  /// **'Documentos de viaje'**
  String get travelDocs;

  /// No description provided for @groupPrefs.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get groupPrefs;

  /// No description provided for @flightAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas de vuelo'**
  String get flightAlerts;

  /// No description provided for @seatPref.
  ///
  /// In es, this message translates to:
  /// **'Asiento preferido'**
  String get seatPref;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// No description provided for @groupHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get groupHelp;

  /// No description provided for @helpCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de ayuda'**
  String get helpCenter;

  /// No description provided for @privacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y seguridad'**
  String get privacy;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @versionLabel.
  ///
  /// In es, this message translates to:
  /// **'FlyNow · Versión 1.0.0'**
  String get versionLabel;

  /// No description provided for @airlinesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} aerolíneas'**
  String airlinesCount(int count);

  /// No description provided for @fareCaption.
  ///
  /// In es, this message translates to:
  /// **'1 pasajero · incl. {taxes} de impuestos'**
  String fareCaption(String taxes);

  /// No description provided for @paxCaption.
  ///
  /// In es, this message translates to:
  /// **'1 pasajero · tarifa {fare}'**
  String paxCaption(String fare);

  /// No description provided for @seatCaptionNone.
  ///
  /// In es, this message translates to:
  /// **'Elige un asiento para {name} u omite'**
  String seatCaptionNone(String name);

  /// No description provided for @seatCaptionFree.
  ///
  /// In es, this message translates to:
  /// **'1 asiento · sin costo de asiento'**
  String get seatCaptionFree;

  /// No description provided for @seatCaptionExtra.
  ///
  /// In es, this message translates to:
  /// **'1 asiento · más espacio +{fee}'**
  String seatCaptionExtra(String fee);

  /// No description provided for @payCaptionAccept.
  ///
  /// In es, this message translates to:
  /// **'Acepta los términos para pagar'**
  String get payCaptionAccept;

  /// No description provided for @payCaptionOk.
  ///
  /// In es, this message translates to:
  /// **'1 pasajero · incl. impuestos y tasas'**
  String get payCaptionOk;

  /// No description provided for @fareIncludes.
  ///
  /// In es, this message translates to:
  /// **'{name} incluye'**
  String fareIncludes(String name);

  /// No description provided for @seatNote.
  ///
  /// In es, this message translates to:
  /// **'Los asientos estándar están incluidos en {fare}. Más espacio para las piernas: {fee}.'**
  String seatNote(String fare, String fee);

  /// No description provided for @payButton.
  ///
  /// In es, this message translates to:
  /// **'Pagar {total}'**
  String payButton(String total);

  /// No description provided for @payingDetail.
  ///
  /// In es, this message translates to:
  /// **'Visa •••• 4242 · {total}'**
  String payingDetail(String total);

  /// No description provided for @economyFare.
  ///
  /// In es, this message translates to:
  /// **'Económica {fare}'**
  String economyFare(String fare);

  /// No description provided for @agreeText.
  ///
  /// In es, this message translates to:
  /// **'Acepto las reglas de la tarifa {fare}, las condiciones de transporte y la política de mercancías peligrosas.'**
  String agreeText(String fare);

  /// No description provided for @seatWord.
  ///
  /// In es, this message translates to:
  /// **'Asiento {seat}'**
  String seatWord(String seat);

  /// No description provided for @seatSemanticsExtra.
  ///
  /// In es, this message translates to:
  /// **'Asiento {seat}, más espacio'**
  String seatSemanticsExtra(String seat);

  /// No description provided for @seatSemanticsTaken.
  ///
  /// In es, this message translates to:
  /// **'Asiento {seat} ocupado'**
  String seatSemanticsTaken(String seat);

  /// No description provided for @yourFlightDate.
  ///
  /// In es, this message translates to:
  /// **'Tu vuelo · {date}'**
  String yourFlightDate(String date);

  /// No description provided for @yourFlightLine.
  ///
  /// In es, this message translates to:
  /// **'Tu vuelo · {date} · {flight}'**
  String yourFlightLine(String date, String flight);

  /// No description provided for @ticketsTo.
  ///
  /// In es, this message translates to:
  /// **'Boletos a {email}'**
  String ticketsTo(String email);

  /// No description provided for @ticketsOnWay.
  ///
  /// In es, this message translates to:
  /// **'Los boletos de todos van en camino a {email}'**
  String ticketsOnWay(String email);

  /// No description provided for @oneWayFareSummary.
  ///
  /// In es, this message translates to:
  /// **'Solo ida · {fare} · 1 pasajero'**
  String oneWayFareSummary(String fare);

  /// No description provided for @oneWayDateFare.
  ///
  /// In es, this message translates to:
  /// **'Solo ida · {date} · {fare}'**
  String oneWayDateFare(String date, String fare);

  /// No description provided for @departsIn.
  ///
  /// In es, this message translates to:
  /// **'Sale en {time}'**
  String departsIn(String time);

  /// No description provided for @closesOn.
  ///
  /// In es, this message translates to:
  /// **'Cierra el {date}'**
  String closesOn(String date);

  /// No description provided for @checkInClosesOn.
  ///
  /// In es, this message translates to:
  /// **'El check-in online cierra el {date}'**
  String checkInClosesOn(String date);

  /// No description provided for @fromPrice.
  ///
  /// In es, this message translates to:
  /// **'Desde {price}'**
  String fromPrice(String price);

  /// No description provided for @tripsCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 viaje} other{{count} viajes}}'**
  String tripsCount(int count);

  /// No description provided for @extraPrice.
  ///
  /// In es, this message translates to:
  /// **'+{price}'**
  String extraPrice(String price);

  /// No description provided for @freeSeats.
  ///
  /// In es, this message translates to:
  /// **'{count} libres'**
  String freeSeats(int count);

  /// No description provided for @fareLine.
  ///
  /// In es, this message translates to:
  /// **'Tarifa {fare}'**
  String fareLine(String fare);

  /// No description provided for @headlineTrip.
  ///
  /// In es, this message translates to:
  /// **'¡Te vas a {city}!'**
  String headlineTrip(String city);

  /// No description provided for @seatFeeAria.
  ///
  /// In es, this message translates to:
  /// **'Elige un asiento'**
  String get seatFeeAria;

  /// No description provided for @chooseOrigin.
  ///
  /// In es, this message translates to:
  /// **'Elige el origen'**
  String get chooseOrigin;

  /// No description provided for @chooseDestination.
  ///
  /// In es, this message translates to:
  /// **'Elige el destino'**
  String get chooseDestination;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppL10nEs();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
