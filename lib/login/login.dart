import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doan/domains/authentication_repository/authentication_repository.dart';
import 'package:doan/register/register.dart';
import '../ResetPSW/resetpassword.dart';
import '../domains/data_source/firebase_auth_service.dart';
import 'bloc/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocProvider(
            create: (context) {
              final authenticationRepository =
                  context.read<AuthenticationRepository>();
              return LoginCubit(
                  authenticationRepository: authenticationRepository);
            },
            child: const LoginView(),
          ),
        ),
      ),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isSecurePassword = true;
  final _formKey = GlobalKey<FormState>();
  var _autoValidateMode = AutovalidateMode.disabled;
  final _emailTextController = TextEditingController();
  final _passTextController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        // Wrap the whole Column in SingleChildScrollView
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _imageLogin(),
            _buildPageTitle(),
            _buildFormLogin(),
            _buildHavenotAccount(context),
          ],
        ),
      ),
    );
  }

  Widget _imageLogin() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SizedBox(
        child: Image.asset(
          'assets/images/logo_login2.png',
          width: 130,
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25).copyWith(top: 5),
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Color(0xFF2259FF), // Xanh dương trung bình
            Color(0xFF0F5EF1), // Xanh dương nhạt
            Color(0xFF15D5FF), // Xanh dương đậm
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          'DuckAvo', // Nội dung văn bản
          style: TextStyle(
            fontSize: 25,
            // Kích thước chữ
            color: Colors.white,
            // Màu mặc định (không ảnh hưởng trong ShaderMask)
            fontFamily: 'Lobster-Regular',
            // Font chữ
            fontWeight: FontWeight.bold, // Độ dày chữ
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFormLogin() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3), // Đổ bóng dưới
          ),
        ],
      ),
      child: Form(
        autovalidateMode: _autoValidateMode,
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsernameField(),
            _buildPasswordField(),
            const SizedBox(height: 5),
            _buildResetPassword(),
            _buildLoginButton(),
            _buildOrSplitDivider(),
            _buildSocialLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: _logoGmail(),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(top: 0.8), // Điều chỉnh giá
                  // trị này cho khoảng cách phù hợp
                  child: _emailTxt(),
                ),
              )
            ],
          ),
        ]);
  }

  Widget _buildResetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            _gotoResetPassword(context);
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 16,
              color: Colors.black87.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _logoGmail() {
    return Container(
      margin: const EdgeInsets.only(top: 15), // Căn chỉnh khoảng
      // cách trên
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Baseline(
                baseline: 32.2, // Đặt baseline cho chữ "G"
                baselineType: TextBaseline.alphabetic,
                child: const Text(
                  'G',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 1.2, right: 1.4),
                child: Baseline(
                  baseline: 30, // Đặt baseline tương ứng cho icon
                  baselineType: TextBaseline.alphabetic,
                  child: Image.asset(
                    "assets/images/gmail_icon.png",
                    width: 14.5,
                    height: 19,
                  ),
                ),
              ),
              Baseline(
                baseline: 30, // Đặt baseline cho chữ "ail"
                baselineType: TextBaseline.alphabetic,
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'a',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Arial',
                        ),
                      ),
                      TextSpan(
                        text: 'i',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Arial',
                        ),
                      ),
                      TextSpan(
                        text: 'l',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.8),
          // Đường gạch chân (Underline)
          const Divider(
            color: Colors.grey,
            thickness: 1.5,
            height: 3,
          ),
        ],
      ),
    );
  }

  Widget _emailTxt() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      child: TextFormField(
        controller: _emailTextController,
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email!';
          }
          final bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
              .hasMatch(value);
          if (!emailValid) {
            return 'Email không hợp lệ';
          }
          return null;
        },
        decoration: const InputDecoration(
          errorStyle: TextStyle(height: 0),
          // Điều chỉnh khoảng cách thông báo lỗi
          hintText: 'Nhập email...',
          contentPadding: EdgeInsets.symmetric(
            horizontal: 0,
          ),
          hintStyle: TextStyle(
            color: Colors.black38,
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent, width: 1.5)),
          // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
          border: UnderlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
            width: 2,
          )),
          fillColor: Colors.transparent,
          filled: true,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Màu viền
              width: 1.5, // Độ dày viền khi không tương tác
            ),
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget togglePassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isSecurePassword = !_isSecurePassword;
        });
      },
      icon: _isSecurePassword
          ? const Icon(Icons.visibility)
          : const Icon(Icons.visibility_off),
      color: Colors.grey,
    );
  }

  Widget _buildPasswordField() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _passTextController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự hoa';
              }
              if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự thường';
              }
              if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một chữ số';
              }
              if (!RegExp(r'(?=.*?[!@#$&*~.])').hasMatch(value)) {
                return 'Mật khẩu chứa ít nhất một ký tự đặc biệt';
              }
              if (value.length < 8) {
                return 'Mật khẩu phải dài ít nhất 8 ký tự';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu...',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey, // Màu viền
                  width: 1.5, // Độ dày viền khi không tương tác
                ),
              ),
              // Thiết lập viền khi "focus" (khi người dùng nhấn vào TextFormField)
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 2)),
              border: const UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.grey,
                width: 2,
              )),
              fillColor: Colors.transparent,
              filled: true,
              suffixIcon: togglePassword(),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Roboto',
            ),
            obscureText: _isSecurePassword,
          ),
        ]);
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
          onPressed: () {
            _onHandLoginSubmit();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 1.5,
          ),
          child: const Text(
            'Đăng Nhập',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Roboto',
              fontSize: 18,
            ),
          )),
    );
  }

  Widget _buildOrSplitDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Colors.black,
            ),
          ),
          const Text(
            ' or ',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        _buildSocialGoogleLogin(),
      ],
    );
  }

  Widget _buildSocialGoogleLogin() {
    return Center(
      child: SizedBox(
        width: 45,
        height: 45,
        child: GestureDetector(
          onTap: () {
            // Action to be performed when the button is tapped
            print('Google login button tapped');
            // You can navigate to another screen, show a dialog, or trigger a login process here
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 2,
                  offset: const Offset(0, 1), // Đổ bóng dưới
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0), // Khoảng cách giữa logo và viền
              child: Image.asset(
                "assets/images/google_logo.png",
                height: 20,
                width: 20,
                fit: BoxFit.cover, // Đảm bảo hình ảnh không bị cắt xén
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHavenotAccount(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: RichText(
          text: TextSpan(
              text: "Chưa có tài khoản? ",
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
                fontSize: 16,
              ),
              children: [
            TextSpan(
                text: "Đăng ký",
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _gotoRegister(context);
                  }),
          ])),
    );
  }

  void _navigateWithFadeTransition(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _gotoRegister(BuildContext context) {
    _navigateWithFadeTransition(context, const Register());
  }

  void _gotoResetPassword(BuildContext context) {
    _navigateWithFadeTransition(context, const ResetPassword());
  }

  void _onHandLoginSubmit() async {
    final loginCubit = BlocProvider.of<LoginCubit>(context);
    final email = _emailTextController.text;
    final pass = _passTextController.text;

    if (_autoValidateMode == AutovalidateMode.disabled) {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      final errorMessage = await _authService.loginWithEmailAndPass(
        email: email,
        password: pass,
      );
      if (errorMessage != null) {
        ContentType contentType;
        String? error;
        String? title;
        if (errorMessage.contains('We have blocked all requests from this '
            'device')) {
          title = "Cảnh báo";
          error = "Vui lòng thử lại sau";
          contentType = ContentType.failure; // Display as failure
        } else {
          title = "Ôi chao!";
          error = "Thông tin đăng nhập sai rồi!";
          contentType = ContentType.warning; // Display as failure
        }
        _showErrorSnackBar(title, error, contentType);
      } else {
        // Clear the error message on successful login
        loginCubit.login(email, pass); // Proceed with login
      }
    }
  }

  void _showErrorSnackBar(
      String title, String message, ContentType contentType) {
    final snackBar = SnackBar(
      width: double.infinity,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message, // Display the dynamic error message
        contentType: contentType,
      ),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
