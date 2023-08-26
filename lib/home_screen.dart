import 'dart:io';

import 'package:artpac/comment.dart';
import 'package:artpac/database.dart';
import 'package:artpac/login_screen.dart';
import 'package:artpac/post_screen.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  final String? currentUser;

  UserPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _currentUser =
      ''; // Variable para almacenar el nombre de usuario actual
  List<Post> posts = []; // Lista de publicaciones

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts(); // Cargar las publicaciones al iniciar la pantalla
  }

  Future<void> _loadCurrentUser() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query('users',
        limit: 1); // Suponiendo un solo usuario autenticado

    if (result.isNotEmpty) {
      setState(() {
        _currentUser =
            result.first['username'] as String? ?? 'Usuario desconocido';
      });
    }
  }

  Future<void> _loadPosts() async {
    final db = await DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('posts');

    setState(() {
      posts = List.generate(maps.length, (index) {
        return Post(
          username: maps[index]['userName'] as String,
          description: maps[index]['description'] as String,
          imagePath: maps[index]['imageUrl'] as String,
        );
      }).where((post) => post.username == widget.currentUser).toList();
    });
  }

  void _logout() {
    // Aquí puedes implementar la lógica para cerrar la sesión
    // Esto podría involucrar eliminar la información del usuario actual de las variables y redirigir a la pantalla de inicio de sesión
  }

  void _likePost(Post post) {
    setState(() {
      post.likes++;
    });
  }

  void _addComment(Post post) async {
    final content = await showDialog(
      context: context,
      builder: (context) {
        String commentContent = '';

        return AlertDialog(
          title: Text('Agregar Comentario'),
          content: TextField(
            onChanged: (value) {
              commentContent = value;
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, commentContent);
              },
              child: Text('Comentar'),
            ),
          ],
        );
      },
    );

    if (content != null && content.isNotEmpty) {
      final newComment = Comment(
        id: post.comments.length + 1,
        username: widget.currentUser!,
        content: content,
      );

      // Insertar el comentario en la base de datos
      await DatabaseProvider.instance.insertComment(newComment);

      setState(() {
        post.comments.add(newComment);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tu Aplicación'),
          automaticallyImplyLeading:
              false, // Eliminar la flecha de volver atrás
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostScreen(
                        currentUser: _currentUser,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  onPrimary: Colors.white,
                ),
                child: Text('Postear Imagen'),
              ),
              SizedBox(height: 20), // Espacio entre los botones
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 8), // Agrega un margen vertical
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Usuario: ${post.username}'),
                          Text('Descripción: ${post.description}'),
                          Image.file(File(post.imagePath)),
                          Text('Likes: ${post.likes}'),
                          ElevatedButton(
                            onPressed: () {
                              _likePost(post); // Llama a la función _likePost
                            },
                            child: Text('Dar Like'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addComment(
                                  post); // Llama a la función _addComment
                            },
                            child: Text('Agregar Comentario'),
                          ),
                          Column(
                            children: post.comments.map((comment) {
                              return ListTile(
                                title: Text(comment.username),
                                subtitle: Text(comment.content),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(), // Redirigir a la pantalla de inicio de sesión
                    ),
                    (route) => false, // Remover todas las rutas anteriores
                  );
                },
                child: Text('Cerrar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
