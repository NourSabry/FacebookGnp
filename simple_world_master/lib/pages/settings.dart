import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/activity_feed.dart';
import 'package:simpleworld/pages/chat/simpleworld_chat_main.dart';
import 'package:simpleworld/pages/menu/all_pdfs.dart';
import 'package:simpleworld/pages/menu/all_stories.dart';
import 'package:simpleworld/pages/comming_soon_page.dart';
import 'package:simpleworld/pages/menu/discover.dart';
import 'package:simpleworld/pages/all_videos.dart';
import 'package:simpleworld/pages/edit_profile.dart';
import 'package:simpleworld/pages/menu/help_support.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/users.dart';
import 'package:simpleworld/share_preference/preferences_key.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/data/reaction_data.dart' as Reaction;

class SettingsPage extends StatefulWidget {
  final String? currentUserId;

  const SettingsPage({Key? key, this.currentUserId}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late GloabalUser user;
  bool isLoading = false;

  File? imageFileAvatar;
  String? imageFileAvatarUrl;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = GloabalUser.fromDocument(doc);

    setState(() {
      isLoading = false;
    });
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<void> _signOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final mode = AdaptiveTheme.of(context).mode;
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).disabledColor,
        key: _scaffoldKey,
        appBar: header(context, titleText: "Menu", removeBackButton: true),
        body: isLoading
            ? circularProgress()
            : ListView(children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              user.photoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: user.photoUrl,
                                        height: 40,
                                        width: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF003a54),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Image.asset(
                                        'assets/images/defaultavatar.png',
                                        width: 40,
                                      ),
                                    ),
                              const SizedBox(height: 5.0),
                              Text(globalName!.capitalize(),
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        showProfile(context, profileId: globalID);
                      }),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/images/messenger.svg",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Messenger',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const SimpleWorldChat(),
                            ));
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/images/recent_useers.svg",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Recent Users',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => UsersList(),
                            ));
                      }),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SvgPicture.asset(
                                "assets/images/edit.svg",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Edit Profile',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => EditProfile(
                                currentUserId: globalID,
                              ),
                            ));
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/earth.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Discover',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => Discover(UserId: globalID),
                            ));
                      }),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/open_book.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Stories',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AllStories(
                                showappbar: true,
                              ),
                            ));
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/play_button.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Videos',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AllVideos(
                                UserId: globalID,
                                reactions: Reaction.reactions,
                              ),
                            ));
                      }),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/documents.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Documents',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AllPdfs(
                                UserId: globalID,
                                reactions: Reaction.reactions,
                              ),
                            ));
                      }),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/compliant.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Help & Support',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => HelpSupportPage(
                                currentUserId: widget.currentUserId,
                              ),
                            ));
                      }),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 30,
                          height: 85.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/delete_user.png",
                                width: 40,
                              ),
                              const SizedBox(height: 5.0),
                              const Text('Deactivate Account',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold))
                            ],
                          ),
                        ),
                      ).onTap(() {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => CommimgSoon(),
                            ));
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (mode == AdaptiveThemeMode.light) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                    },
                    icon: mode == AdaptiveThemeMode.light
                        ? const Icon(Icons.light_mode)
                        : const Icon(Icons.dark_mode),
                    label: mode == AdaptiveThemeMode.light
                        ? const Text('Set Dark')
                        : const Text('Set Light'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 38),
                      maximumSize: const Size(100, 38),
                    ),
                  ),
                ),
                ListTile(
                  title: Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    height: 38,
                    width: (MediaQuery.of(context).size.width * 0.4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Logout',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ).onTap(
                    () async {
                      _signOut().then((value) async {
                        SharedPreferences preferences =
                            await SharedPreferences.getInstance();
                        preferences
                            .remove(SharedPreferencesKey.LOGGED_IN_USERRDATA)
                            .then((_) async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        });
                      });
                    },
                  ),
                ),
              ]),
      ),
    );
  }
}
