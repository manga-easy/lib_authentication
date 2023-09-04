import 'package:appwrite/models.dart';

abstract class AuthService {
  Future<void> initialization();

  Future<Session> createSession({
    required String email,
    required String password,
  });

  Future<User> getUser();

  Future<String> getJwt();

  Future<User> updateName({required String name});

  Future<User> updatePassword({required String password, String oldPassword});

  Future<dynamic> deleteSession();

  Future<User> updatePrefs({required Map<dynamic, dynamic> prefs});

  Future<dynamic> createOAuth2Session({
    required String provider,
    String? success,
    String? failure,
    List<String>? scopes,
  });

  Future<User> create({
    required String email,
    required String password,
    String? name,
  });

  Future<void> recorverPassword({required String email});

  Future<void> recorverPasswordConfirmation({
    required String userId,
    required String secret,
    required String password,
    required String passwordAgain,
  });
}
