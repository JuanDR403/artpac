import 'dart:io';
import 'package:artpac/comment.dart';
import 'package:artpac/database.dart' as database;
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
  String _currentUser = '';
  List<database.Post> posts = [];
  Set<int> likedPostIds = Set();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadPosts();
  }

  Future<void> _loadCurrentUser() async {
    final db = await database.DatabaseProvider.instance.database;
    final result = await db.query('users', limit: 1);

    if (result.isNotEmpty) {
      setState(() {
        _currentUser =
            result.first['username'] as String? ?? 'Usuario desconocido';
      });
    }
  }

  Future<void> _loadPosts() async {
    final db = await database.DatabaseProvider.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('posts');

    setState(() {
      posts = List.generate(maps.length, (index) {
        return database.Post(
          id: maps[index]['id'] as int,
          username: maps[index]['userName'] as String,
          description: maps[index]['description'] as String,
          imagePath: maps[index]['imageUrl'] as String,
        );
      }).where((post) => post.username == widget.currentUser).toList();
    });
  }

  void _logout() {
    // Implementa la lógica para cerrar la sesión si es necesario
  }

  void _toggleLike(database.Post post) {
    setState(() {
      if (likedPostIds.contains(post.id)) {
        post.likes--;
        likedPostIds.remove(post.id);
      } else {
        post.likes++;
        likedPostIds.add(post.id);
      }
    });
  }

  void _addComment(database.Post post) async {
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
      await database.DatabaseProvider.instance.insertComment(newComment);

      setState(() {
        post.comments.add(newComment);
      });
    }
  }

  void _viewComments(database.Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentScreen(comments: post.comments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tu Aplicación'),
          automaticallyImplyLeading: false,
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
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final hasLiked = likedPostIds.contains(post.id);

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
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
                              _toggleLike(post);
                            },
                            child: Text(hasLiked ? 'Quitar Like' : 'Dar Like'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _addComment(post);
                            },
                            child: Text('Agregar Comentario'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _viewComments(post);
                            },
                            child: Text('Ver Comentarios'),
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
                      builder: (context) => LoginPage(),
                    ),
                    (route) => false,
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

class CommentScreen extends StatelessWidget {
  final List<Comment> comments;

  CommentScreen({required this.comments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios'),
      ),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          return ListTile(
            title: Text(comment.username),
            subtitle: Text(comment.content),
          );
        },
      ),
    );
  }
}
