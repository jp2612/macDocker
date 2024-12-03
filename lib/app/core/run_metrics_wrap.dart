import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// A class representing the metrics of a run in the layout.
///
/// The metrics include the main axis extent (the size along the main axis),
/// the cross axis extent (the size along the cross axis), and the child count
/// in the run. This class is used to keep track of the layout dimensions of
/// a group of children that are laid out together in a run.
class _RunMetrics {
  _RunMetrics(this.mainAxisExtent, this.crossAxisExtent, this.childCount);

  /// The total size of the run along the main axis.
  final double mainAxisExtent;

  /// The total size of the run along the cross axis.
  final double crossAxisExtent;

  /// The number of children in this run.
  final int childCount;
}

/// A function type for calculating the size of a child along the main axis.
///
/// This type is used to define a function that computes the size of a child
/// based on the given [child] and the provided [extent]. It returns a [double]
/// representing the size of the child along the main axis.
typedef _ChildSizingFunction = double Function(RenderBox child, double extent);

/// Parent data for use with [RenderWrap].
///
/// This class extends [WrapParentData] and adds functionality for tracking the
/// index of the run in the layout. The [runIndex] is used to determine the
/// positioning of the child within the run.
class WrapWithMainAxisCountParentData extends WrapParentData {
  /// The index of the run this child belongs to.
  int _runIndex = 0;
}

  /// A custom widget that wraps children with a configurable number of main axis items.
  ///
  /// This widget allows wrapping the children in a `Wrap` layout, with the ability
  /// to specify a minimum and maximum count of items along the main axis. The main axis
  /// count constraints help ensure that the widget behaves correctly when dealing with
  /// different screen sizes or dynamic content.
  class RenderWrapWithMainAxisCount extends RenderWrap {
  /// The minimum number of items to be displayed along the main axis.
  ///
  /// If null, no minimum is enforced. If specified, the `maxMainAxisCount` must
  /// be greater than or equal to `minMainAxisCount`.
  int? minMainAxisCount;

  /// The maximum number of items to be displayed along the main axis.
  ///
  /// If null, no maximum is enforced. This value must be greater than or equal to
  /// the `minMainAxisCount` if it is specified.
  int? maxMainAxisCount;

  /// Constructs a [RenderWrapWithMainAxisCount] widget with the specified parameters.
  ///
  /// All parameters are forwarded to the parent `Wrap` widget, with additional
  /// parameters for `minMainAxisCount` and `maxMainAxisCount`.
  ///
  /// The assert checks that if `minMainAxisCount` is provided, `maxMainAxisCount`
  /// is either null or greater than or equal to `minMainAxisCount`.
  ///
  /// * [children] - A list of children widgets to be displayed inside the wrap.
  /// * [direction] - The direction of the wrap (either horizontal or vertical).
  /// * [alignment] - The alignment of the children within the wrap.
  /// * [spacing] - The spacing between the children.
  /// * [runAlignment] - The alignment of the runs in the wrap.
  /// * [runSpacing] - The spacing between the runs.
  /// * [crossAxisAlignment] - The alignment of the children along the cross axis.
  /// * [textDirection] - The text direction for the wrap.
  /// * [verticalDirection] - The vertical direction for the wrap.
  RenderWrapWithMainAxisCount({
  super.children,
  super.direction,
  super.alignment,
  super.spacing,
  super.runAlignment,
  super.runSpacing,
  super.crossAxisAlignment,
  super.textDirection,
  super.verticalDirection,
  this.minMainAxisCount,
  this.maxMainAxisCount,
  })  : assert(minMainAxisCount == null ||
  maxMainAxisCount == null ||
  maxMainAxisCount >= minMainAxisCount);

  bool get _debugHasNecessaryDirections {
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with multiple children has a null '
          'textDirection, so the layout order is undefined.');
    }
    if (alignment == WrapAlignment.start || alignment == WrapAlignment.end) {
      assert(
          direction == Axis.vertical || textDirection != null,
          'Horizontal $runtimeType with alignment $alignment has a null '
          'textDirection, so the alignment cannot be resolved.');
    }
    if (runAlignment == WrapAlignment.start ||
        runAlignment == WrapAlignment.end) {
      assert(
          direction == Axis.horizontal || textDirection != null,
          'Horizontal $runtimeType with runAlignment $runAlignment has a null '
          'verticalDirection, so the alignment cannot be resolved.');
    }
    if (crossAxisAlignment == WrapCrossAlignment.start ||
        crossAxisAlignment == WrapCrossAlignment.end) {
      assert(
          direction == Axis.horizontal || textDirection != null,
          'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment '
          'has a null textDirection, so the alignment cannot be resolved.');
    }
    return true;
  }

  /// Sets up the parent data for a child in the layout.
  ///
  /// This method checks if the parent data of the [child] is of type [WrapWithMainAxisCountParentData].
  /// If it is not, the parent data is set to a new instance of [WrapWithMainAxisCountParentData].
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WrapWithMainAxisCountParentData) {
      child.parentData = WrapWithMainAxisCountParentData();
    }
  }

  /// Computes the intrinsic height based on the given width.
  ///
  /// This method calculates the intrinsic height of the widget when the [direction] is [Axis.horizontal].
  /// It iterates over the children and measures their dimensions, considering the minimum and maximum
  /// child counts and their respective sizes.
  ///
  /// Returns the computed intrinsic height based on the provided [width].
  double _computeIntrinsicHeightForWidth(double width) {
    assert(direction == Axis.horizontal);
    int runCount = 0;
    double height = 0.0;
    double runWidth = 0.0;
    double runHeight = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;

    while (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(double.infinity);
      final double childHeight = child.getMaxIntrinsicHeight(childWidth);

      if (childCount >= minChildCount &&
          (runWidth + childWidth > width ||
              (maxChildCount >= minChildCount && childCount >= maxChildCount))) {
        height += runHeight;
        if (runCount > 0) height += runSpacing;
        runCount += 1;
        runWidth = 0.0;
        runHeight = 0.0;
        childCount = 0;
      }

      runWidth += childWidth;
      runHeight = math.max(runHeight, childHeight);
      if (childCount > 0) runWidth += spacing;
      childCount += 1;
      child = childAfter(child);
    }

    if (childCount > 0) height += runHeight + runSpacing;
    return height;
  }

  /// Computes the intrinsic width based on the given height.
  ///
  /// This method calculates the intrinsic width of the widget when the [direction] is [Axis.vertical].
  /// It iterates over the children, measuring their dimensions, while considering the minimum and maximum
  /// child counts and their respective sizes.
  ///
  /// Returns the computed intrinsic width based on the provided [height].
  double _computeIntrinsicWidthForHeight(double height) {
    assert(direction == Axis.vertical);
    int runCount = 0;
    double width = 0.0;
    double runHeight = 0.0;
    double runWidth = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;

    while (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(double.infinity);
      final double childWidth = child.getMaxIntrinsicWidth(childHeight);

      if (childCount >= minChildCount &&
          (runHeight + childHeight > height ||
              (maxChildCount >= minChildCount && childCount >= maxChildCount))) {
        width += runWidth;
        if (runCount > 0) width += runSpacing;
        runCount += 1;
        runHeight = 0.0;
        runWidth = 0.0;
        childCount = 0;
      }

      runHeight += childHeight;
      runWidth = math.max(runWidth, childWidth);
      if (childCount > 0) runHeight += spacing;
      childCount += 1;
      child = childAfter(child);
    }

    if (childCount > 0) width += runWidth + runSpacing;
    return width;
  }

  /// Computes the intrinsic size of the widget based on the provided [childCountAlongMainAxis]
  /// and a callback function for child sizing.
  ///
  /// The method calculates the maximum size in the main axis direction, considering the minimum and
  /// maximum number of children allowed per run.
  ///
  /// Returns the computed maximum run size in the main axis.
  double _getIntrinsicSize({
    required int childCountAlongMainAxis,
    required _ChildSizingFunction childSize, // A method to find the size in the sizing direction
  }) {
    double runMainAxisExtent = 0.0;
    double maxRunMainAxisExtent = 0.0;
    int childCount = 0;
    RenderBox? child = firstChild;

    while (child != null) {
      final double childMainAxisExtent = childSize(child, double.infinity);

      if (childCountAlongMainAxis > 0 && childCount >= childCountAlongMainAxis) {
        maxRunMainAxisExtent = math.max(maxRunMainAxisExtent, runMainAxisExtent);
        runMainAxisExtent = 0.0;
        childCount = 0;
      }

      runMainAxisExtent += childMainAxisExtent;
      if (childCount > 0) runMainAxisExtent += spacing;
      childCount += 1;
      child = childAfter(child);
    }

    if (childCount > 0) {
      maxRunMainAxisExtent = math.max(maxRunMainAxisExtent, runMainAxisExtent);
    }
    return maxRunMainAxisExtent;
  }

  /// Computes the minimum intrinsic width based on the given height.
  ///
  /// This method calculates the minimum width of the widget when the [direction] is [Axis.horizontal]
  /// or [Axis.vertical], using the corresponding helper methods.
  ///
  /// Returns the computed minimum intrinsic width for the given height.
  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        return _getIntrinsicSize(
          childCountAlongMainAxis: minMainAxisCount ?? 1,
          childSize: (RenderBox child, double extent) =>
              child.getMinIntrinsicWidth(extent),
        );
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }

  /// Computes the maximum intrinsic width based on the given height.
  ///
  /// This method calculates the maximum width of the widget when the [direction] is [Axis.horizontal]
  /// or [Axis.vertical], using the corresponding helper methods.
  ///
  /// Returns the computed maximum intrinsic width for the given height.
  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        return _getIntrinsicSize(
          childCountAlongMainAxis: maxMainAxisCount ?? -1,
          childSize: (RenderBox child, double extent) =>
              child.getMaxIntrinsicWidth(extent),
        );
      case Axis.vertical:
        return _computeIntrinsicWidthForHeight(height);
    }
  }


  /// Computes the minimum intrinsic height based on the provided width.
  ///
  /// The behavior of this method varies depending on the [direction].
  /// If the direction is [Axis.horizontal], it calls [_computeIntrinsicHeightForWidth].
  /// If the direction is [Axis.vertical], it computes the intrinsic size using the
  /// [childCountAlongMainAxis] and the provided child size callback.
  ///
  /// Returns the minimum intrinsic height for the given width.
  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        return _getIntrinsicSize(
          childCountAlongMainAxis: minMainAxisCount ?? 1,
          childSize: (RenderBox child, double extent) =>
              child.getMinIntrinsicHeight(extent),
        );
    }
  }

  /// Computes the maximum intrinsic height based on the provided width.
  ///
  /// This method's behavior also depends on the [direction].
  /// For [Axis.horizontal], it calls [_computeIntrinsicHeightForWidth].
  /// For [Axis.vertical], it calculates the intrinsic size using the
  /// [childCountAlongMainAxis] and the provided child size callback.
  ///
  /// Returns the maximum intrinsic height for the given width.
  @override
  double computeMaxIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return _computeIntrinsicHeightForWidth(width);
      case Axis.vertical:
        return _getIntrinsicSize(
          childCountAlongMainAxis: maxMainAxisCount ?? -1,
          childSize: (RenderBox child, double extent) =>
              child.getMaxIntrinsicHeight(extent),
        );
    }
  }

  /// Gets the main axis extent of the child.
  ///
  /// This method calculates the dimension of the child based on the [direction].
  /// If the direction is [Axis.horizontal], it returns the width of the child.
  /// If the direction is [Axis.vertical], it returns the height of the child.
  ///
  /// Returns the extent of the child in the main axis direction.
  double _getMainAxisExtent(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.width;
      case Axis.vertical:
        return child.size.height;
    }
  }

  /// Gets the cross axis extent of the child.
  ///
  /// This method calculates the dimension of the child in the cross axis direction
  /// based on the [direction]. If the direction is [Axis.horizontal], it returns
  /// the height of the child. If the direction is [Axis.vertical], it returns
  /// the width of the child.
  ///
  /// Returns the extent of the child in the cross axis direction.
  double _getCrossAxisExtent(RenderBox child) {
    switch (direction) {
      case Axis.horizontal:
        return child.size.height;
      case Axis.vertical:
        return child.size.width;
    }
  }

  /// Gets the offset based on the provided main and cross axis offsets.
  ///
  /// This method computes the correct offset for the child based on the [direction].
  /// If the direction is [Axis.horizontal], it returns an offset with the main axis
  /// as the x-coordinate and the cross axis as the y-coordinate.
  /// If the direction is [Axis.vertical], it swaps the coordinates.
  ///
  /// Returns the computed [Offset] for the child.
  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
  }


  /// Calculates the offset of a child along the cross axis, based on the alignment
  /// and whether the cross axis is flipped.
  ///
  /// [flipCrossAxis] - Whether the cross axis is flipped, affecting the starting position.
  /// [runCrossAxisExtent] - The total space available along the cross axis for the current run.
  /// [childCrossAxisExtent] - The space occupied by the current child along the cross axis.
  ///
  /// Returns the offset for the child along the cross axis.
  double _getChildCrossAxisOffset(
      bool flipCrossAxis,
      double runCrossAxisExtent,
      double childCrossAxisExtent,
      ) {
    // Calculate the remaining free space after placing the child.
    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;

    // Determine the child position based on the cross axis alignment and flipping.
    switch (crossAxisAlignment) {
      case WrapCrossAlignment.start:
      // Position at the start of the run (left or right depending on flipping).
        return flipCrossAxis ? freeSpace : 0.0;

      case WrapCrossAlignment.end:
      // Position at the end of the run.
        return flipCrossAxis ? 0.0 : freeSpace;

      case WrapCrossAlignment.center:
      // Position in the center of the available space.
        return freeSpace / 2.0;
    }
  }


  bool _hasVisualOverflow = false;
  late List<int> childRunIndexes;

  /// Lays out the children in a wrap-like layout, adjusting their positions based on the available space
  /// along the main and cross axes. This method calculates the necessary positions, sizes, and overflow
  /// for each child widget and adjusts the container size accordingly.
  ///
  /// This method is used for custom layout widgets that need to wrap children into multiple lines
  /// or columns depending on the available space and alignment settings.
  @override
  void performLayout() {
    assert(_debugHasNecessaryDirections);

    // Flag indicating if the layout has visual overflow.
    _hasVisualOverflow = false;

    // Initialize the first child for layout processing.
    RenderBox? child = firstChild;

    // If there are no children, return with the smallest possible size.
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // Define constraints for child layouts and initialize variables for layout calculations.
    BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;

    // Set up constraints and axis flipping based on the direction.
    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }

    // Initialize spacing and layout variables.
    final double spacing = this.spacing;
    final double runSpacing = this.runSpacing;
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double runMainAxisExtent = 0.0;
    double runCrossAxisExtent = 0.0;
    int childCount = 0;
    int minChildCount = minMainAxisCount ?? 1;
    int maxChildCount = maxMainAxisCount ?? -1;
    int runIndex = 0;
    childRunIndexes = [];

    // Loop over the children to calculate their sizes and positions.
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      final double childMainAxisExtent = _getMainAxisExtent(child);
      final double childCrossAxisExtent = _getCrossAxisExtent(child);

      // If the child does not fit, move it to the next line.
      if (childCount >= minChildCount &&
          (runMainAxisExtent + spacing + childMainAxisExtent > mainAxisLimit ||
              (maxChildCount >= minChildCount && childCount >= maxChildCount))) {
        mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
        crossAxisExtent += runCrossAxisExtent;
        if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
        runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
        runMainAxisExtent = 0.0;
        runCrossAxisExtent = 0.0;
        childCount = 0;
        runIndex++;
      }

      runMainAxisExtent += childMainAxisExtent;
      if (childCount > 0) runMainAxisExtent += spacing;
      runCrossAxisExtent = math.max(runCrossAxisExtent, childCrossAxisExtent);
      childCount += 1;

      final WrapWithMainAxisCountParentData childParentData =
      child.parentData! as WrapWithMainAxisCountParentData;
      childParentData._runIndex = runMetrics.length;
      child = childParentData.nextSibling;
      childRunIndexes.add(runIndex);
    }

    // Final adjustments after the last child.
    if (childCount > 0) {
      mainAxisExtent = math.max(mainAxisExtent, runMainAxisExtent);
      crossAxisExtent += runCrossAxisExtent;
      if (runMetrics.isNotEmpty) crossAxisExtent += runSpacing;
      runMetrics.add(_RunMetrics(runMainAxisExtent, runCrossAxisExtent, childCount));
    }

    // Calculate the container's size based on the calculated extents.
    final int runCount = runMetrics.length;
    assert(runCount > 0);

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
        containerMainAxisExtent = size.width;
        containerCrossAxisExtent = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
        containerMainAxisExtent = size.height;
        containerCrossAxisExtent = size.width;
        break;
    }

    // Flag indicating if the layout exceeds the container's size (visual overflow).
    _hasVisualOverflow = containerMainAxisExtent < mainAxisExtent ||
        containerCrossAxisExtent < crossAxisExtent;

    // Calculate free space on the cross axis and set alignment spacing.
    final double crossAxisFreeSpace = math.max(0.0, containerCrossAxisExtent - crossAxisExtent);
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;

    switch (runAlignment) {
      case WrapAlignment.start:
        break;
      case WrapAlignment.end:
        runLeadingSpace = crossAxisFreeSpace;
        break;
      case WrapAlignment.center:
        runLeadingSpace = crossAxisFreeSpace / 2.0;
        break;
      case WrapAlignment.spaceBetween:
        runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case WrapAlignment.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case WrapAlignment.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
    }

    runBetweenSpace += runSpacing;
    double crossAxisOffset = flipCrossAxis ? containerCrossAxisExtent - runLeadingSpace : runLeadingSpace;

    // Set the position of each child within the container.
    child = firstChild;
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final int childCount = metrics.childCount;

      final double mainAxisFreeSpace = math.max(0.0, containerMainAxisExtent - runMainAxisExtent);
      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      switch (alignment) {
        case WrapAlignment.start:
          break;
        case WrapAlignment.end:
          childLeadingSpace = mainAxisFreeSpace;
          break;
        case WrapAlignment.center:
          childLeadingSpace = mainAxisFreeSpace / 2.0;
          break;
        case WrapAlignment.spaceBetween:
          childBetweenSpace = childCount > 1 ? mainAxisFreeSpace / (childCount - 1) : 0.0;
          break;
        case WrapAlignment.spaceAround:
          childBetweenSpace = mainAxisFreeSpace / childCount;
          childLeadingSpace = childBetweenSpace / 2.0;
          break;
        case WrapAlignment.spaceEvenly:
          childBetweenSpace = mainAxisFreeSpace / (childCount + 1);
          childLeadingSpace = childBetweenSpace;
          break;
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis ? containerMainAxisExtent - childLeadingSpace : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      // Set the position for each child within its respective run.
      while (child != null) {
        final WrapWithMainAxisCountParentData childParentData = child.parentData! as WrapWithMainAxisCountParentData;
        if (childParentData._runIndex != i) break;

        final double childMainAxisExtent = _getMainAxisExtent(child);
        final double childCrossAxisExtent = _getCrossAxisExtent(child);
        final double childCrossAxisOffset = _getChildCrossAxisOffset(
            flipCrossAxis, runCrossAxisExtent, childCrossAxisExtent);

        if (flipMainAxis) childMainPosition -= childMainAxisExtent;

        childParentData.offset = _getOffset(childMainPosition, crossAxisOffset + childCrossAxisOffset);

        // Move to the next child position.
        if (flipMainAxis) {
          childMainPosition -= childBetweenSpace;
        } else {
          childMainPosition += childMainAxisExtent + childBetweenSpace;
        }

        child = childParentData.nextSibling;
      }

      // Adjust cross-axis offset after placing the children for the run.
      if (flipCrossAxis) {
        crossAxisOffset -= runBetweenSpace;
      } else {
        crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
      }
    }
  }

  /// Paints the widget, applying clipping if there is visual overflow.
  ///
  /// If the layout overflows (i.e., the widget does not fit within the available
  /// space), a clipping region is applied to prevent drawing outside the bounds.
  /// Otherwise, the widget is painted normally.
  ///
  /// This method is used for custom painting in a layout where overflow handling
  /// or other visual adjustments are needed.
  @override
  void paint(PaintingContext context, Offset offset) {
    // If there is visual overflow, clip the area to prevent drawing outside the bounds.
    if (_hasVisualOverflow) {
      // Apply a clipping rectangle to the widget.
      context.pushClipRect(
        needsCompositing,         // Whether the clip should be composited.
        offset,                   // The offset for the widget's position.
        Offset.zero & size,       // The clip area (from the top-left corner).
        defaultPaint,             // The painting function to apply inside the clip.
      );
    } else {
      // If there is no overflow, simply perform the default painting.
      defaultPaint(context, offset);
    }
  }
}
