import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/status_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../widgets/status_card.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Column(
        children: [
          // En-tête avec titre et filtre
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statuts vocaux',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Écoutez les derniers messages de la communauté',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 16),

                // Filtres rapides
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tous', true),
                      const SizedBox(width: 8),
                      _buildFilterChip('Récents', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Populaires', false),
                      const SizedBox(width: 8),
                      _buildFilterChip('Mes quartiers', false),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des statuts
          Expanded(
            child: StreamBuilder<List<StatusModel>>(
              stream: _firestoreService.getVoiceStatusStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.textGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Impossible de charger les statuts',
                          style: TextStyle(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final statuses = snapshot.data ?? [];

                if (statuses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mic_none,
                            size: 60,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Aucun statut vocal',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Soyez le premier à partager\\nun message vocal !',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Déclencher l'enregistrement
                          },
                          icon: const Icon(Icons.mic),
                          label: const Text('Enregistrer un statut'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryOrange,
                  onRefresh: () async {
                    // Actualiser les données
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: statuses.length,
                    itemBuilder: (context, index) {
                      final status = statuses[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: StatusCard(
                          status: status,
                          onLike: () => _likeStatus(status.id),
                          onPlay: () => _playStatus(status),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // Logique de filtrage
      },
      selectedColor: AppColors.primaryOrange.withOpacity(0.2),
      checkmarkColor: AppColors.primaryOrange,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryOrange : AppColors.textGrey,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryOrange
            : AppColors.textGrey.withOpacity(0.3),
      ),
    );
  }

  Future<void> _likeStatus(String statusId) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      try {
        await _firestoreService.likeStatus(statusId, currentUser.uid);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _playStatus(StatusModel status) {
    // Logique de lecture du statut audio
    print('Lecture du statut: ${status.id}');
  }
}
