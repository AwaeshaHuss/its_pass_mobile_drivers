import 'dart:developer';

// import 'package:assets_audio_player/assets_audio_player.dart'; // Commented out due to compatibility issues
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_notification_channel/flutter_notification_channel.dart'; // Commented out due to compatibility issues
// import 'package:flutter_notification_channel/notification_importance.dart'; // Commented out due to compatibility issues
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../global/global.dart';
import '../main.dart';
import '../models/trip_details.dart';
import '../widgets/notification_dialog.dart';

class PushNotificationSystem {
  final FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;
  final Dio dio;
  final SharedPreferences sharedPreferences;
  final String baseUrl;

  PushNotificationSystem({
    required this.dio,
    required this.sharedPreferences,
    required this.baseUrl,
  });

  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();

    // Send device token to API instead of Firebase Database
    final token = sharedPreferences.getString('auth_token');
    final driverId = sharedPreferences.getString('driver_id');
    
    if (token != null && driverId != null && deviceRecognitionToken != null) {
      try {
        await dio.put(
          '$baseUrl/drivers/$driverId/device-token',
          data: {'deviceToken': deviceRecognitionToken},
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (e) {
        log('Failed to update device token: $e');
      }
    }

    firebaseCloudMessaging.subscribeToTopic("drivers");
    firebaseCloudMessaging.subscribeToTopic("users");
    return deviceRecognitionToken;
  }

  startListeningForNewNotification(BuildContext context) async {
    // var result = await FlutterNotificationChannel().registerNotificationChannel(
    //   description: 'For Showing Message Notification',
    //   id: 'uberApp',
    //   importance: NotificationImportance.IMPORTANCE_HIGH,
    //   name: 'UberApp',
    // );

    // log('\nNotification Channel Result: $result'); // Commented out due to compatibility issues

    //Terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });
    //Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });

    //Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String tripID = messageRemote.data["tripID"];
        print(tripID);
        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context) async {
    // Use the global navigatorKey to get the current context
    final currentContext = navigatorKey.currentContext;

    if (currentContext != null) {
      try {
        final token = sharedPreferences.getString('auth_token');
        if (token == null) {
          log("Error: No authentication token found");
          return;
        }

        // Get trip request from API instead of Firebase Database
        final response = await dio.get(
          '$baseUrl/trips/$tripID',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          
          // Log the received data for debugging
          log("Trip Data: $data");

          // audioPlayer.open(
          //   Audio("assets/audio/alert-sound.mp3"),
          // );

          // audioPlayer.play(); // Commented out due to compatibility issues

          TripDetails tripDetailsInfo = TripDetails();

          // Extracting pickup location
          final pickUpLatLng = data["pickUpLatLng"] as Map<String, dynamic>;
          double pickUpLat = double.parse(pickUpLatLng["latitude"].toString());
          double pickUpLng = double.parse(pickUpLatLng["longitude"].toString());
          tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

          // Pickup address
          tripDetailsInfo.pickupAddress = data["pickUpAddress"].toString();

          // Extracting dropoff location
          final dropOffLatLng = data["dropOffLatLng"] as Map<String, dynamic>;
          double dropOffLat =
              double.parse(dropOffLatLng["latitude"].toString());
          double dropOffLng =
              double.parse(dropOffLatLng["longitude"].toString());
          tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

          // Dropoff address
          tripDetailsInfo.dropOffAddress = data["dropOffAddress"].toString();

          // User details
          tripDetailsInfo.userName = data["userName"].toString();
          tripDetailsInfo.userPhone = data["userPhone"].toString();
          bidAmount = data["bidAmount"].toString();
          fareAmount = data["fareAmount"].toString();

          // Trip ID
          tripDetailsInfo.tripID = tripID;

          // Show the notification dialog with trip details
          showDialog(
            context: currentContext,
            builder: (BuildContext context) => NotificationDialog(
              tripDetailsInfo: tripDetailsInfo,
              bidAmount: bidAmount,
              fareAmount: fareAmount,
            ),
          );
        } else {
          log("Error: Failed to fetch trip data for tripID $tripID");
        }
      } catch (e, stackTrace) {
        // Catch any errors during API call or parsing
        log("Error retrieving trip request info: $e\n$stackTrace");
      }
    }
  }
}
