import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
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
                'Help Center',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                '''
Welcome to the Authentico Help Center! Whether you're a new user or a seasoned pro, find answers to your questions here.

• Navigating Authentico: Tips on using our intuitive interface for a seamless experience.

• Privacy and Security: Information on how we prioritize your privacy and ensure data security.

• Account Assistance: Solutions for account-related issues and maintaining confidentiality.

Need more help? Reach out to our support team through the app—we're here to make your Authentico experience smooth and enjoyable.

Thank you for being part of the Authentico community—we're here to assist you every step of the way!
                ''',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  _showFAQ(context);
                },
                child: const Text('Frequently Asked Questions (FAQ)'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _showContactUs(context);
                },
                child: const Text('Contact Us'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFAQ(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frequently Asked Questions (FAQ)'),
        content: const SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '''
Frequently Asked Questions (FAQ) for Authentico:

Q: What is Authentico?
A: Authentico is a platform that prioritizes authenticity and genuine connections.

Q: How do I ensure my privacy?
A: Authentico values privacy; refer to our Privacy Policy for detailed information.

Q: Can I share my "bereal" moments?
A: Absolutely! Authentico encourages users to share authentic moments.

Q: What happens if I violate the Terms?
A: Authentico reserves the right to suspend accounts violating our Terms.

Q: How often are Terms and Privacy Policy updated?
A: Periodic updates may occur; users are encouraged to review them.

Q: How can I contact support?
A: For assistance, contact our support team through the app.

Using Authentico? Find more answers in our complete FAQ section. Thanks for choosing Authentico—we're here to help!
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

  void _showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Us'),
        content: const SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '''
Contact Us:

Have questions or need assistance? Reach out to us!

• Email: support@authentico.com

• Phone: 011-2122 6573

Our dedicated support team is here to help. Feel free to contact us for any inquiries, feedback, or assistance you may need.

Thanks for choosing Authentico—we appreciate your engagement!
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
