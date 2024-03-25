import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/graphwidget/graph.dart';

import 'edge_render.dart';

const  _epsilon = 0.0001;

class MyAlgorithm {
  final displacement = <MyNode, Offset>{};
  final Random rand = Random();
  late double graphHeight = 500; //default value, change ahead of time
  late double graphWidth = 500;
  late double tick;

  final int iterations;
  double repulsionRate;
  double attractionRate;
  final double repulsionPercentage;
  final double attractionPercentage;

  MyEdgeRenderer renderer;

  MyAlgorithm(
      {this.iterations = 1000,
      MyEdgeRenderer? renderer,
      this.repulsionRate = 0.0025,
      this.attractionRate = 0.035,
      this.repulsionPercentage = 0.35,
      this.attractionPercentage = 0.55})
      : renderer = renderer ?? MyArrowEdgeRenderer();

  void init<T>(MyGraph<T> graph) {
    for (final node in graph.nodes.values) {
      displacement[node] = Offset.zero;
      final d1 = rand.nextDouble();
      final d2 = rand.nextDouble();
      node.position = Offset(d1 * graphWidth, d2 * graphHeight);
    }
    graph.onNodeAddedListener((n) {
      displacement[n] = Offset.zero;
      final d1 = rand.nextDouble();
      final d2 = rand.nextDouble();
      n.position = Offset(d1 * graphWidth, d2 * graphHeight);
    });
  }

  void step<T>(MyGraph<T> graph) {
    displacement.clear();
    for (final node in graph.nodes.values) {
      displacement[node] = Offset.zero;
    }
    calculateRepulsion(graph.nodes.values);
    calculateAttraction(graph.edges);
    moveNodes(graph);
  }

  // 弹力
  void calculateAttraction<T>(Iterable<MyEdge<T>> edges) {
    for (final edge in edges) {
      final src = edge.source;
      final dst = edge.destination;
      final delta = src.position - dst.position;
      final deltaDistance = max(_epsilon, delta.distance);
      final maxAttractionDistance = min(graphWidth * attractionPercentage,
          graphHeight * attractionPercentage);
      final attractionForce =
          min(0, (maxAttractionDistance - deltaDistance)).abs() /
              (maxAttractionDistance * 2);
      final attractionVector = delta * attractionForce * attractionRate;

      displacement[src] = displacement[src]! - attractionVector;
      displacement[dst] = displacement[dst]! + attractionVector;
    }
  }

  // 库仑力
  void calculateRepulsion<T>(Iterable<MyNode<T>> nodes) {
    for (final nodeA in nodes) {
      for (final nodeB in nodes) {
        if (nodeA != nodeB) {
          final delta = nodeA.position - nodeB.position;
          final deltaDistance = max(_epsilon, delta.distance); //protect for 0
          final maxRepulsionDistance = min(graphWidth * repulsionPercentage,
              graphHeight * repulsionPercentage);
          final repulsionForce = max(0, maxRepulsionDistance - deltaDistance) /
              maxRepulsionDistance; //value between 0-1
          final repulsionVector = delta * repulsionForce * repulsionRate;

          displacement[nodeA] = displacement[nodeA]! + repulsionVector;
        }
      }
    }

    // for (final nodeA in nodes) {
    //   displacement[nodeA] = displacement[nodeA]! / nodes.length.toDouble();
    // }
  }

  void moveNodes<T>(MyGraph<T> graph) {
    for (final node in graph.nodes.values) {
      final newPosition = node.position + displacement[node]!;
      double newDX = min(graphWidth - 40, max(40, newPosition.dx));
      double newDY = min(graphHeight - 40, max(40, newPosition.dy));
      node.position = Offset(newDX, newDY);
    }
  }
  void setDimensions(double width, double height) {
    graphWidth = width;
    graphHeight = height;
  }
}
