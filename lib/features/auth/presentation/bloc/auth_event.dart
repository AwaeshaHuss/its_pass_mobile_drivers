part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInWithPhoneRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSignInWithPhoneRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String otp;

  const AuthVerifyOtpRequested({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object> get props => [verificationId, otp];
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class AuthProfileUpdateRequested extends AuthEvent {
  final DriverEntity driver;

  const AuthProfileUpdateRequested(this.driver);

  @override
  List<Object> get props => [driver];
}

class AuthProfileImageUploadRequested extends AuthEvent {
  final String imagePath;

  const AuthProfileImageUploadRequested(this.imagePath);

  @override
  List<Object> get props => [imagePath];
}
