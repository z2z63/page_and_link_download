import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/graphwidget/graph.dart';
import 'package:provider/provider.dart';

import 'fruchmanreingold.dart';

class MyDirectedGraph<T> extends StatefulWidget {
  final MyGraph<T> graph;
  final MyAlgorithm algorithm = MyAlgorithm();
  final Paint? paint;

  final stepMilis = 10;
  final Widget Function(BuildContext,MyNode<T>) builder;

  MyDirectedGraph(
      {super.key, required this.graph, this.paint, required this.builder});

  @override
  State<MyDirectedGraph<T>> createState() => _MyDirectedGraphState<T>();
}

class _MyDirectedGraphState<T> extends State<MyDirectedGraph<T>> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    widget.algorithm.init(widget.graph);
    timer = Timer.periodic(Duration(milliseconds: widget.stepMilis), (_) {
      widget.algorithm.step(widget.graph);
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    widget.algorithm.setDimensions(size.width, size.height);
    final parameters =  context.watch<ValueNotifier<(double, double)>>().value;
    widget.algorithm.repulsionRate = parameters.$1;
    widget.algorithm.attractionRate = parameters.$2;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: size,
          painter: MyEdgeRender(
              widget.algorithm, widget.graph, const Offset(0, 0)),
        ),
        ...List<Widget>.generate(
          widget.graph.nodes.length,
          (index) {
            final node = widget.graph.nodes.values.elementAt(index);
            return Positioned(
              top: node.position.dy,
              left: node.position.dx,
              child: GestureDetector(
                child: widget.builder(context, node),
                onPanUpdate: (details) {
                  node.position += details.delta;
                  setState(() {});
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class MyEdgeRender extends CustomPainter {
  MyAlgorithm algorithm;
  MyGraph graph;
  Offset offset;

  MyEdgeRender(this.algorithm, this.graph, this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = (Paint()
      ..color = Colors.black
      ..strokeWidth = 3)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    algorithm.renderer.render(canvas, graph, edgePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
