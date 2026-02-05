import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:login_signup_ui/Widgets/CustomButton.dart';
import 'package:login_signup_ui/Widgets/CustomFormFeildWidget.dart';
import 'package:login_signup_ui/Widgets/CustomLabelWidget.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isObscure = true;
  bool isObscureConfirmPass = true;
  bool isCheckedMale = false;
  bool isCheckedFemale = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? password;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        leadingWidth: 90,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Back',
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
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Sign up',
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              CustomLabelWidget(Label: "Full Name"),
              CustomFormFeildWidget(
                controller: nameController,
                suffixIcon: null,
                FeildName: "Full Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              CustomLabelWidget(Label: "Email"),
              CustomFormFeildWidget(
                controller: emailController,
                suffixIcon: const Icon(Icons.email_outlined),
                FeildName: "email",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  final emailRegex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }

                  return null;
                },
              ),

              CustomLabelWidget(Label: "Address"),
              CustomFormFeildWidget(
                controller: addressController,
                suffixIcon: null,
                FeildName: "address",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),

              CustomLabelWidget(Label: "User Name"),
              CustomFormFeildWidget(
                controller: usernameController,
                suffixIcon: null,
                FeildName: "User Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your User Name';
                  }
                  return null;
                },
              ),

              CustomLabelWidget(Label: "Password"),
              CustomFormFeildWidget(
                controller: passwordController,
                isObscure: isObscure,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isObscure = !isObscure;
                    });
                  },
                  icon: Icon(
                    isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                FeildName: "password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              CustomLabelWidget(Label: "Confirm Password"),
              CustomFormFeildWidget(
                controller: confirmPasswordController,
                isObscure: isObscureConfirmPass,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isObscureConfirmPass = !isObscureConfirmPass;
                    });
                  },
                  icon: Icon(
                    isObscureConfirmPass
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
                FeildName: "confirm password",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != passwordController.text) {
                    return 'Password not match';
                  }
                  return null;
                },
              ),

              CustomLabelWidget(Label: 'Gender'),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      activeColor: const Color(0xff24394a),
                      value: isCheckedMale,
                      onChanged: (value) {
                        setState(() {
                          isCheckedMale = value!;
                          isCheckedFemale = false;
                        });
                      },
                      title: const Text("Male"),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      activeColor: const Color(0xff24394a),
                      value: isCheckedFemale,
                      onChanged: (value) {
                        setState(() {
                          isCheckedFemale = value!;
                          isCheckedMale = false;
                        });
                      },
                      title: const Text("Female"),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: CustomButtonWidget(
                  w: w,
                  h: h,
                  text: 'Sign up',
                  onPress: () {
                    if (_formKey.currentState!.validate()) {
                      if (!isCheckedMale && !isCheckedFemale) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select gender')),
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        '/verify',
                        arguments: {
                          'isFromSignup': true,
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'address': addressController.text.trim(),
                          'username': usernameController.text.trim(),
                          'password': passwordController.text.trim(),
                          'gender': isCheckedMale ? 'male' : 'female',
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
