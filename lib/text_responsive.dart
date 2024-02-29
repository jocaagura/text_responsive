import 'package:flutter/material.dart';

/// A responsive text widget that automatically adjusts font size to fit available space.
///
/// This widget calculates and adjusts the font size of the provided [Text] to fit
/// within the available space defined by the parent widget. It's particularly useful
/// in situations where you want to prevent text overflow without explicitly setting
/// a fixed font size.
///
/// Usage:
/// ```dart
/// const TextResponsiveWidget(
///   child: Text(
///     'Your Text Here',
///     style: TextStyle(fontSize: 20),
///   ),
/// )
/// ```
///
/// The [TextResponsiveWidget] should be used as a direct child of a widget where
/// you want to ensure responsive text sizing.
class TextResponsiveWidget extends StatelessWidget {
  /// Creates a [TextResponsiveWidget].
  ///
  /// The [child] parameter is required and represents the text to be displayed.
  ///
  /// The [overflowCallback] is an optional callback function that is called
  /// when overflow is detected and the font size is adjusted.
  const TextResponsiveWidget({
    required this.child,
    this.overflowCallback,
    this.minFontSize = 1.0,
    super.key,
  });

  /// The text to be displayed and made responsive.
  final Text child;

  /// An optional callback function called when overflow is detected.
  final void Function()? overflowCallback;

  /// An optional value for min fontSize
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints boxConstraints) {
        if (child.overflow != null || child.style?.overflow != null) {
          return child;
        }
        final double insideFontSize = child.style?.fontSize ?? 12;
        final TextStyle textStyle =
            child.style?.copyWith(fontSize: insideFontSize) ??
                TextStyle(fontSize: insideFontSize, height: 1);

        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: child.data, style: textStyle),
          textDirection: TextDirection.ltr,
          maxLines: child.maxLines ?? 1,
        );

        textPainter.layout(maxWidth: double.maxFinite);

        final double maxAvailableSpaceToWrite = boxConstraints.maxWidth * 0.925;
        final double maxAvailableHeightSpaceToWrite =
            boxConstraints.maxHeight * 0.925;

        if (textPainter.height > maxAvailableHeightSpaceToWrite ||
            textPainter.width > maxAvailableSpaceToWrite) {
          final double adjustedFontSize = calculateFontSizeToFit(
            text: textPainter.plainText,
            maxLines: child.maxLines ?? 1,
            maxWidth: maxAvailableSpaceToWrite,
            maxHeight: maxAvailableHeightSpaceToWrite,
            style: textStyle,
            initialFontSize: insideFontSize,
            minFontSize: minFontSize,
          );

          overflowCallback?.call();

          return Text(
            child.data ?? '',
            style: textStyle.copyWith(fontSize: adjustedFontSize),
            textAlign: child.textAlign ?? TextAlign.left,
            maxLines: child.maxLines ?? 1,
          );
        }

        return child;
      },
    );
  }

  /// Calculates the font size to fit the available space.
  ///
  /// This method calculates and returns the adjusted font size based on the
  /// [TextPainter] measurements and the maximum available space for both width
  /// and height.
  double calculateFontSizeToFit({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required double maxHeight,
    required int maxLines,
    double minFontSize = 1.0,
    double initialFontSize = 18,
  }) {
    double fontSize = initialFontSize;
    double lastGoodFontSize = minFontSize;
    bool hasOverflow = true;

    while (hasOverflow && fontSize > minFontSize) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style.copyWith(fontSize: fontSize)),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      );

      textPainter.layout(maxWidth: maxWidth);

      if (textPainter.width <= maxWidth &&
          textPainter.height <= maxHeight &&
          !textPainter.didExceedMaxLines) {
        lastGoodFontSize = fontSize;

        hasOverflow = false;
      } else {
        fontSize *= 0.99;
      }
    }
    return lastGoodFontSize;
  }
}

/// A widget that provides responsive text functionality for paragraph text.
///
/// This widget wraps a Text widget and automatically resizes the text
/// to fit its container's width and height while respecting the original
/// style and structure of the paragraph.
///
/// The widget is useful in scenarios where you want to display a paragraph
/// of text that needs to adapt to the screen size and orientation changes
/// without manually adjusting the font size.
///
/// Example:
/// ```
/// ParagraphTextWidget(
///   'Your paragraph text goes here',
///   style: TextStyle(fontSize: 20),
/// ),
/// ```
class ParagraphTextWidget extends StatelessWidget {
  /// Creates a [ParagraphTextWidget].
  ///
  /// The [text] parameter must not be null and is the text that the widget displays.
  /// The [style] parameter is for specifying the style of the text such as fontSize, fontWeight, etc.
  /// Other parameters like [textAlign], [softWrap], etc., can be set to control how the text behaves.
  const ParagraphTextWidget(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines = 10,
    this.semanticsLabel,
    this.textWidthBasis,
    this.selectionColor,
  });

  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final Text child = Text(
      text,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      selectionColor: selectionColor,
    );

    return TextResponsiveWidget(child: child);
  }
}

/// A widget designed to provide responsive text functionality for inline text.
///
/// This widget is similar to [ParagraphTextWidget] but is tailored for short,
/// inline text elements. It resizes text to fit its container's width and height
/// and maintains the original text style.
///
/// This widget is particularly useful for headings, captions, or any short text
/// that needs to be flexible with its surrounding environment.
///
/// Example:
/// ```
/// InlineTextWidget(
///   'Your inline text goes here',
///   style: TextStyle(fontSize: 20),
/// ),
/// ```
class InlineTextWidget extends StatelessWidget {
  /// Creates an [InlineTextWidget].
  ///
  /// The [text] parameter must not be null and is the text that the widget displays.
  /// The [style] parameter is for specifying the style of the text.
  /// Other parameters like [textAlign], [softWrap], etc., can be set to control how the text behaves.
  const InlineTextWidget(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.selectionColor,
  });

  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final Text child = Text(
      text,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      semanticsLabel: semanticsLabel,
      selectionColor: selectionColor,
    );

    return TextResponsiveWidget(child: child);
  }
}
