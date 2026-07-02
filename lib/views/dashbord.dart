import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/views/le_ticket.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';
import 'package:ticket_cine/views/navBar/seance.dart';
import 'package:ticket_cine/views/navBar/tous.dart';
import 'package:ticket_cine/views/splash_screen.dart';

class HomeNavigation extends StatefulWidget {
  final UserModel user;

  const HomeNavigation({super.key, required this.user});
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final SessionService _sessionService = SessionService();
  final _seanceKey = GlobalKey<SeanceState>();
  final _tousKey = GlobalKey<TousState>(); // si tu veux aussi
  final _tickeyKey = GlobalKey<LeTicketState>();

  @override
  void initState() {
    super.initState();
    _loadSessions();
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


  Future<void> _loadSessions() async {
    try {
      final response = await _sessionService.getAllSeances();
      //setState(() => _sessions = [response.seance]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des séances : $e')),
      );
    } finally {
    }
  }

  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  List<Widget> _buildScreens() => [
    Tous(
      key:_tousKey,
      user: widget.user,
      onLogout: _logoutUser,
    ),
    Seance(key: _seanceKey, user: widget.user,
    onLogout: _logoutUser,),
    //MobileTicketScreen(),
    Center(child: LeTicket(key: _tickeyKey, user: widget.user,
    onLogout: _logoutUser,)),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.movie_outlined),
          title: ("Films"),
          activeColorPrimary: AppTheme.primaryColor,
          inactiveColorPrimary: Colors.white54,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.schedule),
          title: ("Séances"),
          activeColorPrimary: AppTheme.primaryColor,
          inactiveColorPrimary: Colors.white54,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.confirmation_number_outlined),
          title: ("Tickets"),
          activeColorPrimary: AppTheme.primaryColor,
          inactiveColorPrimary: Colors.white54,
        ),
      ];

  void _logoutUser() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      navBarHeight: 65,
      decoration: const NavBarDecoration(
        colorBehindNavBar: Colors.black,
      ),
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: AppTheme.backgroundColor.withOpacity(0.9),
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 800),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 800),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
      navBarStyle: NavBarStyle.style3, // Tu peux tester différents styles ici
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/views/le_ticket.dart';
import 'package:ticket_cine/views/navBar/seance.dart';
import 'package:ticket_cine/views/navBar/tous.dart';
import 'package:ticket_cine/views/splash_screen.dart'; // pour redirection après logout

class HomeNavigation extends StatefulWidget {
  final UserModel user;

  const HomeNavigation({super.key, required this.user});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Tous(user: widget.user, onLogout: _logoutUser),
      Seance(user: widget.user),
      LeTicket(user: widget.user),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logoutUser() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: "Films du moment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: "Séances",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: "Mes réservations",
          ),
        ],
      ),
    );
  }
}*/

