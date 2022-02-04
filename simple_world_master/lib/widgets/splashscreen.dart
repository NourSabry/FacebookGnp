import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/constant/constant.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:simpleworld/widgets/bezier_containernew.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_World_Widgets.dart';

class SplashScreen extends StatefulWidget {
  final String? userId;

  const SplashScreen({Key? key, this.userId}) : super(key: key);
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var _duration = Duration(seconds: 1);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(APP_SCREEN);
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
    startTime();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Simple World',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _welcomenote() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Simple World',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Username() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _welcomenote(),
            Text(
              user!.username.capitalize(),
              style: boldTextStyle(),
            ),
          ],
        );
      },
    );
  }

  Widget _logoWidget() {
    return Column(
      children: <Widget>[
        Container(
          child: Center(
            child: Stack(children: <Widget>[
              Image.asset(
                'assets/icon.png',
                width: 100.0,
                height: 100.0,
              ),
            ]),
          ),
          width: double.infinity,
          margin: const EdgeInsets.all(20.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: const BezierContainer(),
              ),
              Positioned(
                bottom: -MediaQuery.of(context).size.height * .15,
                left: -MediaQuery.of(context).size.width * .4,
                child: const BezierContainernew(),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _title(),
                      _logoWidget(),
                      const SizedBox(
                        height: 20,
                      ),
                      // Username(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
