import 'package:flutter/material.dart';
import '../core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripProvider with ChangeNotifier {
  final Dio? dio;
  final SharedPreferences? sharedPreferences;
  final String? baseUrl;
  
  String currentDriverTotalTripsCompleted = "";
  bool isLoading = true;
  List<Map<String, dynamic>> completedTrips = [];

  TripProvider({this.dio, this.sharedPreferences, this.baseUrl});

  // Method to fetch the total trips completed by the current driver
  Future<void> getCurrentDriverTotalNumberOfTripsCompleted() async {
    try {
      isLoading = true;
      notifyListeners();

      if (dio != null && sharedPreferences != null && baseUrl != null) {
        final token = sharedPreferences!.getString('auth_token');
        
        if (token != null) {
          final response = await dio!.get(
            '$baseUrl/mobile/driver/trip-history',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          );
          
          if (response.statusCode == 200) {
            final List<dynamic> trips = response.data['trips'] ?? [];
            currentDriverTotalTripsCompleted = trips.length.toString();
            // Also store the trips data for later use
            completedTrips = trips.map((trip) => Map<String, dynamic>.from(trip)).toList();
          } else {
            currentDriverTotalTripsCompleted = "0";
          }
        } else {
          currentDriverTotalTripsCompleted = "0";
        }
      } else {
        currentDriverTotalTripsCompleted = "0";
      }

      AppLogger.info("Total trips completed: $currentDriverTotalTripsCompleted");
    } catch (e) {
      AppLogger.error('Error fetching trip count', e);
      currentDriverTotalTripsCompleted = "0";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to fetch completed trips for the current driver
  Future<void> getCompletedTrips() async {
    try {
      isLoading = true;
      notifyListeners();

      if (dio != null && sharedPreferences != null && baseUrl != null) {
        final token = sharedPreferences!.getString('auth_token');
        
        if (token != null) {
          final response = await dio!.get(
            '$baseUrl/mobile/driver/trip-history',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
          );
          
          if (response.statusCode == 200) {
            final List<dynamic> tripsData = response.data['trips'] ?? [];
            completedTrips = tripsData.map((trip) => Map<String, dynamic>.from(trip)).toList();
          } else {
            completedTrips.clear();
          }
        } else {
          completedTrips.clear();
        }
      } else {
        completedTrips.clear();
      }

      AppLogger.info("Completed trips count: ${completedTrips.length}");
    } catch (e) {
      AppLogger.error('Error fetching completed trips', e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
