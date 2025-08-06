import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/status_model.dart';
import '../utils/app_colors.dart';
import '../utils/audio_utils.dart';
import 'dart:math';

class StatusCard extends StatefulWidget {
  final StatusModel status;
  final VoidCallback onLike;
  final VoidCallback onPlay;

  const StatusCard({
    super.key,
    required this.status,
    required this.onLike,
    required this.onPlay,
  });

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLiked = false;
  late AnimationController _waveController;
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heartAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _waveController.repeat();
    } else {
      _waveController.stop();
    }

    widget.onPlay();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      _heartController.forward().then((_) {
        _heartController.reverse();
      });
    }

    widget.onLike();
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec avatar et infos utilisateur
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
                  backgroundImage: widget.status.userPhotoUrl != null
                      ? CachedNetworkImageProvider(widget.status.userPhotoUrl!)
                      : null,
                  child: widget.status.userPhotoUrl == null
                      ? Text(
                          widget.status.userPseudo.isNotEmpty
                              ? widget.status.userPseudo[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // Infos utilisateur
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.status.userPseudo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      Text(
                        _getTimeAgo(widget.status.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu options
                IconButton(
                  onPressed: () => _showOptionsMenu(),
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description si présente
            if (widget.status.description != null) ...[
              Text(
                widget.status.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Lecteur audio
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Bouton play/pause
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Onde audio et durée
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Onde audio visuelle
                        SizedBox(
                          height: 30,
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Row(
                                children: List.generate(20, (index) {
                                  final height = _isPlaying
                                      ? 4 +
                                          (20 *
                                              (0.5 +
                                                  0.5 *
                                                      (index / 20) *
                                                      (1 +
                                                          0.5 *
                                                              (1 +
                                                                  sin(_waveController
                                                                              .value *
                                                                          2 *
                                                                          pi +
                                                                      index *
                                                                          0.5)))))
                                      : 4.0 + (index % 3) * 3;

                                  return Container(
                                    width: 3,
                                    height: height,
                                    margin: const EdgeInsets.only(right: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOrange
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(1.5),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Durée
                        Text(
                          AudioUtils.formatDuration(widget.status.duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions (like, partage, etc.)
            Row(
              children: [
                // Bouton like
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedBuilder(
                    animation: _heartAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _heartAnimation.value,
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked
                                  ? AppColors.error
                                  : AppColors.textGrey,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.status.likes}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 24),

                // Bouton partage
                GestureDetector(
                  onTap: _shareStatus,
                  child: Row(
                    children: [
                      Icon(
                        Icons.share,
                        color: AppColors.textGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Partager',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Indicateur de lecture
                if (_isPlaying)
                  Row(
                    children: [
                      Icon(
                        Icons.volume_up,
                        color: AppColors.primaryOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En cours...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textGrey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.download, color: AppColors.primaryOrange),
              title: const Text('Sauvegarder'),
              onTap: () {
                Navigator.pop(context);
                _downloadAudio();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.warning),
              title: const Text('Signaler'),
              onTap: () {
                Navigator.pop(context);
                _reportStatus();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _shareStatus() {
    // Logique de partage
    print('Partage du statut: ${widget.status.id}');
  }

  void _downloadAudio() {
    // Logique de téléchargement
    print('Téléchargement de l\'audio: ${widget.status.audioUrl}');
  }

  void _reportStatus() {
    // Logique de signalement
    print('Signalement du statut: ${widget.status.id}');
  }
}
