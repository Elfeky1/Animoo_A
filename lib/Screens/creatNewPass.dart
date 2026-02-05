import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_signup_ui/Widgets/CustomLabelWidget.dart';
import 'package:password_rule_check/password_rule_check.dart';
import '../services/api_service.dart';
import '../widgets/loading_overlay.dart';

class Creatnewpass extends StatefulWidget {
  const Creatnewpass({super.key});

  @override
  State<Creatnewpass> createState() => _CreatnewpassState();
}

class _CreatnewpassState extends State<Creatnewpass> {
  bool isObsecure = true;
  bool isObsecureConfirmPass = true;
  bool isLoading = false;

  String? password;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<PasswordRuleCheckState> _ruleCheckKey = GlobalKey();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String email = args['email'];

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xfff2f2f2),
        resizeToAvoidBottomInset: true,
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
                  const Icon(
                    Icons.arrow_back_ios,
                    size: 18,
                    color: Colors.white,
                  ),
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
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Create New Password ?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff24394a),
                  ),
                ),
                const SizedBox(height: 25),
                const CustomLabelWidget(Label: "New Password"),
                _passwordField(
                  controller: passwordController,
                  obscure: isObsecure,
                  toggle: () {
                    setState(() => isObsecure = !isObsecure);
                  },
                  validator: (value) {
                    if (_ruleCheckKey.currentState?.validate() == false) {
                      return 'Please add all required characters';
                    }
                    password = value;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PasswordRuleCheck(
                  key: _ruleCheckKey,
                  controller: passwordController,
                  showIcon: true,
                  rowHeight: 28,
                  successColor: const Color(0xff30905b),
                  ruleSet: PasswordRuleSet(
                    minLength: 12,
                    uppercase: 1,
                    lowercase: 1,
                    digits: 1,
                    specialCharacters: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const CustomLabelWidget(Label: "Confirm Password"),
                _passwordField(
                  controller: confirmPasswordController,
                  obscure: isObsecureConfirmPass,
                  toggle: () {
                    setState(
                        () => isObsecureConfirmPass = !isObsecureConfirmPass);
                  },
                  validator: (value) {
                    if (value != password) {
                      return 'Password not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff24394a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;

                            setState(() => isLoading = true);

                            final success = await ApiService.resetPassword(
                              email,
                              passwordController.text.trim(),
                            );

                            if (!mounted) return;

                            setState(() => isLoading = false);

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Password updated successfully'),
                                ),
                              );

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/pass-success',
                                (route) => false,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to reset password'),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      cursorColor: const Color(0xff24394a),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade200,
        hintText: '************',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xff24394a),
          ),
        ),
      ),
    );
  }
}
