import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../widgets/loading_overlay.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success =
        await ApiService.sendOtp('', _emailController.text.trim());

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushNamed(
        context,
        '/otp',
        arguments: {
          'isFromSignup': false,
          'email': _emailController.text.trim(),
          'phone': '',
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
return LoadingOverlay(
  isLoading: isLoading,
  child: Scaffold(      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xff24394a),
        elevation: 0,
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios,
                    size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Text(
              'Forgot your password?',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xff24394a),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'We will send you a verification code (OTP)\n'
              'to reset your password.\n'
              'Please enter your email address below.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Image.asset(
                'assets/images/lock.png',
                height: 170,
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xff24394a),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: const Color(0xff24394a),
              decoration: InputDecoration(
                hintText: 'Enter your Email',
                suffixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xff24394a),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                filled: true,
                fillColor: Colors.grey.shade100,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xffe0e0e0),
                    width: 1.2,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xff24394a),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff24394a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Send OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
