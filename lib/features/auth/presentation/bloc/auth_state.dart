part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final DriverEntity driver;
  final bool isProfileComplete;
  final bool isBlocked;

  const AuthAuthenticated({
    required this.driver,
    required this.isProfileComplete,
    required this.isBlocked,
  });

  @override
  List<Object> get props => [driver, isProfileComplete, isBlocked];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const AuthOtpSent({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [verificationId, phoneNumber];
}

class AuthProfileUpdating extends AuthState {
  final DriverEntity driver;

  const AuthProfileUpdating(this.driver);

  @override
  List<Object> get props => [driver];
}

class AuthProfileUpdated extends AuthState {
  final DriverEntity driver;

  const AuthProfileUpdated(this.driver);

  @override
  List<Object> get props => [driver];
}

class AuthImageUploading extends AuthState {}

class AuthImageUploaded extends AuthState {
  final String imageUrl;

  const AuthImageUploaded(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
