import 'package:dio/dio.dart';
import 'package:resultx/resultx.dart';

class Api {
  final Dio _dio;
  Api(this._dio);

  Result<T, ApiError> _parseResponse<T>(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (data is T) {
        return Success(data);
      } else {
        return Error(
          ApiError(
            'API Error: Unexpected data type',
            statusCode: response.statusCode,
          ),
        );
      }
    } else {
      return Error(
        ApiError(
          'API Error: ${response.statusMessage ?? 'Unknown error'}',
          statusCode: response.statusCode,
        ),
      );
    }
  }

  FtrResult<T, ApiError> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<T>(path, queryParameters: queryParameters);
      return _parseResponse<T>(res);
    } on DioException catch (e) {
      final data = e.response?.data;

      return Error(
        ApiError(
          data is Map<String, dynamic> && data['message'] is String
              ? data['message']
              : e.message ?? 'Request Error occurred',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      print(e);
      return Error(ApiError('Unexpected Error: $e'));
    }
  }

  FtrResult<T, ApiError> post<T>(String path, {required Object body}) async {
    try {
      final res = await _dio.post<T>(path, data: body);
      return _parseResponse<T>(res);
    } on DioException catch (e) {
      final data = e.response?.data;

      return Error(
        ApiError(
          data is Map<String, dynamic> && data['message'] is String
              ? data['message']
              : e.message ?? 'Request Error occurred',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Error(ApiError('Unexpected Error: $e'));
    }
  }

  // temporary logging function
  // logs directly to the server
  // me just lazy to change console logs to server logs
  // mostliky tobe removed in future
  void sLog(
    dynamic v1, [
    dynamic v2 = 'x_x',
    dynamic v3 = 'x_x',
    dynamic v4 = 'x_x',
  ]) {
    post(
      '/log',
      body: {
        'logs': [v1, v2, v3, v4].where((v) => v != 'x_x').toList(),
      },
    );
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  ApiError(this.message, {this.statusCode});

  @override
  String toString() {
    return '${statusCode ?? ''}: $message';
  }
}
