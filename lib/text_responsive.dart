import 'dart:ui' as ui show LineMetrics;

import 'package:flutter/widgets.dart';

/// A responsive text widget that adjusts font size to fit available space.
///
/// The widget preserves the child's wrapping and line limit. It delegates to
/// Flutter's layout when [Text.overflow] or [TextStyle.overflow] is set on the
/// child, when rich text contains a [WidgetSpan], or when both dimensions are
/// unbounded.
///
/// ```dart
/// import 'package:flutter/widgets.dart';
/// import 'package:text_responsive/text_responsive.dart';
///
/// void main() {
///   runApp(const Directionality(
///     textDirection: TextDirection.ltr,
///     child: Center(
///       child: SizedBox(
///         width: 120,
///         child: TextResponsiveWidget(
///           child: Text('Hello, Flutter', maxLines: 1),
///         ),
///       ),
///     ),
///   ));
/// }
/// ```
class TextResponsiveWidget extends StatelessWidget {
  /// Creates a [TextResponsiveWidget] for the provided [child].
  const TextResponsiveWidget({
    required this.child,
    this.overflowCallback,
    this.minFontSize = 1.0,
    super.key,
  });

  /// The text to be displayed and made responsive.
  final Text child;

  /// Called after the frame, once while the original size continues to overflow.
  ///
  /// This reports overflow detected before shrinking. The callback can safely
  /// update widget state and can fire again after the original size fits.
  final void Function()? overflowCallback;

  /// The minimum unscaled base font size to try, with a floor of 6 logical pixels.
  ///
  /// An original base size below the floor keeps its size. For [Text.rich],
  /// explicit span sizes shrink in proportion to the base and can fall below
  /// this minimum.
  final double minFontSize;

  @override
  Widget build(BuildContext context) => _ResponsiveText(configuration: this);

  /// Calculates a fitting font size for plain text with no inherited styling.
  ///
  /// Defaults to a minimum of 6 logical pixels. You can pass a nonnegative
  /// [minFontSize] below 6. The effective minimum is capped at [initialFontSize]
  /// and returned when the text cannot fit.
  ///
  /// ```dart
  /// import 'package:flutter/foundation.dart';
  /// import 'package:flutter/widgets.dart';
  /// import 'package:text_responsive/text_responsive.dart';
  ///
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   const widget = TextResponsiveWidget(child: Text('Hello'));
  ///   final double size = widget.calculateFontSizeToFit(
  ///     text: 'Hello',
  ///     style: const TextStyle(),
  ///     maxWidth: 80,
  ///     maxHeight: 24,
  ///     maxLines: 1,
  ///     minFontSize: 4,
  ///   );
  ///   debugPrint('Fitting size is $size');
  /// }
  /// ```
  double calculateFontSizeToFit({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required double maxHeight,
    required int maxLines,
    double minFontSize = 6.0,
    double initialFontSize = 18,
  }) {
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    );
    final BoxConstraints constraints = BoxConstraints(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    try {
      final double minimumSize = minFontSize.clamp(0.0, initialFontSize);
      bool fits(double size) {
        painter.text =
            TextSpan(text: text, style: style.copyWith(fontSize: size));
        return _textFits(painter, constraints, softWrap: true);
      }

      return fits(initialFontSize)
          ? initialFontSize
          : _findSmallerFontSize(initialFontSize, minimumSize, fits);
    } finally {
      painter.dispose();
    }
  }
}

class _ResponsiveText extends StatefulWidget {
  const _ResponsiveText({required this.configuration});

  final TextResponsiveWidget configuration;

  @override
  State<_ResponsiveText> createState() => _ResponsiveTextState();
}

class _ResponsiveTextState extends State<_ResponsiveText> {
  bool _overflowing = false;
  bool _callbackScheduled = false;
  bool _overflowReported = false;

  void _reportOverflow(bool overflowing) {
    _overflowing = overflowing;
    if (!overflowing) {
      _overflowReported = false;
      return;
    }
    if (_overflowReported ||
        _callbackScheduled ||
        widget.configuration.overflowCallback == null) {
      return;
    }

    _callbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      _callbackScheduled = false;
      if (!mounted || !_overflowing) {
        return;
      }
      final VoidCallback? callback = widget.configuration.overflowCallback;
      if (callback != null) {
        _overflowReported = true;
        callback();
      }
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: _buildText);

  Widget _buildText(BuildContext context, BoxConstraints constraints) {
    final Text child = widget.configuration.child;
    final InlineSpan? span = child.textSpan;
    // Inline widgets need a render layout to determine their placeholder sizes.
    if (child.overflow != null ||
        child.style?.overflow != null ||
        (!constraints.hasBoundedWidth && !constraints.hasBoundedHeight) ||
        span?.visitChildren((InlineSpan span) => span is! PlaceholderSpan) ==
            false) {
      _reportOverflow(false);
      return child;
    }

    final DefaultTextStyle defaults = DefaultTextStyle.of(context);
    TextStyle style = child.style?.inherit == false
        ? child.style!
        : defaults.style.merge(child.style);
    if (MediaQuery.boldTextOf(context)) {
      style = style.merge(const TextStyle(fontWeight: FontWeight.bold));
    }

    final double originalSize = style.fontSize ?? 14;
    final double minimumSize = originalSize < 6.0
        ? originalSize
        : widget.configuration.minFontSize.clamp(6.0, originalSize);
    // ignore: deprecated_member_use
    final double? scaleFactor = child.textScaleFactor;
    final TextScaler scaler = child.textScaler ??
        (scaleFactor == null
            ? MediaQuery.textScalerOf(context)
            : TextScaler.linear(scaleFactor));
    final bool softWrap = child.softWrap ?? defaults.softWrap;
    final TextOverflow overflow = style.overflow ?? defaults.overflow;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: child.data,
        style: style,
        children: span == null ? null : <InlineSpan>[span],
      ),
      textAlign: child.textAlign ?? defaults.textAlign ?? TextAlign.start,
      textDirection: child.textDirection ?? Directionality.of(context),
      locale: child.locale ?? Localizations.maybeLocaleOf(context),
      textScaler: scaler,
      strutStyle: child.strutStyle,
      maxLines: child.maxLines ?? defaults.maxLines,
      ellipsis: overflow == TextOverflow.ellipsis ? '\u2026' : null,
      textWidthBasis: child.textWidthBasis ?? defaults.textWidthBasis,
      textHeightBehavior: child.textHeightBehavior ??
          defaults.textHeightBehavior ??
          DefaultTextHeightBehavior.maybeOf(context),
    );
    try {
      final bool overflowing =
          !_textFits(painter, constraints, softWrap: softWrap);
      _reportOverflow(overflowing);
      if (!overflowing || minimumSize == originalSize) {
        return child;
      }

      final double fontSize = _findSmallerFontSize(
        originalSize,
        minimumSize,
        (double size) {
          if (span == null) {
            painter.text = TextSpan(
              text: child.data,
              style: style.copyWith(fontSize: size),
            );
          } else {
            painter.textScaler = _FontSizeScaler(scaler, size / originalSize);
          }
          return _textFits(painter, constraints, softWrap: softWrap);
        },
      );
      return _resizeText(context, child, fontSize, scaler, originalSize);
    } finally {
      painter.dispose();
    }
  }
}

bool _textFits(
  TextPainter painter,
  BoxConstraints constraints, {
  required bool softWrap,
}) {
  painter.layout(
    minWidth: constraints.minWidth,
    maxWidth: softWrap || painter.ellipsis != null
        ? constraints.maxWidth
        : double.infinity,
  );
  return painter.height <= constraints.maxHeight &&
      painter.width <= constraints.maxWidth &&
      !painter.didExceedMaxLines &&
      (!constraints.hasBoundedWidth ||
          painter.computeLineMetrics().every(
                (ui.LineMetrics line) => line.width <= constraints.maxWidth,
              ));
}

double _findSmallerFontSize(
  double initialSize,
  double minimumSize,
  bool Function(double) fits,
) {
  if (minimumSize == initialSize || !fits(minimumSize)) {
    return minimumSize;
  }

  double lower = minimumSize;
  double upper = initialSize;
  for (int i = 0; i < 20 && upper - lower > 0.01; i++) {
    final double size = lower + (upper - lower) / 2;
    if (fits(size)) {
      lower = size;
    } else {
      upper = size;
    }
  }
  return lower;
}

Widget _resizeText(
  BuildContext context,
  Text text,
  double size,
  TextScaler scaler,
  double originalSize,
) {
  final InlineSpan? span = text.textSpan;
  final Text resized = span == null
      ? Text(
          text.data!,
          key: text.key,
          style: (text.style ?? const TextStyle()).copyWith(fontSize: size),
          strutStyle: text.strutStyle,
          textAlign: text.textAlign,
          textDirection: text.textDirection,
          locale: text.locale,
          softWrap: text.softWrap,
          overflow: text.overflow,
          textScaler: scaler,
          maxLines: text.maxLines,
          semanticsLabel: text.semanticsLabel,
          textWidthBasis: text.textWidthBasis,
          textHeightBehavior: text.textHeightBehavior,
          selectionColor: text.selectionColor,
        )
      : Text.rich(
          span,
          key: text.key,
          style: text.style,
          strutStyle: text.strutStyle,
          textAlign: text.textAlign,
          textDirection: text.textDirection,
          locale: text.locale,
          softWrap: text.softWrap,
          overflow: text.overflow,
          textScaler: _FontSizeScaler(scaler, size / originalSize),
          maxLines: text.maxLines,
          semanticsLabel: text.semanticsLabel,
          textWidthBasis: text.textWidthBasis,
          textHeightBehavior: text.textHeightBehavior,
          selectionColor: text.selectionColor,
        );

  // Carry forward native semantics properties that may be newer than the
  // minimum supported Flutter SDK, such as an accessibility identifier.
  final Widget original = text.build(context);
  if (original is Semantics) {
    return Semantics.fromProperties(
      properties: original.properties,
      container: original.container,
      explicitChildNodes: original.explicitChildNodes,
      excludeSemantics:
          original.excludeSemantics || original.child is ExcludeSemantics,
      child: resized,
    );
  }
  return resized;
}

class _FontSizeScaler extends TextScaler {
  const _FontSizeScaler(this.scaler, this.ratio);

  final TextScaler scaler;
  final double ratio;

  @override
  double scale(double fontSize) => scaler.scale(fontSize * ratio);

  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) =>
      other is _FontSizeScaler &&
      scaler == other.scaler &&
      ratio == other.ratio;

  @override
  int get hashCode => Object.hash(scaler, ratio);
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
      maxLines: overflow == null && style?.overflow == null
          ? DefaultTextStyle.of(context).maxLines ?? 1
          : null,
      semanticsLabel: semanticsLabel,
      selectionColor: selectionColor,
    );

    return TextResponsiveWidget(child: child);
  }
}
