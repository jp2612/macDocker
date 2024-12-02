import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'passthrough_overlay.dart';
import 'typedefs.dart';
import 'wrap.dart';
import 'run_metrics_wrap.dart';
import 'reorderable_mixin.dart';

class ReorderableWrap extends StatefulWidget {
  /// Creates a reorderable wrap.
  const ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.header,
    this.footer,
    this.controller,
    this.direction = Axis.horizontal,
    this.scrollDirection = Axis.vertical,
    this.scrollPhysics,
    this.padding,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.needsLongPressDraggable = true,
    this.alignment = WrapAlignment.start,
    this.spacing = 0.0,
    this.runAlignment = WrapAlignment.start,
    this.runSpacing = 0.0,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.minMainAxisCount,
    this.maxMainAxisCount,
    this.onNoReorder,
    this.onReorderStarted,
    this.reorderAnimationDuration = const Duration(milliseconds: 200),
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
    this.ignorePrimaryScrollController = false,
    this.enableReorder = true,
    super.key,
  });

  final List<Widget>? header;
  final Widget? footer;
  final ScrollController? controller;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final bool needsLongPressDraggable;
  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final bool ignorePrimaryScrollController;
  final bool enableReorder;

  @override ReorderableWrapState createState() => ReorderableWrapState();
}


class ReorderableWrapState extends State<ReorderableWrap> {
  // We use an inner overlay so that the dragging list item doesn't draw outside of the list itself.
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$ReorderableWrap overlay key');

  // This entry contains the scrolling list itself.
  late PassthroughOverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = PassthroughOverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return _ReorderableWrapContent(
          header: widget.header,
          footer: widget.footer,
          direction: widget.direction,
          scrollDirection: widget.scrollDirection,
          scrollPhysics: widget.scrollPhysics,
          onReorder: widget.onReorder,
          onNoReorder: widget.onNoReorder,
          onReorderStarted: widget.onReorderStarted,
          padding: widget.padding,
          buildItemsContainer: widget.buildItemsContainer,
          buildDraggableFeedback: widget.buildDraggableFeedback,
          needsLongPressDraggable: widget.needsLongPressDraggable,
          alignment: widget.alignment,
          spacing: widget.spacing,
          runAlignment: widget.runAlignment,
          runSpacing: widget.runSpacing,
          crossAxisAlignment: widget.crossAxisAlignment,
          textDirection: widget.textDirection,
          verticalDirection: widget.verticalDirection,
          minMainAxisCount: widget.minMainAxisCount,
          maxMainAxisCount: widget.maxMainAxisCount,
          controller: widget.controller,
          reorderAnimationDuration: widget.reorderAnimationDuration,
          scrollAnimationDuration: widget.scrollAnimationDuration,
          enableReorder: widget.enableReorder,
          children: widget.children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PassthroughOverlay passthroughOverlay = PassthroughOverlay(
        key: _overlayKey,
        initialEntries: <PassthroughOverlayEntry>[
          _listOverlayEntry,
        ]);
    return widget.ignorePrimaryScrollController
        ? PrimaryScrollController.none(child: passthroughOverlay)
        : passthroughOverlay;
  }
}

// This widget is responsible for the inside of the Overlay in the
// ReorderableListView.
class _ReorderableWrapContent extends StatefulWidget {
  const _ReorderableWrapContent(
      {required this.children,
      required this.direction,
      required this.scrollDirection,
      required this.scrollPhysics,
      required this.padding,
      required this.onReorder,
      required this.onNoReorder,
      required this.onReorderStarted,
      required this.buildItemsContainer,
      required this.buildDraggableFeedback,
      required this.needsLongPressDraggable,
      required this.alignment,
      required this.spacing,
      required this.runAlignment,
      required this.runSpacing,
      required this.crossAxisAlignment,
      required this.textDirection,
      required this.verticalDirection,
      required this.minMainAxisCount,
      required this.maxMainAxisCount,
      this.header,
      this.footer,
      this.controller,
      this.reorderAnimationDuration = const Duration(milliseconds: 200),
      this.scrollAnimationDuration = const Duration(milliseconds: 200),
      required this.enableReorder});

  final List<Widget>? header;
  final Widget? footer;
  final ScrollController? controller;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final ScrollPhysics? scrollPhysics;
  final EdgeInsets? padding;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final bool needsLongPressDraggable;

  final WrapAlignment alignment;
  final double spacing;
  final WrapAlignment runAlignment;
  final double runSpacing;
  final WrapCrossAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final int? minMainAxisCount;
  final int? maxMainAxisCount;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final bool enableReorder;

  @override
  _ReorderableWrapContentState createState() => _ReorderableWrapContentState();
}

class _ReorderableWrapContentState extends State<_ReorderableWrapContent>
    with TickerProviderStateMixin<_ReorderableWrapContent>, ReorderableMixin {
  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
//  static const double _defaultDropAreaExtent = 1.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 0.0;

  // How long an animation to reorder an element in the list takes.
  late Duration _reorderAnimationDuration;

  // How long an animation to scroll to an off-screen element in the
  // list takes.
  late Duration _scrollAnimationDuration;

  // Controls scrolls and measures scroll progress.
  late ScrollController _scrollController;

  // This controls the entrance of the dragging widget into a new place.
  late AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  late AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
//  int _dragging;
  Widget? _draggingWidget;

  // The last computed size of the feedback widget being dragged.
  Size? _draggingFeedbackSize;

//  List<GlobalObjectKey> _childKeys;
  late List<BuildContext?> _childContexts;
  late List<Size> _childSizes;
  late List<int> _childIndexToDisplayIndex;
  late List<int> _childDisplayIndexToIndex;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = -1;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostDisplayIndex = -1;

  int _currentDisplayIndex = -1;

  int _nextDisplayIndex = -1;

  bool _scrolling = false;

  final GlobalKey _wrapKey = GlobalKey(debugLabel: '$ReorderableWrap wrap key');
  late List<int> _wrapChildRunIndexes;
  late List<int> _childRunIndexes;
  late List<int> _nextChildRunIndexes;
  late List<Widget?> _wrapChildren;
  late bool enableReorder;

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return const Size(0, 0);
    }
    return _draggingFeedbackSize! +
        const Offset(_dropAreaMargin, _dropAreaMargin);
  }

  @override
  void initState() {
    super.initState();
    enableReorder = widget.enableReorder;
    _reorderAnimationDuration = widget.reorderAnimationDuration;
    _scrollAnimationDuration = widget.scrollAnimationDuration;
    _entranceController = AnimationController(
        value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(
        value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
    _childContexts = List.filled(widget.children.length, null);
    _childSizes = List.filled(widget.children.length, const Size(0, 0));
    _wrapChildRunIndexes = List.filled(widget.children.length, -1);
    _childRunIndexes = List.filled(widget.children.length, -1);
    _nextChildRunIndexes = List.filled(widget.children.length, -1);
    _wrapChildren = List.filled(widget.children.length, null);
  }

  @override
  void didChangeDependencies() {
    _scrollController = widget.controller ??
        PrimaryScrollController.maybeOf(context) ??
        ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex({bool isAcceptingNewTarget = false}) {
    if (_entranceController.isCompleted) {
      _ghostDisplayIndex = _currentDisplayIndex;
      if (!isAcceptingNewTarget && _nextDisplayIndex == _currentDisplayIndex) {
        return;
      }
      _currentDisplayIndex = _nextDisplayIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  void _scrollTo(BuildContext context) {
    if (_scrolling || !_scrollController.hasClients) return;
    final RenderObject contextObject = context.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject);
    final double margin = widget.direction == Axis.horizontal
        ? _dropAreaSize.width
        : _dropAreaSize.height;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final double bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final bool onScreen =
        scrollOffset <= topOffset && scrollOffset >= bottomOffset;
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      )
          .then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  Widget _buildContainerForMainAxis({required List<Widget> children}) {
    WrapAlignment runAlignment;
    switch (widget.crossAxisAlignment) {
      case WrapCrossAlignment.start:
        runAlignment = WrapAlignment.start;
        break;
      case WrapCrossAlignment.end:
        runAlignment = WrapAlignment.end;
        break;
      case WrapCrossAlignment.center:
      default:
        runAlignment = WrapAlignment.center;
        break;
    }
    return Wrap(
      direction: widget.direction,
      runAlignment: runAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: children,
    );
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index) {
    _wrapChildren[index] = toWrap;
    int displayIndex = _childIndexToDisplayIndex[index];
    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _draggingWidget = toWrap;
        _dragStartIndex = index;
        _ghostDisplayIndex = displayIndex;
        _currentDisplayIndex = displayIndex;
        _nextDisplayIndex = displayIndex;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = _childContexts[index]!.size;
        for (int i = 0; i < widget.children.length; i++) {
          _childSizes[i] = _childContexts[i]!.size!;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
          for (int i = 0; i < _childRunIndexes.length; i++) {
            _nextChildRunIndexes[i] =
                _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
          }
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
            for (int i = 0; i < _childRunIndexes.length; i++) {
              _nextChildRunIndexes[i] =
                  _wrapChildRunIndexes[_childIndexToDisplayIndex[i]];
            }
          }
        }
        widget.onReorderStarted?.call(index);
      });
    }

    void reorderItem(int startIndex, int endIndex) {
      if (startIndex != endIndex) {
        // Trigger the reordering callback if indices differ
        widget.onReorder(startIndex, endIndex);
      } else {
        // Trigger the optional no-reorder callback if provided
        widget.onNoReorder?.call(startIndex);
      }

      // Reverse animations to reset the item appearance
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);

      // Reset the drag index
      _dragStartIndex = -1;
    }

    void reorder(int startIndex, int endIndex) {
      setState(() {
        reorderItem(startIndex, endIndex);
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
      setState(() {
        reorderItem(_dragStartIndex, _currentDisplayIndex);
        _dragStartIndex = -1;
        _ghostDisplayIndex = -1;
        _currentDisplayIndex = -1;
        _nextDisplayIndex = -1;
        _draggingWidget = null;
      });
    }

    Widget wrapWithSemantics() {
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length - 1);
      void moveBefore() => reorder(index, index - 1);
      void moveAfter() => reorder(index, index + 2);

      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
          label: WidgetsLocalizations.of(context).reorderItemToStart,
        )] = moveToStart;

        String reorderItemBefore = WidgetsLocalizations.of(context).reorderItemUp;

        if (widget.direction == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
              ? WidgetsLocalizations.of(context).reorderItemLeft
              : WidgetsLocalizations.of(context).reorderItemRight;
        }

        semanticsActions[CustomSemanticsAction(
          label: reorderItemBefore,
        )] = moveBefore;
      }

      if (index < widget.children.length - 1) {
        String reorderItemAfter = WidgetsLocalizations.of(context).reorderItemDown;

        if (widget.direction == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? WidgetsLocalizations.of(context).reorderItemRight
              : WidgetsLocalizations.of(context).reorderItemLeft;
        }

        semanticsActions[CustomSemanticsAction(
          label: reorderItemAfter,
        )] = moveAfter;

        semanticsActions[CustomSemanticsAction(
          label: WidgetsLocalizations.of(context).reorderItemToEnd,
        )] = moveToEnd;
      }


      return MergeSemantics(
        child: Semantics(
          customSemanticsActions: semanticsActions,
          child: toWrap,
        ),
      );
    }

    Widget makeAppearingWidgetChild(Widget child) {
      return makeAppearingWidget(
        child,
        _entranceController,
        null,
        widget.direction,
      );
    }

    Widget makeDisappearingWidgetChild(Widget child) {
      return makeDisappearingWidget(
        child,
        _ghostController,
        null,
        widget.direction,
      );
    }

    //Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates, List<dynamic> rejectedCandidates) {
    Widget buildDraggable() {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(builder: (BuildContext context) {
//          RenderRepaintBoundary renderObject = _contentKey.currentContext.findRenderObject();
//          BoxConstraints contentSizeConstraints = BoxConstraints.loose(renderObject.size);
        BoxConstraints contentSizeConstraints = BoxConstraints.loose(
            _draggingFeedbackSize!); //renderObject.constraints
//          debugPrint('feedbackBuilder: contentConstraints:$contentSizeConstraints');
        return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(
            context, contentSizeConstraints, toWrap);
      });

      bool isReorderable = widget.enableReorder;

      Widget child;
      if (!isReorderable) {
        child = toWrapWithSemantics;
      } else {
         child = widget.needsLongPressDraggable
            ? LongPressDraggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                childWhenDragging: IgnorePointer(
                    ignoring: true,
                    child: Opacity(
                        opacity: 0.2,
                         child: makeAppearingWidgetChild(toWrap))),
                onDragStarted: onDragStarted,
                 onDragCompleted: onDragEnded,
                dragAnchorStrategy: childDragAnchorStrategy,
               onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
                // Wrap toWrapWithSemantics with a widget that supports HitTestBehavior
                // to make sure the whole toWrapWithSemantics responds to pointer events, i.e. dragging
                child: MetaData(
                    behavior: HitTestBehavior.opaque,
                    child: toWrapWithSemantics),
              )
            : Draggable<int>(
                maxSimultaneousDrags: 1,
                data: index,
                //toWrap.key,
                ignoringFeedbackSemantics: false,
                feedback: feedbackBuilder,
                childWhenDragging: IgnorePointer(
                  ignoring: true,
                  child: Opacity(
                    opacity: 0.2,
                    child: makeAppearingWidgetChild(toWrap),
                  ),
                ),
                onDragStarted: onDragStarted,
                onDragCompleted: onDragEnded,
                dragAnchorStrategy: childDragAnchorStrategy,
                onDraggableCanceled: (Velocity velocity, Offset offset) =>
                    onDragEnded(),
                child: MetaData(
                    behavior: HitTestBehavior.opaque,
                    child: toWrapWithSemantics),
              );
      }
      if (index >= widget.children.length) {
        child = toWrap;
      }
      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    var builder = Builder(builder: (BuildContext context) {
      Widget draggable = buildDraggable(); //buildDragTarget(null, null, null);
      var containedDraggable =
          ContainedDraggable(Builder(builder: (BuildContext context) {
        _childContexts[index] = context;
        return draggable;
      }), draggable is LongPressDraggable || draggable is Draggable);

      List<Widget> includeMovedAdjacentChildIfNeeded(
          Widget child, int childDisplayIndex) {
        int checkingTargetDisplayIndex = -1;
        if (_ghostDisplayIndex < _currentDisplayIndex &&
            childDisplayIndex > _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex - 1;
        } else if (_ghostDisplayIndex > _currentDisplayIndex &&
            childDisplayIndex < _ghostDisplayIndex) {
          checkingTargetDisplayIndex = childDisplayIndex + 1;
        }
        if (checkingTargetDisplayIndex == -1) {
          return [child];
        }
        int checkingTargetIndex =
            _childDisplayIndexToIndex[checkingTargetDisplayIndex];
        if (checkingTargetIndex == _dragStartIndex) {
          return [child];
        }
        if (_childRunIndexes[checkingTargetIndex] == -1 ||
            _childRunIndexes[checkingTargetIndex] ==
                _wrapChildRunIndexes[checkingTargetDisplayIndex]) {
          return [child];
        }
        Widget disappearingPreChild =
            makeDisappearingWidgetChild(_wrapChildren[checkingTargetIndex]!);
        return _ghostDisplayIndex < _currentDisplayIndex
            ? [disappearingPreChild, child]
            : [child, disappearingPreChild];
      }

      _nextChildRunIndexes[index] = _wrapChildRunIndexes[displayIndex];

      if (_currentDisplayIndex == -1 || displayIndex == _currentDisplayIndex) {
        //we still wrap dragTarget with a container so that widget's depths are the same and it prevents layout alignment issue
        return _buildContainerForMainAxis(
            children: includeMovedAdjacentChildIfNeeded(
                containedDraggable.builder, displayIndex));
      }

      bool onWillAccept(int? toAccept, bool isPre) {
        int nextDisplayIndex;
        if (_currentDisplayIndex < displayIndex) {
          nextDisplayIndex = isPre ? displayIndex - 1 : displayIndex;
        } else {
          nextDisplayIndex = !isPre ? displayIndex + 1 : displayIndex;
        }

        bool movingToAdjacentChild =
            nextDisplayIndex <= _currentDisplayIndex + 1 &&
                nextDisplayIndex >= _currentDisplayIndex - 1;
        bool willAccept = _dragStartIndex == toAccept &&
            toAccept != index &&
            (_entranceController.isCompleted || !movingToAdjacentChild) &&
            _currentDisplayIndex != nextDisplayIndex;

        if (!willAccept) {
          return false;
        }
        if (!(_childDisplayIndexToIndex[_currentDisplayIndex] != index &&
            _currentDisplayIndex != displayIndex)) {
          return false;
        }

        if (_wrapKey.currentContext != null) {
          RenderWrapWithMainAxisCount wrapRenderObject =
              _wrapKey.currentContext!.findRenderObject()
                  as RenderWrapWithMainAxisCount;
          _wrapChildRunIndexes = wrapRenderObject.childRunIndexes;
        } else {
          if (widget.minMainAxisCount != null &&
              widget.maxMainAxisCount != null &&
              widget.minMainAxisCount == widget.maxMainAxisCount) {
            _wrapChildRunIndexes = List.generate(widget.children.length,
                (int index) => index ~/ widget.minMainAxisCount!);
          }
        }

        setState(() {
          _nextDisplayIndex = nextDisplayIndex;
          _requestAnimationToNextIndex(isAcceptingNewTarget: true);
        });
        _scrollTo(context);
        // If the target is not the original starting point, then we will accept the drop.
        return willAccept; //_dragging == toAccept && toAccept != toWrap.key;
      }

      Widget preDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
            List<dynamic> rejectedCandidates) =>
        const SizedBox(),
        onWillAcceptWithDetails: (DragTargetDetails<int?> details) {
          return onWillAccept(details.data, true);
        },
        onAcceptWithDetails: (DragTargetDetails<int> details) {
        },
        onLeave: (Object? leaving) {
        },
      );

      Widget nextDragTarget = DragTarget<int>(
        builder: (BuildContext context, List<int?> acceptedCandidates,
            List<dynamic> rejectedCandidates) =>
        const SizedBox(),
        onWillAcceptWithDetails: (DragTargetDetails<int?> details) {
          return onWillAccept(details.data, false);
        },
        onAcceptWithDetails: (DragTargetDetails<int> details) {

        },
        onLeave: (Object? leaving) {

        },
      );


      Widget dragTarget = Stack(
        clipBehavior: Clip.hardEdge,
        children: <Widget>[
          containedDraggable.builder,
          if (containedDraggable.isReorderable)
            Positioned(
                left: 0,
                top: 0,
                width: widget.direction == Axis.horizontal
                    ? _childSizes[index].width / 2
                    : _childSizes[index].width,
                height: widget.direction == Axis.vertical
                    ? _childSizes[index].height / 2
                    : _childSizes[index].height,
                child: preDragTarget),
          if (containedDraggable.isReorderable)
            Positioned(
                right: 0,
                bottom: 0,
                width: widget.direction == Axis.horizontal
                    ? _childSizes[index].width / 2
                    : _childSizes[index].width,
                height: widget.direction == Axis.vertical
                    ? _childSizes[index].height / 2
                    : _childSizes[index].height,
                child: nextDragTarget),
        ],
      );

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = _draggingWidget == null
          ? SizedBox.fromSize(size: _dropAreaSize)
          : Opacity(opacity: 0.2, child: _draggingWidget);

      if (_childRunIndexes[index] != -1 &&
          _childRunIndexes[index] != _wrapChildRunIndexes[displayIndex]) {
        dragTarget = makeAppearingWidgetChild(dragTarget);
      }

      if (displayIndex == _ghostDisplayIndex) {
        Widget ghostSpacing = makeDisappearingWidgetChild(spacing);
        if (_ghostDisplayIndex < _currentDisplayIndex) {
          return _buildContainerForMainAxis(
              children: [ghostSpacing] +
                  includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));
        } else if (_ghostDisplayIndex > _currentDisplayIndex) {
          return _buildContainerForMainAxis(
              children:
                  includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex) +
                      [ghostSpacing]);
        }
      }

      return _buildContainerForMainAxis(
          children:
              includeMovedAdjacentChildIfNeeded(dragTarget, displayIndex));
    });
    return KeyedSubtree(key: ValueKey(index), child: builder);
  }

  @override
  Widget build(BuildContext context) {
    List<E> resizeListMember<E>(List<E> listVar, E initValue) {
      if (listVar.length < widget.children.length) {
        return listVar +
            List.filled(widget.children.length - listVar.length, initValue);
      } else if (listVar.length > widget.children.length) {
        return listVar.sublist(0, widget.children.length);
      }
      return listVar;
    }

    _childContexts = resizeListMember(_childContexts, null);
    _childSizes = resizeListMember(_childSizes, const Size(0, 0));

    _childDisplayIndexToIndex =
        List.generate(widget.children.length, (int index) => index);
    _childIndexToDisplayIndex =
        List.generate(widget.children.length, (int index) => index);
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      _childDisplayIndexToIndex.insert(_currentDisplayIndex,
          _childDisplayIndexToIndex.removeAt(_dragStartIndex));
    }
    int index = 0;
    for (var element in _childDisplayIndexToIndex) {
      _childIndexToDisplayIndex[element] = index++;
    }
    _wrapChildRunIndexes = resizeListMember(_wrapChildRunIndexes, -1);
    _childRunIndexes = resizeListMember(_childRunIndexes, -1);
    _nextChildRunIndexes = resizeListMember(_nextChildRunIndexes, -1);
    _wrapChildren = resizeListMember(_wrapChildren, null);
    _childRunIndexes = _nextChildRunIndexes.toList();

    final List<Widget> wrappedChildren = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      wrappedChildren.add(_wrap(widget.children[i], i));
    }
    if (_dragStartIndex >= 0 &&
        _currentDisplayIndex >= 0 &&
        _dragStartIndex != _currentDisplayIndex) {
      //we are dragging an widget
      wrappedChildren.insert(
          _currentDisplayIndex, wrappedChildren.removeAt(_dragStartIndex));
    }
    if (widget.header != null) {
      wrappedChildren.insertAll(0, widget.header!);
    }
    if (widget.footer != null) {
      wrappedChildren.add(widget.footer!);
    }

    if (widget.controller != null &&
        PrimaryScrollController.maybeOf(context) == null) {
      return (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
          context, widget.direction, wrappedChildren);
    } else {
      return SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        padding: widget.padding,
        controller: _scrollController,
        child: (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
            context, widget.direction, wrappedChildren),
      );
    }
  }

  Widget defaultBuildItemsContainer(
      BuildContext context, Axis direction, List<Widget> children) {
    return WrapWithMainAxisCount(
      key: _wrapKey,
      direction: direction,
      alignment: widget.alignment,
      spacing: widget.spacing,
      runAlignment: widget.runAlignment,
      runSpacing: widget.runSpacing,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      minMainAxisCount: widget.minMainAxisCount,
      maxMainAxisCount: widget.maxMainAxisCount,
      children: children,
    );
  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: Material(
        elevation: 6.0,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child:
            Card(child: ConstrainedBox(constraints: constraints, child: child)),
      ),
    );
  }
}

class ContainedDraggable {
  Builder builder;
  bool isReorderable;

  ContainedDraggable(this.builder, this.isReorderable);
}
