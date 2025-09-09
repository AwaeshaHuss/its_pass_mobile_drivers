import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/usecases/get_current_driver.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentDriver getCurrentDriver;
  final SignInWithPhone signInWithPhone;
  final VerifyOtp verifyOtp;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthBloc({
    required this.getCurrentDriver,
    required this.signInWithPhone,
    required this.verifyOtp,
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithPhoneRequested>(_onSignInWithPhoneRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentDriver(NoParams());
    
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (driver) {
        if (driver != null) {
          // TODO: Check if driver is blocked and profile is complete
          emit(AuthAuthenticated(
            driver: driver,
            isProfileComplete: true, // Placeholder
            isBlocked: false, // Placeholder
          ));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInWithPhoneRequested(
    AuthSignInWithPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithPhone(
      SignInWithPhoneParams(phoneNumber: event.phoneNumber),
    );

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (driver) {
        // In real implementation, this would trigger OTP flow
        emit(const AuthOtpSent(
          verificationId: 'dummy_verification_id',
          phoneNumber: '',
        ));
      },
    );
  }

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyOtp(
      VerifyOtpParams(
        verificationId: event.verificationId,
        otp: event.otp,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (driver) => emit(AuthAuthenticated(
        driver: driver,
        isProfileComplete: true, // TODO: Implement proper check
        isBlocked: false, // TODO: Implement proper check
      )),
    );
  }

  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signInWithGoogle(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (driver) => emit(AuthAuthenticated(
        driver: driver,
        isProfileComplete: true, // TODO: Implement proper check
        isBlocked: false, // TODO: Implement proper check
      )),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.toString())),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
