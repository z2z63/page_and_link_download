import 'dart:convert';
import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import 'request.dart';

typedef ParseCallback = Iterable<Request> Function(Response);

class Response {
  final String url;
  final Uri uri;
  final String? fromUrl;
  final Map<String, String> headers;
  final int status;
  final Uint8List body;
  String? text;
  late bool isHtml = false;
  Element? document;
  ParseCallback? callback;

  Response(
      {required this.url,
      this.fromUrl,
      this.callback,
      required this.headers,
      required this.status,
      required this.body})
      : uri = Uri.parse(url) {
    if (headers['Content-Type']?.contains('text') ?? false) {
      text = utf8.decode(body);
    }
    if (headers['Content-Type']?.contains('html') ?? false) {
      document = parse(text).documentElement!;
      isHtml = true;
    }
  }

  XPathResult<Node> xpath(String path) {
    assert(isHtml, 'Only HTML document can be used for xpath');
    return document!.queryXPath(path);
  }

  List<Element> css(String selector) {
    assert(isHtml, 'Only HTML document can be used for css');
    return document!.querySelectorAll(selector);
  }

  Iterable<Request> follow(String? url, {ParseCallback? callback}) sync* {
    if (url == null || Uri.tryParse(url) == null) {
      // 处理data:等非HTTP链接
      // eg: "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' h...
      return;
    }
    final newUri = uri.resolve(url);
    // 去除javascript,chrome等非HTML链接
    if (newUri.host.isNotEmpty && ['http', 'https'].contains(newUri.scheme)) {
      yield Request(newUri.toString(), fromUrl: this.url, callback: callback);
    }
  }
}
