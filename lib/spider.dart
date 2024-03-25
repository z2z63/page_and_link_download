import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:my_app/src/rust/api/simple.dart' show NetworkError;

import 'request.dart';
import 'response.dart';

abstract class Spider {
  Uri get startUri;

  void Function(String, String) addEdge;

  Spider(this.addEdge);

  final controller = StreamController<Request>();

  Iterable<Request> parse(Response response) sync* {
    throw UnimplementedError();
  }

  final Set<String> visited = {};

  Future<void> listenCallback(Request request) async {
    final requestUri = Uri.parse(request.url);
    if (requestUri.host != startUri.host ||
        !requestUri.path.startsWith(startUri.path)) {
      return; // 不爬取外链和不在起始路径下的链接
    }
    if (request.fromUrl != null) {
      addEdge(requestUri.path, Uri.parse(request.fromUrl!).path);
    }

    if (visited.contains(request.url)) {
      return;
    }
    if (request.method == 'GET') {
      // 只有GET请求才去重
      visited.add(request.url);
    }

    for (var i = 0; i < 3; i++) {
      // 重试3次
      try {
        final response = await request.perform();
        debugPrint(request.url);
        final parseCallback = response.callback ?? parse;
        for (final request in parseCallback(response)) {
          controller.add(request);
        }
        return;
      } on NetworkError catch (e) {
        debugPrint(e.reason);
      }
    }
    debugPrint('Failed to fetch ${request.url}');
  }

  void run() {
    controller.stream.listen(listenCallback);
    controller.add(Request(startUri.toString()));
  }
}
