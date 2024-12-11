import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan/app/app_cubit.dart';
import 'package:doan/domains/authentication_repository/authentication_repository.dart';
import 'package:doan/splash_screen/splash_1.dart';
import 'package:doan/status_mode/authentication_status.dart';
import 'main/waiting page/waiting_page.dart';
import 'domains/data_source/firebase_auth_service.dart';
import 'login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Thêm dòng này
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthenticationRepository _authenticationRepository;
  late final FirebaseAuthService _firebaseAuthService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseAuthService = FirebaseAuthService();
    _authenticationRepository = AuthenticReposityImpl(
      firebaseAuthService: _firebaseAuthService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => _authenticationRepository),
        ],
        child: BlocProvider(
            create: (BuildContext context) {
              return AppCubit(
                authenticationRepository: _authenticationRepository,
              );
            },
            child: const MyApp()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THIS THIS MY HOME',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
          textSelectionTheme: const TextSelectionThemeData(
            selectionColor: Colors.lightBlueAccent,
            cursorColor: Colors.blue, // Màu con trỏ
            selectionHandleColor: Colors.lightBlueAccent,
          )),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return BlocListener<AppCubit, AppState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (route) => false,
                );
                break;
              case AuthenticationStatus.unauthenticated:
                _navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                      (route) => false,
                );
                break;
              case AuthenticationStatus.unknow:
                // không làm gì
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) {
        return MaterialPageRoute(builder: (context) => Splash1());
      },
    );
  }
}
