import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photo_sharer/auth/login_screen.dart'; // Update path
import 'package:photo_sharer/screens/photo_feed_screen.dart'; // Update path
import 'package:photo_sharer/auth/auth_service.dart'; // Update path

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // User is not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen(); // Or a screen that lets user choose Login/Register
        }

        // User is signed in
        return const PhotoFeedScreen();
      },
    );
  }
}
