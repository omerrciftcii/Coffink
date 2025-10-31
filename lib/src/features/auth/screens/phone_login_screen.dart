
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneNumberController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Phone Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1 123 456 7890',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final phoneNumber = _phoneNumberController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  authService.verifyPhoneNumber(
                    phoneNumber,
                    context,
                    (verificationId) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OtpScreen(verificationId: verificationId),
                        ),
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a phone number'),
                    ),
                  );
                }
              },
              child: Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
