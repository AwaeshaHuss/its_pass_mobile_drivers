import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uber_drivers_app/methods/common_method.dart';
import 'package:uber_drivers_app/pages/dashboard.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController =
      TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController vehicleModelTextEditingController =
      TextEditingController();
  TextEditingController vehicleColorTextEditingController =
      TextEditingController();
  TextEditingController vehicleNumberTextEditingController =
      TextEditingController();
  CommonMethods cMethods = CommonMethods();
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkIsAvailable() {
    //cMethods.checkConnectivity(context);

    if (imageFile != null) //image validation
    {
      signUpFormValidation();
    } else {
      cMethods.displaySnackBar("Please choose image first.", context);
    }
  }

  signUpFormValidation() {
    if (userNameTextEditingController.text.trim().length < 3) {
      cMethods.displaySnackBar(
          "your name must be atleast 4 or more characters.", context);
    } else if (userPhoneTextEditingController.text.trim().length < 7) {
      cMethods.displaySnackBar(
          "your phone number must be atleast 8 or more characters.", context);
    } else if (!emailTextEditingController.text.contains("@")) {
      cMethods.displaySnackBar("please write valid email.", context);
    } else if (passwordTextEditingController.text.trim().length < 5) {
      cMethods.displaySnackBar(
          "your password must be atleast 6 or more characters.", context);
    } else if (vehicleModelTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar("please write your car model", context);
    } else if (vehicleColorTextEditingController.text.trim().isEmpty) {
      cMethods.displaySnackBar("please write your car color.", context);
    } else if (vehicleNumberTextEditingController.text.isEmpty) {
      cMethods.displaySnackBar("please write your car number.", context);
    } else {
      uploadImageToStorage();
    }
  }

  uploadImageToStorage() async {
    // Image will be uploaded via API in registerNewDriver method
    registerNewDriver();
  }

  registerNewDriver() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const LoadingDialog(messageText: "Registering your account..."),
      );

      // TODO: Replace with API call to register new driver
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;
      Navigator.pop(context);

      // For now, just show success message
      cMethods.displaySnackBar("Registration successful! Please complete your profile.", context);
      
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => const Dashboard()));
    } catch (errorMsg) {
      if (!context.mounted) return;
      Navigator.pop(context);
      cMethods.displaySnackBar(errorMsg.toString(), context);
    }
  }

  chooseImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              const Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join as a driver and start earning',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Profile photo section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: chooseImageFromGallery,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          image: imageFile != null
                              ? DecorationImage(
                                  image: FileImage(File(imageFile!.path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageFile == null
                            ? Icon(
                                Icons.camera_alt_outlined,
                                size: 40,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add profile photo',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Form fields
              _buildTextField(
                'Full Name',
                'Enter your full name',
                userNameTextEditingController,
                Icons.person_outline,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Phone Number',
                'Enter your phone number',
                userPhoneTextEditingController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Email',
                'Enter your email',
                emailTextEditingController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Password',
                'Create a password',
                passwordTextEditingController,
                Icons.lock_outline,
                isPassword: true,
              ),
              
              const SizedBox(height: 24),
              
              // Vehicle information section
              const Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                'Vehicle Model',
                'e.g., Toyota Corolla',
                vehicleModelTextEditingController,
                Icons.directions_car_outlined,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Vehicle Color',
                'e.g., White',
                vehicleColorTextEditingController,
                Icons.palette_outlined,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'License Plate',
                'Enter license plate number',
                vehicleNumberTextEditingController,
                Icons.confirmation_number_outlined,
              ),
              
              const SizedBox(height: 32),
              
              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: checkIfNetworkIsAvailable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sign in link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Sign in',
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
  
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
