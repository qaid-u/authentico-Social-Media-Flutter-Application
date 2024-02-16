import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.popAndPushNamed(context, '/settingspage');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About Authentico',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '''
Authentico is more than just an app; it's a dedicated space for genuine connections and meaningful experiences.

• Privacy and Security: We prioritize your data security and privacy for a safe and secure user experience.

• Personalized Connections: Connect with like-minded individuals through our personalized matching algorithms.

• Authentic Moments: Share real experiences, thoughts, and emotions with the Authentico community.

Join Authentico today and embark on a journey where authenticity and connection take center stage. Download now to start creating genuine connections and sharing authentic moments!
                ''',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  _showTermsOfService(context);
                },
                child: const Text('Terms of Service'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showPrivacyPolicy(context);
                },
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ),
      ),
    );
  }

 void _showTermsOfService(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Terms of Service'),
      content: const SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '''
Welcome to Authentico! By using our services, you agree to:

• Acceptance of Terms: Accessing Authentico signifies your agreement to these Terms.

• User Conduct: Respect community guidelines, prioritize privacy, and avoid unlawful activities.

• Intellectual Property: Authentico content is protected by intellectual property laws.

• Privacy and Data Security: Our Privacy Policy ensures a secure user experience.

• User Responsibilities: Maintain account confidentiality, ensure information accuracy.

• Termination: Authentico reserves the right to suspend accounts violating our Terms.

• Changes to Terms: Authentico may update terms; users are encouraged to review periodically.

Using Authentico implies agreement. For details, read our complete Terms of Service.
Thanks for choosing Authentico—we're thrilled to have you with us!
                  ''',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}


  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '''
Privacy Policy for Authentico:

Your privacy is crucial to us. Here's an overview:

• Data Collection: Authentico collects minimal data for an enhanced user experience.

• Data Usage: Your data is used to improve Authentico's features and services.

• Security: We prioritize data security; measures are in place for a safe user experience.

• Third-Party Access: Authentico does not share your data with third parties without consent.

• Cookies: Authentico uses cookies to enhance functionality; you can manage preferences.

• Updates: Periodic updates to the privacy policy may occur; check for the latest information.

Using Authentico indicates your acceptance of this privacy policy. For detailed information, read our complete Privacy Policy. Thank you for choosing Authentico—we value your trust!
                ''',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
