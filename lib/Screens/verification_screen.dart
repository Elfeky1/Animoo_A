import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();

  bool isLoading = false;
  late String email;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  
Future<void> _sendOtp(bool isFromSignup) async {
  if (_phoneController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter phone number')),
    );
    return;
  }
  final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;


  setState(() => isLoading = true);

  

  final bool success = await ApiService.sendOtp(
  _phoneController.text.trim(),
  email,
);


  setState(() => isLoading = false);

  if (!mounted) return;

  if (success) {
    Navigator.pushNamed(
  context,
  '/otp',
  arguments: {
    'isFromSignup': isFromSignup,
    'phone': _phoneController.text.trim(),
    'email': email,
    'name': args['name'],
    'password': args['password'],
  },


    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to send OTP')),
    );
  }


}



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final bool isFromSignup = args['isFromSignup'];
    email = args['email'];

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),

      appBar: AppBar(
        backgroundColor: const Color(0xff24394a),
        elevation: 0,
        leadingWidth: 90,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          30,
          24,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          children: [
            Container(
              height: size.height * 0.22,
              width: size.width * 0.55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage("assets/images/lock.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Verification',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff24394a),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'We will send you an OTP code\non your phone number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phone number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '01XXXXXXXXX',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _sendOtp(isFromSignup),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff24394a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Get OTP',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
