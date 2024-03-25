import 'package:flutter/material.dart';
import 'graph.dart';

abstract class MyEdgeRenderer {
  void render(Canvas canvas, MyGraph graph, Paint paint);
}

class MyArrowEdgeRenderer extends MyEdgeRenderer {

  @override
  void render(Canvas canvas, MyGraph graph, Paint paint) {
    for (final edge in graph.edges) {
      canvas.drawLine(
        edge.source.position + Offset(edge.source.width / 2, edge.source.height / 2),
        edge.destination.position + Offset(edge.destination.width / 2, edge.destination.height / 2),
        edge.paint ?? paint,
      );
    }
  }
}
