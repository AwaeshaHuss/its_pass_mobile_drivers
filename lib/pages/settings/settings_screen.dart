import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/utils/error_handler.dart';
import '../../widgets/loading_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final NavigationService _navigationService = NavigationService();
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _autoAcceptTrips = false;
  String _language = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from secure storage or API
    // This would typically come from a settings API endpoint
    setState(() {
      _notificationsEnabled = true;
      _locationEnabled = true;
      _autoAcceptTrips = false;
      _language = 'English';
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save settings to API
      // await _driverService.updateSettings({
      //   'notifications_enabled': _notificationsEnabled,
      //   'location_enabled': _locationEnabled,
      //   'auto_accept_trips': _autoAcceptTrips,
      //   'language': _language,
      // });

      ErrorHandler.showSuccessMessage(context, 'Settings saved successfully');
    } catch (e) {
      ErrorHandler.showErrorMessage(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showLogoutDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();
      _navigationService.navigateToLogin();
    } catch (e) {
      ErrorHandler.showErrorMessage(context, ErrorHandler.getErrorMessage(e));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingCard(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive trip requests and updates',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),

            SizedBox(height: 24.h),

            // Location Section
            _buildSectionHeader('Location'),
            _buildSettingCard(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              subtitle: 'Allow app to access your location',
              trailing: Switch(
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                  _saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),

            SizedBox(height: 24.h),

            // Trip Settings Section
            _buildSectionHeader('Trip Settings'),
            _buildSettingCard(
              icon: Icons.auto_awesome_outlined,
              title: 'Auto Accept Trips',
              subtitle: 'Automatically accept trip requests',
              trailing: Switch(
                value: _autoAcceptTrips,
                onChanged: (value) {
                  setState(() {
                    _autoAcceptTrips = value;
                  });
                  _saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),

            SizedBox(height: 24.h),

            // Language Section
            _buildSectionHeader('Language'),
            _buildSettingCard(
              icon: Icons.language_outlined,
              title: 'Language',
              subtitle: _language,
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              onTap: () {
                _showLanguageDialog();
              },
            ),

            SizedBox(height: 24.h),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingCard(
              icon: Icons.person_outline,
              title: 'Profile Information',
              subtitle: 'Update your personal details',
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              onTap: () {
                // Navigate to profile update screen
              },
            ),
            _buildSettingCard(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              onTap: () {
                // Navigate to privacy settings
              },
            ),

            SizedBox(height: 24.h),

            // Support Section
            _buildSectionHeader('Support'),
            _buildSettingCard(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help with the app',
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              onTap: () {
                // Navigate to help screen
              },
            ),
            _buildSettingCard(
              icon: Icons.info_outline,
              title: 'About',
              subtitle: 'App version and information',
              trailing: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24.sp,
              ),
              onTap: () {
                // Show about dialog
              },
            ),

            SizedBox(height: 32.h),

            // Logout Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
                        'Logout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    icon,
                    size: 24.sp,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Text(
            'Select Language',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),
              _buildLanguageOption('العربية'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _language == language;
    return ListTile(
      title: Text(
        language,
        style: TextStyle(
          fontSize: 16.sp,
          color: isSelected ? Colors.green : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Colors.green, size: 20.sp)
          : null,
      onTap: () {
        setState(() {
          _language = language;
        });
        Navigator.of(context).pop();
        _saveSettings();
      },
    );
  }
}
