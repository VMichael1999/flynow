import 'package:flutter/widgets.dart';

/// Relación ascenso/descenso de Plus Jakarta Sans (hhea 1038 / 222).
const double _ascent = 1.038;
const double _content = 1.26;

/// Línea de CSS `line-height: normal` para Plus Jakarta Sans.
const double kNormalLineHeight = _content;

double _baseline(double size, double lh) =>
    size * ((lh - _content) / 2 + _ascent);

/// Texto en línea (`<span>`) dentro de un bloque cuya fuente base es mayor:
/// la caja de línea la fija la «puntal» (strut) del bloque, como en CSS.
///
/// [strutSize] y [lineHeight] son los del bloque contenedor; [style] el del
/// texto. Devuelve un widget de alto `strutSize × lineHeight`.
class StrutText extends StatelessWidget {
  const StrutText(
    this.text, {
    super.key,
    required this.style,
    required this.strutSize,
    required this.lineHeight,
    this.textAlign,
    this.maxLines = 1,
    this.alignment = Alignment.topLeft,
  });

  final String text;
  final TextStyle style;
  final double strutSize;
  final double lineHeight;
  final TextAlign? textAlign;
  final int maxLines;

  /// Dónde cae el texto en la línea (`text-align`).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final top =
        _baseline(strutSize, lineHeight) -
        _baseline(style.fontSize!, lineHeight);
    return SizedBox(
      height: strutSize * lineHeight,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.only(top: top < 0 ? 0 : top),
          child: Text(
            text,
            maxLines: maxLines,
            textAlign: textAlign,
            softWrap: false,
            style: style.copyWith(height: lineHeight),
          ),
        ),
      ),
    );
  }
}
