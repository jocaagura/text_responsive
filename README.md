## Overview

The TextResponsiveWidget is designed to handle scenarios where you want to prevent text overflow without explicitly setting a fixed font size. It calculates and adjusts the font size of the provided Text widget to fit within the available space defined by the parent widget.
### Usage
#### TextResponsiveWidget

Wrap a `Text` or `Text.rich` with `TextResponsiveWidget` to shrink it when it
exceeds the available space. The widget uses the original text's effective
style, wrapping, line limit, direction, and accessibility scaling. Flutter
handles layout directly when the child sets `Text.overflow` or
`TextStyle.overflow`, when rich text contains a `WidgetSpan`, or when both
dimensions are unbounded.

The widget's `minFontSize` applies to the unscaled base size. It has a floor of
6 logical pixels and is capped at the original base size. Rich spans with
explicit font sizes shrink proportionally and can end up below the base
minimum. If the text still overflows at the minimum, Flutter applies its normal
overflow behavior. The optional `overflowCallback` reports overflow at the
original size after the frame and can fire again after that size fits.

#### ParagraphTextWidget & InlineTextWidget

Use these widgets for paragraph or inline text scenarios respectively. They offer the same responsive functionality with a focus on their specific text use cases.

`ParagraphTextWidget` lets you set `maxLines`, including `null` for Flutter's
inherited behavior. Responsive `InlineTextWidget` uses the inherited line limit
when present and fits to one line by default.
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
Features

* Automatically adjusts font size to fit available space.
* Respects the minimum font size and the text's overflow behavior.
* Optional callback function when overflow is detected.

### Installation

Add the following to your pubspec.yaml:
```yaml
dependencies:
  text_responsive: ^1.3.0
```
Then run:
```bash
flutter pub get
```

For more details, refer to the installation guide.
API Reference
TextResponsiveWidget
Constructor

```dart
const TextResponsiveWidget({
  required this.child,
  this.overflowCallback,
  this.minFontSize = 1.0,
  Key? key,
});
```

With the default `minFontSize` of `1.0`, the effective minimum is 6 logical
pixels for an original base font size of 6 or larger. Smaller original base
sizes keep their original size.

#### Parameters
    child: The text to be displayed and made responsive.
    overflowCallback: An optional callback delivered after the frame when overflow starts.
    minFontSize: The requested minimum unscaled base font size.

#### Methods

`calculateFontSizeToFit` measures plain text. Its minimum defaults to 6 logical
pixels and accepts explicit nonnegative values below 6.

### Contributing

Feel free to contribute to this project by opening issues or pull requests.
## License

This project is licensed under the MIT License - see the LICENSE file for details.
