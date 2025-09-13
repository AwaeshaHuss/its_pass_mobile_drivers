import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/app_logger.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/driver_service.dart';
import '../../core/models/trip_models.dart';
import '../../core/utils/error_handler.dart';
import 'trip_completion_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final Trip trip;
  
  const ActiveTripScreen({super.key, required this.trip});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  final DriverService _driverService = DriverService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  
  String _tripStatus = 'accepted';
  String _buttonText = 'Arrived at Pickup';
  Color _buttonColor = Colors.blue;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupMapMarkers();
    _getCurrentLocation();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _setupMapMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(widget.trip.pickupLatitude, widget.trip.pickupLongitude),
        infoWindow: InfoWindow(
          title: 'Pickup Location',
          snippet: widget.trip.pickupAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(widget.trip.destinationLatitude, widget.trip.destinationLongitude),
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.trip.destinationAddress,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = position;
          _markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        });
      }
    } catch (e) {
      AppLogger.info('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _markers.removeWhere((marker) => marker.markerId.value == 'driver');
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      // Update driver location to server
      _updateDriverLocation(position);
    });
  }

  Future<void> _updateDriverLocation(Position position) async {
    try {
      await _driverService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      AppLogger.info('Error updating location: $e');
    }
  }

  Future<void> _updateTripStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String newStatus;
      switch (_tripStatus) {
        case 'accepted':
          newStatus = 'arrived';
          break;
        case 'arrived':
          newStatus = 'in_progress';
          break;
        case 'in_progress':
          newStatus = 'completed';
          break;
        default:
          return;
      }

      final response = await _driverService.updateTripStatus(
        widget.trip.id.toString(),
        newStatus,
      );

      if (response.success) {
        setState(() {
          _tripStatus = newStatus;
          _updateButtonState();
        });

        if (newStatus == 'completed') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TripCompletionScreen(trip: widget.trip),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorSnackBar(context, response.error ?? 'Failed to update trip status');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, ErrorHandler.getErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateButtonState() {
    switch (_tripStatus) {
      case 'accepted':
        _buttonText = 'Arrived at Pickup';
        _buttonColor = Colors.blue;
        break;
      case 'arrived':
        _buttonText = 'Start Trip';
        _buttonColor = Colors.orange;
        break;
      case 'in_progress':
        _buttonText = 'Complete Trip';
        _buttonColor = Colors.green;
        break;
    }
  }

  String _getTripStatusText() {
    switch (_tripStatus) {
      case 'accepted':
        return 'Driving to pickup location';
      case 'arrived':
        return 'Arrived at pickup - Waiting for passenger';
      case 'in_progress':
        return 'Trip in progress';
      default:
        return 'Trip status unknown';
    }
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
          'Active Trip',
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
          // Map Section
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                        : LatLng(widget.trip.pickupLatitude, widget.trip.pickupLongitude),
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                ),
              ),
            ),
          ),

          // Trip Info Section
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trip Status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: _buttonColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: _buttonColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(_getStatusIcon(), color: _buttonColor, size: 32.sp),
                        SizedBox(height: 8.h),
                        Text(
                          _getTripStatusText(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: _buttonColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Customer Info
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: widget.trip.customer.profilePhoto != null
                              ? NetworkImage(widget.trip.customer.profilePhoto!)
                              : null,
                          child: widget.trip.customer.profilePhoto == null
                              ? Icon(Icons.person, color: Colors.grey[600], size: 25.sp)
                              : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trip.customer.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (widget.trip.customer.rating != null)
                                Row(
                                  children: [
                                    Icon(Icons.star, color: Colors.amber, size: 14.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      widget.trip.customer.rating!.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // Call customer
                              },
                              icon: Icon(Icons.phone, color: Colors.green, size: 20.sp),
                            ),
                            IconButton(
                              onPressed: () {
                                // Message customer
                              },
                              icon: Icon(Icons.message, color: Colors.blue, size: 20.sp),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Trip Details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Distance',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.trip.distance.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${widget.trip.estimatedDuration} min',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Fare',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '\$${widget.trip.estimatedFare.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          Container(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateTripStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
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
                        _buttonText,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (_tripStatus) {
      case 'accepted':
        return Icons.directions_car;
      case 'arrived':
        return Icons.person_pin_circle;
      case 'in_progress':
        return Icons.navigation;
      default:
        return Icons.help;
    }
  }
}
