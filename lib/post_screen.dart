import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:artpac/database.dart';
import 'package:artpac/home_screen.dart'; // Importa el archivo correcto según tu estructura

class Post {
  final String username;
  final String description;
  final String imagePath;

  Post({
    required this.username,
    required this.description,
    required this.imagePath,
  });
}

class PostScreen extends StatefulWidget {
  final String currentUser;

  PostScreen({required this.currentUser});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _selectedImage;
  bool _showImageError = false;
  TextEditingController _descriptionController = TextEditingController();

  Future<String> _uploadImageToStorage(File imageFile) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagePath = appDir.path + '/${DateTime.now()}.png';
    await imageFile.copy(imagePath);
    return imagePath;
  }

  Future<void> _savePostToDatabase(
      String description, String imageUrl, String? username) async {
    final db = await DatabaseProvider.instance.database;

    await db.insert(
      'posts',
      {
        'userName': username ?? 'Usuario desconocido',
        'description': description,
        'imageUrl': imageUrl,
      },
    );
  }

  void _postImageAndNavigateToHome(BuildContext context) async {
    if (_selectedImage == null) {
      setState(() {
        _showImageError = true;
      });
    } else {
      String description = _descriptionController.text;
      _showImageError = false;

      String imageUrl = await _uploadImageToStorage(_selectedImage!);

      String? currentUser =
          await DatabaseProvider.instance.getCurrentUsername();

      await _savePostToDatabase(description, imageUrl, currentUser);

      Navigator.pop(context); // Regresar a la pantalla anterior (PostScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserPage(
              currentUser:
                  currentUser), // Cambiar por UserPage o HomeScreen según tu estructura
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Publicar Imagen')),
        body: Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Selecciona una opción'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text('Tomar foto con la cámara'),
                                onTap: () async {
                                  Navigator.pop(
                                      context,
                                      await ImagePicker().pickImage(
                                          source: ImageSource.camera));
                                },
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                child: Text('Seleccionar de la galería'),
                                onTap: () async {
                                  Navigator.pop(
                                      context,
                                      await ImagePicker().pickImage(
                                          source: ImageSource.gallery));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                },
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo, size: 50),
                            Text('Insertar Imagen'),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 50,
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Descripción de la imagen',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _postImageAndNavigateToHome(context),
                child: Text('Publicar'),
              ),
              _showImageError
                  ? Text(
                      'Debe de insertar una imagen para publicar.',
                      style: TextStyle(color: Colors.red),
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
