import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/views/main/sessions_screen.dart';
import 'package:ticket_cine/views/main/profile_screen.dart';

import '../../theme/app_theme.dart';
import 'movie_screen.dart';
import 'reservation_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  final UserModel user;

  const HomeNavigationScreen({super.key, required this.user});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const MoviesScreen(),
      const SessionsScreen(),
      ReservationsScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusLarge),
              topRight: Radius.circular(AppTheme.radiusLarge),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.black, // 🔥 fond noir
              currentIndex: _currentIndex,
              selectedItemColor: Colors.red, // 🎯 élément actif (bleu)
              unselectedItemColor: Colors.white70, // éléments inactifs
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie_outlined),
                  activeIcon: Icon(Icons.movie),
                  label: 'Films',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Séances',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.confirmation_number_outlined),
                  activeIcon: Icon(Icons.confirmation_number),
                  label: 'Billets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      );
  }
}