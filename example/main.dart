import 'package:flutter/material.dart';
import 'package:interactive_gallery/interactive_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Example());
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  List<String> networkImages = [
    'https://www.travelandleisure.com/thmb/aFSOhQj2_rSqHdYLFflyxrTAsW4=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/machu-PICCHU0916-2000-c0b8a30f2ce949dc90aff1ef34b7c631.jpg',
    'https://i.ytimg.com/vi/u9AMJGOF26g/maxresdefault.jpg',
    'https://assets.newatlas.com/dims4/default/e35c3e6/2147483647/strip/true/crop/1600x1669+0+0/resize/1600x1669!/quality/90/?url=http%3A%2F%2Fnewatlas-brightspot.s3.amazonaws.com%2Fff%2Fe6%2F2071913045559fb5f77834f34b4b%2Fcarina.png'
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) {
                    return InteractiveGallery(
                      imageList: networkImages,
                      backgroundColor: Colors.black.withOpacity(0.95),
                      // singleTapBottomsheWidget: Container(height: 100, color: Colors.red),
                      // longTapBottomsheetWidget: Container(height: 100, color: Colors.yellow),
                    );
                  },
                ));
              },
              child: const Text('Navigator')),
        ),
      ),
    );
  }
}
