// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.28.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// The type `HTTPMethod` is not used by any `pub` functions, thus it is ignored.
// The type `HTTPSchema` is not used by any `pub` functions, thus it is ignored.
// The type `Request` is not used by any `pub` functions, thus it is ignored.

String greet({required String name, dynamic hint}) =>
    RustLib.instance.api.greet(name: name, hint: hint);

Future<Response> get({required String url, dynamic hint}) =>
    RustLib.instance.api.get(url: url, hint: hint);

class NetworkError implements FrbException {
  final String reason;

  const NetworkError({
    required this.reason,
  });

  @override
  int get hashCode => reason.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkError &&
          runtimeType == other.runtimeType &&
          reason == other.reason;
}

class Response {
  final int status;
  final List<String> headers;
  final Uint8List body;

  const Response({
    required this.status,
    required this.headers,
    required this.body,
  });

  String text({dynamic hint}) => RustLib.instance.api.responseText(
        that: this,
      );

  @override
  int get hashCode => status.hashCode ^ headers.hashCode ^ body.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Response &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          headers == other.headers &&
          body == other.body;
}

class Utf8DecodeError implements FrbException {
  const Utf8DecodeError();

  @override
  int get hashCode => 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Utf8DecodeError && runtimeType == other.runtimeType;
}
