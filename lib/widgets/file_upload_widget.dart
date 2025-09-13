import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../core/services/file_upload_service.dart';
import '../core/utils/error_handler.dart';

class FileUploadWidget extends StatefulWidget {
  final String label;
  final String description;
  final Function(String?) onFileUploaded;
  final String? initialFileUrl;
  final bool isRequired;
  final List<String> allowedExtensions;

  const FileUploadWidget({
    super.key,
    required this.label,
    required this.description,
    required this.onFileUploaded,
    this.initialFileUrl,
    this.isRequired = false,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final FileUploadService _fileUploadService = FileUploadService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedFile;
  String? _uploadedFileUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _uploadedFileUrl = widget.initialFileUrl;
  }

  Future<void> _pickFile() async {
    try {
      setState(() {
        _error = null;
      });

      // Show options for camera or gallery
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
        await _uploadFile();
      }
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
      });
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select Image Source',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _error = null;
    });

    try {
      // Convert File to XFile for the upload service
      final xFile = XFile(_selectedFile!.path);
      
      // Simulate progress updates for better UX
      _simulateProgress();
      
      final response = await _fileUploadService.uploadFile(
        file: xFile,
        endpoint: '/api/upload', // Default endpoint, can be customized
      );

      if (response.success && response.data != null) {
        setState(() {
          _uploadProgress = 1.0;
          _uploadedFileUrl = response.data!;
          _isUploading = false;
        });
        widget.onFileUploaded(_uploadedFileUrl);
        
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(context, 'File uploaded successfully!');
        }
      } else {
        setState(() {
          _error = response.error ?? 'Upload failed';
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  void _simulateProgress() {
    // Simulate upload progress for better UX
    const duration = Duration(milliseconds: 100);
    const steps = 20;
    int currentStep = 0;
    
    Timer.periodic(duration, (timer) {
      if (!_isUploading || currentStep >= steps) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _uploadProgress = (currentStep / steps) * 0.9; // Max 90% during simulation
      });
      
      currentStep++;
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _uploadedFileUrl = null;
      _error = null;
    });
    widget.onFileUploaded(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (widget.isRequired)
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
          
          // Upload Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: _error != null ? Colors.red : Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: _buildUploadContent(),
          ),
          
          // Error Message
          if (_error != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                _error!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadContent() {
    if (_isUploading) {
      return _buildUploadingState();
    } else if (_uploadedFileUrl != null || _selectedFile != null) {
      return _buildUploadedState();
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 12.h),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Choose File',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadingState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          CircularProgressIndicator(
            value: _uploadProgress,
            strokeWidth: 3,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 12.h),
          Text(
            'Uploading... ${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedState() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // File Preview
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey[100],
            ),
            child: _selectedFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      _selectedFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : _uploadedFileUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          _uploadedFileUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.description,
                              size: 30.sp,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.description,
                        size: 30.sp,
                        color: Colors.grey[600],
                      ),
          ),
          SizedBox(width: 12.w),
          
          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'File uploaded successfully',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _pickFile,
                icon: Icon(
                  Icons.edit,
                  size: 20.sp,
                  color: Colors.blue,
                ),
                tooltip: 'Change file',
              ),
              IconButton(
                onPressed: _removeFile,
                icon: Icon(
                  Icons.delete,
                  size: 20.sp,
                  color: Colors.red,
                ),
                tooltip: 'Remove file',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
