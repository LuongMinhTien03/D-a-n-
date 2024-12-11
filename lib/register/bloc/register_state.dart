part of 'register_cubit.dart';

class RegisterState extends Equatable {

  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {


}

class RegisterEmailExists extends RegisterState {}

class RegisterFailure extends RegisterState {
  final String error;
  const RegisterFailure(this.error);

  @override
  List<Object> get props => [error];
}
