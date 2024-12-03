import 'package:flutter/widgets.dart';

/// A typedef for a function that builds a container for a list of items.
///
/// The [BuildItemsContainer] function takes a [BuildContext], an [Axis]
/// direction (horizontal or vertical), and a list of [children] widgets,
/// and returns a [Widget] representing the container.
typedef BuildItemsContainer = Widget Function(
    BuildContext context,
    Axis direction,
    List<Widget> children,
    );

/// A typedef for a function that builds a draggable feedback widget.
///
/// The [BuildDraggableFeedback] function takes a [BuildContext], a set of
/// [BoxConstraints], and a [Widget] [child], and returns a [Widget] that
/// represents the feedback displayed while dragging.
typedef BuildDraggableFeedback = Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    Widget child,
    );

/// A typedef for a callback function that is triggered when an item is not
/// reordered.
///
/// The [NoReorderCallback] function takes an integer [index] representing
/// the position of the item that was not reordered.
typedef NoReorderCallback = void Function(int index);

/// A typedef for a callback function that is triggered when the reorder
/// operation starts.
///
/// The [ReorderStartedCallback] function takes an integer [index] representing
/// the index of the item being reordered.
typedef ReorderStartedCallback = void Function(int index);
