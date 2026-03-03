import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _fetchUser(user.uid);
  }

  Future<AppUser?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return _fetchUser(cred.user!.uid);
  }

  Future<AppUser?> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = AppUser(id: cred.user!.uid, email: email, name: name);
    await _db.collection('users').doc(user.id).set(user.toJson());
    return user;
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> _fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!);
  }
}
