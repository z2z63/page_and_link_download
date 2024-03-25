import 'package:flutter/material.dart';

class MyGraph<T> {
  final _nodes = <ValueKey<T>, MyNode<T>>{};
  final Set<MyEdge<T>> _edges = {};

  final List<void Function(MyNode<T>)> onNodeAdded = [];

  Map<ValueKey<T>, MyNode<T>> get nodes => Map.unmodifiable(_nodes);

  Iterable<MyEdge<T>> get edges => _edges;

  void onNodeAddedListener(void Function(MyNode<T>) fn) {
    onNodeAdded.add(fn);
  }

  MyEdge<T> addEdge(MyNode<T> source, MyNode<T> destination, {Paint? paint}) {
    source = _nodes.putIfAbsent(source.key, () {
      // 回调设置节点随机初始位置
      for (final fn in onNodeAdded) {
        fn(source);
      }
      return source;
    });
    destination = _nodes.putIfAbsent(destination.key, () {
      for (final fn in onNodeAdded) {
        fn(destination);
      }
      return destination;
    });
    // 更新入度和出度
    nodes[source.key]!.nDegree++;
    nodes[destination.key]!.pDegree++;
    final edge = MyEdge(source, destination, paint: paint);
    _edges.add(edge); // 自动去重
    return edge;
  }
}

class MyNode<T> {
  final ValueKey<T> key;

  MyNode.id(T id) : key = ValueKey(id);

  Size size = const Size(0, 0);

  int pDegree = 0;
  int nDegree = 0;

  Offset position = const Offset(0, 0);

  double get height => size.height;

  double get width => size.width;

  double get x => position.dx;

  double get y => position.dy;

  set y(double value) {
    position = Offset(position.dx, value);
  }

  set x(double value) {
    position = Offset(value, position.dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MyNode && hashCode == other.hashCode;

  @override
  int get hashCode => key.hashCode;
}

class MyEdge<T> {
  MyNode<T> source;
  MyNode<T> destination;
  Paint? paint;

  MyEdge(this.source, this.destination, {this.paint});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MyEdge && hashCode == other.hashCode;

  @override
  int get hashCode => Object.hash(source, destination);
}
