import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simpleworld/config/palette.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/share_preference/preferences_key.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class App extends StatefulWidget {
  final SharedPreferences prefs;
  final AdaptiveThemeMode? savedThemeMode;

  const App(this.prefs, this.savedThemeMode, {Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setnotification();
  }

  setnotification() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.red,
          primaryColor: Palette.primaryColor,
          primaryColorDark: Colors.white,
          canvasColor: Colors.transparent,
          disabledColor: Palette.menuBackgroundColor,
          backgroundColor: Palette.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: Palette.appbarbackgroundColor,
            actionsIconTheme: IconThemeData(
              color: Palette.appbariconcolor,
            ),
            iconTheme: IconThemeData(
              color: Palette.appbariconcolor,
              size: 24,
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            brightness: Brightness.dark,
          ),
          tabBarTheme: const TabBarTheme(
            labelColor: Palette.tabbarlabelColor,
            unselectedLabelColor: Palette.tabbarunselectedLabelColor,
          ),
          iconTheme: const IconThemeData(color: Palette.iconThemeColor),
          scaffoldBackgroundColor: Palette.scaffoldBackgroundColor,
          textTheme: TextTheme(
            headline4: GoogleFonts.portLligatSans(
              textStyle: Theme.of(context).textTheme.headline4,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Palette.apptitlecolor,
            ),
          ),
          cardColor: Palette.cardColor,
          shadowColor: Palette.shadowColor,
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Palette.inputfillcolor,
          ),
          secondaryHeaderColor: Palette.secondaryHeaderColor),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        backgroundColor: Palette.backgroundColordark,
        disabledColor: Palette.scaffoldBackgroundColordark,
        secondaryHeaderColor: Palette.secondaryHeaderColorDark,
        appBarTheme: const AppBarTheme(
          actionsIconTheme: IconThemeData(
            color: Palette.appbariconcolordark,
          ),
          backgroundColor: Palette.appbarbackgroundColordark,
          iconTheme:
              IconThemeData(color: Palette.appbariconcolordark, size: 24),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          brightness: Brightness.light,
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Palette.tabbarlabelColordark,
          unselectedLabelColor: Palette.tabbarunselectedLabelColordark,
        ),
        iconTheme: const IconThemeData(color: Palette.iconThemeColordark),
        scaffoldBackgroundColor: Palette.scaffoldBackgroundColordark,
        textTheme: TextTheme(
          headline4: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Palette.apptitlecolordark,
          ),
        ),
        cardColor: Palette.cardColordark,
        shadowColor: Palette.shadowColordark,
        inputDecorationTheme: const InputDecorationTheme(
          fillColor: Palette.inputfillcolordark,
        ),
      ),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Simple World',
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        home: _handleCurrentScreen(widget.prefs),
      ),
    );
  }

  Widget _handleCurrentScreen(SharedPreferences prefs) {
    String? data = prefs.getString(SharedPreferencesKey.LOGGED_IN_USERRDATA);
    preferences = prefs;

    if (data == null) {
      return const LoginPage();
    } else {
      return Home(
        userId: data,
      );
    }
  }
}
