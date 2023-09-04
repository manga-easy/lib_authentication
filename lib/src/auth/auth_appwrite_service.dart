import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:authentication/src/auth/auth_service.dart';
import 'package:authentication/src/exceptions/auth_exception.dart';
import 'package:manga_easy_sdk/manga_easy_sdk.dart';
import 'package:toggle_config/toggle_config.dart';

class AuthAppwriteService implements AuthService {
  final GetToggleConfigCase _getToggleConfigCase;
  late Account _account;

  AuthAppwriteService(this._getToggleConfigCase);

  @override
  Future<void> initialization() async {
    final url = await _getToggleConfigCase.call<String>(
      key: ToggleKey.urlAuth,
    );
    final Client client = Client();
    client.setEndpoint(url).setProject('64372675b0f256f58f4f').setSelfSigned();
    _account = Account(client);
  }

  Future<void> _serverUnderMaintenance() async {
    if (!await _getToggleConfigCase.call<bool>(key: ToggleKey.isAuth)) {
      throw AuthException(
        'Servidor em manutenção, em breve voltaremos'
        ', para mais informações entre em contato!',
      );
    }
  }

  @override
  Future<models.Session> createSession({
    required String email,
    required String password,
  }) async {
    await _serverUnderMaintenance();
    try {
      return await _account.createEmailSession(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<String> getJwt({String? sessionId}) async {
    await _serverUnderMaintenance();

    final ret = await _account.createJWT();
    Helps.log(ret.jwt);
    return ret.jwt;
  }

  @override
  Future<models.User> updateName({required String name}) async {
    await _serverUnderMaintenance();
    try {
      return await _account.updateName(name: name);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<models.User> updatePassword({
    required String password,
    String? oldPassword,
  }) async {
    await _serverUnderMaintenance();
    try {
      return await _account.updatePassword(
        password: password,
        oldPassword: oldPassword,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteSession({String? sessionId}) async {
    await _serverUnderMaintenance();
    try {
      return await _account.deleteSession(sessionId: sessionId ?? 'current');
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<models.User> updatePrefs({
    required Map<dynamic, dynamic> prefs,
  }) async {
    await _serverUnderMaintenance();
    try {
      return await _account.updatePrefs(prefs: prefs);
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<dynamic> createOAuth2Session({
    required String provider,
    String? success,
    String? failure,
    List<String>? scopes,
  }) async {
    await _serverUnderMaintenance();
    try {
      return await _account.createOAuth2Session(
        provider: provider,
        failure: failure,
        scopes: scopes,
        success: success,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<models.User> create({
    required String email,
    required String password,
    String? name,
  }) async {
    await _serverUnderMaintenance();
    try {
      String? nameNull;
      // tiver quer merda por causa do appwrite n aceita ""
      if (name != null && name.isNotEmpty) {
        nameNull = name.trim();
      }
      return await _account.create(
        userId: 'unique()',
        email: email.trim(),
        password: password.trim(),
        name: nameNull,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> recorverPassword({required String email}) async {
    await _serverUnderMaintenance();
    try {
      final url = await _getToggleConfigCase.call<String>(
        key: ToggleKey.urlRecovery,
      );
      await _account.createRecovery(
        email: email,
        url: url,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> recorverPasswordConfirmation({
    required String userId,
    required String secret,
    required String password,
    required String passwordAgain,
  }) async {
    await _serverUnderMaintenance();
    try {
      await _account.updateRecovery(
        userId: userId,
        secret: secret,
        password: password,
        passwordAgain: passwordAgain,
      );
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<models.User> getUser() async {
    await _serverUnderMaintenance();
    try {
      return await _account.get();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(Object? e) {
    if (e is AppwriteException) {
      final message = e.message ?? '';
      if (message.contains('Invalid email')) {
        throw AuthException(
          'O e-mail fornecido é inválido',
        );
      }
      if (message.contains('Invalid password')) {
        throw AuthException(
          'A senha fornecida é inválida',
        );
      }
      throw AuthException(_mapErrorTypes[e.type ?? ''] ?? e.toString());
    }
  }

  Map<String, String> get _mapErrorTypes => {
        'general_rate_limit_exceeded':
            'Você atingiu o limite máximo de solicitações para este recurso no momento.'
                ' Por favor, tente novamente mais tarde.',
        'user_email_already_exists': 'Já existe um usuário com o mesmo e-mail.',
        'user_already_exists': 'Já existe um usuário com o mesmo e-mail.',
        'user_unauthorized':
            'O usuário atual não está autorizado a executar a ação solicitada.',
        'user_invalid_credentials':
            'Credenciais inválidas. Por favor, verifique o e-mail e a senha.🦄',
        'user_invalid_token':
            'Token inválido. Por favor, verifique e tente novamente.😥',
        'user_blocked': 'O usuário atual foi bloqueado.😥',
        'user_password_mismatch':
            'As senhas não coincidem. Verifique a senha e confirme a senha.🦄',
      };
}
