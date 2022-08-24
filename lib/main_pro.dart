import 'dart:async';

// import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gogo_pharma/common/font_style.dart';
import 'package:gogo_pharma/common/route_generator.dart';
import 'package:gogo_pharma/services/firebase_analytics_services.dart';
import 'package:gogo_pharma/services/firebase_messaging_services.dart';
import 'package:gogo_pharma/services/flavour_config.dart';
import 'package:gogo_pharma/utils/color_palette.dart';
import 'package:gogo_pharma/utils/multi_provider_list.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

void main() async {
  FlavourConstants.setEnvironment(Environment.prod);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runZonedGuarded(() async {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    runApp(
      // DevicePreview(
      //   enabled: true,
      //   builder: (context) =>
        const MyApp());
    // );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: MultiProviderList.providerList,
      child: OverlaySupport.global(
          toastTheme:
          ToastThemeData(textColor: Colors.white, background: Colors.black),
          child: MaterialApp(
            title: 'Gogo Pharma',
            debugShowCheckedModeBanner: false,
            navigatorObservers: [
              FirebaseAnalyticsService.appAnalyticsObserver()
            ],
            theme: ThemeData(
                primarySwatch: ColorPalette.materialPrimary,
                fontFamily: FontStyle.themeFont,
                brightness: Brightness.light,
                appBarTheme: const AppBarTheme(
                    systemOverlayStyle: SystemUiOverlayStyle(
                        systemNavigationBarIconBrightness: Brightness.light,
                        statusBarIconBrightness: Brightness.light,
                        statusBarBrightness: Brightness.dark)),
                textSelectionTheme:
                const TextSelectionThemeData(cursorColor: Colors.black)),
            onGenerateRoute: (settings) =>
                RouteGenerator().generateRoute(settings),
          )),
    );
  }
}
