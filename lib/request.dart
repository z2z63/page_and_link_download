import 'package:my_app/src/rust/api/simple.dart' as request;

import 'response.dart';

class Request {
  final String url;
  final String method;
  final String? fromUrl;
  final ParseCallback? callback;

  Request(String url, {this.method = 'GET', this.fromUrl, this.callback})
      : url = url.split('#').first;

  Future<Response> perform() async {
    assert(method == 'GET', 'Only GET method is supported');
    final resp = await request.get(url: url);
    final headers = <String, String>{};
    for (final header in resp.headers) {
      final line = header.split(':');
      headers[line[0].trim()] = line[1].trim();
    }
    return Response(
      url: url,
      fromUrl: fromUrl,
      headers: headers,
      status: resp.status,
      body: resp.body,
      callback: callback,
    );
  }
}
