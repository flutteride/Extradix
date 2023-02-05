//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:thinkcreative_technologies/Configs/db_keys.dart';
import 'package:thinkcreative_technologies/Configs/Dbpaths.dart';
import 'package:thinkcreative_technologies/Configs/enum.dart';
import 'package:thinkcreative_technologies/Configs/MyRegisteredFonts.dart';
import 'package:thinkcreative_technologies/Configs/app_constants.dart';
import 'package:thinkcreative_technologies/Configs/optional_constants.dart';
import 'package:thinkcreative_technologies/Localization/app_localization_for_current_user.dart';
import 'package:thinkcreative_technologies/Localization/app_localization_for_events_and_alerts.dart';
import 'package:thinkcreative_technologies/Models/ticket_model.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialization_constant.dart';
import 'package:thinkcreative_technologies/Screens/splash_screen/splash_screen.dart';
import 'package:thinkcreative_technologies/Services/Providers/BottomNavigationBarProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/BroadcastProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/GroupChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/Observer.dart';
import 'package:thinkcreative_technologies/Services/Providers/TicketChatProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/TimerProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/currentchat_peer.dart';
import 'package:thinkcreative_technologies/Services/Providers/exploreProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/liveListener.dart';
import 'package:thinkcreative_technologies/Services/Providers/seen_provider.dart';
import 'package:thinkcreative_technologies/Services/Providers/user_registry_provider.dart';
import 'package:thinkcreative_technologies/Localization/language_constants.dart';
import 'package:thinkcreative_technologies/Services/Providers/DownloadInfoProvider.dart';
import 'package:thinkcreative_technologies/Services/Providers/call_history_provider.dart';
import 'package:thinkcreative_technologies/Screens/initialization/initialize.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thinkcreative_technologies/Configs/my_colors.dart';

List<CameraDescription> cameras = <CameraDescription>[];
void main() async {
  // if (DESIGN_TYPE == Themetype.messenger) {
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //       statusBarColor:
  //           Color(0XFFFFFFFF), //or set color with: Color(0xFF0000FF)
  //       statusBarIconBrightness: Brightness.dark));
  // }

  WidgetsFlutterBinding.ensureInitialized();
  if (IsBannerAdShow == true ||
      IsInterstitialAdShow == true ||
      IsVideoAdShow == true) {
    MobileAds.instance.initialize();
  }

  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  binding.renderView.automaticSystemUiAdjustment = false;
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(OverlaySupport(
        child: AppWrapper(
      loadAttempt: 0,
    )));
  });
}

class AppWrapper extends StatefulWidget {
  final int loadAttempt;
  const AppWrapper({Key? key, required this.loadAttempt}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _AppWrapperState state =
        context.findAncestorStateOfType<_AppWrapperState>()!;
    state.setLocale(newLocale);
  }

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void didChangeDependencies() {
    getLocaleForUsers().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
    final FirebaseTicketServices firebaseTicketServices =
        FirebaseTicketServices();
    final FirebaseBroadcastServices firebaseBroadcastServices =
        FirebaseBroadcastServices();
    final FirebaseLiveDataServices firebaseLiveDataServices =
        FirebaseLiveDataServices();
    if (this._locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splashscreen(),
      );
    } else {
      return FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(
                'ERROR OCCURED WHILE INITIALIZING FIREBASE',
                textDirection: TextDirection.ltr,
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder:
                      (context, AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(create: (_) => UserRegistry()),
                          ChangeNotifierProvider(
                              create: (_) => BottomNavigationBarProvider()),
                          ChangeNotifierProvider(
                              create: (_) => ExploreProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE()),
                          ChangeNotifierProvider(
                              create: (_) => TimerProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforTICKETCHAT()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforGROUPCHAT()),
                          ChangeNotifierProvider(create: (_) => Observer()),
                          Provider(create: (_) => SeenProvider()),
                          ChangeNotifierProvider(
                              create: (_) => DownloadInfoprovider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderCALLHISTORY()),
                          ChangeNotifierProvider(
                              create: (_) => CurrentChatPeer()),
                        ],
                        child: StreamProvider<List<BroadcastModel>>(
                          initialData: [],
                          create: (BuildContext context) =>
                              firebaseBroadcastServices.getBroadcastsList(
                                  uid: snapshot.data!.getString(Dbkeys.id)),
                          child: StreamProvider<List<GroupModel>>(
                            initialData: [],
                            create: (BuildContext context) =>
                                firebaseGroupServices.getGroupsList(
                                    uid: snapshot.data!.getString(Dbkeys.id)),
                            child: StreamProvider<List<TicketModel>>(
                              initialData: [],
                              create: (BuildContext context) =>
                                  firebaseTicketServices.getTicketsList(
                                      snapshot.data!.getString(Dbkeys.phone) ??
                                          ''),
                              child: StreamProvider<SpecialLiveConfigData?>(
                                create: (BuildContext context) =>
                                    firebaseLiveDataServices.getLiveData(
                                        FirebaseFirestore.instance
                                            .collection(DbPaths.userapp)
                                            .doc(DbPaths.collectionconfigs)),
                                initialData: null,
                                catchError: (context, e) {
                                  return SpecialLiveConfigData.fromJson({});
                                },
                                child: MaterialApp(
                                  builder:
                                      (BuildContext? context, Widget? widget) {
                                    ErrorWidget.builder =
                                        (FlutterErrorDetails errorDetails) {
                                      return CustomError(
                                          errorDetails: errorDetails);
                                    };

                                    return widget!;
                                  },
                                  theme: ThemeData(
                                      fontFamily: MyRegisteredFonts.regular,
                                      primaryColor: Mycolors.primary,
                                      primaryColorLight: Mycolors.primary,
                                      indicatorColor: Mycolors.secondary),
                                  title: Appname,
                                  debugShowCheckedModeBanner: false,

                                  home: Initialize(
                                      loadAttempt: widget.loadAttempt,
                                      app: InitializationConstant.k11,
                                      doc: InitializationConstant.k9,
                                      prefs: snapshot.data!,
                                      iscustomer: snapshot.data!.getInt(
                                                      Dbkeys.userLoginType) ==
                                                  null ||
                                              snapshot.data!.getInt(
                                                      Dbkeys.userLoginType) ==
                                                  Usertype.customer.index
                                          ? true
                                          : false),

                                  // ignore: todo
                                  //TODO:---- All localizations settings----
                                  locale: _locale,
                                  supportedLocales: supportedlocale,
                                  localizationsDelegates: [
                                    AppLocalizationForCurrentUser.delegate,
                                    AppLocalizationForEventsAndAlerts.delegate,
                                    GlobalMaterialLocalizations.delegate,
                                    GlobalWidgetsLocalizations.delegate,
                                    GlobalCupertinoLocalizations.delegate,
                                  ],
                                  localeResolutionCallback:
                                      (locale, supportedLocales) {
                                    for (var supportedLocale
                                        in supportedLocales) {
                                      if (supportedLocale.languageCode ==
                                              locale!.languageCode &&
                                          supportedLocale.countryCode ==
                                              locale.countryCode) {
                                        return supportedLocale;
                                      }
                                    }
                                    return supportedLocales.first;
                                  },
                                  //--- All localizations settings ended here----
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return MaterialApp(
                        theme: ThemeData(
                            fontFamily: MyRegisteredFonts.regular,
                            primaryColor: Mycolors.primary,
                            primaryColorLight: Mycolors.primary,
                            indicatorColor: Mycolors.secondary),
                        debugShowCheckedModeBanner: false,
                        home: Splashscreen());
                  });
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Splashscreen(),
            );
          });
    }
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
      width: 0,
    );
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
