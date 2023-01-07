class User {
  String _id;
  final String username;
  final String photoURL;

  final bool active;
  final DateTime lastSeen;

  String get getId => _id;

  User({
    this.username,
    this.photoURL,
    this.active,
    this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'photoURL': photoURL,
        'active': active,
        'lastSeen': lastSeen
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        username: json['username'],
        photoURL: json['photoURL'],
        active: json['active'],
        lastSeen: json['lastSeen']);
    user._id = json['id'];

    return user;
  }
}
