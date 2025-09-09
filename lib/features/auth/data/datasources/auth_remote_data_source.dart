import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../models/driver_model.dart';

abstract class AuthRemoteDataSource {
  Future<DriverModel> signInWithPhone(String phoneNumber);
  Future<DriverModel> verifyOtp(String verificationId, String otp);
  Future<DriverModel> signInWithGoogle();
  Future<void> signOut();
  Future<DriverModel?> getCurrentDriver();
  Future<bool> isDriverBlocked(String driverId);
  Future<bool> isDriverProfileComplete(String driverId);
  Future<DriverModel> updateDriverProfile(DriverModel driver);
  Future<String> uploadProfileImage(String imagePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
    required this.googleSignIn,
  });

  @override
  Future<DriverModel> signInWithPhone(String phoneNumber) async {
    try {
      // This would typically trigger OTP verification
      // For now, we'll simulate the process
      throw UnimplementedError('Phone auth requires OTP verification flow');
    } catch (e) {
      throw AuthException('Failed to sign in with phone: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> verifyOtp(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw AuthException('Authentication failed');
      }

      // Check if driver exists in Firestore
      final driverDoc = await firebaseFirestore
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (driverDoc.exists) {
        return DriverModel.fromJson({
          'id': user.uid,
          ...driverDoc.data()!,
        });
      } else {
        // Create new driver document
        final newDriver = DriverModel(
          id: user.uid,
          name: '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await firebaseFirestore
            .collection('drivers')
            .doc(user.uid)
            .set(newDriver.toJson());
            
        return newDriver;
      }
    } catch (e) {
      throw AuthException('OTP verification failed: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Google authentication failed');
      }

      // Check if driver exists in Firestore
      final driverDoc = await firebaseFirestore
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (driverDoc.exists) {
        return DriverModel.fromJson({
          'id': user.uid,
          ...driverDoc.data()!,
        });
      } else {
        // Create new driver document
        final newDriver = DriverModel(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: user.phoneNumber ?? '',
          profileImageUrl: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await firebaseFirestore
            .collection('drivers')
            .doc(user.uid)
            .set(newDriver.toJson());
            
        return newDriver;
      }
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel?> getCurrentDriver() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final driverDoc = await firebaseFirestore
          .collection('drivers')
          .doc(user.uid)
          .get();

      if (driverDoc.exists) {
        return DriverModel.fromJson({
          'id': user.uid,
          ...driverDoc.data()!,
        });
      }
      return null;
    } catch (e) {
      throw AuthException('Failed to get current driver: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDriverBlocked(String driverId) async {
    try {
      final driverDoc = await firebaseFirestore
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        final data = driverDoc.data()!;
        return data['isBlocked'] ?? false;
      }
      return false;
    } catch (e) {
      throw AuthException('Failed to check driver status: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDriverProfileComplete(String driverId) async {
    try {
      final driverDoc = await firebaseFirestore
          .collection('drivers')
          .doc(driverId)
          .get();

      if (driverDoc.exists) {
        final data = driverDoc.data()!;
        final driver = DriverModel.fromJson({'id': driverId, ...data});
        
        // Check if essential fields are filled
        return driver.name.isNotEmpty &&
               driver.phone.isNotEmpty &&
               driver.vehicle != null;
      }
      return false;
    } catch (e) {
      throw AuthException('Failed to check profile completeness: ${e.toString()}');
    }
  }

  @override
  Future<DriverModel> updateDriverProfile(DriverModel driver) async {
    try {
      final updatedDriver = driver.copyWith(updatedAt: DateTime.now());
      
      await firebaseFirestore
          .collection('drivers')
          .doc(driver.id)
          .update(updatedDriver.toJson());

      return updatedDriver;
    } catch (e) {
      throw AuthException('Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('User not authenticated');
      }

      final file = File(imagePath);
      final ref = firebaseStorage
          .ref()
          .child('drivers')
          .child(user.uid)
          .child('profile.jpg');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw AuthException('Failed to upload image: ${e.toString()}');
    }
  }
}
