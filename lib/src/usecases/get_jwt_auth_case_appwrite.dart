import 'dart:async';
import 'package:authentication/src/auth/auth_service.dart';
import 'package:authentication/src/usecases/get_jwt_auth_case.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:manga_easy_sdk/manga_easy_sdk.dart';

class GetJWTAuthCaseAppwrite extends GetJWTAuthCase {
  final AuthService _authService;
  Completer? complete;

  GetJWTAuthCaseAppwrite(this._authService);
  @override
  Future<String> call() async {
    await complete?.future;
    if (isValid()) {
      return Global.jwt!;
    }
    complete = Completer();
    Global.jwt = await _authService.getJwt();
    complete!.complete();

    return Global.jwt!;
  }

  bool isValid() {
    try {
      return !JwtDecoder.isExpired(Global.jwt ?? '');
    } catch (e) {
      Helps.log(e);
      return false;
    }
  }
}
