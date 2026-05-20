import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/providers/theme_provider.dart';
import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: context.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Corredor',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(user?.level.displayName ?? 'Iniciante'),
                avatar: const Icon(Icons.star, size: 18),
              ),
              const SizedBox(height: 32),
              const Divider(),
              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: 'Configurações',
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Ajuda',
                onTap: () {
                  // TODO: Navigate to help
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'Sobre',
                onTap: () {
                  // TODO: Navigate to about
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
