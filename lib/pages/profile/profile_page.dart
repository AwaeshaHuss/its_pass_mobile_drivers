import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:itspass_driver/pages/profileUpdation/driver_main_info.dart';
import 'package:itspass_driver/providers/auth_provider.dart';
import 'package:itspass_driver/providers/registration_provider.dart';

import '../../global/global.dart';
import '../../widgets/ratting_stars.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<RegistrationProvider>(context, listen: false)
        .retrieveCurrentDriverInfo();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account and preferences',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Profile Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Image
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2.w),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: driverPhoto,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Name
                    Text(
                      driverName.isEmpty && driverSecondName.isEmpty 
                          ? "Driver Name" 
                          : "$driverName $driverSecondName".trim(),
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RatingStars(ratting: ratting.isEmpty ? "0.0" : ratting),
                        SizedBox(width: 8.w),
                        Text(
                          ratting.isEmpty ? "0.0" : ratting,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Contact Info
                    _buildInfoRow(Icons.phone, driverPhone.isEmpty ? "Phone not set" : driverPhone),
                    if (driverEmail.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(Icons.email, driverEmail),
                    ],
                    if (address.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildInfoRow(Icons.location_on, address),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Menu Items
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DriverMainInfo()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'App preferences and notifications',
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get support and find answers',
                onTap: () {
                  // TODO: Navigate to help center
                },
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and legal information',
                onTap: () {
                  // TODO: Navigate to about page
                },
              ),

              SizedBox(height: 40.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () async {
                    await _showLogoutDialog(context, authProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24.sp,
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
                  SizedBox(height: 4.h),
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
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, AuthenticationProvider authProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}
