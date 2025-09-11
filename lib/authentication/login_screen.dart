import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/pages/dashboard.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import '../methods/common_method.dart';
import '../widgets/loading_dialog.dart';
import 'signup_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailTextEditingController;
  late final TextEditingController passwordTextEditingController;
  final CommonMethods cMethods = CommonMethods();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
  }

  @override
  void dispose() {
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }



  void _checkIfNetworkIsAvailable() {
    if (_isLoading) return;
    _signInFormValidation();
  }

  void _signInFormValidation() {
    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();

    if (email.isEmpty) {
      cMethods.displaySnackBar("Please enter your email address.", context);
      _emailFocusNode.requestFocus();
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      cMethods.displaySnackBar("Please enter a valid email address.", context);
      _emailFocusNode.requestFocus();
      return;
    }
    
    if (password.isEmpty) {
      cMethods.displaySnackBar("Please enter your password.", context);
      _passwordFocusNode.requestFocus();
      return;
    }
    
    if (password.length < 6) {
      cMethods.displaySnackBar("Password must be at least 6 characters long.", context);
      _passwordFocusNode.requestFocus();
      return;
    }
    
    _signInUser();
  }

  Future<void> _signInUser() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const LoadingDialog(messageText: "Signing you in..."),
    );

    try {
      final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      await authProvider.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
        context: context,
      );

      if (!mounted) return;
      Navigator.pop(context);

      // Check if login was successful
      if (authProvider.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } catch (errorMsg) {
      if (!mounted) return;
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              
              // Logo and branding
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80.w,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_taxi,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to your driver account',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h),
              
              // Email field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: emailTextEditingController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Password field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: passwordTextEditingController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _checkIfNetworkIsAvailable(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Login button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkIfNetworkIsAvailable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey[400] : Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.w,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.h,
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.h,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 24.h),
              
              // Sign up link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign up',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
