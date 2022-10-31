import 'package:adgene/widget/adgene_ad_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Adgene Ad Sample'),
      ),
      body: const Home(),
    ));
  }
}

class Home extends StatelessWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("ad start"),
          AdgeneAd(
            slotId: "48547",
            width: 320,
            height: 50,
          ),
          const Text("ad end"),
          AdgeneAd(
            slotId: "48548",
            width: 320,
            height: 100,
          ),
          const Text("ad 300x250"),
          AdgeneAd(
            slotId: "48549",
            width: 300,
            height: 250,
          ),
        ]),
      ),
    );
  }
}
