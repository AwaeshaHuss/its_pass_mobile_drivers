import 'dart:async';
// import 'dart:convert'; // Removed due to unused import
// import 'dart:typed_data'; // Removed due to unused import

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_geofire/flutter_geofire.dart'; // Commented out due to compatibility issues with AGP 8.1.0+
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:itspass_driver/global/global.dart';
import 'package:itspass_driver/providers/registration_provider.dart';

import '../../methods/map_theme_methods.dart';
import '../../pushNotifications/push_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> googleMapCompleterController =
      Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  Color colorToShow = Colors.black;
  String titleToShow = "GO ONLINE NOW";
  bool isDriverAvailable = false;
  StreamSubscription<Position>? positionStreamHomePage;
  // Removed Firebase Database reference - now using API calls
  MapThemeMethods themeMethods = MapThemeMethods();

  getCurrentLiveLocationOfDriver() async {
    try {
      // Check location permissions first
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      Position positionOfUser = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPositionOfDriver = positionOfUser;
      driverCurrentPosition = currentPositionOfDriver;

      LatLng positionOfUserInLatLng = LatLng(
          currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

      CameraPosition cameraPosition =
          CameraPosition(target: positionOfUserInLatLng, zoom: 15);
      
      if (controllerGoogleMap != null) {
        try {
          await controllerGoogleMap!
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        } catch (e) {
          print("Error animating camera: $e");
          // Fallback to direct position setting
          try {
            await controllerGoogleMap!
                .moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
          } catch (moveError) {
            print("Error moving camera: $moveError");
          }
        }
      }
    } catch (e) {
      print("Error getting location: $e");
      // Use default Jordan location if location access fails
      LatLng defaultPosition = const LatLng(31.9454, 35.9284); // Amman, Jordan
      CameraPosition defaultCameraPosition =
          CameraPosition(target: defaultPosition, zoom: 12);
      
      if (controllerGoogleMap != null) {
        try {
          await controllerGoogleMap!
              .animateCamera(CameraUpdate.newCameraPosition(defaultCameraPosition));
        } catch (e) {
          print("Error animating to default camera: $e");
          // Fallback to direct position setting
          try {
            await controllerGoogleMap!
                .moveCamera(CameraUpdate.newCameraPosition(defaultCameraPosition));
          } catch (moveError) {
            print("Error moving to default camera: $moveError");
          }
        }
      }
    }
  }

  _loadDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isDriverAvailable = prefs.getBool('isDriverAvailable') ?? false;
      if (isDriverAvailable) {
        colorToShow = Colors.red[400]!;
        titleToShow = "GO OFFLINE NOW";
      } else {
        colorToShow = Colors.black;
        titleToShow = "GO ONLINE NOW";
      }
    });
  }

  _saveDriverStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDriverAvailable', status);
  }

  goOnlineNow() {
    //all drivers who are Available for new trip requests
    // Geofire.initialize("onlineDrivers"); // Commented out due to compatibility issues with AGP 8.1.0+

    // Geofire.setLocation( // Commented out due to compatibility issues with AGP 8.1.0+
    //   FirebaseAuth.instance.currentUser!.uid,
    //   currentPositionOfDriver!.latitude,
    //   currentPositionOfDriver!.longitude,
    // );
    print("Geofire functionality temporarily disabled due to compatibility issues.");

    // TODO: Replace with API call to set driver status to "waiting"
    // await updateDriverStatus("waiting");
  }

  setAndGetLocationUpdates() {
    positionStreamHomePage =
        Geolocator.getPositionStream().listen((Position position) {
      currentPositionOfDriver = position;

      if (isDriverAvailable == true) {
        // Geofire.setLocation( // Commented out due to compatibility issues with AGP 8.1.0+
        //   FirebaseAuth.instance.currentUser!.uid,
        //   currentPositionOfDriver!.latitude,
        //   currentPositionOfDriver!.longitude,
        // );
        print("Geofire location update temporarily disabled due to compatibility issues.");
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      if (controllerGoogleMap != null) {
        try {
          controllerGoogleMap!
              .animateCamera(CameraUpdate.newLatLng(positionLatLng));
        } catch (e) {
          print("Error animating camera in position stream: $e");
          // Fallback to direct position setting
          try {
            controllerGoogleMap!
                .moveCamera(CameraUpdate.newLatLng(positionLatLng));
          } catch (moveError) {
            print("Error moving camera in position stream: $moveError");
          }
        }
      }
    });
  }

  goOfflineNow() {
    //stop sharing driver live location updates
    // Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid); // Commented out due to compatibility issues with AGP 8.1.0+
    print("Geofire remove location temporarily disabled due to compatibility issues.");

    // Cancel location stream when going offline
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.cancel();
      positionStreamHomePage = null;
      print("Location stream cancelled - driver is now offline");
    }

    // TODO: Replace with API call to set driver status to "offline"
    // await updateDriverStatus("offline");
  }

  initializePushNotificationSystem() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final dio = Dio();
    
    PushNotificationSystem notificationSystem = PushNotificationSystem(
      dio: dio,
      sharedPreferences: sharedPreferences,
      baseUrl: 'https://your-api-base-url.com/api', // TODO: Replace with actual API URL
    );
    notificationSystem.generateDeviceRegistrationToken();
    notificationSystem.startListeningForNewNotification(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadDriverStatus();
    initializePushNotificationSystem();
    Provider.of<RegistrationProvider>(context, listen: false)
        .retrieveCurrentDriverInfo();
    
  }

  @override
  void dispose() {
    // Cancel location stream to prevent memory leaks
    if (positionStreamHomePage != null) {
      positionStreamHomePage!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            padding: const EdgeInsets.only(top: 140),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController) async {
              try {
                controllerGoogleMap = mapController;
                googleMapCompleterController.complete(controllerGoogleMap);
                
                // Add a small delay to ensure map is fully initialized
                await Future.delayed(const Duration(milliseconds: 500));
                
                // Apply dark theme if needed
                themeMethods.updateMapTheme(controllerGoogleMap!);
                
                // Get current location
                getCurrentLiveLocationOfDriver();
              } catch (e) {
                print("Error initializing map: $e");
              }
            },
          ),

          // Top Header
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isDriverAvailable ? 'You\'re Online' : 'You\'re Offline',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDriverAvailable 
                                    ? 'Ready to accept trips'
                                    : 'Go online to start earning',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDriverAvailable ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Online/Offline Toggle Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _showStatusChangeDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDriverAvailable ? Colors.red[400] : Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          titleToShow,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Buttons
          Positioned(
            right: 20,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "location",
                  onPressed: getCurrentLiveLocationOfDriver,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: "menu",
                  onPressed: () {
                    // TODO: Add menu functionality
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    (!isDriverAvailable) ? "Go Online" : "Go Offline",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    (!isDriverAvailable)
                        ? "You'll start receiving trip requests from nearby riders."
                        : "You'll stop receiving new trip requests.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print("Toggle button pressed. Current state: isDriverAvailable = $isDriverAvailable");
                            if (!isDriverAvailable) {
                              print("Going online...");
                              goOnlineNow();
                              setAndGetLocationUpdates();
                              setState(() {
                                colorToShow = Colors.red[400]!;
                                titleToShow = "GO OFFLINE NOW";
                                isDriverAvailable = true;
                              });
                              _saveDriverStatus(true);
                              print("Driver is now ONLINE");
                            } else {
                              print("Going offline...");
                              goOfflineNow();
                              setState(() {
                                colorToShow = Colors.black;
                                titleToShow = "GO ONLINE NOW";
                                isDriverAvailable = false;
                              });
                              _saveDriverStatus(false);
                              print("Driver is now OFFLINE");
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (!isDriverAvailable) ? Colors.black : Colors.red[400],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            (!isDriverAvailable) ? "Go Online" : "Go Offline",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
