import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../providers/registration_provider.dart';
import '../../core/services/driver_service.dart';
import '../../core/utils/error_handler.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _earningsData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEarningsData();
  }

  Future<void> _fetchEarningsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final driverService = DriverService();
      final response = await driverService.getEarnings();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _earningsData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = ErrorHandler.getErrorMessage(response.error ?? 'Failed to load earnings');
          _isLoading = false;
        });
        
        // Fallback to provider method if API fails
        if (mounted) {
          Provider.of<RegistrationProvider>(context, listen: false)
              .fetchDriverEarnings();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
      
      // Fallback to provider method if API fails
      if (mounted) {
        Provider.of<RegistrationProvider>(context, listen: false)
            .fetchDriverEarnings();
      }
    }
  }

  Widget _buildEarningsDisplay() {
    if (_isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Loading...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<RegistrationProvider>(
            builder: (context, provider, child) {
              return Text(
                'JOD ${provider.driverEarnings ?? 0}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[300],
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'Using cached data',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Use API data if available, otherwise fallback to provider
    final totalEarnings = _earningsData?['total_earnings'] ?? 0;
    return Text(
      'JOD $totalEarnings',
      style: TextStyle(
        color: Colors.white,
        fontSize: 36.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Text(
          'Earnings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black, Color(0xFF2C2C2C)],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      offset: Offset(0, 4.h),
                      blurRadius: 20.r,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildEarningsDisplay(),
                  ],
                ),
              ),
              
              SizedBox(height: 32.h),
              
              // Quick Stats Section
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Trips',
                      value: '24',
                      icon: Icons.route_outlined,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Hours',
                      value: '32.5',
                      icon: Icons.access_time_outlined,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Rating',
                      value: '4.8',
                      icon: Icons.star_outline,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Distance',
                      value: '245 km',
                      icon: Icons.straighten_outlined,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to detailed earnings history
                    },
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16.h),
              
              // Activity List
              _buildActivityItem(
                date: 'Today',
                amount: 'JOD 1,250',
                trips: '5 trips',
                time: '6 hours',
              ),
              
              _buildActivityItem(
                date: 'Yesterday',
                amount: 'JOD 980',
                trips: '4 trips',
                time: '4.5 hours',
              ),
              
              _buildActivityItem(
                date: 'Dec 9',
                amount: 'JOD 1,450',
                trips: '6 trips',
                time: '7 hours',
              ),
              
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: Offset(0, 2.h),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem({
    required String date,
    required String amount,
    required String trips,
    required String time,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: Colors.grey[600],
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$trips • $time',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
