import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Runner085'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, ${user?.displayName ?? 'Corredor'}!',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pronto para treinar hoje?',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Placeholder cards
              _buildSectionCard(
                context,
                icon: Icons.fitness_center,
                title: 'Treino de Hoje',
                subtitle: 'Nenhum treino agendado',
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                icon: Icons.trending_up,
                title: 'Seu Progresso',
                subtitle: 'Comece um plano para acompanhar',
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                context,
                icon: Icons.emoji_events,
                title: 'Sequência',
                subtitle: '0 dias consecutivos',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: context.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
