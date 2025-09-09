import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<DriverEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, DriverEntity>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(params.verificationId, params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String verificationId;
  final String otp;

  const VerifyOtpParams({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object> get props => [verificationId, otp];
}
