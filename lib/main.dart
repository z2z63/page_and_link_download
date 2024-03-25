import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_app/graphwidget/graph.dart';
import 'package:my_app/graphwidget/graphwidget.dart';
import 'package:provider/provider.dart';

import 'download.dart';
import 'nodes.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('网页及链接下载')),
        body: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NodesNotifier()),
        ChangeNotifierProvider(create: (_) => ValueNotifier(false)),
        ChangeNotifierProvider(create: (_) => ValueNotifier((0.0025, 0.035))),
      ],
      child: Center(
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 600,
                child: Row(
                  children: [
                    Expanded(child: InputWidget()),
                    const SliderWidget(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Consumer<ValueNotifier<bool>>(
                builder: (context, value, child) {
                  if (value.value) {
                    return const GraphWidget();
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputWidget extends StatelessWidget {
  final formKey = GlobalKey<FormFieldState<String>>();

  InputWidget({super.key});

  Future<void> submit(String? input, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final nodes = context.read<NodesNotifier>();
    final value = context.read<ValueNotifier<bool>>();
    final mainI = ReceivePort();
    // share memory by communicating
    mainI.listen((data) {
      if (data is (String, String)) {
        nodes.addEdge(data.$1, data.$2);
        value.value = true;
      } else if (data is SendPort) {
        data.send(input!);
      }else if(data == null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('下载完成'),
        ));
      }
    });
    await Isolate.spawn((sp) {
      final workerI = ReceivePort();
      sp.send(workerI.sendPort);
      workerI.listen((data) async {
        if (data is String) {
          await download(
            startUrl: data,
            addEdge: (a, b) => sp.send((a, b)),
          );
        }
      });
    }, mainI.sendPort, onExit: mainI.sendPort);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 400,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: TextFormField(
                key: formKey,
                initialValue: 'https://blog.virtualfuture.top/',
                decoration: const InputDecoration(
                  labelText: '输入网址',
                  hintText: 'https://blog.virtualfuture.top/',
                  contentPadding: EdgeInsets.only(left: 10),
                ),
                validator: (input) {
                  if (input == null || input.isEmpty) {
                    return '请输入网址';
                  }
                  final uri = Uri.tryParse(input);
                  if (uri == null || !['http', 'https'].contains(uri.scheme)) {
                    return '请输入正确的网址';
                  }
                  return null;
                },
                onFieldSubmitted: (input) {
                  submit(input, context);
                },
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              submit(formKey.currentState!.value, context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}

class GraphWidget extends StatelessWidget {
  const GraphWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(10),
      minScale: 0.0001,
      maxScale: 10000,
      child: SizedBox(
        width: 4000,
        height: 4000,
        child: MyDirectedGraph(
          graph: context.read<NodesNotifier>().graph,
          builder: nodeBuilder,
        ),
      ),
    );
  }
}

Widget nodeBuilder(BuildContext context, MyNode<String> node) {
  double r = 5 + min(node.nDegree + node.pDegree, 300) / 6;
  const start = Colors.green;
  const end = Colors.red;
  final color =
      Color.lerp(start, end, min((node.nDegree + node.pDegree), 300) / 300);
  node.size = Size(r, r);
  return Tooltip(
    message: node.key.value,
    child: Container(
      width: r,
      height: r,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 0.2),
      ),
    ),
  );
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double p1;
  late double p2;

  @override
  void initState() {
    super.initState();
    final value = context.read<ValueNotifier<(double, double)>>().value;
    p1 = value.$1;
    p2 = value.$2;
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<ValueNotifier<(double, double)>>();
    return SizedBox(
      width: 300,
      height: 100,
      child: Column(
        children: [
          Row(
            children: [
              const Text('斥力'),
              Slider(
                value: p1,
                onChanged: (value) {
                  p1 = value;
                  const start = 0.0025;
                  const end = 0.1;
                  final computed = (end - start) * value + start;
                  notifier.value = (computed, notifier.value.$2);
                  setState(() {});
                },
              )
            ],
          ),
          Row(
            children: [
              const Text('引力'),
              Slider(
                value: p2,
                onChanged: (value) {
                  p2 = value;
                  const start = 0.075;
                  const end = 0.15;
                  final computed = (end - start) * value + start;
                  notifier.value = (notifier.value.$1, computed);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
