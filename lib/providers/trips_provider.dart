import 'package:flutter/material.dart';
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
        final driverId = sharedPreferences!.getString('driver_id');
        final token = sharedPreferences!.getString('auth_token');
        
        if (driverId != null && token != null) {
          final response = await dio!.get(
            '$baseUrl/drivers/$driverId/trips/count',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );
          
          if (response.statusCode == 200) {
            currentDriverTotalTripsCompleted = response.data['totalTrips']?.toString() ?? "0";
          } else {
            currentDriverTotalTripsCompleted = "0";
          }
        } else {
          currentDriverTotalTripsCompleted = "0";
        }
      } else {
        currentDriverTotalTripsCompleted = "0";
      }

      print("Total trips completed: $currentDriverTotalTripsCompleted");
    } catch (e) {
      print("Error fetching total trips: $e");
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
        final driverId = sharedPreferences!.getString('driver_id');
        final token = sharedPreferences!.getString('auth_token');
        
        if (driverId != null && token != null) {
          final response = await dio!.get(
            '$baseUrl/drivers/$driverId/trips/completed',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
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

      print("Completed trips count: ${completedTrips.length}");
    } catch (e) {
      print("Error fetching completed trips: $e");
      completedTrips.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
