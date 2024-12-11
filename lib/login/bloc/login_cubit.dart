import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan/domains/authentication_repository/authentication_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthenticationRepository authenticationRepository;

  LoginCubit({
    required this.authenticationRepository,
  }) : super(const LoginState(""));

  Future<void> login(String email, String pass) async {
    try {
      await authenticationRepository.loginWithEmailAndPass(
          email: email, password: pass);
    } catch (_) {}
  }
}
