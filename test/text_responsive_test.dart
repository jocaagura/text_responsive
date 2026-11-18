import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph, RenderProxyBox;
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

    final Text resized =
        tester.widget<Text>(find.text('Overflow Example Text'));
    expect(resized.style!.fontSize, lessThan(60));
  });

  testWidgets('TextResponsiveWidget does not adjust font size if not overflow',
      (WidgetTester tester) async {
    const Text text = Text(
      'No Overflow Example Text',
      style: TextStyle(fontSize: 16),
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

    expect(
      tester.widget<Text>(find.text('No Overflow Example Text')),
      same(text),
    );
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

  group('ParagraphTextWidget Tests', () {
    testWidgets('should build without exploding', (WidgetTester tester) async {
      // Create a minimal app with the widget under test.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParagraphTextWidget(
              'Test paragraph text for size adjustment',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // You should check that the text widget appears and possibly that no errors are thrown.
      expect(find.byType(ParagraphTextWidget), findsOneWidget);
    });
  });
  group('ParagraphTextWidget Tests', () {
    testWidgets('should build without exploding', (WidgetTester tester) async {
      // Create a minimal app with the widget under test.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParagraphTextWidget(
              'Test paragraph text for size adjustment',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // You should check that the text widget appears and possibly that no errors are thrown.
      expect(find.byType(ParagraphTextWidget), findsOneWidget);
    });

    testWidgets('should build without exploding', (WidgetTester tester) async {
      // Create a minimal app with the widget under test.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400.0,
              height: 400.0,
              child: ParagraphTextWidget(
                'Test paragraph text for size adjustment',
                style: TextStyle(fontSize: 4),
              ),
            ),
          ),
        ),
      );

      // You should check that the text widget appears and possibly that no errors are thrown.
      expect(find.byType(ParagraphTextWidget), findsOneWidget);
    });
  });

  group('InlineTextWidget Tests', () {
    testWidgets('should build without exploding', (WidgetTester tester) async {
      // Create a minimal app with the widget under test.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineTextWidget(
              'Test inline text for size adjustment, Test inline text for size adjustment, Test inline text for size adjustment, ',
              //  style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      // Check that the InlineTextWidget appears
      expect(find.byType(InlineTextWidget), findsOneWidget);
    });

    testWidgets('should build with overflow', (WidgetTester tester) async {
      // Create a minimal app with the widget under test.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InlineTextWidget(
              'Test inline text for size adjustment,Test inline text for size adjustment,Test inline text for size adjustment,Test inline text for size adjustment,Test inline text for size adjustment,Test inline text for size adjustment,',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      // Check that the InlineTextWidget appears
      expect(find.byType(InlineTextWidget), findsOneWidget);
    });
  });

  group('Responsive layout regressions', () {
    testWidgets('an exact fit across two lines keeps the original size',
        (WidgetTester tester) async {
      const Text child = Text(
        'aaaa aaaa aaaa',
        maxLines: 2,
        style: TextStyle(fontSize: 10),
      );
      int overflows = 0;
      await tester.pumpWidget(
        _constrainText(
          TextResponsiveWidget(
            child: child,
            overflowCallback: () => overflows++,
          ),
          width: 90,
        ),
      );

      expect(tester.widget<Text>(find.byType(Text)), same(child));
      _expectLastCharacterLaidOut(_paragraph(tester));
      expect(overflows, 0);
    });

    testWidgets('adjustment retains semantics, RTL, and text properties',
        (WidgetTester tester) async {
      final Key textKey = UniqueKey();
      const StrutStyle strut = StrutStyle(fontSize: 12, height: 1);
      const TextHeightBehavior height = TextHeightBehavior(
        applyHeightToFirstAscent: false,
      );
      const Color selectionColor = Color(0xFF123456);
      final Text child = Text(
        'ABCDEF',
        key: textKey,
        semanticsLabel: 'Six characters',
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.end,
        locale: const Locale('ar'),
        softWrap: false,
        maxLines: 1,
        strutStyle: strut,
        textHeightBehavior: height,
        textWidthBasis: TextWidthBasis.longestLine,
        selectionColor: selectionColor,
        style: const TextStyle(fontSize: 30),
      );
      await tester.pumpWidget(
        _constrainText(TextResponsiveWidget(child: child), width: 90),
      );

      final Text resized = tester.widget<Text>(find.byKey(textKey));
      final RenderParagraph paragraph = _paragraph(tester);
      expect(resized.style!.fontSize, closeTo(15, 0.02));
      expect(find.bySemanticsLabel('Six characters'), findsOneWidget);
      expect(paragraph.textDirection, TextDirection.rtl);
      expect(paragraph.textAlign, TextAlign.end);
      expect(paragraph.locale, const Locale('ar'));
      expect(paragraph.softWrap, isFalse);
      expect(paragraph.maxLines, 1);
      expect(paragraph.strutStyle, strut);
      expect(paragraph.textHeightBehavior, height);
      expect(paragraph.textWidthBasis, TextWidthBasis.longestLine);
      expect(resized.selectionColor, selectionColor);
    });

    testWidgets('measures inherited style and line limits across resizes',
        (WidgetTester tester) async {
      const Text child = Text('ABCD');
      const Widget widget = DefaultTextStyle(
        style: TextStyle(fontSize: 40, height: 1),
        textAlign: TextAlign.end,
        maxLines: 1,
        child: TextResponsiveWidget(child: child),
      );
      await tester.pumpWidget(
        _constrainText(
          widget,
          width: 80,
          direction: TextDirection.rtl,
        ),
      );

      final RenderParagraph paragraph = _paragraph(tester);
      expect(paragraph.text.style!.fontSize, closeTo(20, 0.02));
      expect(paragraph.text.style!.height, 1);
      expect(paragraph.textDirection, TextDirection.rtl);
      expect(paragraph.textAlign, TextAlign.end);
      expect(paragraph.maxLines, 1);
      _expectLastCharacterLaidOut(paragraph);

      await tester.pumpWidget(
        _constrainText(widget, width: 200, direction: TextDirection.rtl),
      );
      expect(tester.widget<Text>(find.byType(Text)), same(child));
      expect(_paragraph(tester).maxLines, 1);
      expect(_paragraph(tester).text.style!.fontSize, 40);
    });

    for (final bool explicitScale in <bool>[false, true]) {
      testWidgets(
        'fits with ${explicitScale ? 'explicit' : 'ambient'} nonlinear scaling',
        (WidgetTester tester) async {
          const TextScaler scaler = _NonlinearTextScaler();
          await tester.pumpWidget(
            _constrainText(
              TextResponsiveWidget(
                child: Text(
                  'ABCD',
                  style: const TextStyle(fontSize: 20),
                  maxLines: 1,
                  textScaler: explicitScale ? scaler : null,
                ),
              ),
              width: 120,
              scaler: explicitScale ? TextScaler.noScaling : scaler,
            ),
          );

          final RenderParagraph paragraph = _paragraph(tester);
          expect(paragraph.textScaler, same(scaler));
          expect(paragraph.text.style!.fontSize, closeTo(15, 0.02));
          _expectLastCharacterLaidOut(paragraph);
        },
      );
    }

    testWidgets(
        'honors bold text and legacy scaling with a non-inheriting style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _constrainText(
          const DefaultTextStyle(
            style: TextStyle(fontSize: 60, letterSpacing: 10),
            child: TextResponsiveWidget(
              child: Text(
                'ABCD',
                style: TextStyle(inherit: false, fontSize: 28),
                maxLines: 1,
                // ignore: deprecated_member_use
                textScaleFactor: 2,
              ),
            ),
          ),
          width: 120,
          scaler: const _NonlinearTextScaler(),
          boldText: true,
        ),
      );

      final RenderParagraph paragraph = _paragraph(tester);
      expect(paragraph.text.style!.fontSize, closeTo(15, 0.02));
      expect(paragraph.text.style!.fontWeight, FontWeight.bold);
      expect(paragraph.text.style!.letterSpacing, isNull);
      expect(paragraph.textScaler.scale(10), 20);
      _expectLastCharacterLaidOut(paragraph);
    });

    testWidgets('shrinks rich runs without replacing their spans',
        (WidgetTester tester) async {
      const TextSpan span = TextSpan(
        text: 'AB',
        children: <InlineSpan>[
          TextSpan(
            text: 'CD',
            semanticsLabel: 'named run',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ],
      );
      const Text child = Text.rich(
        span,
        style: TextStyle(fontSize: 20),
        maxLines: 1,
        textScaler: _NonlinearTextScaler(),
      );
      await tester.pumpWidget(
        _constrainText(const TextResponsiveWidget(child: child), width: 90),
      );

      final Text resized = tester.widget<Text>(find.byType(Text));
      final RenderParagraph paragraph = _paragraph(tester);
      expect(resized, isNot(same(child)));
      expect(resized.textSpan, same(span));
      expect(paragraph.text.toPlainText(includeSemanticsLabels: false), 'ABCD');
      expect(find.bySemanticsLabel(RegExp('named run')), findsOneWidget);
      expect(
        paragraph.textScaler.scale(40),
        lessThan(child.textScaler!.scale(40)),
      );
      _expectLastCharacterLaidOut(paragraph);
    });

    testWidgets('rich text applies the minimum to its base size',
        (WidgetTester tester) async {
      const TextSpan span = TextSpan(
        text: 'ABCD',
        children: <InlineSpan>[
          TextSpan(text: 'EF', style: TextStyle(fontSize: 8)),
        ],
      );
      await tester.pumpWidget(
        _constrainText(
          const TextResponsiveWidget(
            child: Text.rich(
              span,
              style: TextStyle(fontSize: 20),
              softWrap: false,
            ),
          ),
          width: 5,
        ),
      );

      final TextScaler scaler = _paragraph(tester).textScaler;
      expect(scaler.scale(20), 6);
      expect(scaler.scale(8), closeTo(2.4, 0.001));
      expect(tester.widget<Text>(find.byType(Text)).textSpan, same(span));
    });

    testWidgets('keeps inline widget spans and their original layout',
        (WidgetTester tester) async {
      const Key inlineKey = ValueKey<String>('inline-widget');
      const Text child = Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(text: 'ABCD'),
            WidgetSpan(child: SizedBox(key: inlineKey, width: 8, height: 8)),
          ],
        ),
        style: TextStyle(fontSize: 30),
      );
      await tester.pumpWidget(
        _constrainText(
          const TextResponsiveWidget(child: child),
          width: 70,
          height: 20,
        ),
      );

      expect(tester.widget<Text>(find.byType(Text)), same(child));
      expect(find.byKey(inlineKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('caps the minimum at the original size and uses the floor',
        (WidgetTester tester) async {
      for (final (double original, double requested, double expected) in <(
        double,
        double,
        double
      )>[(4, 1, 4), (20, 1, 6), (20, 12, 12), (10, 15, 10)]) {
        await tester.pumpWidget(
          _constrainText(
            TextResponsiveWidget(
              minFontSize: requested,
              child: Text(
                'ABCDE',
                softWrap: false,
                style: TextStyle(fontSize: original),
              ),
            ),
            width: 5,
          ),
        );

        expect(_paragraph(tester).text.style!.fontSize, expected);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('returns the minimum when height alone prevents a fit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _constrainText(
          const TextResponsiveWidget(
            minFontSize: 8,
            child: Text('ABCD', style: TextStyle(fontSize: 20)),
          ),
          width: 500,
          height: 1,
        ),
      );

      expect(_paragraph(tester).text.style!.fontSize, 8);
    });

    testWidgets('keeps the original text when both dimensions are unbounded',
        (WidgetTester tester) async {
      const Text child = Text('ABCD', style: TextStyle(fontSize: 20));
      int overflows = 0;
      await tester.pumpWidget(
        _constrainText(
          UnconstrainedBox(
            child: TextResponsiveWidget(
              child: child,
              overflowCallback: () => overflows++,
            ),
          ),
          width: 100,
          height: 60,
        ),
      );

      expect(tester.widget<Text>(find.byType(Text)), same(child));
      expect(overflows, 0);
    });

    testWidgets('delivers overflow after layout and once per occurrence',
        (WidgetTester tester) async {
      late StateSetter update;
      double width = 60;
      int overflows = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            update = setState;
            return _constrainText(
              TextResponsiveWidget(
                child: const Text(
                  'ABCDE',
                  softWrap: false,
                  style: TextStyle(fontSize: 24),
                ),
                overflowCallback: () => setState(() => overflows++),
              ),
              width: width,
            );
          },
        ),
      );

      expect(overflows, 1);
      await tester.pump();
      expect(overflows, 1);
      update(() => width = 200);
      await tester.pump();
      update(() => width = 60);
      await tester.pump();
      await tester.pump();
      expect(overflows, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancels pending notification when text fits in the same frame',
        (WidgetTester tester) async {
      const Text child =
          Text('ABCDE', softWrap: false, style: TextStyle(fontSize: 24));
      int overflows = 0;
      await tester.pumpWidget(
        _constrainText(
          _RelayoutText(
            child: TextResponsiveWidget(
              child: child,
              overflowCallback: () => overflows++,
            ),
          ),
          width: 200,
        ),
      );

      expect(tester.widget<Text>(find.byType(Text)), same(child));
      expect(overflows, 0);
    });

    testWidgets('explicit widget and style overflow bypass adjustment',
        (WidgetTester tester) async {
      int overflows = 0;
      for (final Text child in <Text>[
        const Text(
          'ABCD',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 30),
        ),
        const Text(
          'ABCD',
          style: TextStyle(fontSize: 30, overflow: TextOverflow.ellipsis),
        ),
      ]) {
        await tester.pumpWidget(
          _constrainText(
            TextResponsiveWidget(
              child: child,
              overflowCallback: () => overflows++,
            ),
            width: 40,
          ),
        );

        expect(tester.widget<Text>(find.byType(Text)), same(child));
        expect(_paragraph(tester).overflow, TextOverflow.ellipsis);
      }
      expect(overflows, 0);
    });

    testWidgets('paragraph keeps unlimited lines and inline text fits one line',
        (WidgetTester tester) async {
      const TextStyle style = TextStyle(fontSize: 20);
      await tester.pumpWidget(
        _constrainText(
          const ParagraphTextWidget('ABCD ABCD', maxLines: null, style: style),
          width: 90,
        ),
      );
      expect(_paragraph(tester).maxLines, isNull);
      expect(_paragraph(tester).text.style!.fontSize, 20);

      await tester.pumpWidget(
        _constrainText(
          const InlineTextWidget('ABCD ABCD', style: style),
          width: 90,
        ),
      );
      expect(_paragraph(tester).maxLines, 1);
      expect(_paragraph(tester).text.style!.fontSize, closeTo(10, 0.02));
      _expectLastCharacterLaidOut(_paragraph(tester));
    });

    test('public plain-text fitting method respects its size bounds', () {
      const TextResponsiveWidget widget =
          TextResponsiveWidget(child: Text('ABCD'));
      expect(
        widget.calculateFontSizeToFit(
          text: 'ABCD',
          style: const TextStyle(),
          maxWidth: 48,
          maxHeight: 30,
          maxLines: 1,
          initialFontSize: 24,
        ),
        closeTo(12, 0.02),
      );
    });

    test('public plain-text method accepts an explicit minimum below six', () {
      const TextResponsiveWidget widget =
          TextResponsiveWidget(child: Text('ABCD'));
      expect(
        widget.calculateFontSizeToFit(
          text: 'ABCD',
          style: const TextStyle(),
          maxWidth: 1,
          maxHeight: 1,
          maxLines: 1,
          minFontSize: 2,
        ),
        2,
      );
      expect(
        widget.calculateFontSizeToFit(
          text: 'ABCD',
          style: const TextStyle(),
          maxWidth: 1,
          maxHeight: 1,
          maxLines: 1,
        ),
        6,
      );
    });
  });
}

Widget _constrainText(
  Widget child, {
  required double width,
  double? height,
  TextDirection direction = TextDirection.ltr,
  TextScaler scaler = TextScaler.noScaling,
  bool boldText = false,
}) {
  return Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: scaler, boldText: boldText),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 14, fontFamily: 'Ahem'),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    ),
  );
}

RenderParagraph _paragraph(WidgetTester tester) =>
    tester.renderObject<RenderParagraph>(find.byType(RichText));

void _expectLastCharacterLaidOut(RenderParagraph paragraph) {
  final int end =
      paragraph.text.toPlainText(includeSemanticsLabels: false).length;
  expect(
    paragraph.getBoxesForSelection(
      TextSelection(baseOffset: end - 1, extentOffset: end),
    ),
    isNotEmpty,
    reason: 'The last character should be laid out within the line limit.',
  );
}

class _NonlinearTextScaler extends TextScaler {
  const _NonlinearTextScaler();

  @override
  double scale(double fontSize) =>
      fontSize <= 16 ? fontSize * 2 : fontSize + 16;

  @override
  double get textScaleFactor => scale(14) / 14;
}

class _RelayoutText extends SingleChildRenderObjectWidget {
  const _RelayoutText({required super.child});

  @override
  RenderProxyBox createRenderObject(BuildContext context) =>
      _RenderRelayoutText();
}

class _RenderRelayoutText extends RenderProxyBox {
  @override
  void performLayout() {
    child!.layout(const BoxConstraints(maxWidth: 40), parentUsesSize: true);
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
  }
}
