import 'dart:convert';
import 'dart:developer';

import 'package:resultx/resultx.dart';
import 'package:flutter_app/core/api.dart';
import 'package:flutter_app/core/api_paths.dart';
import 'package:flutter_app/models/user.dart';
import 'package:flutter_app/providers/api_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solid_shared_pref/solid_shared_pref.dart';
part 'auth_provider.g.dart';

// for now
// todo: implement secure storage
const authTokenPref = NullableStringPreference('auth_token');
const _authUserPref = NullableStringPreference('_auth_user');

class AuthData {
  final String token;
  final User user;

  AuthData({required this.token, required this.user});
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthData? build() {
    final token = authTokenPref.value;
    if (token == null) {
      return null;
    }
    final userJson = _authUserPref.value;
    if (userJson == null) {
      return null;
    }
    final user = User.fromJson(jsonDecode(userJson));
    initProfile(token);
    return AuthData(token: token, user: user);
  }

  Api api(String? token) {
    return Api(ref.read(dioProvider(authToken: token)));
  }

  void logout() {
    authTokenPref.remove();
    state = null;
  }

  bool _handleAuthRes(Result<Map<String, dynamic>, ApiError> res) {
    return res.when(
      success: (e) {
        final token = e['token'] as String?;
        final userData = e['user'] as Map<String, dynamic>?;
        if (token == null || userData == null) {
          return false;
        }
        final user = User.fromJson(userData);
        authTokenPref.value = token;
        _authUserPref.value = jsonEncode(user.toJson());
        state = AuthData(token: token, user: user);
        return e.containsKey('token');
      },
      error: (e) {
        log('ERROR: ${e.message}');
        return false;
      },
    );
  }

  Future<bool> initProfile(String token) async {
    final res = await api(token).get<Map<String, dynamic>>(ApiGet.profile.path);
    return _handleAuthRes(res.mapSuccess((e) => {...e, 'token': state!.token}));
  }

  Future<bool> reloadProfile() async {
    if (state?.token == null) {
      return false;
    }
    return initProfile(state!.token);
  }

  Future<bool> register(String name, String email, String password) async {
    final res = await api(null).post<Map<String, dynamic>>(
      ApiPost.register.path,
      body: {'name': name, 'email': email, 'password': password},
    );

    return _handleAuthRes(res);
  }

  Future<bool> login(String email, String password) async {
    final res = await api(null).post<Map<String, dynamic>>(
      ApiPost.login.path,
      body: {'email': email, 'password': password},
    );

    return _handleAuthRes(res);
  }
}
