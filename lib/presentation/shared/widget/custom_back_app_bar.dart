import 'package:flutter/material.dart';

class CustomBackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomBackAppBar({
    super.key,
    this.imagePath = 'assets/images/back_ic.png',
    this.icon = Icons.arrow_back_ios_new_rounded,
    this.iconColor = Colors.white,
    this.iconSize = 18,
    this.height = 70,
    this.leadingSize = 48,
    this.margin = const EdgeInsets.only(left: 16),
    this.onTap,
    this.centerTitle,
    this.title,
  });

  final String imagePath;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double height;
  final double leadingSize;
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
      leadingWidth: leadingSize + margin.left,
      leading: Padding(
        padding: margin,
        child: GestureDetector(
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: SizedBox(
            width: leadingSize,
            height: leadingSize,
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
    );
  }
}
