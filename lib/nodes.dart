import 'package:flutter/material.dart';
import 'package:my_app/graphwidget/graph.dart';

final _paint = Paint()
  ..color = Colors.grey
  ..strokeWidth = 0.2
  ..style = PaintingStyle.stroke;

class NodesNotifier extends ChangeNotifier {
  final graph = MyGraph<String>();

  void addEdge(String a, String b) {
    a = Uri.decodeComponent(a);
    b = Uri.decodeComponent(b);
    if (a == b) {
      return;
    }
    // 去除非HTML链接
    if ((a.endsWith('/') ||
            a.endsWith('.html') ||
            !a.split('/').last.contains('.')) &&
        (b.endsWith('/') ||
            b.endsWith('.html') ||
            !a.split('/').last.contains('.'))) {
      graph.addEdge(
        MyNode.id(b),
        MyNode.id(a),
        paint: _paint,
      );
      debugPrint('$a -> $b');
      // notifyListeners();
    }
  }
}
