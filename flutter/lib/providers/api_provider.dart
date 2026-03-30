import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:resultx/resultx.dart';
import 'package:flutter_app/core/api.dart';
import 'package:flutter_app/core/constants.dart';
import 'package:flutter_app/extensions/riverpod.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solid_shared_pref/solid_shared_pref.dart';
part 'api_provider.g.dart';

@riverpod
Dio dio(Ref ref, {String? authToken}) {
  final baseApiRoute = API_URL;
  final dio = Dio(BaseOptions(baseUrl: baseApiRoute));
  if (authToken != null) {
    dio.options.headers['authorization'] = 'Bearer $authToken';
  }
  return dio;
}

@riverpod
Api api(Ref ref) {
  return Api(ref.watch(dioProvider(authToken: ref.watch(authProvider)?.token)));
}
