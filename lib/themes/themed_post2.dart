import 'package:flutter/material.dart';

class NaturePage1 extends StatelessWidget {
  const NaturePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/18/9a/7d/189a7d37fba41b4bfe84d734104cdf69.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class NaturePage2 extends StatelessWidget {
  const NaturePage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/7f/ba/52/7fba525f2bd52e1d170b2719f9503c86.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}

class NaturePage3 extends StatelessWidget {
  const NaturePage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.network(
          'https://i.pinimg.com/474x/e3/72/c9/e372c9b77c6236cd1e2f55a65710d249.jpg', // Replace with your actual image URL
          fit: BoxFit.cover, // This ensures the image covers the entire screen
        ),
      ),
    );
  }
}
