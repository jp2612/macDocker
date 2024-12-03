import 'package:flutter/rendering.dart';
import 'package:flutter/animation.dart';

/// A custom [RenderBox] that applies a size transition effect
/// to its child while respecting the intrinsic size constraints.
///
/// This implementation allows for animating the size of a widget
/// along a given [Axis] (`vertical` or `horizontal`) using an
/// animation value from [sizeFactor].
class RenderSizeTransitionWithIntrinsicSize extends RenderProxyBox {
  /// Creates a [RenderSizeTransitionWithIntrinsicSize].
  ///
  /// - [axis] determines the axis along which the size transition occurs.
  ///   Defaults to [Axis.vertical].
  /// - [sizeFactor] is the animation controlling the size transition.
  RenderSizeTransitionWithIntrinsicSize({
    this.axis = Axis.vertical,
    required this.sizeFactor,
    RenderBox? child,
  }) : super(child);

  /// The axis along which the size transition occurs.
  /// Defaults to [Axis.vertical].
  Axis axis;

  /// The animation that controls the size transition.
  Animation<double> sizeFactor;

  /// Computes the minimum intrinsic width of the widget based on the given height.
  ///
  /// The minimum width is determined by the child’s intrinsic width, which is scaled
  /// only if the transition is horizontal.
  ///
  /// Returns 0.0 if there is no child to compute the width from.
  @override
  double computeMinIntrinsicWidth(double height) {
    final RenderBox? child = this.child;
    if (child != null) {
      final double childWidth = child.getMinIntrinsicWidth(height);
      // Scale width only for horizontal transitions.
      return axis == Axis.horizontal ? childWidth * sizeFactor.value : childWidth;
    }
    return 0.0; // No intrinsic width if there's no child.
  }

  /// Computes the maximum intrinsic width of the widget based on the given height.
  ///
  /// The maximum width is determined by the child’s intrinsic width, which is scaled
  /// only if the transition is horizontal.
  ///
  /// Returns 0.0 if there is no child to compute the width from.
  @override
  double computeMaxIntrinsicWidth(double height) {
    final RenderBox? child = this.child;
    if (child != null) {
      final double childWidth = child.getMaxIntrinsicWidth(height);
      // Scale width only for horizontal transitions.
      return axis == Axis.horizontal ? childWidth * sizeFactor.value : childWidth;
    }
    return 0.0; // No intrinsic width if there's no child.
  }

  /// Computes the minimum intrinsic height of the widget based on the given width.
  ///
  /// The minimum height is determined by the child’s intrinsic height, which is scaled
  /// only if the transition is vertical.
  ///
  /// Returns 0.0 if there is no child to compute the height from.
  @override
  double computeMinIntrinsicHeight(double width) {
    final RenderBox? child = this.child;
    if (child != null) {
      final double childHeight = child.getMinIntrinsicHeight(width);
      // Scale height only for vertical transitions.
      return axis == Axis.vertical ? childHeight * sizeFactor.value : childHeight;
    }
    return 0.0; // No intrinsic height if there's no child.
  }

  /// Computes the maximum intrinsic height of the widget based on the given width.
  ///
  /// The maximum height is determined by the child’s intrinsic height, which is scaled
  /// only if the transition is vertical.
  ///
  /// Returns 0.0 if there is no child to compute the height from.
  @override
  double computeMaxIntrinsicHeight(double width) {
    final RenderBox? child = this.child;
    if (child != null) {
      final double childHeight = child.getMaxIntrinsicHeight(width);
      // Scale height only for vertical transitions.
      return axis == Axis.vertical ? childHeight * sizeFactor.value : childHeight;
    }
    return 0.0; // No intrinsic height if there's no child.
  }

}
