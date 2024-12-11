import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doan/domains/data_source/firebase_auth_service.dart';
import '../../status_mode/authentication_status.dart';
import 'entity/user_entity.dart';

abstract class AuthenticationRepository {
  Stream<AuthenticationStatus> get status;

  Stream<UserEntity> get user;

  Future<void> loginWithEmailAndPass({
    required String email,
    required String password,
  });
}

class AuthenticReposityImpl extends AuthenticationRepository {
  final FirebaseAuthService firebaseAuthService;
  final _statusController = StreamController<AuthenticationStatus>();
  final _userController = StreamController<UserEntity>();

  AuthenticReposityImpl({required this.firebaseAuthService}) {
    firebaseAuthService.user.listen((firebaseUser) {
      final isLoggedIn = firebaseUser != null;

      // biến đổi firebaseUser thanh UserEntity
      final user = isLoggedIn ? firebaseUser.toUserEntity : UserEntity.empty;
      _userController.sink.add(user);
      if (isLoggedIn) {
        _statusController.sink.add(AuthenticationStatus.authenticated);
      } else {
        _statusController.sink.add(AuthenticationStatus.unauthenticated);
      }
    });
  }

  @override
  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _statusController.stream;
  }

  @override
  Stream<UserEntity> get user async* {
    yield* _userController.stream;
  }

  @override
  Future<void> loginWithEmailAndPass(
      {required String email, required String password}) async {
    try {
      await firebaseAuthService.loginWithEmailAndPass(
          email: email, password: password);
    } catch (e) {
      print(e);
    }
  }

  void dispose() {
    _statusController.close();
    _userController.close();
  }
}

extension UserFirebaseAuthExtension on User {
  UserEntity get toUserEntity {
    return UserEntity(
      id: uid,
      email: email,
      name: displayName,
    );
  }
}
