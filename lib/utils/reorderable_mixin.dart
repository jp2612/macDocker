import 'package:flutter/widgets.dart';

import 'transitions.dart';

/// A mixin that provides methods for creating reorderable item animations
/// with size and fade transitions when items appear and disappear.
mixin ReorderableMixin {

  /// Creates a widget that appears with a size and fade transition.
  ///
  /// The [child] widget is animated using the [entranceController] for the
  /// size and fade transition. If [draggingFeedbackSize] is provided,
  /// it will constrain the size of the widget. The [direction] specifies the
  /// axis (horizontal or vertical) for the size transition.
  ///
  /// Returns a widget with a size and fade transition.
  @protected
  Widget makeAppearingWidget(
      Widget child,
      AnimationController entranceController,
      Size? draggingFeedbackSize,
      Axis direction,
      ) {
    if (draggingFeedbackSize == null) {
      return SizeTransitionWithIntrinsicSize(
        sizeFactor: entranceController,
        axis: direction,
        child: FadeTransition(
          opacity: entranceController,
          child: child,
        ),
      );
    } else {
      var transition = SizeTransition(
        sizeFactor: entranceController,
        axis: direction,
        child: FadeTransition(
          opacity: entranceController,
          child: child,
        ),
      );

      BoxConstraints contentSizeConstraints = BoxConstraints.loose(draggingFeedbackSize);
      return ConstrainedBox(constraints: contentSizeConstraints, child: transition);
    }
  }

  /// Creates a widget that disappears with a size and fade transition.
  ///
  /// The [child] widget is animated using the [ghostController] for the
  /// size and fade transition. If [draggingFeedbackSize] is provided,
  /// it will constrain the size of the widget. The [direction] specifies the
  /// axis (horizontal or vertical) for the size transition.
  ///
  /// Returns a widget with a size and fade transition.
  @protected
  Widget makeDisappearingWidget(
      Widget child,
      AnimationController ghostController,
      Size? draggingFeedbackSize,
      Axis direction,
      ) {
    if (draggingFeedbackSize == null) {
      return SizeTransitionWithIntrinsicSize(
        sizeFactor: ghostController,
        axis: direction,
        child: FadeTransition(
          opacity: ghostController,
          child: child,
        ),
      );
    } else {
      var transition = SizeTransition(
        sizeFactor: ghostController,
        axis: direction,
        child: FadeTransition(
          opacity: ghostController,
          child: child,
        ),
      );

      BoxConstraints contentSizeConstraints = BoxConstraints.loose(draggingFeedbackSize);
      return ConstrainedBox(constraints: contentSizeConstraints, child: transition);
    }
  }
}
