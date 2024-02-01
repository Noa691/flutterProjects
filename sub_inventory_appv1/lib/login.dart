import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'usermangament.dart';
import 'package:flutter/services.dart';
import 'text_field_with_no_keyboard.dart';

class ApiResponse {
  final bool success;
  final String message;
  final dynamic result;

  ApiResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'],
      message: json['message'],
      result: json['result'],
    );
  }
}

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<loginScreen> {
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode _passwordFocusNode = FocusNode();

  List<List<String>> tableData = [];
  void _moveToPassword() {
    FocusScope.of(context).requestFocus(_passwordFocusNode);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _navigateToMainMenu(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _passwordFocusNode.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome subApp'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgroundd.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/rljoneslogo.png',
                      fit: BoxFit.cover,
                      height: 80,
                      width: 380,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 15),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: userController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'User',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          _moveToPassword();
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: passwordController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        focusNode: _passwordFocusNode,
                        obscureText: true, // Establece esta propiedad a true
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          // Establece el foco al tocar el campo de contraseña
                          _passwordFocusNode.requestFocus();
                        },
                        onSubmitted: (value) {
                          tryLogin();
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: tryLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(95, 21, 241, 131),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void tryLogin() async {
    String apiUrl = 'http://192.168.111.69:8083/fetch/login';

    // Obtener los valores de los controladores
    String nameUser = userController.text;
    String passwordUser = passwordController.text;

    if (nameUser.isEmpty || passwordUser.isEmpty) {
      _showSnackBar(
          'Please write your credentials<<', Color.fromARGB(255, 235, 98, 88));
      return;
    }

    // Construir el mapa de datos para la solicitud
    Map<String, dynamic> data = {
      'nameUser': nameUser,
      'passwordUser': passwordUser,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'akbmk319irfyr1gxrarso3orcunlgy78',
        },
      );

      final Map<String, dynamic> jsonResponse2 = json.decode(response.body);
      final ApiResponse apiResponse = ApiResponse.fromJson(jsonResponse2);

      String message = apiResponse.message;
      String nameuser = apiResponse.result['nameuser'];

      if (message.contains('Validation successfully')) {
        if (nameuser.contains("Bad")) {
          _showSnackBar(
              'Bad user / password please re-check your credentials provided',
              Color.fromARGB(255, 235, 98, 88));
        } else {
          UserManager.setUserName(nameuser);
          _navigateToMainMenu(context);
        }
      }

      // Actualizar la tabla
    } catch (error) {}
  }
}
