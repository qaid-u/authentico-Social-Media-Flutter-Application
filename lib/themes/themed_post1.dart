import 'package:flutter/material.dart';

class TechPage1 extends StatelessWidget {
  const TechPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/736x/82/c7/66/82c766b08f5154a82d48bc4630796b21.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class TechPage2 extends StatelessWidget {
  const TechPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/73/a8/b0/73a8b0230828a4eff8b4afc99f479436.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class TechPage3 extends StatelessWidget {
  const TechPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/20/fc/87/20fc87b5300054d13d49241905402c3d.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}
