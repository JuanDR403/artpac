class User {
  final int id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});
}

class Post {
  final int id;
  final String username;
  final String description;
  final String imageUrl;

  Post({
    required this.id,
    required this.username,
    required this.description,
    required this.imageUrl,
  });
}
