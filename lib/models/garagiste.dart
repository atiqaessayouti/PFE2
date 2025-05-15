import 'utilisateur.dart';

class Garagiste extends Utilisateur {
  final bool isApproved;

  Garagiste({required String uid, required String email, this.isApproved = false})
      : super(uid: uid, email: email, role: 'Garagiste');
}
