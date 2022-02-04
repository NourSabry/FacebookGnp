// ignore_for_file: unnecessary_this

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/create_post/post_box.dart';
import 'package:simpleworld/pages/chat/simpleworld_chat.dart';
import 'package:simpleworld/pages/edit_profile.dart';
import 'package:simpleworld/story/add_story.dart';
import 'package:simpleworld/widgets/header.dart';
import 'package:simpleworld/widgets/multi_manager/flick_multi_manager.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/single_post.dart';

class Profile extends StatefulWidget {
  final String? profileId;
  final List<Reaction<String>> reactions;

  const Profile({
    this.profileId,
    required this.reactions,
  });

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String? currentUserId = globalID;
  String postOrientation = "list";
  bool isFollowing = false;
  bool isLoading = false;
  int postCount = 0;
  int followerCount = 0;
  int followingCount = 0;
  final ImagePicker _picker = ImagePicker();
  File? storyfile;
  File? imageFileAvatar;
  File? imageFileCover;
  String? imageFileAvatarUrl;
  String? imageFileCoverUrl;
  bool showHeart = false;
  late FlickMultiManager flickMultiManager;
  List<SinglePost> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    flickMultiManager = FlickMultiManager();
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    setState(() {
      followerCount = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    setState(() {
      followingCount = snapshot.docs.length;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .doc(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => SinglePost.fromDocument(doc)).toList();
    });
  }

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (mounted) {
      setState(() async {
        this.storyfile = storyfile;
        if (pickedFile != null) {
          storyfile = File(pickedFile.path);

          await navigator.push(MaterialPageRoute(
              builder: (context) => AddStory(
                  // file: storyfile!,
                  )));
        } else {
          // print('No image selected.');
        }
      });
    }
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildProfileButton() {
    double maxWidth = MediaQuery.of(context).size.width * 0.4;

    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Add Story',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ).onTap(
            () {
              handleChooseFromGallery();
            },
          ),
          const SizedBox(width: 10),
          Container(
            margin: const EdgeInsets.only(top: 10.0),
            height: 38,
            width: maxWidth,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: const Center(
              child: Text(
                'Edit Profile',
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
            () {
              editProfile();
            },
          )
        ],
      );
    } else if (isFollowing) {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 38,
        width: (context.width() - (3 * 16)) * 0.4,
        decoration: BoxDecoration(
          color: Colors.redAccent[700],
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: const Center(
          child: Text(
            'Unfollow',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ).onTap(() {
        handleUnfollowUser();
      });
    } else if (!isFollowing) {
      return Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 38,
        width: (context.width() - (3 * 16)) * 0.4,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
        ),
        child: const Center(
          child: Text(
            'Follow',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ).onTap(() {
        handleFollowUser();
      });
    }
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});
    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    activityFeedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser!.username,
      "userId": currentUserId,
      "userProfileImg": currentUser!.photoUrl,
      "timestamp": timestamp,
      "isSeen": false,
    });
  }

  Future getavatarImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileAvatar = imageFileAvatar;
      if (newImageFile != null) {
        imageFileAvatar = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadAvatar(imageFileAvatar);
  }

  Future uploadAvatar(imageFileAvatar) async {
    String mFileName = globalID!;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("avatar_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileAvatar!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileAvatarUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef.doc(widget.profileId).update({"photoUrl": imageFileAvatarUrl});

      SnackBar snackbar =
          const SnackBar(content: Text("Profile Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  Future getcoverImage() async {
    final newImageFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      this.imageFileCover = imageFileCover;
      if (newImageFile != null) {
        imageFileCover = File(newImageFile.path);
        // print(newImageFile.path);
      } else {
        // print('No image selected.');
      }
    });

    uploadCover(imageFileCover);
  }

  Future uploadCover(imageFileCover) async {
    String mFileName = globalID!;
    Reference storageReference =
        FirebaseStorage.instance.ref().child("cover_$mFileName.jpg");
    UploadTask storageUploadTask = storageReference.putFile(imageFileCover!);
    String downloadUrl = await (await storageUploadTask).ref.getDownloadURL();
    imageFileCoverUrl = downloadUrl;
    setState(() {
      isLoading = false;
      usersRef.doc(widget.profileId).update({"coverUrl": imageFileCoverUrl});

      SnackBar snackbar = const SnackBar(content: Text("Cover Photo updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
  }

  buildProfileHeader() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FutureBuilder<GloabalUser?>(
        future: GloabalUser.fetchUser(widget.profileId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          final user = snapshot.data;
          final bool isProfileOwner = currentUserId == widget.profileId;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(children: <Widget>[
                (imageFileCover == null)
                    ? user!.coverUrl.isEmpty
                        ? Image.asset(
                            'assets/images/defaultcover.png',
                            alignment: Alignment.center,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            height: 200,
                          )
                        : circularProgress()
                    : Material(
                        child: Image.file(
                          imageFileCover!,
                          width: double.infinity,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        clipBehavior: Clip.hardEdge,
                      ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: CachedNetworkImageProvider(user!.coverUrl,
                            scale: 1.0),
                        fit: BoxFit.cover),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Container(
                      alignment: const Alignment(0.0, 2.5),
                      child: Stack(
                        children: [
                          (imageFileAvatar == null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: user.photoUrl == null ||
                                          user.photoUrl.isEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF003a54),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Image.asset(
                                            'assets/images/defaultavatar.png',
                                            width: 120,
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: user.photoUrl,
                                          height: 120,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        ),
                                )
                              : Material(
                                  child: Image.file(
                                    imageFileAvatar!,
                                    width: 120.0,
                                    height: 120.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                          isProfileOwner
                              ? SvgPicture.asset(
                                  'assets/images/photo.svg',
                                  width: 40,
                                ).onTap(() {
                                  getavatarImage();
                                })
                              : const Text(''),
                        ],
                      ),
                    ),
                  ),
                ),
                isProfileOwner
                    ? Positioned(
                        bottom: 0,
                        right: 0,
                        child: SvgPicture.asset(
                          'assets/images/photo.svg',
                          width: 40,
                        ).onTap(() {
                          getcoverImage();
                        }))
                    : const Text(''),
              ]),
              const SizedBox(height: 70),
              Text(
                user.username.capitalize(),
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(fontSize: 16),
              ),
              const SizedBox(height: 3),
              Text(user.bio,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildProfileButton(),
                  const SizedBox(width: 10),
                  if (!isProfileOwner)
                    Container(
                      margin: const EdgeInsets.only(top: 10.0),
                      height: 38,
                      width: (context.width() - (3 * 16)) * 0.4,
                      decoration: const BoxDecoration(
                        color: Color(0xffE5E6EB),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Message',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ).onTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            receiverId: user.id,
                            receiverAvatar: user.photoUrl,
                            receiverName: user.username,
                            key: null,
                          ),
                        ),
                      );
                    }),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    buildCountColumn("Posts", postCount),
                    buildCountColumn("Followers", followerCount),
                    buildCountColumn("Following", followingCount),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              PostBox(currentUser: currentUser),
              buildProfilePosts()
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: header(
        context,
        titleText: "Profile",
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            buildProfileHeader(),
          ],
        ),
      ),
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_content.svg',
            height: 260.0,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "No Posts",
              style: TextStyle(
                color: Colors.red,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (postOrientation == "list") {
      return Column(
        children: posts,
      );
    }
  }
}
