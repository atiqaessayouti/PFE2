import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpScreen.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'dashboord/AddPiecePage.dart';
import 'dashboord/EditPiecePage.dart';
import 'dashboord/MainNavigation.dart';
import 'dashboord/admin/StockPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDCQrY8IpigKt5CSCUkHQbq2PtbQXWwWyo",
        authDomain: "testpfe-daa55.firebaseapp.com",
        projectId: "testpfe-daa55",
        storageBucket: "testpfe-daa55.appspot.com", // ⚡ Corrigé ici (pas "firebasestorage.app")
        messagingSenderId: "593391273273",
        appId: "1:593391273273:web:3e068745008e21826ed4e8",
        measurementId: null, // C'est optionnel pour Flutter, tu peux laisser null
      ),
    );
;
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Flutter Demo',
      initialRoute: '/login', // Route initialeflutter
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/stock': (context) => const StockPage(),     // 🔴 route ajoutée
        '/addPiece': (context) => const AddPiecePage() ,// 🔴 route ajoutée
        '/editPiece': (context) {
          final pieceId = ModalRoute.of(context)!.settings.arguments as String;
          return EditPiecePage(pieceId: pieceId);
        },
      },
      home: LoginScreen(),

    );
  }
}
