import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();
  
  // Simplified image picker without cropping to avoid crashes
  Future<XFile?> pickCropImage({
    required dynamic cropAspectRatio, // Keep for compatibility but ignore
    required ImageSource imageSource,
  }) async {
    try {
      print('Picking image from camera...');
      
      final XFile? image = await _picker.pickImage(
        source: imageSource,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        print('Image picked successfully: ${image.path}');
      } else {
        print('No image selected');
      }
      
      return image;
    } catch (e) {
      print('Error in pickCropImage: $e');
      return null;
    }
  }
  
  // Simple image picker method
  Future<XFile?> pickImageOnly({
    required ImageSource imageSource,
  }) async {
    try {
      print('Picking image only...');
      
      final XFile? image = await _picker.pickImage(
        source: imageSource,
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        print('Image picked successfully: ${image.path}');
      } else {
        print('No image selected');
      }
      
      return image;
    } catch (e) {
      print('Error in pickImageOnly: $e');
      return null;
    }
  }
}
