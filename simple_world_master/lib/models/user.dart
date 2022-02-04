import 'package:cloud_firestore/cloud_firestore.dart';

class GloabalUser {
  final String id;
  final String username;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String coverUrl;

  GloabalUser({
    required this.id,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.displayName,
    required this.bio,
    required this.coverUrl,
  });

  factory GloabalUser.fromDocument(DocumentSnapshot doc) {
    return GloabalUser(
      id: doc['id'],
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      displayName: doc['displayName'],
      bio: doc['bio'],
      coverUrl: doc['coverUrl'],
    );
  }

  factory GloabalUser.fromMap(Map<String, dynamic> map) {
    return GloabalUser(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      coverUrl: map['coverUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'bio': bio,
      'searchIndexes': searchIndexes,
      'coverUrl': coverUrl,
    };
  }

  List<String> get searchIndexes {
    final indices = <String>[];
    for (final s in [username, displayName]) {
      for (var i = 1; i < s.length; i++) {
        indices.add(s.substring(0, i).toLowerCase());
      }
    }
    return indices;
  }

  static final usersCol =
      FirebaseFirestore.instance.collection('users').withConverter<GloabalUser>(
            fromFirestore: (e, _) => GloabalUser.fromMap(e.data()!),
            toFirestore: (m, _) => m.toMap(),
          );
  static DocumentReference<GloabalUser> userDoc([String? id]) =>
      usersCol.doc(id ?? id);

  static Future<GloabalUser?> fetchUser([String? id]) async {
    final doc = await userDoc(id ?? id).get();
    return doc.data();
  }
}
