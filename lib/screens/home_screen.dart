import 'package:flutter/material.dart';
import '../constants.dart';
import 'chat_screen.dart';
import '../widgets/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _sidebarController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    if (_sidebarController.isCompleted) {
      _sidebarController.reverse();
    } else {
      _sidebarController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ChatScreen(onMenuTap: _toggleSidebar),
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _toggleSidebar,
              child: Container(color: Colors.black),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Sidebar(onClose: _toggleSidebar),
          ),
        ],
      ),
    );
  }
}
