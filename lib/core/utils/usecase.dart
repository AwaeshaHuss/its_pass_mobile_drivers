import 'package:equatable/equatable.dart';
import '../errors/failures.dart';
import 'either.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
