import '../core/utils/app_logger.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();
  
  // Simplified image picker without cropping to avoid crashes
  Future<XFile?> pickCropImage({
    required dynamic cropAspectRatio, // Keep for compatibility but ignore
    required ImageSource imageSource,
  }) async {
    try {
      AppLogger.info('Picking image from camera...');
      
      final XFile? image = await _picker.pickImage(
        source: imageSource,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        AppLogger.info('Image picked successfully: ${image.path}');
      } else {
        AppLogger.info('No image selected');
      }
      
      return image;
    } catch (e) {
      AppLogger.info('Error in pickCropImage: $e');
      return null;
    }
  }
  
  // Simple image picker method
  Future<XFile?> pickImageOnly({
    required ImageSource imageSource,
  }) async {
    try {
      AppLogger.info('Picking image only...');
      
      final XFile? image = await _picker.pickImage(
        source: imageSource,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        AppLogger.info('Image picked successfully: ${image.path}');
      } else {
        AppLogger.info('No image selected');
      }
      
      return image;
    } catch (e) {
      AppLogger.info('Error in pickImageOnly: $e');
      return null;
    }
  }
}
