// REPLACE ENTIRE FILE: lib/repositories/firebase_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream that updates when auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('🔐 Firebase Auth: Signing in user: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Firebase Auth: Sign in successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      
      // Convert Firebase errors to user-friendly messages
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Ingen användare hittades med den e-postadressen.';
          break;
        case 'wrong-password':
          message = 'Fel lösenord.';
          break;
        case 'invalid-email':
          message = 'Ogiltig e-postadress.';
          break;
        case 'user-disabled':
          message = 'Detta konto har inaktiverats.';
          break;
        case 'too-many-requests':
          message = 'För många inloggningsförsök. Försök igen senare.';
          break;
        default:
          message = 'Inloggning misslyckades: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('❌ Unexpected auth error: $e');
      throw Exception('Ett oväntat fel uppstod vid inloggning.');
    }
  }
  
  // Register new user with email and password
  Future<UserCredential> register(String email, String password) async {
    try {
      print('📝 Firebase Auth: Registering user: $email');
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Firebase Auth: Registration successful');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Registration Error: ${e.code} - ${e.message}');
      
      // Convert Firebase errors to user-friendly messages
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Lösenordet är för svagt.';
          break;
        case 'email-already-in-use':
          message = 'Ett konto med denna e-postadress finns redan.';
          break;
        case 'invalid-email':
          message = 'Ogiltig e-postadress.';
          break;
        case 'operation-not-allowed':
          message = 'E-post/lösenord-registrering är inte aktiverad.';
          break;
        default:
          message = 'Registrering misslyckades: ${e.message}';
      }
      throw Exception(message);
    } catch (e) {
      print('❌ Unexpected registration error: $e');
      throw Exception('Ett oväntat fel uppstod vid registrering.');
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      print('🚪 Firebase Auth: Signing out user');
      await _auth.signOut();
      print('✅ Firebase Auth: Sign out successful');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw Exception('Kunde inte logga ut.');
    }
  }
  
  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } catch (e) {
      print('❌ Profile update error: $e');
      throw Exception('Kunde inte uppdatera profil.');
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Ingen användare hittades med den e-postadressen.';
          break;
        case 'invalid-email':
          message = 'Ogiltig e-postadress.';
          break;
        default:
          message = 'Kunde inte skicka återställningslänk: ${e.message}';
      }
      throw Exception(message);
    }
  }
  
  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('❌ Account deletion error: $e');
      throw Exception('Kunde inte ta bort konto.');
    }
  }
}