import 'package:flutter/material.dart';
import 'package:whereshot/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool centerTitle;
  final Color? backgroundColor;
  final double? elevation;
  
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.height = kToolbarHeight,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation,
  });
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.white,
      elevation: elevation ?? 0,
      actions: actions,
      leading: leading,
      foregroundColor: AppColors.darkGrey,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(height);
} 