import 'dart:async';
import 'dart:io';
// import 'package:firebase_auth/firebase_auth.dart'; // Removed Firebase Auth
// import 'package:firebase_database/firebase_database.dart'; // Removed Firebase Database
// import 'package:firebase_storage/firebase_storage.dart'; // Removed Firebase Storage
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:itspass_driver/global/global.dart';
import 'package:itspass_driver/methods/common_method.dart';
import 'package:itspass_driver/methods/image_picker_service.dart';
// Removed unused imports: driver.dart, vehicleInfo.dart, profile_page.dart
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

class RegistrationProvider extends ChangeNotifier {
  // final FirebaseAuth _auth = FirebaseAuth.instance; // Removed Firebase Auth
  // final FirebaseDatabase _database = FirebaseDatabase.instance; // Removed Firebase Database
  // final FirebaseStorage _storage = FirebaseStorage.instance; // Removed Firebase Storage
  
  final Dio dio;
  final SharedPreferences sharedPreferences;
  final String baseUrl;
  
  RegistrationProvider({
    required this.dio,
    required this.sharedPreferences,
    required this.baseUrl,
  });

  bool _isLoading = false;
  bool _isFetchLoading = false;
  XFile? _profilePhoto;
  bool _isPhotoAdded = false;
  bool _isFormValidBasic = false;
  bool _isFormValidCninc = false;
  XFile? _cnicFrontImage;
  XFile? _cnicBackImage;
  XFile? _cnicWithSelfieImage;
  bool _isFormValidDrivingLicense = false;
  XFile? _drivingLicenseFrontImage;
  XFile? _drivingLicenseBackImage;
  String? _selectedVehicle;
  bool _isVehicleBasicFormValid = false;
  final RegExp licenseRegExp = RegExp(r'^[A-Z]{2}-\d{2}-\d{4}$');
  XFile? _vehicleImage;
  bool _isVehiclePhotoAdded = false;
  XFile? _vehicleRegistrationFrontImage;
  XFile? _vehicleRegistrationBackImage;
  bool _isDataFetched = false;
  bool get isDataFetched => _isDataFetched;
  bool _currentDriverInfo = false;
  double _driverEarnings = 0.0;
  get driverEarnings => _driverEarnings;

  // TextEditingControllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController drivingLicenseController =
      TextEditingController();

  final TextEditingController brandController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController productionYearController =
      TextEditingController();

  // Getters
  XFile? get profilePhoto => _profilePhoto;
  bool get isPhotoAdded => _isPhotoAdded;
  bool get isFormValidBasic => _isFormValidBasic;
  bool get isLoading => _isLoading;
  bool get isFetchLoading => _isFetchLoading;
  XFile? get cnincFrontImage => _cnicFrontImage;
  XFile? get cnincBackImage => _cnicBackImage;
  bool get isFormValidCninc => _isFormValidCninc;
  bool get isFormValidDrivingLicnese => _isFormValidDrivingLicense;
  XFile? get cnicWithSelfieImage => _cnicWithSelfieImage;
  XFile? get drivingLicenseFrontImage => _drivingLicenseFrontImage;
  XFile? get drivingLicenseBackImage => _drivingLicenseBackImage;
  bool get isVehicleBasicFormValid => _isVehicleBasicFormValid;
  String? get selectedVehicle => _selectedVehicle;
  XFile? get vehicleImage => _vehicleImage;
  bool get isVehiclePhotoAdded => _isVehiclePhotoAdded;
  XFile? get vehicleRegistrationFrontImage => _vehicleRegistrationFrontImage;
  XFile? get vehicleRegistrationBackImage => _vehicleRegistrationBackImage;
  Timer? _debounce;

  CommonMethods commonMethods = CommonMethods();

  void startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void startFetchLoading() {
    _isFetchLoading = true;
    notifyListeners();
  }

  void stopFetchLoading() {
    _isFetchLoading = false;
    notifyListeners();
  }

  void initFields(AuthenticationProvider authProvider) {
    if (!authProvider.isGoogleSignedIn) {
      phoneController.text = authProvider.phoneNumber;
    }
    if (authProvider.isGoogleSignedIn) {
      // TODO: Get email from SharedPreferences or API instead of Firebase
      emailController.text = sharedPreferences.getString('driver_email') ?? '';
      phoneController.text = '';
    }
    checkBasicFormValidity();
  }

  void checkBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidBasic = firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          dobController.text.isNotEmpty &&
          _profilePhoto != null;
      notifyListeners();
    });
  }

  void checkCNICFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidCninc = _cnicFrontImage != null &&
          _cnicBackImage != null &&
          cnicController.text.isNotEmpty &&
          cnicController.text.length == 13;
      notifyListeners();
    });
  }

  // Check if the form is valid
  void checkDrivingLicenseFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isFormValidDrivingLicense = _drivingLicenseFrontImage != null &&
          _drivingLicenseBackImage != null &&
          drivingLicenseController.text.isNotEmpty &&
          licenseRegExp.hasMatch(drivingLicenseController.text);
      notifyListeners();
    });
  }

  void checkVehicleBasicFormValidity() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _isVehicleBasicFormValid = _selectedVehicle != null &&
          brandController.text.isNotEmpty &&
          colorController.text.isNotEmpty &&
          numberPlateController.text.isNotEmpty &&
          productionYearController.text.isNotEmpty;
      notifyListeners();
    });
  }

  void setSelectedVehicle(String vehicle) {
    _selectedVehicle = vehicle;
    checkVehicleBasicFormValidity();
    notifyListeners();
  }

  // Dispose controllers
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    cnicController.dispose();
    emailController.dispose();
    phoneController.dispose();
    drivingLicenseController.dispose();
    brandController.dispose();
    colorController.dispose();
    numberPlateController.dispose();
    productionYearController.dispose();
    super.dispose();
  }

  Future<void> pickProfileImageFromGallary() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _profilePhoto = image;
      _isPhotoAdded = true;
      notifyListeners();
    }
  }

  Future<void> pickVehicleImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _vehicleImage = image;
      _isVehiclePhotoAdded = true;
      notifyListeners();
    }
  }

  Future<void> pickAndCropCnincImage(bool isFrontImage) async {
    try {
      final ImagePickerService imagePickerService = ImagePickerService();

      final XFile? pickedFile = await imagePickerService.pickImageOnly(
        imageSource: ImageSource.camera,
      );

      if (pickedFile != null) {
        if (isFrontImage) {
          _cnicFrontImage = pickedFile;
        } else {
          _cnicBackImage = pickedFile;
        }
        checkCNICFormValidity();
        notifyListeners();
      }
    } catch (e) {
      print('Error picking CNIC image: $e');
    }
  }

  Future<void> pickAndCropVehicleRegistrationImages(bool isFrontImage) async {
    try {
      final ImagePickerService imagePickerService = ImagePickerService();

      final pickedFile = await imagePickerService.pickImageOnly(
        imageSource: ImageSource.camera,
      );

      if (pickedFile != null) {
        if (isFrontImage) {
          _vehicleRegistrationFrontImage = pickedFile;
        } else {
          _vehicleRegistrationBackImage = pickedFile;
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error picking vehicle registration image: $e');
    }
  }

  Future<void> pickAndCropDrivingLicenseImage(bool isFrontImage) async {
    try {
      final ImagePickerService imagePickerService = ImagePickerService();

      final pickedFile = await imagePickerService.pickImageOnly(
        imageSource: ImageSource.camera,
      );

      if (pickedFile != null) {
        if (isFrontImage) {
          _drivingLicenseFrontImage = pickedFile;
        } else {
          _drivingLicenseBackImage = pickedFile;
        }
        checkCNICFormValidity();
        notifyListeners();
      }
    } catch (e) {
      print('Error picking driving license image: $e');
    }
  }

  Future<void> pickCnincImageWithSelfie() async {
    try {
      final ImagePickerService imagePickerService = ImagePickerService();

      final pickedFile = await imagePickerService.pickImageOnly(
        imageSource: ImageSource.camera,
      );

      if (pickedFile != null) {
        _cnicWithSelfieImage = pickedFile;
        checkCNICFormValidity();
        notifyListeners();
      }
    } catch (e) {
      print('Error picking selfie with CNIC image: $e');
    }
  }

  Future<String> uploadImageToAPI(XFile? photo, String? imagePath) async {
    if (photo == null) {
      throw Exception("No image selected");
    }
    
    try {
      final file = File(photo.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imagePath ?? 'image'}.jpg';
      
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(file.path, filename: fileName),
        'path': imagePath ?? 'general',
      });
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.post(
        '$baseUrl/upload/profile-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> saveUserData(BuildContext context) async {
    if (!isFormValidBasic ||
        !isFormValidCninc ||
        !isFormValidDrivingLicnese ||
        !isVehicleBasicFormValid) {
      commonMethods.displaySnackBar("Fill all the details!", context);
      return;
    }
    try {
      startLoading();
      
      // Upload all images to API
      final profilePictureUrl = await uploadImageToAPI(_profilePhoto, "ProfilePicture");
      final frontCnincImageUrl = await uploadImageToAPI(_cnicFrontImage, "Cninc");
      final backCnincImageUrl = await uploadImageToAPI(_cnicBackImage, "Cninc");
      final faceWithCnincImageUrl = await uploadImageToAPI(_cnicWithSelfieImage, "SelfieWithCninc");
      final drivingLicenseFrontImageUrl = await uploadImageToAPI(_drivingLicenseFrontImage, "DrivingLicenseImages");
      final drivingLicenseBackImageUrl = await uploadImageToAPI(_drivingLicenseBackImage, "DrivingLicenseImages");
      final vehicleImageUrl = await uploadImageToAPI(_vehicleImage, "VehicleImage");
      final vehicleRegistrationFrontImageUrl = await uploadImageToAPI(_vehicleRegistrationFrontImage, "VehicleRegistrationImages");
      final vehicleRegistrationBackImageUrl = await uploadImageToAPI(_vehicleRegistrationBackImage, "VehicleRegistrationImages");

      final driverId = sharedPreferences.getString('driver_id') ?? '';
      
      final driverData = {
        'name': '${firstNameController.text} ${lastNameController.text}',
        'email': emailController.text,
        'profileImageUrl': profilePictureUrl,
        'vehicle': {
          'type': selectedVehicle.toString(),
          'make': brandController.text,
          'model': brandController.text,
          'year': int.tryParse(productionYearController.text) ?? 2020,
          'licensePlate': numberPlateController.text,
          'color': colorController.text,
        },
        'documents': {
          'cnicNumber': cnicController.text,
          'cnicFrontImage': frontCnincImageUrl,
          'cnicBackImage': backCnincImageUrl,
          'driverFaceWithCnic': faceWithCnincImageUrl,
          'drivingLicenseNumber': drivingLicenseController.text,
          'drivingLicenseFrontImage': drivingLicenseFrontImageUrl,
          'drivingLicenseBackImage': drivingLicenseBackImageUrl,
          'vehicleImage': vehicleImageUrl,
          'vehicleRegistrationFrontImage': vehicleRegistrationFrontImageUrl,
          'vehicleRegistrationBackImage': vehicleRegistrationBackImageUrl,
        },
        'personalInfo': {
          'address': addressController.text,
          'dateOfBirth': dobController.text,
          'phoneNumber': phoneController.text,
        }
      };

      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Profile updated successfully!", context);
      } else {
        throw Exception('Failed to save driver data: ${response.statusMessage}');
      }
      
      stopLoading();
    } catch (e) {
      stopLoading();
      commonMethods.displaySnackBar("An error occurred while saving user data: $e", context);
      print("An error occurred while saving user data: $e");
    }
  }

  Future<void> fetchUserData() async {
    if (_isDataFetched) {
      print("Data already fetched, skipping...");
      return; // Data already fetched, so skip further fetching
    }
    try {
      startFetchLoading();
      
      // Get driver data from API instead of Firebase
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found in SharedPreferences');
      }
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.get(
        '$baseUrl/drivers/$driverId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;

        // Update fields based on the API response data
        final nameParts = (data['name'] ?? '').split(' ');
        firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
        lastNameController.text = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        addressController.text = data['personalInfo']?['address'] ?? '';
        dobController.text = data['personalInfo']?['dateOfBirth'] ?? '';
        cnicController.text = data['documents']?['cnicNumber'] ?? '';
        drivingLicenseController.text = data['documents']?['drivingLicenseNumber'] ?? '';
        _selectedVehicle = data['vehicle']?['type'] ?? '';
        brandController.text = data['vehicle']?['make'] ?? '';
        colorController.text = data['vehicle']?['color'] ?? '';
        numberPlateController.text = data['vehicle']?['licensePlate'] ?? '';
        productionYearController.text = data['vehicle']?['year']?.toString() ?? '';

        // Update XFile instances if URLs exist (download and save locally)
        if (data['profileImageUrl'] != null) {
          _profilePhoto = await _fetchImageFromUrl(data['profileImageUrl']);
        }
        if (data['documents']?['cnicFrontImage'] != null) {
          _cnicFrontImage = await _fetchImageFromUrl(data['documents']['cnicFrontImage']);
        }
        if (data['documents']?['cnicBackImage'] != null) {
          _cnicBackImage = await _fetchImageFromUrl(data['documents']['cnicBackImage']);
        }
        if (data['documents']?['driverFaceWithCnic'] != null) {
          _cnicWithSelfieImage = await _fetchImageFromUrl(data['documents']['driverFaceWithCnic']);
        }
        if (data['documents']?['drivingLicenseFrontImage'] != null) {
          _drivingLicenseFrontImage = await _fetchImageFromUrl(data['documents']['drivingLicenseFrontImage']);
        }
        if (data['documents']?['drivingLicenseBackImage'] != null) {
          _drivingLicenseBackImage = await _fetchImageFromUrl(data['documents']['drivingLicenseBackImage']);
        }
        if (data['documents']?['vehicleImage'] != null) {
          _vehicleImage = await _fetchImageFromUrl(data['documents']['vehicleImage']);
        }
        if (data['documents']?['vehicleRegistrationFrontImage'] != null) {
          _vehicleRegistrationFrontImage = await _fetchImageFromUrl(data['documents']['vehicleRegistrationFrontImage']);
        }
        if (data['documents']?['vehicleRegistrationBackImage'] != null) {
          _vehicleRegistrationBackImage = await _fetchImageFromUrl(data['documents']['vehicleRegistrationBackImage']);
        }
        
        _isDataFetched = true;
        stopFetchLoading();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch driver data: ${response.statusMessage}');
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
      stopFetchLoading();
    }
  }

  Future<XFile?> _fetchImageFromUrl(String url) async {
    try {
      // Fetch the image from the URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the temporary directory to store the downloaded image
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Write the image to the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Return the XFile
        return XFile(file.path);
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }

// Fetch the driver's earnings from API
  Future<void> fetchDriverEarnings() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.get(
        '$baseUrl/drivers/$driverId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        double earnings = double.tryParse(data['earnings']?.toString() ?? '0.0') ?? 0.0;
        _driverEarnings = double.parse(earnings.toStringAsFixed(2));
        notifyListeners();
      } else {
        _driverEarnings = 0.0;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching driver's earnings: $e");
      _driverEarnings = 0.0;
      notifyListeners();
    }
  }

  Future<void> retrieveCurrentDriverInfo() async {
    try {
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.get(
        '$baseUrl/drivers/$driverId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Update global variables based on the API response
        final nameParts = (data['name'] ?? '').split(' ');
        driverName = nameParts.isNotEmpty ? nameParts[0] : '';
        driverSecondName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
        driverPhone = data['phone'] ?? '';
        driverEmail = data['email'] ?? '';
        address = data['personalInfo']?['address'] ?? '';
        ratting = data['rating']?.toString() ?? '0';
        driverPhoto = data['profileImageUrl'] ?? '';
        carModel = data['vehicle']?['make'] ?? '';
        carColor = data['vehicle']?['color'] ?? '';
        carNumber = data['vehicle']?['licensePlate'] ?? '';

        notifyListeners();
      } else {
        throw Exception('Failed to fetch driver info: ${response.statusMessage}');
      }
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }

  Future<void> updateBasicDriverInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      String? newProfilePicture;
      if (_profilePhoto != null) {
        newProfilePicture = await uploadImageToAPI(_profilePhoto, "ProfilePicture");
      }
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final driverData = {
        'name': '${firstNameController.text} ${lastNameController.text}',
        'email': emailController.text,
        'personalInfo': {
          'address': addressController.text,
          'dateOfBirth': dobController.text,
          'phoneNumber': phoneController.text,
        },
      };
      
      if (newProfilePicture != null) {
        driverData['profileImageUrl'] = newProfilePicture;
      }
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Basic info updated successfully!", context);
      } else {
        throw Exception('Failed to update basic info: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating basic driver info: $e");
      commonMethods.displaySnackBar("Error updating basic info: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCnincInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final frontCnincImageUrl = await uploadImageToAPI(_cnicFrontImage, "Cninc");
      final backCnincImageUrl = await uploadImageToAPI(_cnicBackImage, "Cninc");
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final driverData = {
        'documents': {
          'cnicFrontImage': frontCnincImageUrl,
          'cnicBackImage': backCnincImageUrl,
          'cnicNumber': cnicController.text,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("CNIC info updated successfully!", context);
      } else {
        throw Exception('Failed to update CNIC info: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating CNIC info: $e");
      commonMethods.displaySnackBar("Error updating CNIC info: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSelfieWithCnincInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final faceWithCnincImageUrl = await uploadImageToAPI(_cnicWithSelfieImage, "SelfieWithCninc");
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final driverData = {
        'documents': {
          'driverFaceWithCnic': faceWithCnincImageUrl,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Selfie with CNIC updated successfully!", context);
      } else {
        throw Exception('Failed to update selfie: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating selfie info: $e");
      commonMethods.displaySnackBar("Error updating selfie: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatedriverLicenseInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final drivingLicenseFrontImageUrl = await uploadImageToAPI(_drivingLicenseFrontImage, "DrivingLicenseImages");
      final drivingLicenseBackImageUrl = await uploadImageToAPI(_drivingLicenseBackImage, "DrivingLicenseImages");
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final driverData = {
        'documents': {
          'drivingLicenseFrontImage': drivingLicenseFrontImageUrl,
          'drivingLicenseBackImage': drivingLicenseBackImageUrl,
          'drivingLicenseNumber': drivingLicenseController.text,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: driverData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Driving license updated successfully!", context);
      } else {
        throw Exception('Failed to update license: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating license info: $e");
      commonMethods.displaySnackBar("Error updating license: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicleBasicInfo(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final vehicleData = {
        'vehicle': {
          'type': selectedVehicle,
          'make': brandController.text,
          'color': colorController.text,
          'year': int.tryParse(productionYearController.text) ?? 2020,
          'licensePlate': numberPlateController.text,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: vehicleData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Vehicle info updated successfully!", context);
      } else {
        throw Exception('Failed to update vehicle info: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating vehicle info: $e");
      commonMethods.displaySnackBar("Error updating vehicle info: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicleImage(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final vehicleImageUrl = await uploadImageToAPI(_vehicleImage, "VehicleImage");
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final vehicleData = {
        'documents': {
          'vehicleImage': vehicleImageUrl,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: vehicleData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Vehicle image updated successfully!", context);
      } else {
        throw Exception('Failed to update vehicle image: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating vehicle image: $e");
      commonMethods.displaySnackBar("Error updating vehicle image: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicleRegistraionImages(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final vehicleRegistrationFrontImageUrl = await uploadImageToAPI(_vehicleRegistrationFrontImage, "VehicleRegistrationImages");
      final vehicleRegistrationBackImageUrl = await uploadImageToAPI(_vehicleRegistrationBackImage, "VehicleRegistrationImages");
      
      final driverId = sharedPreferences.getString('driver_id');
      if (driverId == null) {
        throw Exception('Driver ID not found');
      }
      
      final vehicleData = {
        'documents': {
          'vehicleRegistrationFrontImage': vehicleRegistrationFrontImageUrl,
          'vehicleRegistrationBackImage': vehicleRegistrationBackImageUrl,
        }
      };
      
      final token = sharedPreferences.getString('auth_token');
      final response = await dio.put(
        '$baseUrl/drivers/$driverId',
        data: vehicleData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        commonMethods.displaySnackBar("Vehicle registration images updated successfully!", context);
      } else {
        throw Exception('Failed to update registration images: ${response.statusMessage}');
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("An error occurred while updating registration images: $e");
      commonMethods.displaySnackBar("Error updating registration images: $e", context);
      _isLoading = false;
      notifyListeners();
    }
  }
}
