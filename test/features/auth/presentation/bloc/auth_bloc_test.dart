import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uber_drivers_app/core/errors/failures.dart';
import 'package:uber_drivers_app/core/utils/either.dart';
import 'package:uber_drivers_app/core/utils/usecase.dart';
import 'package:uber_drivers_app/features/auth/domain/entities/driver_entity.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/get_current_driver.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/sign_in_with_phone.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/sign_out.dart';
import 'package:uber_drivers_app/features/auth/domain/usecases/verify_otp.dart';
import 'package:uber_drivers_app/features/auth/presentation/bloc/auth_bloc.dart';

class MockGetCurrentDriver extends Mock implements GetCurrentDriver {}
class MockSignInWithPhone extends Mock implements SignInWithPhone {}
class MockVerifyOtp extends Mock implements VerifyOtp {}
class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}
class MockSignOut extends Mock implements SignOut {}

void main() {
  late AuthBloc authBloc;
  late MockGetCurrentDriver mockGetCurrentDriver;
  late MockSignInWithPhone mockSignInWithPhone;
  late MockVerifyOtp mockVerifyOtp;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetCurrentDriver = MockGetCurrentDriver();
    mockSignInWithPhone = MockSignInWithPhone();
    mockVerifyOtp = MockVerifyOtp();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();

    authBloc = AuthBloc(
      getCurrentDriver: mockGetCurrentDriver,
      signInWithPhone: mockSignInWithPhone,
      verifyOtp: mockVerifyOtp,
      signInWithGoogle: mockSignInWithGoogle,
      signOut: mockSignOut,
    );
  });

  tearDown(() {
    authBloc.close();
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

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when driver is found',
      build: () {
        when(() => mockGetCurrentDriver(any()))
            .thenAnswer((_) async => Right(tDriver));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(
          driver: tDriver,
          isProfileComplete: true,
          isBlocked: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when no driver is found',
      build: () {
        when(() => mockGetCurrentDriver(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when failure occurs',
      build: () {
        when(() => mockGetCurrentDriver(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );
  });

  group('AuthSignInWithGoogleRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthAuthenticated] when sign in succeeds',
      build: () {
        when(() => mockSignInWithGoogle(any()))
            .thenAnswer((_) async => Right(tDriver));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignInWithGoogleRequested()),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(
          driver: tDriver,
          isProfileComplete: true,
          isBlocked: false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when sign in fails',
      build: () {
        when(() => mockSignInWithGoogle(any()))
            .thenAnswer((_) async => const Left(AuthFailure('Sign in failed')));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignInWithGoogleRequested()),
      expect: () => [
        AuthLoading(),
        const AuthError('AuthFailure'),
      ],
    );
  });

  group('AuthSignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthUnauthenticated] when sign out succeeds',
      build: () {
        when(() => mockSignOut(any()))
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthSignOutRequested()),
      expect: () => [
        AuthLoading(),
        AuthUnauthenticated(),
      ],
    );
  });
}
