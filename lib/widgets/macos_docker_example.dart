import 'package:flutter/material.dart';
import '../utils/reorderable_wrap.dart';
import 'asset_item.dart';
import 'custom_tooltip.dart';

/// A MacOS-like docker example widget that displays a set of items in a horizontal row,
/// with the ability to reorder them and show tooltips on hover or tap.
class MacosDockerExample extends StatefulWidget {
  const MacosDockerExample({super.key});

  @override
  MacosDockerExampleState createState() => MacosDockerExampleState();
}

class MacosDockerExampleState extends State<MacosDockerExample> {
  // A list of items to display, each item contains an icon, name, and a unique key.
  final List<Map<String, dynamic>> _items = [
    {'icon': 'assets/appstore.png', 'name': 'App Store', 'key': GlobalKey()},
    {'icon': 'assets/calendar.png', 'name': 'Calendar', 'key': GlobalKey()},
    {'icon': 'assets/chrome.png', 'name': 'Google Chrome', 'key': GlobalKey()},
    {'icon': 'assets/finder.png', 'name': 'Finder', 'key': GlobalKey()},
    {'icon': 'assets/launchpad.png', 'name': 'Launchpad', 'key': GlobalKey()},
    {'icon': 'assets/music.png', 'name': 'Music', 'key': GlobalKey()},
  ];

  // The overlay entry for showing tooltips.
  OverlayEntry? _overlayEntry;

  // The message to be displayed in the tooltip.
  String _tooltipMessage = '';

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF7651F2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Center(
                child: ReorderableWrap(
                  direction: Axis.horizontal,
                  onReorder: _onReorder,
                  spacing: 5,
                  runSpacing: 0,
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

  /// Handles the reorder of items in the [ReorderableWrap].
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      _showTooltip(newIndex, item['name']!);
    });
  }

  /// Shows a tooltip with the [message] at the position of the item at [index].
  void _showTooltip(int index, String message) {
    // Remove the existing tooltip if any.
    _overlayEntry?.remove();

    // Update the tooltip message.
    setState(() {
      _tooltipMessage = message;
    });

    // Get the key of the item and find its position on the screen.
    final key = _items[index]['key'] as GlobalKey;
    if (key.currentContext != null) {
      final renderBox = key.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final overlay = Overlay.of(context);

      // Create a text painter to measure the width of the tooltip.
      final textPainter = TextPainter(
        text: TextSpan(
          text: message,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tooltipWidth = textPainter.width;

      // Calculate the position of the tooltip relative to the item.
      final tooltipLeft = position.dx + (renderBox.size.width / 2) - (tooltipWidth / 2) - 15;

      // Create an overlay entry to display the tooltip.
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: tooltipLeft,
          top: position.dy - 55,
          child: Material(
            color: Colors.transparent,
            child: CustomTooltip(message: _tooltipMessage),
          ),
        ),
      );

      // Insert the overlay entry into the overlay.
      overlay.insert(_overlayEntry!);

      // Remove the tooltip after a short delay.
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