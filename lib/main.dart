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
      home: ChangeNotifierProvider(
        create: (_) => ValueNotifier(0),
        child: Consumer<ValueNotifier<int>>(
          builder: (context, value, child) {
            return Scaffold(
              appBar: child as AppBar,
              body: MyApp(
                key: UniqueKey(),
              ),
            );
          },
          child: AppBar(
            title: const Text('网页及链接下载'),
            actions: [
              Builder(builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    context.read<ValueNotifier<int>>().value++;
                  },
                );
              })
            ],
          ),
        ),
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
        Provider(create: (_) => NodesNotifier()),
        ChangeNotifierProvider(create: (_) => ValueNotifier(false)),
        ChangeNotifierProvider(create: (_) => ValueNotifier((0.0025, 0.035))),
      ],
      child: Center(
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constaints) {
              if (constaints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(child: InputWidget()),
                    const SliderWidget(),
                  ],
                );
              } else {
                return SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      InputWidget(),
                      const Expanded(child: SliderWidget()),
                    ],
                  ),
                );
              }
            }),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
      padding: const EdgeInsets.only(left: 10, right: 10),
      height: 100,
      child: Column(
        children: [
          Expanded(
            child: TextFormField(
              key: formKey,
              decoration: const InputDecoration(
                labelText: '输入网址',
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
          ElevatedButton(
            onPressed: () {
              submit(formKey.currentState!.value, context);
            },
            child: const Text('下载'),
          ),
        ],
      ),
    );
  }

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
        data.send((input!));
      } else if (data is String) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('文件将保存在$data'),
        ));
      }
    });
    await Isolate.spawn((sp) {
      final workerI = ReceivePort();
      sp.send(workerI.sendPort);
      workerI.listen((data) async {
        if (data is String) {
          final path = await download(
            startUrl: data,
            addEdge: (a, b) => sp.send((a, b)),
          );
          sp.send(path);
        }
      });
    }, mainI.sendPort, onExit: mainI.sendPort);
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
    return Center(
      child: SizedBox(
        height: 100,
        width: 300,
        child: Column(
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Text('斥力'),
                ),
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
                ),
              ],
            ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10, right: 20),
                  child: Text('引力'),
                ),
                Slider(
                  value: p2,
                  onChanged: (value) {
                    p2 = value;
                    const start = 0.035;
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
      ),
    );
  }
}
