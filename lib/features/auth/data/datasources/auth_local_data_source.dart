import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../models/driver_model.dart';

abstract class AuthLocalDataSource {
  Future<DriverModel?> getCachedDriver();
  Future<void> cacheDriver(DriverModel driver);
  Future<void> clearCache();
  Future<bool> isDriverLoggedIn();
  Future<void> setDriverLoggedIn(bool isLoggedIn);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String cachedDriverKey = 'CACHED_DRIVER';
  static const String isLoggedInKey = 'IS_DRIVER_LOGGED_IN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<DriverModel?> getCachedDriver() async {
    try {
      final jsonString = sharedPreferences.getString(cachedDriverKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return DriverModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheDriver(DriverModel driver) async {
    try {
      final jsonString = json.encode(driver.toJson());
      await sharedPreferences.setString(cachedDriverKey, jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        sharedPreferences.remove(cachedDriverKey),
        sharedPreferences.remove(isLoggedInKey),
      ]);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isDriverLoggedIn() async {
    try {
      return sharedPreferences.getBool(isLoggedInKey) ?? false;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> setDriverLoggedIn(bool isLoggedIn) async {
    try {
      await sharedPreferences.setBool(isLoggedInKey, isLoggedIn);
    } catch (e) {
      throw CacheException();
    }
  }
}
