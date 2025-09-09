import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithPhone implements UseCase<DriverEntity, SignInWithPhoneParams> {
  final AuthRepository repository;

  SignInWithPhone(this.repository);

  @override
  Future<Either<Failure, DriverEntity>> call(SignInWithPhoneParams params) async {
    return await repository.signInWithPhone(params.phoneNumber);
  }
}

class SignInWithPhoneParams extends Equatable {
  final String phoneNumber;

  const SignInWithPhoneParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
