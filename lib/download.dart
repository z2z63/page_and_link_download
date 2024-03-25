import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:my_app/src/rust/frb_generated.dart';

import 'request.dart';
import 'response.dart';
import 'spider.dart';

class MySpider extends Spider {
  MySpider(super.addEdge, startUrl) : startUri = Uri.parse(startUrl);
  @override
  final Uri startUri;

  @override
  Iterable<Request> parse(Response response) sync* {
    // 解析HTML，提取链接
    assert(response.isHtml,
        'Only HTML document can be used for parse: ${response.url}');
    for (final link in response.xpath('//link/@href').attrs) {
      yield* response.follow(link, callback: parseMaybeCSS);
    }

    for (final link in response.xpath('//script/@src').attrs +
        response.xpath('//img/@src').attrs +
        response.xpath('//audio/@src').attrs +
        response.xpath('//video/@src').attrs) {
      yield* response.follow(link, callback: save);
    }
    for (final link in response.xpath('//a/@href').attrs) {
      yield* response.follow(link);
    }
    yield* save(response);
  }

  Iterable<Request> parseMaybeCSS(Response response) sync* {
    // 解析link href中的文件，可能是CSS文件
    yield* save(response);
    if (response.text == null) {
      // print('${response.url} is not a css file');
      return;
    }
    final reg = RegExp(r'url\((.*?)\)');
    for (final match in reg.allMatches(response.text!)) {
      yield* response.follow(match.group(1), callback: save);
    }
  }

  Iterable<Request> save(Response response) sync* {
    // 保存文件，重写链接
    var prefix = startUri.host;
    if (startUri.pathSegments.isNotEmpty) {
      prefix += '_${startUri.pathSegments.join('_')}';
    }
    var path = 'download/$prefix${response.uri.path}';
    if (path.endsWith('/')) {
      path += 'index.html';
    }
    if (!path.split('/').last.contains('.')) {
      path += '.html';
    }
    final file = File(path);
    file.createSync(recursive: true);
    if (response.isHtml) {
      for (final node in response.xpath('//a/@href').nodes +
          response.xpath('//link/@href').nodes) {
        final href = node.attributes['href'];
        if (href == null) {
          continue;
        }
        node.node.attributes['href'] = abs2relative(response.url, href);
      }
      for (final node in response.xpath('//script/@src').nodes +
          response.xpath('//img/@src').nodes +
          response.xpath('//audio/@src').nodes +
          response.xpath('//video/@src').nodes) {
        final src = node.attributes['src'];
        if (src == null) {
          continue;
        }
        node.node.attributes['src'] = abs2relative(response.url, src);
      }
      file.writeAsStringSync(response.document!.outerHtml);
    } else {
      file.writeAsBytesSync(response.body);
    }
    return;
  }
}

Future<void> download(
    {required void Function(String, String) addEdge,
    required String startUrl}) async {
  await RustLib.init();
  final spider = MySpider(addEdge, startUrl);
  spider.run();
}

String abs2relative(String base, String target) {
  // 将绝对路径转换为相对路径
  final baseUri = Uri.parse(base);
  final targetUri = baseUri.resolve(target);
  if (baseUri.host != targetUri.host ||
      !['http', 'https'].contains(targetUri.scheme) ||
      !targetUri.isAbsolute) {
    return target; // 外链,非HTTP链接，相对路径的链接保留
  }
  var index = 0;
  for (;
      index < min(baseUri.pathSegments.length, targetUri.pathSegments.length);
      index++) {
    if (baseUri.pathSegments[index] != targetUri.pathSegments[index]) {
      break;
    }
  } // 找到路径的公共前缀
  // 先回退到公共前缀， 然后前往目标路径
  var path = '../' * (baseUri.pathSegments.length - index - 1) +
      targetUri.pathSegments.skip(index).join('/');
  if (path.isEmpty) {
    path = './'; // 处理两个路径相同的情况
  }
  return path;
}

void main() {
  // 测试abs2relative
  final input = [
    [
      'http://127.0.0.1:8000/',
      '/posts/apue-chapter1-fileio/',
      'posts/apue-chapter1-fileio/',
    ],
    [
      'http://127.0.0.1:8000/posts/apue-chapter1-fileio/',
      '/',
      '../../',
    ],
    [
      'http://127.0.0.1:8000/posts/apue-chapter1-fileio/',
      '#file是操作系统管理的底层资源',
      '#file是操作系统管理的底层资源',
    ],
    [
      'http://127.0.0.1:8000/posts/apue-chapter1-fileio/',
      'https://pdos.csail.mit.edu/6.828/2021/schedule.html',
      'https://pdos.csail.mit.edu/6.828/2021/schedule.html',
    ]
  ];
  for (final item in input) {
    assert(abs2relative(item[0], item[1]) == item[2],
        "abs2relative(${item[0]}, ${item[1]}) != ${item[2]}");
  }
  debugPrint('abs2relative test passed!');
}
