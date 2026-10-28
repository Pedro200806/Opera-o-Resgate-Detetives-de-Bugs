import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'central_page.dart';

class GatePage extends StatelessWidget {
  const GatePage({super.key});

  Future<void> _entrar(BuildContext context) async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();

        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();

        // O usuário pode cancelar o processo de login.
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;

        final credencial = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(
          credencial,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no login: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const CentralPage();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Central de Achados e Perdidos'),
          ),
          body: Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Entrar com Google'),
              onPressed: () => _entrar(context),
            ),
          ),
        );
      },
    );
  }
}