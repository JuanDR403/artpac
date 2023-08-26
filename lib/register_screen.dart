import 'package:flutter/material.dart';
import 'package:artpac/login_screen.dart';
import 'package:artpac/database.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _datesController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  void _register() async {
    final dates = _datesController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      final isTaken = await DatabaseProvider.instance.isUsernameTaken(username);

      if (isTaken) {
        setState(() {
          _errorMessage = 'El nombre de usuario ya está en uso';
        });
      } else {
        final db = await DatabaseProvider.instance.database;
        await db.insert(
          'users',
          {'dates': dates, 'username': username, 'password': password},
        );
        setState(() {
          _errorMessage = '';
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'Completa todos los campos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login_image.png',
                width:
                    200, // Ajusta el tamaño de la imagen según tus necesidades
              ),
              SizedBox(height: 20),
              TextField(
                controller: _datesController,
                decoration: InputDecoration(labelText: 'Datos de Usuario'),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _register,
                child: Text('Registrarse'),
              ),
              SizedBox(height: 8.0),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
