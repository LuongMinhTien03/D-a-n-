import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:doan/status_mode/authentication_status.dart';
import '../domains/authentication_repository/authentication_repository.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final AuthenticationRepository authenticationRepository;

  AppCubit({
    required this.authenticationRepository,
}) : super(const AppState()){
    authenticationRepository.status.listen((status){
        emit(state.copyWith(status:status));
    });
  }

}

