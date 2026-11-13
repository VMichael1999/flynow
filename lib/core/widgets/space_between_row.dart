import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Equivalente a `display:flex; justify-content:space-between` con dos hijos
/// que no se encogen: si no caben, el segundo se coloca justo después del
/// primero y se sale del contenedor (como en CSS), sin error de desborde.
/// `start` pegado a la izquierda, `end` a la derecha.
Widget spaceBetweenRow(Widget start, Widget end) =>
    _SpaceBetween(children: [start, end]);

class _SpaceBetween extends MultiChildRenderObjectWidget {
  const _SpaceBetween({required super.children});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSpaceBetween();
}

class _ParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSpaceBetween extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) child.parentData = _ParentData();
  }

  RenderBox get _a => firstChild!;
  RenderBox get _b => childAfter(_a)!;

  @override
  double computeMinIntrinsicWidth(double height) =>
      _a.getMinIntrinsicWidth(height) + _b.getMinIntrinsicWidth(height);

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _a.getMaxIntrinsicWidth(height) + _b.getMaxIntrinsicWidth(height);

  @override
  double computeMinIntrinsicHeight(double width) => math.max(
    _a.getMinIntrinsicHeight(double.infinity),
    _b.getMinIntrinsicHeight(double.infinity),
  );

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
    _a.getMaxIntrinsicHeight(double.infinity),
    _b.getMaxIntrinsicHeight(double.infinity),
  );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    const loose = BoxConstraints();
    final sa = _a.getDryLayout(loose);
    final sb = _b.getDryLayout(loose);
    return constraints.constrain(
      Size(constraints.maxWidth, math.max(sa.height, sb.height)),
    );
  }

  @override
  void performLayout() {
    const loose = BoxConstraints();
    _a.layout(loose, parentUsesSize: true);
    _b.layout(loose, parentUsesSize: true);
    final width =
        constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _a.size.width + _b.size.width;
    size = constraints.constrain(
      Size(width, math.max(_a.size.height, _b.size.height)),
    );
    (_a.parentData! as _ParentData).offset = Offset.zero;
    (_b.parentData! as _ParentData).offset = Offset(
      math.max(_a.size.width, size.width - _b.size.width),
      0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
