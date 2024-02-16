import 'package:authentico/pages/story_page.dart';
import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String challenge;
  const StoryCircle({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    String challengeImageLink = "";

    if (challenge == "Minty Monday - Decades Edition:") {
      challengeImageLink =
          "https://i.pinimg.com/564x/78/42/1e/78421ee6d7a281bb36345144a053e1e1.jpg";
    } else if (challenge == "Natures Canvas") {
      challengeImageLink =
          "https://i.pinimg.com/564x/10/a6/2d/10a62d355449a0ddf12739851119a2c6.jpg";
    } else if (challenge == "Tech Talk Tuesday:") {
      challengeImageLink =
          "https://i.pinimg.com/564x/e5/38/49/e53849af928aaae4132ce5ccc36376e9.jpg";
    }
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StoryPage(
                        challenge: challenge,
                      )));
        },
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(challengeImageLink),
            )));
  }
}
