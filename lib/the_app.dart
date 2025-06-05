import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';

class TheApp extends StatelessWidget {
  final UserModel user;

  late PersistentTabController _controller;
  final int initialIndex;

  TheApp({Key? key, required this.user, this.initialIndex = 0})
    : super(key: key) {
    _controller = PersistentTabController(initialIndex: initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildScreens(),
      builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: SpinKitPulse(
            duration: Duration(seconds: 3),
            color: Colors.white70,
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }

        return Scaffold(
          body: WillPopScope(
            onWillPop: () => Navigator.of(context).maybePop(),
            child: PersistentTabView(
              context,
              controller: _controller,
              screens: snapshot.data ?? [Placeholder(), Placeholder()],
              items: _navBarsItems(),
              handleAndroidBackButtonPress: true,
              resizeToAvoidBottomInset: true,
              stateManagement: true,
              hideNavigationBarWhenKeyboardAppears: true,
              popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
              isVisible: true,
              animationSettings: const NavBarAnimationSettings(
                navBarItemAnimation: ItemAnimationSettings(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.ease,
                ),
                screenTransitionAnimation: ScreenTransitionAnimationSettings(
                  animateTabTransition: true,
                  duration: Duration(milliseconds: 200),
                  screenTransitionAnimationType:
                      ScreenTransitionAnimationType.fadeIn,
                ),
              ),
              confineToSafeArea: true,
              navBarHeight: kBottomNavigationBarHeight,
              navBarStyle: NavBarStyle.style1,
              decoration: NavBarDecoration(
                colorBehindNavBar: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<List<Widget>> _buildScreens() async {
    final authService = AuthService();

    //return [SessionsPage(user: user!), Placeholder()];
    return [Placeholder(), Placeholder()];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home_outlined),
        title: ("Home"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,

        //scrollController: _scrollController1,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.schedule_outlined),
        title: ("Programme"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,

        //scrollController: _scrollController2,
      ),
    ];
  }
}
