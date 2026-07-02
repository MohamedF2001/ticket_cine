import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/views/le_ticket.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/views/navBar/seance.dart';
import 'package:ticket_cine/views/navBar/tous.dart';
import 'package:ticket_cine/views/splash_screen.dart';
import 'package:ticket_cine/theme/app_theme.dart';

class HomeNavigation extends StatefulWidget {
  final UserModel user;

  const HomeNavigation({super.key, required this.user});
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final _seanceKey = GlobalKey<SeanceState>();
  final _tousKey = GlobalKey<TousState>();
  final _tickeyKey = GlobalKey<LeTicketState>();

  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_controller.index == 0) {
      _tousKey.currentState?.refreshData();
    } else if (_controller.index == 1) {
      _seanceKey.currentState?.refreshData();
    } else if (_controller.index == 2) {
      _tickeyKey.currentState?.refreshData();
    }
  }

  List<Widget> _buildScreens() => [
    Tous(
      key: _tousKey,
      user: widget.user,
      onLogout: _logoutUser,
    ),
    Seance(
      key: _seanceKey,
      user: widget.user,
      onLogout: _logoutUser,
    ),
    LeTicket(
      key: _tickeyKey,
      user: widget.user,
      onLogout: _logoutUser,
    ),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.movie_filter_rounded),
      title: ("Découvrir"),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.confirmation_number_rounded),
      title: ("Séances"),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.bookmark_rounded),
      title: ("Mes tickets"),
      activeColorPrimary: AppColors.primary,
      inactiveColorPrimary: Colors.grey,
    ),
  ];

  void _logoutUser() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        backgroundColor: AppColors.surface,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardAppears: true,
        decoration: NavBarDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          colorBehindNavBar: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            animateTabTransition: true,
            duration: Duration(milliseconds: 300),
            screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
          ),
        ),
        navBarStyle: NavBarStyle.style12,
      ),
    );
  }
}
