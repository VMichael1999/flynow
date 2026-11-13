import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/theme.dart';

abstract interface class AuthRepository {
  Future<void> signIn(String email, String password);
}

class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository({this.latency = AppDurations.signingIn});
  final Duration latency;

  @override
  Future<void> signIn(String email, String password) =>
      Future<void>.delayed(latency);
}

sealed class LoginEvent {
  const LoginEvent();
}

class PasswordVisibilityToggled extends LoginEvent {
  const PasswordVisibilityToggled();
}

class RememberMeToggled extends LoginEvent {
  const RememberMeToggled();
}

class SignInPressed extends LoginEvent {
  const SignInPressed(this.email, this.password);
  final String email;
  final String password;
}

enum LoginStatus { idle, loading, success }

class LoginState extends Equatable {
  const LoginState({
    this.obscure = true,
    this.remember = true,
    this.status = LoginStatus.idle,
  });

  final bool obscure;
  final bool remember;
  final LoginStatus status;

  LoginState copyWith({bool? obscure, bool? remember, LoginStatus? status}) =>
      LoginState(
        obscure: obscure ?? this.obscure,
        remember: remember ?? this.remember,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [obscure, remember, status];
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._auth) : super(const LoginState()) {
    on<PasswordVisibilityToggled>(
      (e, emit) => emit(state.copyWith(obscure: !state.obscure)),
    );
    on<RememberMeToggled>(
      (e, emit) => emit(state.copyWith(remember: !state.remember)),
    );
    on<SignInPressed>((e, emit) async {
      emit(state.copyWith(status: LoginStatus.loading));
      await _auth.signIn(e.email, e.password);
      emit(state.copyWith(status: LoginStatus.success));
    });
  }

  final AuthRepository _auth;
}
