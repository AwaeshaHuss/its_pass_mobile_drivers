import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/driver_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, DriverEntity>> signInWithPhone(String phoneNumber);
  Future<Either<Failure, DriverEntity>> verifyOtp(String verificationId, String otp);
  Future<Either<Failure, DriverEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, DriverEntity?>> getCurrentDriver();
  Future<Either<Failure, bool>> isDriverBlocked(String driverId);
  Future<Either<Failure, bool>> isDriverProfileComplete(String driverId);
  Future<Either<Failure, DriverEntity>> updateDriverProfile(DriverEntity driver);
  Future<Either<Failure, String>> uploadProfileImage(String imagePath);
}
