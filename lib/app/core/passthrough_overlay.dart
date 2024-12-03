import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Represents an entry in the `PassthroughOverlay` widget.
///
/// This class manages the properties of an overlay entry, including its
/// [builder], [opaque], and [maintainState]. It also handles the lifecycle
/// of the entry, such as removal and marking for rebuild.
class PassthroughOverlayEntry {
  /// Creates an instance of [PassthroughOverlayEntry].
  ///
  /// The [builder] parameter is required and provides the widget for the overlay.
  /// The [opaque] and [maintainState] parameters are optional and default to `false`.
  PassthroughOverlayEntry({
    required this.builder,
    bool opaque = false,
    bool maintainState = false,
  })  : _opaque = opaque,
        _maintainState = maintainState;

  /// A builder function that returns the widget for the overlay entry.
  final WidgetBuilder builder;

  bool get opaque => _opaque;
  bool _opaque;

  /// Indicates whether the overlay entry is opaque.
  ///
  /// Setting this property triggers a rebuild of the overlay if the value
  /// changes.
  set opaque(bool value) {
    if (_opaque == value) return;
    _opaque = value;
    assert(_overlay != null);
    _overlay!._didChangeEntryOpacity();
  }

  bool get maintainState => _maintainState;
  bool _maintainState;

  /// Indicates whether the overlay entry should maintain its state when it
  /// is not visible.
  ///
  /// Setting this property triggers a rebuild of the overlay if the value
  /// changes.
  set maintainState(bool value) {
    if (_maintainState == value) return;
    _maintainState = value;
    assert(_overlay != null);
    _overlay!._didChangeEntryOpacity();
  }

  /// The overlay state to which this entry is currently added.
  PassthroughOverlayState? _overlay;

  /// A key for the internal state of the overlay entry.
  final GlobalKey<_OverlayEntryState> _key = GlobalKey<_OverlayEntryState>();

  /// Removes this entry from the overlay.
  ///
  /// This method must be called when the entry is no longer needed. If it is
  /// called during the scheduler's persistent callback phase, the removal is
  /// deferred until the next frame.
  void remove() {
    assert(_overlay != null);
    final PassthroughOverlayState overlay = _overlay!;
    _overlay = null;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
        overlay._remove(this);
      });
    } else {
      overlay._remove(this);
    }
  }

  /// Marks the overlay entry as needing a rebuild.
  ///
  /// This should be called when the entry's widget needs to be updated.
  void markNeedsBuild() {
    _key.currentState?._markNeedsBuild();
  }

  @override
  String toString() =>
      '${describeIdentity(this)}(opaque: $opaque; maintainState: $maintainState)';
}


/// A [StatefulWidget] representing an overlay entry.
///
/// This widget is used to manage the lifecycle of an overlay entry
/// and to rebuild it when necessary.
class _OverlayEntry extends StatefulWidget {
  /// Creates an [_OverlayEntry] with the given [PassthroughOverlayEntry].
  ///
  /// The [entry] parameter must not be null.
  _OverlayEntry(this.entry) : super(key: entry._key);

  /// The [PassthroughOverlayEntry] associated with this widget.
  final PassthroughOverlayEntry entry;

  @override
  _OverlayEntryState createState() => _OverlayEntryState();
}

/// The state for [_OverlayEntry].
///
/// This manages the rebuilds triggered by the overlay entry.
class _OverlayEntryState extends State<_OverlayEntry> {
  @override
  Widget build(BuildContext context) {
    // Builds the widget using the builder function from the associated entry.
    return widget.entry.builder(context);
  }

  /// Marks the widget as needing to rebuild.
  ///
  /// This method triggers a call to [build] to update the UI.
  void _markNeedsBuild() {
    setState(() {
      // Intentionally left empty; the widget rebuild is sufficient.
    });
  }
}


/// A widget that manages a list of overlay entries, allowing them to be added, removed,
/// and displayed in the overlay stack.
class PassthroughOverlay extends StatefulWidget {
  /// Creates a [PassthroughOverlay] widget.
  ///
  /// The [initialEntries] are the overlay entries that will be initially inserted into the overlay.
  /// The default value is an empty list.
  const PassthroughOverlay({
    this.initialEntries = const <PassthroughOverlayEntry>[],
    super.key,
  });

  /// The initial list of overlay entries.
  final List<PassthroughOverlayEntry> initialEntries;

  /// Returns the [PassthroughOverlayState] for the nearest [PassthroughOverlay] ancestor.
  ///
  /// This method ensures that there is an ancestor [PassthroughOverlay] widget in the widget tree.
  /// If [debugRequiredFor] is provided, it helps debug the context where the overlay is being searched from.
  static PassthroughOverlayState of(BuildContext context, {Widget? debugRequiredFor}) {
    final PassthroughOverlayState? result =
    context.findAncestorStateOfType<PassthroughOverlayState>();
    assert(() {
      if (debugRequiredFor != null && result == null) {
        final String additional = context.widget != debugRequiredFor
            ? '\nThe context from which that widget was searching for an overlay was:\n  $context'
            : '';
        throw FlutterError('No Overlay widget found.\n'
            '${debugRequiredFor.runtimeType} widgets require an Overlay widget ancestor for correct operation.\n'
            'The most common way to add an Overlay to an application is to include a MaterialApp or Navigator widget in the runApp() call.\n'
            'The specific widget that failed to find an overlay was:\n'
            '  $debugRequiredFor'
            '$additional');
      }
      return true;
    }());
    return result!;
  }

  @override
  PassthroughOverlayState createState() => PassthroughOverlayState();
}

/// The state for [PassthroughOverlay].
///
/// This class manages a list of overlay entries and handles inserting and removing them from the stack.
class PassthroughOverlayState extends State<PassthroughOverlay> with TickerProviderStateMixin {
  /// The list of overlay entries currently displayed.
  final List<PassthroughOverlayEntry> _entries = <PassthroughOverlayEntry>[];

  @override
  void initState() {
    super.initState();
    insertAll(widget.initialEntries);
  }

  /// Inserts a [PassthroughOverlayEntry] into the overlay at the specified position.
  ///
  /// If [above] is provided, the entry is inserted immediately above it; otherwise, it is added at the end.
  void insert(PassthroughOverlayEntry entry, {PassthroughOverlayEntry? above}) {
    assert(entry._overlay == null);
    assert(
    above == null || (above._overlay == this && _entries.contains(above)));
    entry._overlay = this;
    setState(() {
      final int index =
      above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insert(index, entry);
    });
  }

  /// Inserts multiple [PassthroughOverlayEntry] items into the overlay.
  ///
  /// If [above] is provided, the entries are inserted above it; otherwise, they are added at the end.
  void insertAll(Iterable<PassthroughOverlayEntry> entries, {PassthroughOverlayEntry? above}) {
    assert(
    above == null || (above._overlay == this && _entries.contains(above)));
    if (entries.isEmpty) return;
    for (PassthroughOverlayEntry entry in entries) {
      assert(entry._overlay == null);
      entry._overlay = this;
    }
    setState(() {
      final int index =
      above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insertAll(index, entries);
    });
  }

  /// Removes a [PassthroughOverlayEntry] from the overlay.
  ///
  /// This method ensures the widget is removed only if it's still mounted in the widget tree.
  void _remove(PassthroughOverlayEntry entry) {
    if (mounted) {
      _entries.remove(entry);
      setState(() {});
    }
  }

  /// Checks if the [PassthroughOverlayEntry] is visible in the overlay.
  ///
  /// The entry is considered visible if it is in the stack and no opaque entry blocks it.
  bool debugIsVisible(PassthroughOverlayEntry entry) {
    bool result = false;
    assert(_entries.contains(entry));
    assert(() {
      for (int i = _entries.length - 1; i > 0; i -= 1) {
        final PassthroughOverlayEntry candidate = _entries[i];
        if (candidate == entry) {
          result = true;
          break;
        }
        if (candidate.opaque) break;
      }
      return true;
    }());
    return result;
  }

  /// Called when the opacity of an entry changes, triggering a rebuild of the widget.
  void _didChangeEntryOpacity() {
    setState(() {});
  }

  /// Builds the widget for rendering overlay entries based on their state.
  ///
  /// The widget sorts the entries into two lists: one for onstage entries and one for
  /// offstage entries. The onstage entries are displayed first, while the offstage
  /// entries are added but not rendered directly. Offstage entries are wrapped in a
  /// `TickerMode` to prevent unnecessary animations or updates when they are offstage.
  ///
  /// Returns a `_Theatre` widget that contains both onstage and offstage children.
  @override
  Widget build(BuildContext context) {
    // Lists to hold the onstage and offstage children
    final List<Widget> onstageChildren = <Widget>[];
    final List<Widget> offstageChildren = <Widget>[];

    // Flag to determine if the current entry should be onstage
    bool onstage = true;

    // Iterate through the entries in reverse order
    for (int i = _entries.length - 1; i >= 0; i -= 1) {
      final PassthroughOverlayEntry entry = _entries[i];

      // If the entry is onstage, add it to the onstage list
      if (onstage) {
        onstageChildren.add(_OverlayEntry(entry));
        // If the entry is opaque, switch the flag to offstage
        if (entry.opaque) onstage = false;
      } else if (entry.maintainState) {
        // If the entry should maintain state, add it to the offstage list
        offstageChildren.add(TickerMode(enabled: false, child: _OverlayEntry(entry)));
      }
    }

    // Return the Theatre widget with both onstage and offstage children
    return _Theatre(
      onstage: Stack(
        fit: StackFit.passthrough,
        children: onstageChildren.reversed.toList(growable: false),
      ),
      offstage: offstageChildren,
    );
  }

  /// Fills in the properties for debugging purposes.
  ///
  /// This method adds the current entries list to the diagnostics, which is useful
  /// for debugging purposes.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<PassthroughOverlayEntry>>(
        'entries', _entries));
  }
}


/// A widget that renders an onstage stack and offstage list of widgets.
///
/// The [onstage] widget is displayed above all [offstage] widgets, which are rendered behind it.
/// This widget manages the display of these elements based on their visibility and the widget tree.
class _Theatre extends RenderObjectWidget {
  /// Creates a [_Theatre] widget.
  ///
  /// The [offstage] list contains widgets that are placed behind the [onstage] widget.
  /// The [onstage] widget is displayed at the front.
  const _Theatre({
    required this.offstage,
    this.onstage,
  });

  /// The widget displayed on top of all other children, or null if there is no onstage widget.
  final Stack? onstage;

  /// The list of widgets displayed behind the [onstage] widget.
  final List<Widget> offstage;

  @override
  _TheatreElement createElement() => _TheatreElement(this);

  @override
  _RenderTheatre createRenderObject(BuildContext context) => _RenderTheatre();
}

/// The element responsible for managing the [_Theatre] widget.
///
/// This element manages the mounting, updating, and removal of [onstage] and [offstage] children
/// and ensures the proper rendering order and child management in the render tree.
class _TheatreElement extends RenderObjectElement {
  /// Creates a [_TheatreElement] for the given [_Theatre] widget.
  _TheatreElement(_Theatre super.widget)
      : assert(!debugChildrenHaveDuplicateKeys(widget, widget.offstage));

  @override
  _Theatre get widget => super.widget as _Theatre;

  @override
  _RenderTheatre get renderObject => super.renderObject as _RenderTheatre;

  // The element currently onstage.
  Element? _onstage;

  // Slot used for the onstage widget.
  static final Object _onstageSlot = Object();

  // List of elements for offstage widgets.
  late List<Element> _offstage;

  // Set of forgotten offstage children, used for optimization.
  final Set<Element> _forgottenOffstageChildren = HashSet<Element>();

  @override
  void insertRenderObjectChild(RenderBox child, dynamic slot) {
    assert(renderObject.debugValidateChild(child));

    // If the child is the onstage widget, assign it to the render object.
    if (slot == _onstageSlot) {
      assert(child is RenderStack);
      renderObject.child = child as RenderStack?;
    } else {
      assert(slot == null || slot is Element);
      renderObject.insert(child, after: slot?.renderObject);
    }
  }

  @override
  void moveRenderObjectChild(RenderBox child, dynamic oldSlot, dynamic slot) {
    // If the slot is onstage, handle it accordingly.
    if (slot == _onstageSlot) {
      renderObject.remove(child);
      assert(child is RenderStack);
      renderObject.child = child as RenderStack?;
    } else {
      assert(slot == null || slot is Element);
      if (renderObject.child == child) {
        renderObject.child = null;
        renderObject.insert(child, after: slot?.renderObject);
      } else {
        renderObject.move(child, after: slot?.renderObject);
      }
    }
  }

  @override
  void removeRenderObjectChild(RenderBox child, dynamic slot) {
    // Remove the child if it matches the onstage or offstage children.
    if (renderObject.child == child) {
      renderObject.child = null;
    } else {
      renderObject.remove(child);
    }
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (_onstage != null) visitor(_onstage!);
    for (Element child in _offstage) {
      if (!_forgottenOffstageChildren.contains(child)) visitor(child);
    }
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    if (_onstage != null) visitor(_onstage!);
  }

  @override
  void forgetChild(Element child) {
    // If the child is onstage, remove it from the onstage slot.
    if (child == _onstage) {
      _onstage = null;
    } else {
      assert(_offstage.contains(child));
      assert(!_forgottenOffstageChildren.contains(child));
      _forgottenOffstageChildren.add(child);
    }
    super.forgetChild(child);
  }

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _onstage = updateChild(_onstage, widget.onstage, _onstageSlot);
    _offstage = [];

    // Inflate offstage children and keep track of their elements.
    Element? previousChild;
    for (int i = 0; i < _offstage.length; i += 1) {
      final Element newChild = inflateWidget(widget.offstage[i], previousChild);
      _offstage[i] = newChild;
      previousChild = newChild;
    }
  }

  @override
  void update(_Theatre newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);
    _onstage = updateChild(_onstage, widget.onstage, _onstageSlot);
    _offstage = updateChildren(_offstage, widget.offstage,
        forgottenChildren: _forgottenOffstageChildren);
    _forgottenOffstageChildren.clear();
  }
}

class _RenderTheatre extends RenderBox
    with
        RenderObjectWithChildMixin<RenderStack>,
        RenderProxyBoxMixin<RenderStack>,
        ContainerRenderObjectMixin<RenderBox, StackParentData> {
  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! StackParentData) {
      child.parentData = StackParentData();
    }
  }

  /// Updates the depth of the children.
  ///
  /// This method checks if the widget has a child and updates the depth of the child.
  /// It then calls the `redepthChildren` method from the parent class to ensure the depth of all children is correctly updated.
  @override
  void redepthChildren() {
    if (child != null) redepthChild(child!);
    super.redepthChildren();
  }

  /// Visits the children of this render object.
  ///
  /// If there is a child, this method invokes the `visitor` callback on the child.
  /// It then calls the `visitChildren` method from the parent class to visit any remaining children.
  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
    super.visitChildren(visitor);
  }

  /// Describes the children of this render object for debugging purposes.
  ///
  /// This method returns a list of diagnostics describing the children of this render object.
  /// - If a child exists, it is described as 'onstage'.
  /// - If there are any offstage children, they are described with the name 'offstage' followed by a count number.
  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];

    if (child != null) children.add(child!.toDiagnosticsNode(name: 'onstage'));

    if (firstChild != null) {
      RenderBox child = firstChild!;

      int count = 1;
      while (true) {
        children.add(
          child.toDiagnosticsNode(
            name: 'offstage $count',
            style: DiagnosticsTreeStyle.offstage,
          ),
        );
        if (child == lastChild) break;
        final StackParentData childParentData =
        child.parentData! as StackParentData;
        child = childParentData.nextSibling!;
        count += 1;
      }
    } else {
      children.add(
        DiagnosticsNode.message(
          'no offstage children',
          style: DiagnosticsTreeStyle.offstage,
        ),
      );
    }
    return children;
  }

  /// Visits the children of this render object for semantics.
  ///
  /// This method checks if the widget has a child and invokes the `visitor` callback for the child.
  /// It allows semantic information to be collected for the child widget.
  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) visitor(child!);
  }
}
