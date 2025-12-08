import 'package:capture_campus/features/auth/data/repo/user_repo.dart';
import 'package:capture_campus/features/auth/data/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepoImpl extends UserRepo {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<bool> singin(UserModel userData) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: userData.email,
        password: userData.passCode,
      );
      User? user = userCredential.user;
      firestore.collection('users').doc(user!.uid).set({
        'userId': user.uid,
        'userName': user.displayName,
        'userEmail': user.email,
      });
    } catch (_) {}
    return true;
  }

  @override
  Future<bool> login(String email, String passcode) async {
    try {
      auth.signInWithEmailAndPassword(email: email, password: passcode);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.toString());
    }
    return true;
  }
}
