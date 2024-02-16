import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ToothlessPage extends StatefulWidget {
  const ToothlessPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToothlessPageState createState() => _ToothlessPageState();
}

class _ToothlessPageState extends State<ToothlessPage> {
  // Initialize the audio player
  final AudioPlayer audioPlayer = AudioPlayer();

  // Play audio
  void playAudio() async {
    await audioPlayer.setAsset('assets/toothless.mp3');
    audioPlayer.play();
  }

  @override
  void initState() {
    super.initState();

    // Auto-play audio when the page is loaded
    playAudio();

    // Listen for audio completion to change the state
    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          // Audio playback is complete, update the state
          automaticallyImplyLeading = true;
        });
      }
    });
  }

  @override
  void dispose() {
    // Dispose the audio player to release resources
    audioPlayer.dispose();
    super.dispose();
  }

  bool automaticallyImplyLeading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: automaticallyImplyLeading,
        title: const Text(
          'U just Seeing Toothless Dancing',
          style: TextStyle(
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontStyle: FontStyle.normal),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display GIF using Image widget
            Image.asset('assets/toothless.gif'),

            const SizedBox(height: 20),

            // No need for a button, audio plays automatically
          ],
        ),
      ),
    );
  }
}
