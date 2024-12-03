import 'package:flutter/widgets.dart';
import 'run_metrics_wrap.dart';

/// A custom [Wrap] widget that allows limiting the number of items per row
/// by specifying the minimum and maximum number of items that can be
/// displayed along the main axis.
///
/// This widget uses the [RenderWrapWithMainAxisCount] for custom utils logic.
class WrapWithMainAxisCount extends Wrap {
  /// Creates a [WrapWithMainAxisCount] widget.
  ///
  /// The [minMainAxisCount] and [maxMainAxisCount] parameters can be used
  /// to set the minimum and maximum number of items per row along the main axis.
  const WrapWithMainAxisCount({
    super.key,
    super.direction,
    super.alignment,
    super.spacing,
    super.runAlignment,
    super.runSpacing,
    super.crossAxisAlignment,
    super.textDirection,
    super.verticalDirection,
    super.children,
    this.minMainAxisCount,
    this.maxMainAxisCount,
  });

  /// The minimum number of items to display in a row along the main axis.
  /// If `null`, no minimum is enforced.
  final int? minMainAxisCount;

  /// The maximum number of items to display in a row along the main axis.
  /// If `null`, no maximum is enforced.
  final int? maxMainAxisCount;

  /// Creates the render object for this widget.
  ///
  /// This method returns a [RenderWrapWithMainAxisCount] that implements the custom
  /// utils logic, including respecting the [minMainAxisCount] and [maxMainAxisCount].
  @override
  RenderWrapWithMainAxisCount createRenderObject(BuildContext context) {
    return RenderWrapWithMainAxisCount(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection ?? Directionality.of(context),
      verticalDirection: verticalDirection,
      minMainAxisCount: minMainAxisCount,
      maxMainAxisCount: maxMainAxisCount,
    );
  }

  /// Updates the render object when the widget's properties change.
  ///
  /// This method is called to propagate changes to the [minMainAxisCount] and
  /// [maxMainAxisCount] values to the [RenderWrapWithMainAxisCount] render object.
  @override
  void updateRenderObject(
      BuildContext context,
      RenderWrapWithMainAxisCount renderObject,
      ) {
    super.updateRenderObject(context, renderObject);
    renderObject
      ..minMainAxisCount = minMainAxisCount
      ..maxMainAxisCount = maxMainAxisCount;
  }
}
