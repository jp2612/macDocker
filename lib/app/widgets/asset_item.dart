import 'package:flutter/material.dart';
import '../utils/dimens.dart';


/// A widget that displays an icon and a name for an asset item.
/// This widget displays an icon image from the specified [iconPath] and the asset's name.
/// The layout is vertically aligned with the image centered and the name displayed below the icon.
class AssetItem extends StatelessWidget {
  /// The path to the asset's icon image.
  final String iconPath;

  /// The name of the asset item.
  final String name;

  /// Creates an [AssetItem] widget with the provided [iconPath] and [name].
  const AssetItem({
    super.key,
    required this.iconPath,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Displays the asset's icon image using the static icon size from Dimens.
        Image.asset(
          iconPath,
          width: Dimens.iconSize,
          height: Dimens.iconSize,
        ),
      ],
    );
  }
}
