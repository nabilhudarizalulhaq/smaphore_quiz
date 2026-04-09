import 'package:flutter/material.dart';

class CustomSettingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomSettingAppBar({
    super.key,
    this.imagePath = 'assets/images/back_ic.png',
    this.icon = Icons.settings,
    this.iconColor = Colors.white,
    this.iconSize = 18,
    this.height = 70,
    this.size = 48,
    this.margin = const EdgeInsets.only(right: 16),
    this.onTap,
    this.centerTitle,
    this.title,
  });

  final String imagePath;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double height;
  final double size;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Widget? title;
  final bool? centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      title: title,
      actions: [
        Padding(
          padding: margin,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                  Icon(icon, color: iconColor, size: iconSize),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
