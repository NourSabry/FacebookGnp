import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/auth/signup_page2.dart';
import 'package:simpleworld/share_preference/preferences_key.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late String userId;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpassController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left,
                  color: Theme.of(context).iconTheme.color),
            ),
            const Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      TextInputAction textInputAction,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              textInputAction: textInputAction,
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red.shade500, Colors.red.shade900])),
      child: const Text(
        'Register Now',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      RegExp regex = RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
      if (passwordController.text != '' &&
          nameController.text != '' &&
          regex.hasMatch(emailController.text.trim()) &&
          emailController.text.trim() != '' &&
          passwordController.text.length > 5) {
        _register();
      } else {
        simpleAlertBox(
            content: const Text(
                "Fields is empty or password length should be between 6-8 characters."),
            context: context);
      }
    });
  }

  Future<void> _register() async {
    try {
      setState(() {
        isLoading = true;
      });
      final valid = await usernameCheck(nameController.text);
      if (!valid) {
        setState(() {
          isLoading = false;
        });
        simpleworldtoast("Error", "Username is taken ", context);
      } else {
        final User? user = (await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        ))
            .user;
        if (user != null) {
          createUserInFirestore(user.uid, user.email);
        } else {
          setState(() {
            isAuth = false;
            isLoading = false;
          });
          simpleworldtoast(
              "Error", "Something went wrong please try again ", context);
        }
      }
    } catch (e) {
      setState(() {
        isAuth = false;
        isLoading = false;
      });
      // print(e.toString());
      simpleworldtoast("Error",
          "The email address is already in use by anoter account", context);
    }
  }

  Future<bool> usernameCheck(String username) async {
    final result = await usersRef.where('username', isEqualTo: username).get();
    return result.docs.isEmpty;
  }

  createUserInFirestore(userId, email) async {
    User? user = firebaseAuth.currentUser;
    DocumentSnapshot doc = await usersRef.doc(user!.uid).get();

    if (!doc.exists) {
      usersRef.doc(userId).set({
        "id": userId,
        "username": nameController.text,
        "photoUrl": '',
        "email": email,
        "displayName": nameController.text,
        "bio": "",
        "coverUrl": "",
        "timestamp": timestamp
      });
      await followersRef
          .doc(userId)
          .collection('userFollowers')
          .doc(userId)
          .set({});

      doc = await usersRef.doc(userId).get();
    }

    currentUser = GloabalUser.fromDocument(doc);

    setState(() {
      globalID = userId;
      isLoading = false;
      isAuth = true;
    });

    configurePushNotifications(userId);
    if (isAuth = true) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
            builder: (context) => GetAvatar(
                  currentUserId: userId,
                )),
      );
    }
  }

  configurePushNotifications(userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences
        .setString(SharedPreferencesKey.LOGGED_IN_USERRDATA, userId)
        .then((value) {
      _firebaseMessaging.getToken().then((token) {
        // print("Firebase Messaging Token: $token\n");
        usersRef.doc(userId).update({"androidNotificationToken": token});
      });
    });

    FirebaseMessaging.onMessage.listen(
      (message) async {
        final String recipientId = userId;
        final String body = message.notification?.body ?? '';

        if (recipientId == userId) {
          // print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      },
    );
  }

  Widget _loginAccount() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username", nameController, TextInputAction.next),
        _entryField("Email id", emailController, TextInputAction.next),
        _entryField("Password", passwordController, TextInputAction.next,
            isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    const SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    const SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    _loginAccount(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
