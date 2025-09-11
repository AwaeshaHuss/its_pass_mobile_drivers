import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/methods/common_method.dart';
import 'package:itspass_driver/pages/dashboard.dart';
import 'package:itspass_driver/pages/driverRegistration/driver_registration.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:itspass_driver/widgets/blocked_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String? phoneNumber;
  const OTPScreen({
    super.key, 
    required this.verificationId,
    this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  final CommonMethods commonMethods = CommonMethods();
  final TextEditingController _pinController = TextEditingController();
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
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
              SizedBox(height: 40.h),
              
              // Header section
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
                        Icons.sms_outlined,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Verify your number',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.phoneNumber != null 
                          ? 'Enter the 6-digit code sent to\n${widget.phoneNumber}'
                          : 'Enter the 6-digit code sent to your phone',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 48.h),

              // OTP Input
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  showCursor: true,
                  enabled: !_isLoading,
                  defaultPinTheme: PinTheme(
                    width: 50.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.grey[50],
                      border: Border.all(color: Colors.black, width: 2.w),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 50.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.black.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.black),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  errorPinTheme: PinTheme(
                    width: 50.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  onCompleted: (value) {
                    setState(() {
                      smsCode = value;
                    });
                    _verifyOTP(smsCode: value);
                  },
                  onChanged: (value) {
                    setState(() {
                      smsCode = value;
                    });
                  },
                ),
              ),

              
              const SizedBox(height: 32),
              
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: (_isLoading || (smsCode?.length ?? 0) < 6) 
                      ? null 
                      : () => _verifyOTP(smsCode: smsCode!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isLoading || (smsCode?.length ?? 0) < 6) 
                        ? Colors.grey[400] 
                        : Colors.black,
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
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Status indicators
              if (authRepo.isSuccessful)
                Center(
                  child: Container(
                    height: 60.w,
                    width: 60.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Resend section
              Center(
                child: Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: _canResend ? _resendOTP : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        _canResend 
                            ? 'Resend Code'
                            : 'Resend in ${_resendCountdown}s',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _canResend ? Colors.black : Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyOTP({required String smsCode}) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

      await authProvider.verifyOTP(
        otp: smsCode,
        context: context,
      );

      if (!mounted) return;

      // 1. Check if the driver exists
      bool driverExists = await authProvider.checkUserExistById();

      if (driverExists) {
        // 2. Check if the driver is blocked
        bool isBlocked = await authProvider.checkIfDriverIsBlocked();

        if (isBlocked) {
          // Navigate to Block Screen if blocked
          _navigate(
            const BlockedScreen(),
            clearStack: true,
          );
        } else {
          // 3. Get user data from Firebase if not blocked
          await authProvider.getUserDataFromFirebaseDatabase();

          // 4. Check if driver fields are filled
          bool isDriverComplete = await authProvider.checkDriverFieldsFilled();

          if (isDriverComplete) {
            // Navigate to dashboard if profile is complete
            _navigate(const Dashboard(), clearStack: true);
          } else {
            // Navigate to driver registration if profile is incomplete
            _navigate(DriverRegistration(), clearStack: true);
            if (mounted) {
              commonMethods.displaySnackBar(
                "Please complete your profile information.",
                context,
              );
            }
          }
        }
      } else {
        // Navigate to user information screen if driver doesn't exist
        _navigate(DriverRegistration(), clearStack: true);
      }
    } catch (error) {
      if (mounted) {
        // Clear the PIN input on error
        _pinController.clear();
        setState(() {
          smsCode = '';
        });
        
        commonMethods.displaySnackBar(
          "Invalid verification code. Please try again.",
          context,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;
    
    try {
      // TODO: Implement resend OTP functionality
      // This would typically call the auth provider to resend the OTP
      
      commonMethods.displaySnackBar(
        "Verification code sent successfully.",
        context,
      );
      
      // Restart the timer
      _startResendTimer();
      
      // Clear the current input
      _pinController.clear();
      setState(() {
        smsCode = '';
      });
    } catch (error) {
      if (mounted) {
        commonMethods.displaySnackBar(
          "Failed to resend code. Please try again.",
          context,
        );
      }
    }
  }

  void _navigate(Widget destination, {bool clearStack = false}) {
    if (clearStack) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => destination),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }
}
