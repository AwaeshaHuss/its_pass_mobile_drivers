import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itspass_driver/methods/common_method.dart';
import 'package:itspass_driver/pages/dashboard.dart';
import '../widgets/loading_dialog.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController userNameTextEditingController;
  late final TextEditingController userPhoneTextEditingController;
  late final TextEditingController emailTextEditingController;
  late final TextEditingController passwordTextEditingController;
  late final TextEditingController vehicleModelTextEditingController;
  late final TextEditingController vehicleColorTextEditingController;
  late final TextEditingController vehicleNumberTextEditingController;
  
  final CommonMethods cMethods = CommonMethods();
  final List<FocusNode> _focusNodes = [];
  
  XFile? imageFile;
  String urlOfUploadedImage = "";
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userNameTextEditingController = TextEditingController();
    userPhoneTextEditingController = TextEditingController();
    emailTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
    vehicleModelTextEditingController = TextEditingController();
    vehicleColorTextEditingController = TextEditingController();
    vehicleNumberTextEditingController = TextEditingController();
    
    // Create focus nodes for all fields
    for (int i = 0; i < 7; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    userNameTextEditingController.dispose();
    userPhoneTextEditingController.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    vehicleModelTextEditingController.dispose();
    vehicleColorTextEditingController.dispose();
    vehicleNumberTextEditingController.dispose();
    
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _checkIfNetworkIsAvailable() {
    if (_isLoading) return;
    
    if (imageFile != null) {
      _signUpFormValidation();
    } else {
      cMethods.displaySnackBar("Please add a profile photo first.", context);
    }
  }

  void _signUpFormValidation() {
    final name = userNameTextEditingController.text.trim();
    final phone = userPhoneTextEditingController.text.trim();
    final email = emailTextEditingController.text.trim();
    final password = passwordTextEditingController.text.trim();
    final vehicleModel = vehicleModelTextEditingController.text.trim();
    final vehicleColor = vehicleColorTextEditingController.text.trim();
    final vehicleNumber = vehicleNumberTextEditingController.text.trim();

    if (name.isEmpty) {
      cMethods.displaySnackBar("Please enter your full name.", context);
      _focusNodes[0].requestFocus();
      return;
    }
    
    if (name.length < 3) {
      cMethods.displaySnackBar("Name must be at least 3 characters long.", context);
      _focusNodes[0].requestFocus();
      return;
    }
    
    if (phone.isEmpty) {
      cMethods.displaySnackBar("Please enter your phone number.", context);
      _focusNodes[1].requestFocus();
      return;
    }
    
    if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      cMethods.displaySnackBar("Please enter a valid phone number.", context);
      _focusNodes[1].requestFocus();
      return;
    }
    
    if (email.isEmpty) {
      cMethods.displaySnackBar("Please enter your email address.", context);
      _focusNodes[2].requestFocus();
      return;
    }
    
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      cMethods.displaySnackBar("Please enter a valid email address.", context);
      _focusNodes[2].requestFocus();
      return;
    }
    
    if (password.isEmpty) {
      cMethods.displaySnackBar("Please create a password.", context);
      _focusNodes[3].requestFocus();
      return;
    }
    
    if (password.length < 6) {
      cMethods.displaySnackBar("Password must be at least 6 characters long.", context);
      _focusNodes[3].requestFocus();
      return;
    }
    
    if (vehicleModel.isEmpty) {
      cMethods.displaySnackBar("Please enter your vehicle model.", context);
      _focusNodes[4].requestFocus();
      return;
    }
    
    if (vehicleColor.isEmpty) {
      cMethods.displaySnackBar("Please enter your vehicle color.", context);
      _focusNodes[5].requestFocus();
      return;
    }
    
    if (vehicleNumber.isEmpty) {
      cMethods.displaySnackBar("Please enter your license plate number.", context);
      _focusNodes[6].requestFocus();
      return;
    }
    
    _uploadImageToStorage();
  }

  Future<void> _uploadImageToStorage() async {
    // Image will be uploaded via API in registerNewDriver method
    await _registerNewDriver();
  }

  Future<void> _registerNewDriver() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            const LoadingDialog(messageText: "Creating your account..."),
      );

      // TODO: Replace with API call to register new driver
      // This is a placeholder implementation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context);

      // For now, just show success message
      cMethods.displaySnackBar("Registration successful! Please complete your profile.", context);
      
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
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

  Future<void> _chooseImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        cMethods.displaySnackBar("Failed to pick image. Please try again.", context);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Photo',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  Icons.camera_alt_outlined,
                  'Camera',
                  () async {
                    Navigator.pop(context);
                    await _chooseImageFromCamera();
                  },
                ),
                _buildImageSourceOption(
                  Icons.photo_library_outlined,
                  'Gallery',
                  () async {
                    Navigator.pop(context);
                    await _chooseImageFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseImageFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        cMethods.displaySnackBar("Failed to take photo. Please try again.", context);
      }
    }
  }

  Widget _buildImageSourceOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32.sp, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Text(
                'Create account',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Join as a driver and start earning',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Profile photo section
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 100.w,
                        width: 100.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2.w,
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
                                size: 40.sp,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Add profile photo',
                      style: TextStyle(
                        fontSize: 14.sp,
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
                focusNode: _focusNodes[0],
                nextFocusNode: _focusNodes[1],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Phone Number',
                'Enter your phone number',
                userPhoneTextEditingController,
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                focusNode: _focusNodes[1],
                nextFocusNode: _focusNodes[2],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Email',
                'Enter your email',
                emailTextEditingController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                focusNode: _focusNodes[2],
                nextFocusNode: _focusNodes[3],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Password',
                'Create a password',
                passwordTextEditingController,
                Icons.lock_outline,
                isPassword: true,
                focusNode: _focusNodes[3],
                nextFocusNode: _focusNodes[4],
                textInputAction: TextInputAction.next,
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
                focusNode: _focusNodes[4],
                nextFocusNode: _focusNodes[5],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'Vehicle Color',
                'e.g., White',
                vehicleColorTextEditingController,
                Icons.palette_outlined,
                focusNode: _focusNodes[5],
                nextFocusNode: _focusNodes[6],
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 20),
              
              _buildTextField(
                'License Plate',
                'Enter license plate number',
                vehicleNumberTextEditingController,
                Icons.confirmation_number_outlined,
                focusNode: _focusNodes[6],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _checkIfNetworkIsAvailable(),
              ),
              
              const SizedBox(height: 32),
              
              // Sign up button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkIfNetworkIsAvailable,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey[400] : Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
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
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
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
            focusNode: focusNode,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            textInputAction: textInputAction ?? TextInputAction.next,
            onSubmitted: onSubmitted ?? (nextFocusNode != null ? (_) => nextFocusNode.requestFocus() : null),
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
              suffixIcon: isPassword
                  ? IconButton(
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
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
