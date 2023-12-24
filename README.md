## Overview

The TextResponsiveWidget is designed to handle scenarios where you want to prevent text overflow without explicitly setting a fixed font size. It calculates and adjusts the font size of the provided Text widget to fit within the available space defined by the parent widget.
### Usage
#### TextResponsiveWidget

Wrap your Text widget with TextResponsiveWidget to ensure responsive text sizing. Optionally, provide an overflowCallback to be notified when overflow is detected and the font size is adjusted.

#### ParagraphTextWidget & InlineTextWidget

Use these widgets for paragraph or inline text scenarios respectively. They offer the same responsive functionality with a focus on their specific text use cases.
```dart
import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Use ParagraphTextWidget for paragraph text
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: const ParagraphTextWidget(
                    'In Flutter, the adaptability of a paragraph to its container is crucial for creating responsive and user-friendly applications. This flexibility ensures that text content optimally fits within varying screen sizes and orientations, enhancing readability and user experience. By automatically adjusting to the container, the paragraph prevents overflow issues and maintains a clean, professional layout. This adaptability is especially important in a mobile-first world, where users access content on a diverse range of devices with different screen dimensions. In summary, an adaptable paragraph in Flutter is key to delivering a seamless and accessible app interface.',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                // Use InlineTextWidget for inline text
                const InlineTextWidget(
                  'Your inline text here',
                  style: TextStyle(fontSize: 20),
                ),
              ]),
        ),
      ),
    );
  }
}
```
Simply wrap your Text widget with TextResponsiveWidget to ensure responsive text sizing. Optionally, you can provide an overflowCallback to be notified when overflow is detected and the font size is adjusted.
Features

* Automatically adjusts font size to fit available space.
* Prevents text overflow without explicitly setting a fixed font size.
* Optional callback function when overflow is detected.

### Installation

Add the following to your pubspec.yaml:
```yaml
dependencies:
  text_responsive: ^latest_version
```
Then run:
```bash
dart pub get
```

For more details, refer to the installation guide.
API Reference
TextResponsiveWidget
Constructor

```

const TextResponsiveWidget({
  required this.child,
  this.overflowCallback,
  Key? key,
});
```
#### Parameters
    child: The text to be displayed and made responsive.
    overflowCallback: An optional callback function called when overflow is detected.

#### Methods

    calculateFontSizeToFit: Calculates the font size to fit the available space.

### Contributing

Feel free to contribute to this project by opening issues or pull requests.
## License

This project is licensed under the MIT License - see the LICENSE file for details.