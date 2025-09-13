import 'dart:io';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final ApiService _apiService = ApiService();

  // Document upload methods
  Future<ApiResponse<void>> uploadProfilePhoto({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadProfilePhoto,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'profile_photo',
    );
  }

  Future<ApiResponse<void>> uploadIdFront({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadIdFront,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'id_front',
    );
  }

  Future<ApiResponse<void>> uploadIdBack({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadIdBack,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'id_back',
    );
  }

  Future<ApiResponse<void>> uploadLicenseFront({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadLicenseFront,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'license_front',
    );
  }

  Future<ApiResponse<void>> uploadLicenseBack({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadLicenseBack,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'license_back',
    );
  }

  Future<ApiResponse<void>> uploadNoConvictionCertificate({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadNoConvictionCertificate,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'no_conviction_certificate',
    );
  }

  Future<ApiResponse<void>> uploadSelfieWithId({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadSelfieWithId,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'selfie_with_id',
    );
  }

  Future<ApiResponse<void>> uploadCarImage({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadCarImage,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'car_image',
    );
  }

  Future<ApiResponse<void>> uploadCarRegistrationFront({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadCarRegistrationFront,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'car_registration_front',
    );
  }

  Future<ApiResponse<void>> uploadCarRegistrationBack({
    required File file,
    required String phoneNumber,
  }) async {
    return await _apiService.uploadDocument(
      endpoint: ApiConstants.uploadCarRegistrationBack,
      file: file,
      phoneNumber: phoneNumber,
      fieldName: 'car_registration_back',
    );
  }

  // Batch upload method for multiple documents
  Future<Map<String, ApiResponse<void>>> uploadMultipleDocuments({
    required String phoneNumber,
    File? profilePhoto,
    File? idFront,
    File? idBack,
    File? licenseFront,
    File? licenseBack,
    File? noConvictionCertificate,
    File? selfieWithId,
    File? carImage,
    File? carRegistrationFront,
    File? carRegistrationBack,
  }) async {
    final Map<String, ApiResponse<void>> results = {};

    // Upload profile photo
    if (profilePhoto != null) {
      results['profile_photo'] = await uploadProfilePhoto(
        file: profilePhoto,
        phoneNumber: phoneNumber,
      );
    }

    // Upload ID documents
    if (idFront != null) {
      results['id_front'] = await uploadIdFront(
        file: idFront,
        phoneNumber: phoneNumber,
      );
    }

    if (idBack != null) {
      results['id_back'] = await uploadIdBack(
        file: idBack,
        phoneNumber: phoneNumber,
      );
    }

    // Upload license documents
    if (licenseFront != null) {
      results['license_front'] = await uploadLicenseFront(
        file: licenseFront,
        phoneNumber: phoneNumber,
      );
    }

    if (licenseBack != null) {
      results['license_back'] = await uploadLicenseBack(
        file: licenseBack,
        phoneNumber: phoneNumber,
      );
    }

    // Upload no conviction certificate
    if (noConvictionCertificate != null) {
      results['no_conviction_certificate'] = await uploadNoConvictionCertificate(
        file: noConvictionCertificate,
        phoneNumber: phoneNumber,
      );
    }

    // Upload selfie with ID
    if (selfieWithId != null) {
      results['selfie_with_id'] = await uploadSelfieWithId(
        file: selfieWithId,
        phoneNumber: phoneNumber,
      );
    }

    // Upload car documents
    if (carImage != null) {
      results['car_image'] = await uploadCarImage(
        file: carImage,
        phoneNumber: phoneNumber,
      );
    }

    if (carRegistrationFront != null) {
      results['car_registration_front'] = await uploadCarRegistrationFront(
        file: carRegistrationFront,
        phoneNumber: phoneNumber,
      );
    }

    if (carRegistrationBack != null) {
      results['car_registration_back'] = await uploadCarRegistrationBack(
        file: carRegistrationBack,
        phoneNumber: phoneNumber,
      );
    }

    return results;
  }

  // Helper method to check upload results
  bool allUploadsSuccessful(Map<String, ApiResponse<void>> results) {
    return results.values.every((response) => response.isSuccess);
  }

  // Get failed uploads
  List<String> getFailedUploads(Map<String, ApiResponse<void>> results) {
    return results.entries
        .where((entry) => entry.value.isError)
        .map((entry) => entry.key)
        .toList();
  }

  // Get upload summary
  String getUploadSummary(Map<String, ApiResponse<void>> results) {
    final successful = results.values.where((r) => r.isSuccess).length;
    final total = results.length;
    final failed = getFailedUploads(results);

    if (failed.isEmpty) {
      return 'All $total documents uploaded successfully';
    } else {
      return '$successful/$total documents uploaded. Failed: ${failed.join(', ')}';
    }
  }
}
