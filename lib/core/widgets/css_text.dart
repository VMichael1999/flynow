import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Texto con el alto de línea fraccionario de CSS.
///
/// Flutter redondea cada línea de texto a un número entero de píxeles (19.5 →
/// 20), mientras que CSS conserva la fracción. En una columna de varios textos
/// el redondeo se acumula y desplaza los elementos. [Txt] mide el párrafo y
/// reserva exactamente `líneas × fontSize × height`, centrando el párrafo.
class Txt extends StatelessWidget {
  const Txt(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textAlign,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final effective = DefaultTextStyle.of(context).style.merge(style);
    final text = Text(
      data,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textAlign: textAlign,
    );
    final size = effective.fontSize;
    final height = effective.height;
    if (size == null || height == null) return text;
    return _CssTextBox(
      lineHeight: size * height,
      measureStyle: effective,
      child: text,
    );
  }
}

class _CssTextBox extends SingleChildRenderObjectWidget {
  const _CssTextBox({
    required this.lineHeight,
    required this.measureStyle,
    required Widget super.child,
  });

  final double lineHeight;
  final TextStyle measureStyle;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCssText(lineHeight, _singleLine(measureStyle));

  @override
  void updateRenderObject(BuildContext context, _RenderCssText ro) {
    ro
      ..lineHeight = lineHeight
      ..singleLine = _singleLine(measureStyle);
  }
}

final Map<TextStyle, double> _singleLineCache = {};

/// Alto (redondeado por el motor) de una línea de este estilo.
double _singleLine(TextStyle style) => _singleLineCache.putIfAbsent(style, () {
  final tp = TextPainter(
    text: TextSpan(text: 'Ag', style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final h = tp.height;
  tp.dispose();
  return h;
});

class _RenderCssText extends RenderShiftedBox {
  _RenderCssText(this._lineHeight, this._singleLine) : super(null);

  double _lineHeight;
  double _singleLine;

  set lineHeight(double v) {
    if (v == _lineHeight) return;
    _lineHeight = v;
    markNeedsLayout();
  }

  set singleLine(double v) {
    if (v == _singleLine) return;
    _singleLine = v;
    markNeedsLayout();
  }

  double _exact(double childHeight) {
    final lines = (childHeight / _singleLine).round().clamp(1, 1000);
    return lines * _lineHeight;
  }

  @override
  double computeMinIntrinsicWidth(double height) =>
      child?.getMinIntrinsicWidth(height) ?? 0;

  @override
  double computeMaxIntrinsicWidth(double height) =>
      child?.getMaxIntrinsicWidth(height) ?? 0;

  @override
  double computeMinIntrinsicHeight(double width) =>
      _exact(child?.getMinIntrinsicHeight(width) ?? 0);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _exact(child?.getMaxIntrinsicHeight(width) ?? 0);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final c = child;
    if (c == null) return constraints.smallest;
    final s = c.getDryLayout(constraints);
    return constraints.constrain(Size(s.width, _exact(s.height)));
  }

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(constraints.copyWith(minHeight: 0), parentUsesSize: true);
    final exact = _exact(c.size.height);
    size = constraints.constrain(Size(c.size.width, exact));
    (c.parentData! as BoxParentData).offset = Offset(
      0,
      (size.height - c.size.height) / 2,
    );
  }
}
