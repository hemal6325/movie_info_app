import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart'; // 🔥 নতুন প্যাকেজ

class TrailerPlayerScreen extends StatefulWidget {
  final String videoId;

  const TrailerPlayerScreen({super.key, required this.videoId});

  @override
  State<TrailerPlayerScreen> createState() => _TrailerPlayerScreenState();
}

class _TrailerPlayerScreenState extends State<TrailerPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    // 🔥 নতুন কন্ট্রোলার সেটআপ (Web & Mobile সাপোর্টেড)
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close(); // প্লেয়ার বন্ধ করা
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          // 🔥 ভিডিও প্লেয়ার উইজেট
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        ),
      ),
    );
  }
}
