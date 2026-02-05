import 'package:flutter/material.dart';
import 'core/loading/loading_overlay.dart';
import 'Screens/homeScreen.dart';
import 'Screens/splash_screen.dart';
import 'Screens/login_screen.dart';
import 'Screens/Sign_Up.dart';
import 'Screens/creatNewPass.dart';
import 'Screens/otp_verification_screen.dart';
import 'Screens/verification_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/password_success_screen.dart';
import 'screens/details_screen.dart';
import 'screens/add_ad_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/my_ads_screen.dart';
import 'screens/profileScreen.dart';
import 'screens/EditAdScreen.dart';

void main() {
  runApp(const LoginSignupUI());
}

class LoginSignupUI extends StatelessWidget {
  const LoginSignupUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      builder: (context, child) {
        return GlobalLoadingOverlay(
          child: child!,
        );
      },
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUp(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/verify': (context) => const VerificationScreen(),
        '/otp': (context) => const OtpVerificationScreen(),
        '/newpass': (context) => const Creatnewpass(),
        '/home': (context) => const HomeScreen(),
        '/pass-success': (context) => const PasswordSuccessScreen(),
        '/details': (context) => const DetailsScreen(),
        '/add': (context) => const AddAdScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/myAds': (context) => const MyAdsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-ad': (context) => const EditAdScreen(),
      },
    );
  }
}
