import 'dart:async';

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:tracking_app/utils/custom_text_field.dart';
import 'package:tracking_app/screen/navigation_screen.dart';
import 'package:tracking_app/service/api_service.dart';
import 'package:tracking_app/service/auth_service.dart';
import 'package:tracking_app/model/user.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isConnectedInternet = false;
  bool isLoading = false;
  StreamSubscription? _internetConnectionStreamSubscription;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => isLoading = true);

    String username = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? userData = await APIService().login(username, password);

      if (userData != null) {
        await AuthService.saveUserData(
          token: userData.token ?? '',
          id: userData.id!,
          username: userData.username,
          email: userData.email,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Username atau Password salah!',
              style: TextStyle(fontSize: 18),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login gagal: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 250, 253, 1),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 750,
                  height: 400,
                  decoration: BoxDecoration(
                    // border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: CustomTextFieldStyle.inputDecoration(
                            hintText: "Masukan Email",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email tidak boleh kosong";
                            } else if (!EmailValidator.validate(value)) {
                              return "Mohon isi email dengan format yang benar";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),
                        TextFormField(
                          obscureText: _isObscure,
                          controller: _passwordController,
                          decoration: CustomTextFieldStyle.inputDecoration(
                            hintText: "Masukan Password",
                            iconButton: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              },
                              icon:
                                  _isObscure
                                      ? Icon(
                                        Icons.visibility_off,
                                        color: Colors.black,
                                      )
                                      : Icon(
                                        Icons.visibility,
                                        color: Colors.black,
                                      ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        OutlinedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _login();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(57, 42, 45, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: (Size(double.infinity, 50)),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.blue,
                size: 40,
              ),
            ),
        ],
      ),
    );
  }
}
