import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:ticket_cine/widgets/horizontale.dart';
import 'package:ticket_cine/widgets/popular.dart';
import 'package:ticket_cine/widgets/top_rated.dart';

class Tous extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const Tous({super.key, required this.user, required this.onLogout});
  @override
  State<Tous> createState() => TousState();
}

class TousState extends State<Tous> {
  final _scrollController = ScrollController();

  void refreshData() {
    // Les widgets enfants gèrent leur propre rafraîchissement ou on peut forcer un rebuild
    setState(() {});
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'profile':
        _showProfileDialog();
        break;
      case 'logout':
        widget.onLogout();
        break;
    }
  }

  void _showProfileDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 40, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              '${widget.user.prenom} ${widget.user.nom}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.user.numero,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.primary),
              title: const Text('Changer le mot de passe'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Se déconnecter'),
              onTap: () {
                Navigator.pop(context);
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Nouveau mot de passe'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Entrez le nouveau mot de passe',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique de changement de mot de passe à implémenter côté API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité en cours de développement'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              title: FadeInLeft(
                child: Text(
                  'Hello, ${widget.user.prenom}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surface, AppColors.background],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, size: 20, color: Colors.black),
                ),
                onPressed: _showProfileDialog,
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  FadeInRight(child: HorizontalMovieList()),
                  const SizedBox(height: 16),
                  FadeInLeft(child: PopularPage()),
                  const SizedBox(height: 16),
                  FadeInRight(child: TopRatedPage()),
                  const SizedBox(height: 100), // Space for nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
