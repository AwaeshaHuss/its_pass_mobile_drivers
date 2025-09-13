import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/driver_service.dart';
import '../../core/models/trip_models.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../core/utils/error_handler.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({super.key});

  @override
  State<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  final DriverService _driverService = DriverService();
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'This Week';
  double _totalEarnings = 0.0;
  int _totalTrips = 0;

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _loadEarningsHistory();
  }

  Future<void> _loadEarningsHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final trips = await _driverService.getTripHistory();
      final filteredTrips = _filterTripsByPeriod(trips, _selectedPeriod);
      
      setState(() {
        _trips = filteredTrips;
        _totalEarnings = _calculateTotalEarnings(filteredTrips);
        _totalTrips = filteredTrips.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  List<Trip> _filterTripsByPeriod(List<Trip> trips, String period) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'This Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        final endDate = DateTime(now.year, now.month, 0);
        return trips.where((trip) {
          final tripDate = DateTime.parse(trip.createdAt);
          return tripDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 tripDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      case 'All Time':
      default:
        return trips;
    }

    return trips.where((trip) {
      final tripDate = DateTime.parse(trip.createdAt);
      return tripDate.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
  }

  double _calculateTotalEarnings(List<Trip> trips) {
    return trips.fold(0.0, (sum, trip) => sum + trip.fare);
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
          'Earnings History',
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
          // Period Selector
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20.sp),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                items: _periods.map((period) {
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                    _loadEarningsHistory();
                  }
                },
              ),
            ),
          ),

          // Summary Cards
          if (!_isLoading && _error == null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Earnings',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '\$${_totalEarnings.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Trips',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$_totalTrips',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Content
          Expanded(
            child: _isLoading
                ? const CustomLoadingWidget(message: 'Loading earnings history...')
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _loadEarningsHistory,
                      )
                    : _trips.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64.sp,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No earnings found',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Complete trips to see your earnings history',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: _trips.length,
                            itemBuilder: (context, index) {
                              final trip = _trips[index];
                              return _buildTripEarningCard(trip);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripEarningCard(Trip trip) {
    final tripDate = DateTime.parse(trip.createdAt);
    final formattedDate = '${tripDate.day}/${tripDate.month}/${tripDate.year}';
    final formattedTime = '${tripDate.hour.toString().padLeft(2, '0')}:${tripDate.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
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
                'Trip #${trip.id}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: trip.status == 'completed' ? Colors.green[100] : Colors.orange[100],
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  trip.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: trip.status == 'completed' ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on, size: 16.sp, color: Colors.grey[600]),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  '${trip.pickupAddress} → ${trip.destinationAddress}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    '$formattedDate at $formattedTime',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                '\$${trip.fare.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
