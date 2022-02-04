// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/login_page.dart';
import 'package:simpleworld/pages/create_post/pdf_upload.dart';
import 'package:simpleworld/pages/create_post/upload.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simpleworld/pages/create_post/video_upload.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

class AddPost extends StatefulWidget {
  final GloabalUser? currentUser;

  const AddPost({Key? key, this.currentUser}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost>
    with AutomaticKeepAliveClientMixin<AddPost> {
  Color? mainColor = Colors.deepPurple[400];
  final ImagePicker _picker = ImagePicker();
  TextEditingController captionController = TextEditingController();
  bool isLoading = false;
  File? vediofile;
  File? newvediofile;
  File? pdffile;
  File? file;
  bool isUploading = false;
  String postId = const Uuid().v4();
  List<XFile>? _imageFileList;

  Future handleChooseFromGallery() async {
    final navigator = Navigator.of(context);

    final pickedFileList = await _picker.pickMultiImage(imageQuality: 50);

    if (mounted) {
      setState(() async {
        _imageFileList = pickedFileList;
        if (pickedFileList != null) {
          await navigator.push(MaterialPageRoute(
              builder: (context) => Upload(
                    currentUser: currentUser,
                    imageFileList: _imageFileList,
                  )));
        } else {}
      });
    }
  }

  Future selectVideoFile() async {
    final navigator = Navigator.of(context);
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);

    if (mounted) {
      setState(() async {
        vediofile = vediofile;
        if (pickedFile != null) {
          vediofile = File(pickedFile.path);
          print(vediofile);
          await VideoCompress.setLogLevel(0);
          final MediaInfo? info = await VideoCompress.compressVideo(
            vediofile!.path,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          print(info!.path);
          if (info != null) {
            setState(() {
              newvediofile = File(info.path!);
            });
          }
          int size = newvediofile!.lengthSync();
          double sizeInMb = size / (1024 * 1024);
          if (sizeInMb > 5) {
            simpleworldtoast("", "File Size is larger then 5mb", context);
            return;
          }
          await navigator.push(MaterialPageRoute(
              builder: (context) => VideoUpload(
                  currentUser: currentUser,
                  file: newvediofile!,
                  videopath: pickedFile.path)));
        } else {
          // print('No image selected.');
        }
      });
    }
  }

  Future selectPDFFile() async {
    final navigator = Navigator.of(context);
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;
    final path = result.files.single.path!;

    String fileName = result.files.first.name;

    setState(() async {
      pdffile = File(path);
      if (result != null) {
        pdffile = File(path);
        int size = pdffile!.lengthSync();
        String pdfsize = "$size";
        double sizeInMb = size / (1024 * 1024);
        if (sizeInMb > 5) {
          simpleworldtoast("", "File Size is larger then 5mb", context);
          return;
        }
        await navigator.push(MaterialPageRoute(
            builder: (context) => PdfUpload(
                  currentUser: currentUser,
                  file: pdffile!,
                  pdfpath: path,
                  pdfname: fileName,
                  pdfsize: pdfsize,
                )));
      } else {
        // print('No image selected.');
      }
    });
  }

  createPostInFirestore({List? mediaUrl, String? description, int? type}) {
    postsRef.doc(globalID).collection("userPosts").doc(postId).set({
      "postId": postId,
      "ownerId": globalID,
      "username": globalName,
      "mediaUrl": mediaUrl,
      "description": description,
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
      "videoUrl": '',
      "pdfUrl": '',
      "pdfsize": '',
      "pdfName": '',
      "type": 'text',
    });
  }

  handleSubmitontext() async {
    createPostInFirestore(mediaUrl: [], description: captionController.text);
    captionController.clear();

    if (mounted) {
      setState(() {
        postId = const Uuid().v4();
        FocusScope.of(context).unfocus();
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
              builder: (context) => Home(
                    userId: globalID,
                  )),
        );
      });
    }
  }

  buildPostBox() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).shadowColor,
            width: 1.0,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Create Post',
                  style: Theme.of(context).textTheme.headline5!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width * 0.25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.red.shade500, Colors.red.shade900])),
            child: const Text(
              'Post',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ).onTap(() {
            if (captionController.text != '') {
              setState(() {
                isLoading = true;
              });

              handleSubmitontext();
            } else {
              simpleworldtoast("Error", "Write something", context);
            }
          })
        ],
        elevation: 0.0,
      ),
      body: Card(
        margin: const EdgeInsets.symmetric(horizontal: 0.0),
        elevation: 0.0,
        shape: isDesktop
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))
            : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
          child: Column(
            children: [
              ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: globalImage == null || globalImage!.isEmpty
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF003a54),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Image.asset(
                            'assets/images/defaultavatar.png',
                            width: 50,
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: globalImage!,
                          height: 50.0,
                          width: 50.0,
                          fit: BoxFit.cover,
                        ),
                ),
                title: Text(
                  globalName!.capitalize(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                        controller: captionController,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            hintText: 'What\'s on your mind?',
                            border: InputBorder.none,
                            filled: true)),
                  ),
                  const SizedBox(width: 8.0),
                ],
              ),
              const Divider(height: 10.0, thickness: 0.5),
              SizedBox(
                height: 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => handleChooseFromGallery(),
                      icon: const Icon(
                        Icons.photo_library,
                        color: Colors.green,
                      ),
                      label: Text(
                        'Photo',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    const VerticalDivider(width: 8.0),
                    TextButton.icon(
                      onPressed: () => selectVideoFile(),
                      icon: const Icon(
                        Icons.videocam,
                        color: Colors.red,
                      ),
                      label: Text(
                        'Video',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    const VerticalDivider(width: 8.0),
                    TextButton.icon(
                      onPressed: () => selectPDFFile(),
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.purpleAccent,
                      ),
                      label: Text(
                        'PDF',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return buildPostBox();
  }
}
