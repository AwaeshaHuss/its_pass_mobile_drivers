import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import 'secure_storage_service.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  factory FileUploadService() => _instance;
  FileUploadService._internal();

  final Dio _dio = Dio();
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60); // Longer timeout for file uploads
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    
    // Add interceptor for automatic token attachment
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        handler.next(options);
      },
    ));
    
    _isInitialized = true;
  }

  Future<ApiResponse<String>> uploadFile({
    required XFile file,
    required String endpoint,
    String fieldName = 'file',
  }) async {
    try {
      initialize(); // Ensure service is initialized
      
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(response.data['file_url'] ?? response.data['url'] ?? '');
      } else {
        return ApiResponse.error('Upload failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        return ApiResponse.error('Upload failed: ${e.message}');
      }
      return ApiResponse.error('Upload failed: $e');
    }
  }

  // Profile Photo Upload
  Future<ApiResponse<String>> uploadProfilePhoto(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadProfilePhoto,
      fieldName: 'profile_photo',
    );
  }

  // ID Front Upload
  Future<ApiResponse<String>> uploadIdFront(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadIdFront,
      fieldName: 'id_front',
    );
  }

  // ID Back Upload
  Future<ApiResponse<String>> uploadIdBack(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadIdBack,
      fieldName: 'id_back',
    );
  }

  // License Front Upload
  Future<ApiResponse<String>> uploadLicenseFront(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadLicenseFront,
      fieldName: 'license_front',
    );
  }

  // License Back Upload
  Future<ApiResponse<String>> uploadLicenseBack(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadLicenseBack,
      fieldName: 'license_back',
    );
  }

  // No Conviction Certificate Upload
  Future<ApiResponse<String>> uploadNoConvictionCertificate(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadNoConvictionCertificate,
      fieldName: 'no_conviction_certificate',
    );
  }

  // Selfie with ID Upload
  Future<ApiResponse<String>> uploadSelfieWithId(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadSelfieWithId,
      fieldName: 'selfie_with_id',
    );
  }

  // Car Image Upload
  Future<ApiResponse<String>> uploadCarImage(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadCarImage,
      fieldName: 'car_image',
    );
  }

  // Car Registration Front Upload
  Future<ApiResponse<String>> uploadCarRegistrationFront(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadCarRegistrationFront,
      fieldName: 'car_registration_front',
    );
  }

  // Car Registration Back Upload
  Future<ApiResponse<String>> uploadCarRegistrationBack(XFile file) async {
    return uploadFile(
      file: file,
      endpoint: ApiConstants.uploadCarRegistrationBack,
      fieldName: 'car_registration_back',
    );
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
