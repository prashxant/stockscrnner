import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

const String _googleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue: '',
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();

    try {
      if (_googleWebClientId.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-web-client-id',
          message:
              'Google sign-in needs GOOGLE_WEB_CLIENT_ID. Configure the Firebase '
              'OAuth client for this app and pass it with --dart-define.',
        );
      }

      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: _googleWebClientId,
        serverClientId: _googleWebClientId,
      );

      final googleUser = await googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google sign-in did not return an ID token.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);

      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      await googleSignIn.signOut();
      await ref.read(firebaseAuthProvider).signOut();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
