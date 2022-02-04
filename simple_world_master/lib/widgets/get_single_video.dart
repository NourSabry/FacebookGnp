import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/post_screen.dart';
import 'package:simpleworld/pages/post_screen_album.dart';
import 'package:simpleworld/widgets/_build_list.dart';
import 'package:video_player/video_player.dart';

class GetSingleVideo extends StatefulWidget {
  final String? videopath;
  final String? postId;
  final String? ownerId;

  const GetSingleVideo({
    Key? key,
    this.videopath,
    this.postId,
    this.ownerId,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  GetSingleVideoState createState() => GetSingleVideoState(
        videopath: videopath,
        postId: postId,
        ownerId: ownerId,
      );
}

class GetSingleVideoState extends State<GetSingleVideo> {
  final String? videopath;
  final String? postId;
  final String? ownerId;
  late VideoPlayerController _controller;

  GetSingleVideoState({
    this.videopath,
    this.postId,
    this.ownerId,
  });

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      videopath!,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          ClosedCaption(text: _controller.value.caption.text),
          _ControlsOverlay(
            controller: _controller,
            postId: postId,
            ownerId: ownerId,
          ),
          // VideoProgressIndicator(_controller, allowScrubbing: true),
        ],
      ),
    );

    // return Text(
    //   CommentsCount.toString(),
    //   style: TextStyle(
    //     fontSize: 14.0,
    //     color: Theme.of(context).iconTheme.color,
    //   ),
    // );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final String? postId;
  final String? ownerId;
  const _ControlsOverlay({
    Key? key,
    required this.controller,
    this.postId,
    this.ownerId,
  }) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            // controller.value.isPlaying ? controller.pause() : controller.play();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostScreen(
                    postId: postId,
                    userId: ownerId,
                  ),
                ));
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (context) {
              return [
                for (final speed in _examplePlaybackRates)
                  PopupMenuItem(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
