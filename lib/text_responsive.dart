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
    super.key,
  });

  /// The text to be displayed and made responsive.
  final Text child;

  /// An optional callback function called when overflow is detected.
  final void Function()? overflowCallback;

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
    double initialFontSize =
        18, // Puede ser un valor predeterminado o basado en la preferencia del usuario
  }) {
    double fontSize =
        initialFontSize; // Comienza con el tamaño de la fuente inicial
    late double
        lastGoodFontSize; // Mantener registro del último tamaño de fuente que encajaba bien
    bool hasOverflow = true; // Control para el bucle

    while (hasOverflow && fontSize > 1) {
      // Evita que la fuente sea menor a 1
      // Configura el TextPainter
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style.copyWith(fontSize: fontSize)),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
      );

      // Realiza el layout del texto
      textPainter.layout(maxWidth: maxWidth);

      // Verifica si hay overflow
      if (textPainter.width <= maxWidth &&
          textPainter.height <= maxHeight &&
          !textPainter.didExceedMaxLines) {
        lastGoodFontSize =
            fontSize; // Actualiza el último tamaño de fuente bueno

        hasOverflow = false;
      } else {
        fontSize *= 0.99; // Reduce el tamaño de la fuente
      }
    }
    return lastGoodFontSize; // Devuelve el último tamaño de fuente que encajaba bien
  }
}
