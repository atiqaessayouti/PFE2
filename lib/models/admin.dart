import 'utilisateur.dart';

class Admin extends Utilisateur {
  Admin({required String uid, required String email})
      : super(uid: uid, email: email, role: 'Admin');
}
