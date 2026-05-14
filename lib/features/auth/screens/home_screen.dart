import 'package:flutter/material.dart';
import 'package:sine_ai/shared/navigation/bottom_navbar.dart';
import 'package:sine_ai/features/aura/screens/aura_screen.dart';
import 'package:sine_ai/features/chat/screens/chat_screen.dart';
import 'package:sine_ai/features/alerts/screens/alarm_screen.dart';
import 'package:sine_ai/features/profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AuraScreen(),
    ChatScreen(),
    AlarmScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
