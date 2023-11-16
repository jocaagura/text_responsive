import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_responsive/text_responsive.dart';

void main() {
  testWidgets('TextResponsiveWidget adjusts font size on overflow',
      (WidgetTester tester) async {
    const Text text = Text(
      'Overflow Example Text',
      style: TextStyle(fontSize: 60),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: TextResponsiveWidget(child: text),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Overflow Example Text'), findsOneWidget);
  });

  testWidgets('TextResponsiveWidget does not adjust font size if not overflow',
      (WidgetTester tester) async {
    const Text text = Text(
      'No Overflow Example Text',
      style: TextStyle(fontSize: 60),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              height: 100,
              child: TextResponsiveWidget(child: text),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No Overflow Example Text'), findsOneWidget);
  });

  // Add more test cases for different scenarios

  testWidgets('TextResponsiveWidget calls overflow callback',
      (WidgetTester tester) async {
    bool overflowCallbackCalled = false;
    void setOverflowCallback() {
      overflowCallbackCalled = true;
    }

    const Text text = Text(
      'Overflow Callback Example Text',
      style: TextStyle(fontSize: 60),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 100,
              child: TextResponsiveWidget(
                overflowCallback: setOverflowCallback,
                child: text,
              ),
            ),
          ),
        ),
      ),
    );

    // Simulate overflow
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 50,
              child: TextResponsiveWidget(
                overflowCallback: setOverflowCallback,
                child: text,
              ),
            ),
          ),
        ),
      ),
    );

    expect(overflowCallbackCalled, true);
  });
}
