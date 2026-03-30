import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resultx/resultx.dart';
import 'package:flutter_app/extensions/context.dart';

import '../core/api.dart';

extension ApiResExt<T> on FtrResult<T, ApiError> {
  Future<Result<T, ApiError>> resolveWithUI(BuildContext context) async {
    return await when(
      success: (data) => Success<T, ApiError>(data),
      error: (e) {
        if (e.statusCode != null && e.statusCode == 401) {
          context.showSnackBar(
            'Session expired. Please log in again.',
            isError: true,
          );
          context.go('/login');
          return Error(e);
        }
        context.showSnackBar(e.message, isError: true);
        return Error(e);
      },
    );
  }
}
