import 'package:flutter/material.dart';

class RetroPage1 extends StatelessWidget {
  const RetroPage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/31/eb/7e/31eb7e934c8f6aba94e7a49a288cbe3b.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class RetroPage2 extends StatelessWidget {
  const RetroPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/81/a3/40/81a34032cbde10a908ce8fb2ed5d9979.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class RetroPage3 extends StatelessWidget {
  const RetroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/e0/19/ad/e019adcef7865125084b109e7134cf98.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}
