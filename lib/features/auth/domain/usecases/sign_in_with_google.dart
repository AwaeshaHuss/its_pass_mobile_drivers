import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<DriverEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, DriverEntity>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
