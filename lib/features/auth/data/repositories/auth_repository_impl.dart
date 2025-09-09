import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/driver_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DriverEntity>> signInWithPhone(String phoneNumber) async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.signInWithPhone(phoneNumber);
        await localDataSource.cacheDriver(driver);
        await localDataSource.setDriverLoggedIn(true);
        return Right(driver.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> verifyOtp(String verificationId, String otp) async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.verifyOtp(verificationId, otp);
        await localDataSource.cacheDriver(driver);
        await localDataSource.setDriverLoggedIn(true);
        return Right(driver.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> signInWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final driver = await remoteDataSource.signInWithGoogle();
        await localDataSource.cacheDriver(driver);
        await localDataSource.setDriverLoggedIn(true);
        return Right(driver.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, DriverEntity?>> getCurrentDriver() async {
    try {
      // First try to get from cache
      final cachedDriver = await localDataSource.getCachedDriver();
      if (cachedDriver != null) {
        return Right(cachedDriver.toEntity());
      }

      // If not in cache and connected, try remote
      if (await networkInfo.isConnected) {
        final driver = await remoteDataSource.getCurrentDriver();
        if (driver != null) {
          await localDataSource.cacheDriver(driver);
          return Right(driver.toEntity());
        }
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on CacheException {
      return Left(CacheFailure());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isDriverBlocked(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final isBlocked = await remoteDataSource.isDriverBlocked(driverId);
        return Right(isBlocked);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isDriverProfileComplete(String driverId) async {
    if (await networkInfo.isConnected) {
      try {
        final isComplete = await remoteDataSource.isDriverProfileComplete(driverId);
        return Right(isComplete);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, DriverEntity>> updateDriverProfile(DriverEntity driver) async {
    if (await networkInfo.isConnected) {
      try {
        final driverModel = driver.toModel();
        final updatedDriver = await remoteDataSource.updateDriverProfile(driverModel);
        await localDataSource.cacheDriver(updatedDriver);
        return Right(updatedDriver.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String imagePath) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrl = await remoteDataSource.uploadProfileImage(imagePath);
        return Right(imageUrl);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
