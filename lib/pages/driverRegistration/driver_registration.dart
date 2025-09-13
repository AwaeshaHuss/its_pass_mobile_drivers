import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/pages/dashboard.dart';
import 'package:itspass_driver/pages/driverRegistration/basic_info_screen.dart';
import 'package:itspass_driver/pages/driverRegistration/driving_license_screen.dart';
import 'package:itspass_driver/pages/driverRegistration/cninc_screen.dart';
import 'package:itspass_driver/pages/driverRegistration/selfie_screen.dart';
import 'package:itspass_driver/providers/registration_provider.dart';
import 'vehicle_info_screen.dart';

class DriverRegistration extends StatefulWidget {
  const DriverRegistration({super.key});

  @override
  State<DriverRegistration> createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistration> {
  bool isBasicInfoComplete = false;
  bool isCnicComplete = false;
  bool isSelfieComplete = false;
  bool isVehicleInfoComplete = false;
  bool isDrivingLicenseInfoComplete = false;

  // Function to recalculate 'isAllComplete'
  void _recalculateAllComplete() {
    setState(() {
      isAllComplete = isBasicInfoComplete &&
          isCnicComplete &&
          isSelfieComplete &&
          isVehicleInfoComplete &&
          isDrivingLicenseInfoComplete;
    });
  }

  bool isAllComplete = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, registrationProvider, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Complete Registration',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                
                // Header section
                const Text(
                  'Complete your profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Finish setting up your driver profile to start earning',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Progress indicator
                _buildProgressIndicator(),
                
                const SizedBox(height: 32),
                
                // Registration steps
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildRegistrationStep(
                          stepNumber: 1,
                          title: 'Basic Information',
                          subtitle: 'Your personal details',
                          icon: Icons.person_outline,
                          isCompleted: isBasicInfoComplete,
                          onTap: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BasicInfoScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isBasicInfoComplete = true;
                                _recalculateAllComplete();
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildRegistrationStep(
                          stepNumber: 2,
                          title: 'Non-conviction',
                          subtitle: 'Upload your non-conviction document',
                          icon: Icons.description_outlined,
                          isCompleted: isCnicComplete,
                          onTap: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CNICScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isCnicComplete = true;
                                _recalculateAllComplete();
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildRegistrationStep(
                          stepNumber: 3,
                          title: 'Selfie with CNIC',
                          subtitle: 'Take a selfie holding your CNIC',
                          icon: Icons.camera_alt_outlined,
                          isCompleted: isSelfieComplete,
                          onTap: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SelfieScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isSelfieComplete = true;
                                _recalculateAllComplete();
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildRegistrationStep(
                          stepNumber: 4,
                          title: 'Driving License',
                          subtitle: 'Upload your driving license',
                          icon: Icons.badge_outlined,
                          isCompleted: isDrivingLicenseInfoComplete,
                          onTap: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DrivingLicenseScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isDrivingLicenseInfoComplete = true;
                                _recalculateAllComplete();
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildRegistrationStep(
                          stepNumber: 5,
                          title: 'Vehicle Information',
                          subtitle: 'Add your vehicle details',
                          icon: Icons.directions_car_outlined,
                          isCompleted: isVehicleInfoComplete,
                          onTap: () async {
                            bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VehicleInfoScreen(),
                              ),
                            );
                            if (result != null && result) {
                              setState(() {
                                isVehicleInfoComplete = true;
                                _recalculateAllComplete();
                              });
                            }
                          },
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                // Complete registration button
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isAllComplete && !registrationProvider.isLoading
                              ? () {
                                  // For UI testing - navigate directly to dashboard
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => const Dashboard(),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAllComplete ? Colors.black : Colors.grey[400],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            disabledBackgroundColor: Colors.grey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: registrationProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Complete Registration',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'By completing registration you agree to our Terms and Conditions and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int completedSteps = 0;
    if (isBasicInfoComplete) completedSteps++;
    if (isCnicComplete) completedSteps++;
    if (isSelfieComplete) completedSteps++;
    if (isDrivingLicenseInfoComplete) completedSteps++;
    if (isVehicleInfoComplete) completedSteps++;
    
    double progress = completedSteps / 5.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$completedSteps of 5 completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: progress == 1.0 ? Colors.green : Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.green.withValues(alpha: 0.3) : Colors.grey[200]!,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            // Step number/check icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      stepNumber.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? Colors.green[700] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            
            // Icon and arrow
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isCompleted ? Colors.green[700] : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
