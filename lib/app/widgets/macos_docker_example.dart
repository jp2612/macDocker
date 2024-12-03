import 'package:flutter/material.dart';
import '../core/reorderable_wrap.dart';
import 'asset_item.dart';
import 'custom_tooltip.dart';
import '../utils/dimens.dart';  // Import the dimens file

/// A StatefulWidget that demonstrates a macOS-like Docker interface,
/// allowing users to reorder app icons in a horizontal layout.
class MacosDockerExample extends StatefulWidget {
  const MacosDockerExample({super.key});

  @override
  MacosDockerExampleState createState() => MacosDockerExampleState();
}

class MacosDockerExampleState extends State<MacosDockerExample> {
  // List of app icons and their names to be displayed in the Docker
  final List<Map<String, dynamic>> _items = [
    {'icon': 'assets/appstore.png', 'name': 'App Store', 'key': GlobalKey()},
    {'icon': 'assets/calendar.png', 'name': 'Calendar', 'key': GlobalKey()},
    {'icon': 'assets/chrome.png', 'name': 'Google Chrome', 'key': GlobalKey()},
    {'icon': 'assets/finder.png', 'name': 'Finder', 'key': GlobalKey()},
    {'icon': 'assets/launchpad.png', 'name': 'Launchpad', 'key': GlobalKey()},
    {'icon': 'assets/music.png', 'name': 'Music', 'key': GlobalKey()},
  ];

  OverlayEntry? _overlayEntry;  // Overlay for tooltip
  String _tooltipMessage = '';  // Tooltip message to be shown
  int? draggedIndex;  // Index of the currently dragged item

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MacOS Docker Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: Dimens.horizontalPadding.add(Dimens.verticalPadding),
            child: Container(
              height: Dimens.itemHeight,
              decoration: Dimens.containerDecoration,
              child: Center(
                child: ReorderableWrap(
                  direction: Axis.horizontal,
                  onReorder: _onReorder,
                  spacing: Dimens.itemSpacing,
                  runSpacing: Dimens.runSpacing,
                  onReorderStarted: (index) {
                    setState(() {
                      draggedIndex = index;
                    });
                  },
                  buildDraggableFeedback: (context, constraints, child) {
                    if (draggedIndex == null) return Container();
                    final assetItem = _items[draggedIndex!];
                    return AssetItem(
                      iconPath: assetItem['icon']!,
                      name: assetItem['name']!,
                    );
                  },
                  // Generate the list of draggable app icons
                  children: List.generate(
                    _items.length,
                        (index) => GestureDetector(
                      key: _items[index]['key']!,
                      onTap: () {
                        _showTooltip(index, _items[index]['name']!);
                      },
                      child: MouseRegion(
                        onEnter: (_) => _showTooltip(index, _items[index]['name']!),
                        onExit: (_) => _hideTooltip(),
                        child: AssetItem(
                          iconPath: _items[index]['icon']!,
                          name: _items[index]['name']!,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Called when the order of the items in the Docker is changed.
  /// Updates the position of the item in the list and shows the tooltip.
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _showTooltip(newIndex, item['name']!);
    });
  }

  /// Shows a tooltip at the position of the item.
  /// Uses an overlay entry to display a custom tooltip.
  void _showTooltip(int index, String message) {
    _overlayEntry?.remove();  // Remove any existing tooltip
    setState(() {
      _tooltipMessage = message;
    });

    final key = _items[index]['key'] as GlobalKey;
    if (key.currentContext != null) {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final overlay = Overlay.of(context);

      final textPainter = TextPainter(
        text: TextSpan(
          text: message,
          style: Dimens.tooltipTextStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tooltipWidth = textPainter.width;
      final tooltipLeft = position.dx + (renderBox.size.width / 2) - (tooltipWidth / 2) - Dimens.tooltipOffset;

      // Create the overlay entry for the tooltip
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: tooltipLeft,
          top: position.dy - Dimens.tooltipTopOffset,
          child: Material(
            color: Colors.transparent,
            child: CustomTooltip(
              message: _tooltipMessage,
            ),
          ),
        ),
      );

      overlay.insert(_overlayEntry!);

      // Hide the tooltip after a delay
      Future.delayed(const Duration(seconds: 2), () {
        _hideTooltip();
      });
    }
  }

  /// Hides the tooltip by removing the overlay entry.
  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _tooltipMessage = '';
    });
  }
}