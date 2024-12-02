import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'render_size_transition.dart';

/// A widget that transitions the size of its child along a given [Axis],
/// with support for intrinsic sizing.
///
/// This widget uses [RenderSizeTransitionWithIntrinsicSize] to handle the
/// actual size transition at the render object level. It animates the size
/// of its child using the provided [sizeFactor].
class SizeTransitionWithIntrinsicSize extends SingleChildRenderObjectWidget {
  /// Creates a [SizeTransitionWithIntrinsicSize].
  ///
  /// - [axis] determines the axis along which the size transition occurs.
  ///   Defaults to [Axis.vertical].
  /// - [sizeFactor] is the animation controlling the size transition.
  /// - [axisAlignment] aligns the child along the transition axis.
  const SizeTransitionWithIntrinsicSize({
    this.axis = Axis.vertical,
    required this.sizeFactor,
    this.axisAlignment = 0.0,
    super.child,
    super.key,
  });

  /// The axis along which the size transition occurs.
  /// Defaults to [Axis.vertical].
  final Axis axis;

  /// The animation that controls the size transition.
  final Animation<double> sizeFactor;

  /// The alignment of the child along the [axis].
  ///
  /// A value of `-1.0` aligns the child to the start, `0.0` centers it,
  /// and `1.0` aligns it to the end.
  final double axisAlignment;

  @override
  RenderSizeTransitionWithIntrinsicSize createRenderObject(
      BuildContext context) {
    return RenderSizeTransitionWithIntrinsicSize(
      axis: axis,
      sizeFactor: sizeFactor,
    );
  }

  /// Updates the render object with the current configuration.
  ///
  /// This method is called whenever the widget’s configuration changes, and it
  /// updates the associated `RenderObject` accordingly. It passes relevant
  /// properties, such as the axis and size factor, to the `RenderSizeTransitionWithIntrinsicSize`.
  @override
  void updateRenderObject(
      BuildContext context, RenderSizeTransitionWithIntrinsicSize renderObject) {
    renderObject
      ..axis = axis                  // Set the axis of the transition.
      ..sizeFactor = sizeFactor;     // Set the animation controlling the size transition.
  }

  /// Adds relevant properties to the diagnostic output for debugging purposes.
  ///
  /// This method provides information about the widget's state that can be
  /// used in debugging and performance tracing. It includes the axis, size factor,
  /// and axis alignment properties to give a complete picture of the widget's configuration.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Axis>('axis', axis));  // Add the axis property.
    properties.add(DiagnosticsProperty<Animation<double>>(
        'sizeFactor', sizeFactor,
        description: 'Animation controlling the size transition.'));  // Add the size factor property.
    properties.add(DoubleProperty('axisAlignment', axisAlignment));  // Add the axis alignment property.
  }
}
