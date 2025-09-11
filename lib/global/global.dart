import 'dart:async';

// import 'package:assets_audio_player/assets_audio_player.dart'; // Commented out due to compatibility issues
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userName = '';
String userEmail = '';
const String googleMapKey = "AIzaSyDKCK7ObKSfI445t8A4dxaVcT3YiE8DsPIAIzaSyDKCK7ObKSfI445t8A4dxaVcT3YiE8DsPI";
const CameraPosition  googlePlexInitialPosition = CameraPosition(
  target: LatLng(31.9454, 35.9284), // Amman, Jordan
  zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomePage;
StreamSubscription<Position>? positionStreamNewTripPage;


int driverTripRequestTimeout = 40;

// final audioPlayer = AssetsAudioPlayer(); // Commented out due to compatibility issues

Position? driverCurrentPosition;

String driverName = "";
String driverPhone = "";
String driverPhoto = "";
String driverEmail = "";
String carModel = "";
String carColor = "";
String carNumber = "";
String driverSecondName = "";
String address = "";
String ratting = "0.0";
String bidAmount = "";
String fareAmount = "";
