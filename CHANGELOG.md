## 1.0.0

* Include all functionality for the package

## 1.0.1

* Updated homepage for package

## 1.0.2

* Updated readme

## 1.0.3

* Updated description for package dart recomendation for SEO

## 1.1.0

* Added new classes ParagraphTextWidget and InlineTextWidget for more specialized text handling.
* Enhanced TextResponsiveWidget to support new text handling features.
* General improvements and bug fixes.

## 1.2.0

* Fixed lateInicialization error with lastGoodFontSize
* Added minFontSize parameter for TextResponsiveWidget 

## 1.2.1

* we set minFontSize to 6px to make sure the legibility of the text

## 1.3.0

* Measure text with its actual layout constraints, inherited styling, wrapping,
  direction, and scaling while preserving accessibility labels and rich spans.
* Preserve explicit overflow behavior and keep text at its effective minimum
  when further shrinking is unavailable.
* Deliver `overflowCallback` after the frame, once per continuous overflow.
* Declare Flutter 3.16 and Dart 3.2 as the minimum SDK versions.
