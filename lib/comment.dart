class Comment {
  final int id;
  final String username;
  final String content;

  Comment({
    required this.id,
    required this.username,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'content': content,
    };
  }
}
