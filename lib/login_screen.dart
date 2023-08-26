import 'package:artpac/main.dart';
import 'package:artpac/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:artpac/database.dart'; // Importa el servicio de la base de datos
import 'package:artpac/home_screen.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _logout() {
    setState(() {
      isAuthenticated = false;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
      (route) => false,
    );
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      final db = await DatabaseProvider.instance.database;
      final result = await db.query(
        'users',
        where: 'username = ? AND password = ?',
        whereArgs: [username, password],
      );

      if (result.isNotEmpty) {
        // Autenticación exitosa
        setState(() {
          isAuthenticated = true;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserPage(currentUser: username)),
        );
      } else {
        setState(() {
          _errorMessage = 'Credenciales incorrectas';
        });
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
      appBar: AppBar(title: Text('Inicio de Sesión')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                onPressed: _login,
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 8.0),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                  height:
                      8.0), // Agrega un espacio entre el mensaje de error y el hipervínculo
              GestureDetector(
                onTap: () {
                  // Navega a la página de registro cuando se hace clic en el texto
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RegisterPage()), // Reemplaza con el nombre de tu clase de registro
                  );
                },
                child: Text(
                  '¿No tienes una cuenta? Regístrate aquí',
                  style: TextStyle(
                    color: Colors
                        .blue, // Cambia el color del texto a azul para que parezca un hipervínculo
                    decoration: TextDecoration
                        .underline, // Agrega un subrayado al texto
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
