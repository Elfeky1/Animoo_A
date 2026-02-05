import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../core/loading/loading_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  // Resend OTP
  int _seconds = 60;
  bool _canResend = false;
  Timer? _timer;

  // INIT 
  @override
  void initState() {
    super.initState();
    _startResendTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get isOtpComplete {
    return _controllers.every((c) => c.text.isNotEmpty);
  }

  void _startResendTimer() {
    _canResend = false;
    _seconds = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _seconds--;
        if (_seconds == 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp(bool isFromSignup) async {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length < 6) return;

    LoadingController.show();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String email = args['email'];
    final String phone = args['phone'];

    final success = await ApiService.verifyOtp(email, otp);

    LoadingController.hide();

    if (!mounted) return;

    if (!success) {
      HapticFeedback.mediumImpact();

      for (final c in _controllers) {
        c.clear();
      }

      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired OTP')),
      );
      setState(() {});
      return;
    }

    if (isFromSignup) {
      final registerSuccess = await ApiService.register(
        args['name'],
        email,
        phone,
        args['password'],
      );

      if (registerSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully')),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed')),
        );
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/newpass',
        arguments: {'email': email},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final bool isFromSignup = args['isFromSignup'];
    final String email = args['email'];
    final String phone = args['phone'];

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF24394A),
        elevation: 0,
        leadingWidth: 110,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Image.asset(
              'assets/images/lock.png',
              height: 150,
            ),

            const SizedBox(height: 25),

            const Text(
              'OTP Verification',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF24394A),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'You will get an OTP via Email',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 45),

            Row(
              children: List.generate(6, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF24394A),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        counterText: '',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF24394A), width: 2),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFF24394A), width: 3),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 25),

            TextButton(
              onPressed: _canResend
                  ? () async {
                      await ApiService.sendOtp(phone, email);
                      _startResendTimer();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('OTP resent successfully'),
                        ),
                      );
                    }
                  : null,
              child: Text(
                _canResend
                    ? 'Resend OTP'
                    : 'Resend OTP in $_seconds s',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    isOtpComplete ? () => _verifyOtp(isFromSignup) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24394A),
                  disabledBackgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'VERIFY',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Colors.white,
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
