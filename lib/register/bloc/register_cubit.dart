import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan/domains/authentication_repository/authentication_repository.dart';
part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthenticationRepository authenticationRepository;

  RegisterCubit({required this.authenticationRepository})
      : super(const RegisterState());

  Future<void> register( String email, String password) async {
    emit(RegisterLoading()); // Emit loading state
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        emit(RegisterEmailExists());
      } else {
        emit(RegisterFailure(e.message ?? 'Registration failed'));
      }
    } catch (e) {
      emit(RegisterFailure('An unknown error occurred'));
    }
  }
}
