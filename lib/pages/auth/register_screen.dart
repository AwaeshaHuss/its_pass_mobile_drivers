import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itspass_driver/methods/common_method.dart';
import 'package:itspass_driver/pages/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/pages/auth/otp_screen.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:itspass_driver/l10n/app_localizations.dart';
import 'package:itspass_driver/pages/driverRegistration/driver_registration.dart';
import 'package:itspass_driver/widgets/blocked_screen.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();

  Country selectedCountry = Country(
    phoneCode: '962',
    countryCode: 'JO',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Jordan',
    example: 'Jordan',
    displayName: 'Jordan',
    displayNameNoCountryCode: 'JO',
    e164Key: '',
  );

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter Your Mobile Number",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: phoneController,
                  maxLength: 9,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.grey,
                    counterText: '',
                    hintText: '791234567',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      //borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      //borderSide: BorderSide(color: Colors.black),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            countryListTheme: const CountryListThemeData(
                                borderRadius: BorderRadius.zero,
                                bottomSheetHeight: 400),
                            onSelect: (value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedCountry.flagEmoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${selectedCountry.phoneCode}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    suffixIcon: phoneController.text.length > 8
                        ? Container(
                            height: 20,
                            width: 20,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black),
                            child: const Icon(
                              Icons.done,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: ElevatedButton(
                    onPressed: () {
                      // For UI testing - navigate directly to next screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DriverRegistration()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 0,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Or",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade400,
                        endIndent: 0,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (!authProvider.isLoading) {
                              await authProvider.signInWithGoogle(
                                context,
                                () async {
                                  bool userExists =
                                      await authProvider.checkUserExistById();
                                  bool userExistsInDatabase =
                                      await authProvider.checkUserExistByEmail(
                                    authProvider.driverEmail,
                                  );
                                  print("User Exists: $userExists");
                                  print(
                                      "User Exist in datbase response $userExistsInDatabase");

                                  if (userExists) {
                                    if (userExistsInDatabase) {
                                      // Check if the driver is blocked
                                      bool isBlocked = await authProvider
                                          .checkIfDriverIsBlocked();

                                      if (isBlocked) {
                                        // Navigate to Block Screen if blocked
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BlockedScreen()), // Replace with your actual Block Screen
                                        );
                                      } else {
                                        // Get user data from database if not blocked
                                        await authProvider
                                            .getUserDataFromFirebaseDatabase();

                                        // Check if driver's profile is complete
                                        bool isDriverComplete =
                                            await authProvider
                                                .checkDriverFieldsFilled();

                                        if (isDriverComplete) {
                                          navigate(isSingedIn: true);
                                        } else {
                                          navigate(isSingedIn: false);
                                          commonMethods.displaySnackBar(
                                              "Fill your missing information!",
                                              context);
                                        }
                                      }
                                    } else {
                                      // Navigate to user registration if user doesn't exist in database
                                      navigate(isSingedIn: false);
                                    }
                                  } else {
                                    // Navigate to user information screen if user doesn't exist
                                    navigate(isSingedIn: false);
                                  }
                                },
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: authProvider.isGoogleSigInLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.9,
                //   height: MediaQuery.of(context).size.height * 0.07,
                //   child: ElevatedButton.icon(
                //     onPressed: () {},
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.grey.shade400,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(5),
                //       ),
                //     ),
                //     label: const Text(
                //       "Continue with Apple",
                //       style: TextStyle(
                //         color: Colors.black,
                //         fontSize: 14,
                //       ),
                //     ),
                //     icon: const Icon(
                //       Icons.apple,
                //       color: Colors.black,
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "By proceeding, you consent to get calls, whatsApp or SMS messages,including by automated means, from Uber and its affiliates to the number provided.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    
    final authRepo =
        Provider.of<AuthenticationProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();

    // Validate the phone number based on country
    bool isValid = false;
    String errorMessage = "Please enter a valid mobile number.";

    if (selectedCountry.phoneCode == '962') {
      // Jordan validation: 9 digits starting with 7
      isValid = phoneNumber.length == 9 && RegExp(r'^[7][0-9]{8}$').hasMatch(phoneNumber);
      errorMessage = "Please enter a valid Jordanian mobile number (9 digits starting with 7).";
    } else if (selectedCountry.phoneCode == '92') {
      // Pakistan validation: 10 digits starting with 3
      isValid = phoneNumber.length == 10 && RegExp(r'^[3][0-9]{9}$').hasMatch(phoneNumber);
      errorMessage = "Please enter a valid Pakistani mobile number (10 digits starting with 3).";
    } else {
      // General validation: 8-15 digits
      isValid = phoneNumber.length >= 8 && phoneNumber.length <= 15 && RegExp(r'^[0-9]+$').hasMatch(phoneNumber);
    }

    if (phoneNumber.isEmpty || !isValid) {
      // Show error if the phone number is invalid
      commonMethods.displaySnackBar(
        errorMessage,
        context,
      );
      return;
    }

    // Append country code
    String fullPhoneNumber = '+${selectedCountry.phoneCode}$phoneNumber';

    // Proceed with phone number authentication
    authRepo.signInWithPhone(
      context: context,
      phoneNumber: fullPhoneNumber,
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
          (route) => false);
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => DriverRegistration()));
    }
  }
}
