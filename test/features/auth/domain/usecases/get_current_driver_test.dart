import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uber_drivers_app/core/errors/failures.dart';
import 'package:uber_drivers_app/core/utils/either.dart';
import 'package:uber_drivers_app/core/utils/usecase.dart';
import 'package:uber_drivers_app/features/auth/domain/entities/driver_entity.dart';
import 'package:uber_drivers_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/get_current_driver.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentDriver usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentDriver(mockAuthRepository);
  });

  final tDriver = DriverEntity(
    id: '1',
    name: 'Test Driver',
    email: 'test@example.com',
    phone: '+1234567890',
    isBlocked: false,
    isApproved: true,
    rating: 4.5,
    totalTrips: 10,
    totalEarnings: 500.0,
    status: 'online',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  test('should get current driver from the repository', () async {
    // arrange
    when(() => mockAuthRepository.getCurrentDriver())
        .thenAnswer((_) async => Right(tDriver));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result.isRight, true);
    if (result.isRight) {
      expect(result.right, tDriver);
    }
    verify(() => mockAuthRepository.getCurrentDriver());
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockAuthRepository.getCurrentDriver())
        .thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result.isLeft, true);
    verify(() => mockAuthRepository.getCurrentDriver());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
