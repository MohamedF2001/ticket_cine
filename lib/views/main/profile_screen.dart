import 'package:flutter/material.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/views/splash_screen_new.dart';

import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SplashScreenNew()),
            (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Avatar et nom
                Container(
                  margin: const EdgeInsets.all(AppTheme.paddingLarge),
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.user.prenom[0]}${widget.user.nom[0]}',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Nom complet
                      Text(
                        '${widget.user.prenom} ${widget.user.nom}',
                        //style: Theme.of(context).textTheme.headlineMedium,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                            fontSize: 34,
                          letterSpacing: 0.24,
                          color: Colors.white
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Numéro
                      Text(
                        widget.user.numero,
                        //style: Theme.of(context).textTheme.bodyMedium,
                        style:TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            letterSpacing: 0.25,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),

                // Options du menu
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.paddingLarge,
                  ),
                  child: Column(
                    children: [
                      _MenuSection(
                        title: 'Compte',
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline,
                            title: 'Informations personnelles',
                            onTap: () {
                              _showUserInfoDialog();
                            },
                          ),
                          _MenuItem(
                            icon: Icons.lock_outline,
                            title: 'Changer le mot de passe',
                            onTap: () {
                              _showChangePasswordDialog();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _MenuSection(
                        title: 'Paramètres',
                        items: [
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {},
                              activeColor: AppTheme.primaryColor,
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.language_outlined,
                            title: 'Langue',
                            subtitle: 'Français',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _MenuSection(
                        title: 'Support',
                        items: [
                          _MenuItem(
                            icon: Icons.help_outline,
                            title: 'Aide & FAQ',
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Confidentialité',
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.description_outlined,
                            title: 'Conditions d\'utilisation',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Bouton de déconnexion
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Se déconnecter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Version
                      Text(
                        'CinéBook v1.0.0',
                        //style: Theme.of(context).textTheme.bodySmall,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: 0.4,
                            color: Colors.white
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUserInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Informations personnelles',style: TextStyle(color: Colors.white),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoItem(label: 'Nom', value: widget.user.nom),
            const SizedBox(height: 12),
            _InfoItem(label: 'Prénom', value: widget.user.prenom),
            const SizedBox(height: 12),
            _InfoItem(label: 'Numéro', value: widget.user.numero),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer',style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Changer le mot de passe',style: TextStyle(color: Colors.white),),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.radiusMedium,
          ),
        ),
      ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique de changement de mot de passe
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Mot de passe modifié avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusMedium,
                ),
              ),
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = items.indexOf(item) == items.length - 1;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppTheme.textSecondary.withOpacity(0.1),
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      //style: Theme.of(context).textTheme.bodyLarge,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.5,
                          color: AppTheme.textSecondary
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        //style: Theme.of(context).textTheme.bodySmall,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: 0.4,
                            color: AppTheme.textSecondary
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          //style: Theme.of(context).textTheme.bodyLarge,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              letterSpacing: 0.5,
              color: Colors.white
          ),
        ),
      ],
    );
  }
}