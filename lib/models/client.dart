import 'utilisateur.dart';

class Client extends Utilisateur {
  Client({required String uid, required String email})
      : super(uid: uid, email: email, role: 'Client');
}
