## Overview

The TextResponsiveWidget is designed to handle scenarios where you want to prevent text overflow without explicitly setting a fixed font size. It calculates and adjusts the font size of the provided Text widget to fit within the available space defined by the parent widget.
### Usage

```dart
import 'package:flutter/material.dart';
import 'package:text_responsive/text_responsive.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: const TextResponsiveWidget(
            child: Text(
              'Your Text Here',
              style: TextStyle(fontSize: 20),
            ),
          ),
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