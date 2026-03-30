import 'package:dio/dio.dart';

extension MapExt on Map<String, dynamic> {
  FormData toFormData() {
    return FormData.fromMap(this);
  }
}

extension MapExtV<K, V> on Map<K, V> {
  T get<T>(K key, [T? defaultValue]) {
    final V? value = this[key];
    if (value is T) {
      return value;
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    throw Exception(
      'Map.get $key: Expected $T, Received ${value.runtimeType}. Value: $value',
    );
  }

  X getAndMap<T, X>(K key, X Function(T) mapper, [T? defaultValue]) {
    final V? value = this[key];
    try {
      if (value is T) {
        return mapper(value);
      }
      if (defaultValue != null) {
        return mapper(defaultValue);
      }
    } catch (e) {
      throw Exception(
        'Map.getMap $key: Mapper threw an exception. Value: $value. Exception: $e',
      );
    }
    throw Exception(
      'Map.getMap $key: Expected $T, Received ${value.runtimeType}. Value: $value',
    );
  }
}
