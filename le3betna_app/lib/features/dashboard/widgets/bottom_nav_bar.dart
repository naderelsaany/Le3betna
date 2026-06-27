import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.9),
        border: const Border(top: BorderSide(color: AppTheme.borderTransparent)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentRed,
        unselectedItemColor: AppTheme.textMuted,
        currentIndex: currentIndex,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'الألعاب',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(width: 40), // Placeholder for FAB
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'الأصدقاء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'بروفايل',
          ),
        ],
      ),
    );
  }
}
