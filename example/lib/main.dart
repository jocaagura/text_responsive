import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';

const String paragraph =
    'In Flutter, the adaptability of a paragraph to its container is crucial for creating responsive and user-friendly applications. This flexibility ensures that text content optimally fits within varying screen sizes and orientations, enhancing readability and user experience. By automatically adjusting to the container, the paragraph prevents overflow issues and maintains a clean, professional layout. This adaptability is especially important in a mobile-first world, where users access content on a diverse range of devices with different screen dimensions. In summary, an adaptable paragraph in Flutter is key to delivering a seamless and accessible app interface.';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text responsive demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    const Text text = Text(
      'Here we go!!!!!',
      style: TextStyle(fontSize: 60),
    );
    const Text textName = Text(
      'Jhon Emiliano Doe Belalcazar',
      style: TextStyle(fontSize: 60),
    );

    const Text ellipsisText = Text(
      'Here we go with a very long ellipsis text that maybe has error',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 20,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final bloodTypeText = Text(
      'O+',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: MediaQuery.of(context).devicePixelRatio * 100,
          color: Theme.of(context).canvasColor),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Text responsive demo'),
      ),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          const SizedBox(
            width: double.maxFinite,
            child: Text(
              'Fisrt case before: ',
            ),
          ),
          Container(
            width: 50.0,
            height: 50.0,
            color: Colors.orange,
            child: text,
          ),
          const Text(
            'Fisrt case after: ',
          ),
          Container(
            width: 500.0,
            height: 50.0,
            color: Colors.orange,
            child: const TextResponsiveWidget(
              child: text,
            ),
          ),
          const TextResponsiveWidget(
            child: Text('Before'),
          ),
          CardExampleWidget(
            textName: textName,
            bloodTypeText: bloodTypeText,
            ellipsisText: ellipsisText,
          ),
          const TextResponsiveWidget(
            child: Text('After: With TextResponsiveWidget'),
          ),
          CardExampleWidget(
            textName: const TextResponsiveWidget(
              child: textName,
            ),
            bloodTypeText: TextResponsiveWidget(child: bloodTypeText),
            ellipsisText: const TextResponsiveWidget(
              child: ellipsisText,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Colors.orangeAccent,
                width: size.width * 0.4,
                height: size.height * 0.4,
                child: const Text(
                  paragraph,
                  maxLines: 10,
                  style: TextStyle(fontSize: 50),
                ),
              ),
              Container(
                color: Colors.green,
                width: size.width * 0.4,
                height: size.height * 0.4,
                child: const TextResponsiveWidget(
                  child: Text(
                    paragraph,
                    maxLines: 10,
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.4,
                child: const InlineTextWidget(
                  paragraph,
                  style: TextStyle(fontSize: 50),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                width: size.width * 0.4,
                height: size.height * 0.4,
                child: const ParagraphTextWidget(
                  paragraph,
                  maxLines: 10,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardExampleWidget extends StatelessWidget {
  const CardExampleWidget({
    super.key,
    required this.textName,
    required this.ellipsisText,
    required this.bloodTypeText,
  });

  final Widget textName;
  final Widget ellipsisText;
  final Widget bloodTypeText;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.4;
    final double cardHeight = size.height * 0.25;
    final innerWidth = cardWidth * 0.8;
    final innerContainer = cardHeight * 0.5;

    final color = Theme.of(context).canvasColor;
    return Card(
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  child: Icon(
                    Icons.person,
                    color: color,
                  ),
                ),
                Container(
                  width: innerWidth,
                  height: 50,
                  color: Colors.orangeAccent,
                  child: textName,
                )
              ],
            ),
            SizedBox(
              height: cardHeight * 0.5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    width: 20.0,
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.yellow,
                    child: ellipsisText,
                  )),
                  const SizedBox(
                    width: 20.0,
                  ),
                  const Icon(Icons.bloodtype),
                  const SizedBox(
                    width: 30.0,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 25.0),
                    height: innerContainer,
                    width: innerContainer,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius: BorderRadius.circular(innerContainer)),
                    child: bloodTypeText,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
