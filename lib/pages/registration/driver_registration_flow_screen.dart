import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/driver_service.dart';
import '../../core/utils/error_handler.dart';
import '../dashboard.dart';

class DriverRegistrationFlowScreen extends StatefulWidget {
  const DriverRegistrationFlowScreen({super.key});

  @override
  State<DriverRegistrationFlowScreen> createState() => _DriverRegistrationFlowScreenState();
}

class _DriverRegistrationFlowScreenState extends State<DriverRegistrationFlowScreen> {
  final PageController _pageController = PageController();
  final DriverService _driverService = DriverService();
  final _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;

  // Form Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehicleMakeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleYearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _swiftCodeController = TextEditingController();

  // Collect form data before proceeding to next step
  void _collectCurrentStepData() {
    switch (_currentStep) {
      case 0: // Basic Info
        _registrationData['basic_info'] = {
          'full_name': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'date_of_birth': _dobController.text,
          'address': _addressController.text,
        };
        break;
      case 2: // Vehicle Info
        _registrationData['vehicle_info'] = {
          'make': _vehicleMakeController.text,
          'model': _vehicleModelController.text,
          'year': _vehicleYearController.text,
          'license_plate': _licensePlateController.text,
          'color': _vehicleColorController.text,
        };
        break;
      case 3: // Bank Details
        _registrationData['bank_details'] = {
          'bank_name': _bankNameController.text,
          'account_holder_name': _accountHolderController.text,
          'account_number': _accountNumberController.text,
          'routing_number': _routingNumberController.text,
          'swift_code': _swiftCodeController.text,
        };
        break;
    }
  }

  // Registration data
  final Map<String, dynamic> _registrationData = {
    'basic_info': {},
    'documents': {},
    'vehicle_info': {},
    'bank_details': {},
  };

  final List<String> _stepTitles = [
    'Basic Information',
    'Upload Documents',
    'Vehicle Information',
    'Bank Details',
    'Review & Submit',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _vehicleMakeController.dispose();
    _vehicleModelController.dispose();
    _vehicleYearController.dispose();
    _licensePlateController.dispose();
    _vehicleColorController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    // Validate current step before proceeding
    if (_currentStep == 0 && _formKey.currentState != null) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }
    
    // Collect current step data
    _collectCurrentStepData();
    
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitRegistration() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Submit registration data to API
      final response = await _driverService.registerDriver(_registrationData);
      
      if (response.success) {
        // Show success message
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, 'Registration submitted successfully!');
          
          // Navigate to dashboard
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Dashboard()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _error = response.error ?? 'Registration failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
      });
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          'Driver Registration',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_stepTitles.length, (index) {
                    return Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index <= _currentStep ? Colors.green : Colors.grey[300],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index <= _currentStep ? Colors.white : Colors.grey[600],
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8.h),
                Text(
                  _stepTitles[_currentStep],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of ${_stepTitles.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildDocumentsStep(),
                _buildVehicleInfoStep(),
                _buildBankDetailsStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Error Display
          if (_error != null)
            Container(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Navigation Buttons
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _currentStep == _stepTitles.length - 1 ? 'Submit' : 'Next',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            _buildTextField('Full Name', 'Enter your full name', _fullNameController, isRequired: true),
            _buildTextField('Email', 'Enter your email address', _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
            _buildTextField('Phone Number', 'Enter your phone number', _phoneController, isRequired: true, keyboardType: TextInputType.phone),
            _buildTextField('Date of Birth', 'DD/MM/YYYY', _dobController, isRequired: true),
            _buildTextField('Address', 'Enter your full address', _addressController, isRequired: true, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Required Documents',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDocumentUpload('National ID', 'Upload front and back of your ID'),
          _buildDocumentUpload('Driving License', 'Upload your valid driving license'),
          _buildDocumentUpload('Profile Photo', 'Upload a clear photo of yourself'),
          _buildDocumentUpload('Background Check', 'Upload background check document'),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildTextField('Vehicle Make', 'e.g., Toyota', _vehicleMakeController, isRequired: true),
          _buildTextField('Vehicle Model', 'e.g., Camry', _vehicleModelController, isRequired: true),
          _buildTextField('Vehicle Year', 'e.g., 2020', _vehicleYearController, isRequired: true, keyboardType: TextInputType.number),
          _buildTextField('License Plate', 'Enter license plate number', _licensePlateController, isRequired: true),
          _buildTextField('Vehicle Color', 'e.g., White', _vehicleColorController, isRequired: true),
          _buildDocumentUpload('Vehicle Registration', 'Upload vehicle registration document'),
          _buildDocumentUpload('Insurance Certificate', 'Upload valid insurance certificate'),
        ],
      ),
    );
  }

  Widget _buildBankDetailsStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          _buildTextField('Bank Name', 'Enter your bank name', _bankNameController, isRequired: true),
          _buildTextField('Account Holder Name', 'Enter account holder name', _accountHolderController, isRequired: true),
          _buildTextField('Account Number', 'Enter account number', _accountNumberController, isRequired: true, keyboardType: TextInputType.number),
          _buildTextField('Routing Number', 'Enter routing number', _routingNumberController, isRequired: true, keyboardType: TextInputType.number),
          _buildTextField('SWIFT Code', 'Enter SWIFT code (if applicable)', _swiftCodeController),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 24.sp),
                SizedBox(height: 8.h),
                Text(
                  'Registration Review',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Please review all your information before submitting. Once submitted, your application will be reviewed by our team within 24-48 hours.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'By submitting this application, you agree to our Terms of Service and Privacy Policy.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            } : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.black),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload(String label, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 32.sp, color: Colors.grey[600]),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    // Handle file upload
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Choose File',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
