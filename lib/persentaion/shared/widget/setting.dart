import 'package:flutter/material.dart';

class CustomSettingAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomSettingAppBar({
    super.key,
    this.backImage = 'assets/images/back_ic.png',
    this.settingImage = 'assets/images/back_ic.png',
    this.backIcon = Icons.arrow_back_ios_new_rounded,
    this.settingIcon = Icons.settings,
    this.iconColor = Colors.white,
    this.backIconSize = 18,
    this.settingIconSize = 18,
    this.height = 70,
    this.size = 48,
    this.leftMargin = const EdgeInsets.only(left: 0),
    this.rightMargin = const EdgeInsets.only(right: 0),
    this.onBackTap,
    this.onSettingTap,
    this.centerTitle,
    this.title,
  });

  final String backImage;
  final String settingImage;
  final IconData backIcon;
  final IconData settingIcon;
  final Color iconColor;
  final double backIconSize;
  final double settingIconSize;
  final double height;
  final double size;
  final EdgeInsets leftMargin;
  final EdgeInsets rightMargin;
  final VoidCallback? onBackTap;
  final VoidCallback? onSettingTap;
  final Widget? title;
  final bool? centerTitle;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Padding(
            padding: leftMargin,
            child: _ActionButton(
              imagePath: backImage,
              icon: backIcon,
              iconColor: iconColor,
              iconSize: backIconSize,
              size: size,
              onTap:
                  onBackTap,
            ),
          ),
          Spacer(),
          // Expanded(child: Center(child: title ?? const SizedBox.shrink())),
          Padding(
            padding: rightMargin,
            child: _ActionButton(
              imagePath: settingImage,
              icon: settingIcon,
              iconColor: iconColor,
              iconSize: settingIconSize,
              size: size,
              onTap: onSettingTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.imagePath,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.size,
    required this.onTap,
  });

  final String imagePath;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
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
    );
  }
}
