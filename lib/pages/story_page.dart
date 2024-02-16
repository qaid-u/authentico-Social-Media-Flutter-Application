// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:authentico/themes/themed_post1.dart';
import 'package:authentico/themes/themed_post2.dart';
import 'package:authentico/themes/themed_post3.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// ignore: must_be_immutable
class StoryPage extends StatefulWidget {
  String challenge;
  StoryPage({super.key, required this.challenge});

  @override
  // ignore: library_private_types_in_public_api
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  int currentStoryIndex = 0;

  List<Widget> myStories = [];
  late String challenge = widget.challenge;

  List<double> percentWatched = [];

  @override
  void initState() {
    super.initState();

    if (challenge == "Tech Talk Tuesday:") {
          myStories = [
          TechPage1(),
          TechPage2(),
          TechPage3(),
        ];
      
    } else  if(challenge == "Minty Monday - Decades Edition:"){

          myStories = [
          RetroPage1(),
          RetroPage2(),
          RetroPage3(),
        ];
      
    }else if(challenge == "Natures Canvas"){

          myStories = [
          NaturePage1(),
          NaturePage2(),
          NaturePage3(),
        ];

    }else{
        myStories = [
          MyStory1(),
          MyStory2(),
          MyStory3(),
        ];
    }

    // initially, all stories haven't been watched yet
    for (int i = 0; i < myStories.length; i++) {
      percentWatched.add(0);
    }

    _startWatching();
  }

  void _startWatching() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // only add 0.01 as long as it's below 1
        if (percentWatched[currentStoryIndex] + 0.01 < 1) {
          percentWatched[currentStoryIndex] += 0.01;
        }
        // if adding 0.01 exceeds 1, set percentage to 1 and cancel timer
        else {
          percentWatched[currentStoryIndex] = 1;
          timer.cancel();

          // also go to next story as long as there are more stories to go through
          if (currentStoryIndex < myStories.length - 1) {
            currentStoryIndex++;
            // restart story timer
            _startWatching();
          }
          // if we are finishing the last story then return to homepage
          else {
            Navigator.pop(context);
          }
        }
      });
    });
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    // user taps on first half of screen
    if (dx < screenWidth / 2) {
      setState(() {
        // as long as this isnt the first story
        if (currentStoryIndex > 0) {
          // set previous and curent story watched percentage back to 0
          percentWatched[currentStoryIndex - 1] = 0;
          percentWatched[currentStoryIndex] = 0;

          // go to previous story
          currentStoryIndex--;
        }
      });
    }
    // user taps on second half of screen
    else {
      setState(() {
        // if there are more stories left
        if (currentStoryIndex < myStories.length - 1) {
          // finish current story
          percentWatched[currentStoryIndex] = 1;
          // move to next story
          currentStoryIndex++;
        }
        // if user is on the last story, finish this story
        else {
          percentWatched[currentStoryIndex] = 1;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTapDown(details),
      child: Scaffold(
        body: Stack(
          children: [
            // story
            myStories[currentStoryIndex],

            // progress bar
            MyStoryBars(
              percentWatched: percentWatched,
            ),
          ],
        ),
      ),
    );
  }
}

class MyStory1 extends StatelessWidget {
  const MyStory1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
    );
  }
}

class MyStory2 extends StatelessWidget {
  const MyStory2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
    );
  }
}

class MyStory3 extends StatelessWidget {
  const MyStory3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
    );
  }
}

// ignore: must_be_immutable
class MyProgressBar extends StatelessWidget {
  double percentWatched = 0;

  MyProgressBar({super.key, required this.percentWatched});

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
      lineHeight: 15,
      percent: percentWatched,
      progressColor: Colors.grey[400],
      backgroundColor: Colors.grey[600],
    );
  }
}

// ignore: must_be_immutable
class MyStoryBars extends StatelessWidget {
  List<double> percentWatched = [];

  MyStoryBars({super.key, required this.percentWatched});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 60, left: 8, right: 8),
      child: Row(
        children: [
          Expanded(
            child: MyProgressBar(percentWatched: percentWatched[0]),
          ),
          Expanded(
            child: MyProgressBar(percentWatched: percentWatched[1]),
          ),
          Expanded(
            child: MyProgressBar(percentWatched: percentWatched[2]),
          ),
        ],
      ),
    );
  }
}
