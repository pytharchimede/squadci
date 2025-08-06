import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/app_colors.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Duration duration;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onStop;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.onPlay,
    this.onPause,
    this.onStop,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoading = false;
  double _position = 0.0;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _isPlaying = false;
        _waveController.stop();
        widget.onPause?.call();
      } else {
        _isPlaying = true;
        _waveController.repeat();
        widget.onPlay?.call();
      }
    });
  }

  void _stop() {
    setState(() {
      _isPlaying = false;
      _position = 0.0;
      _waveController.stop();
    });
    widget.onStop?.call();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Contrôles de lecture
          Row(
            children: [
              // Bouton play/pause
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOrange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),

              const SizedBox(width: 16),

              // Onde audio et progression
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visualisation d'onde
                    SizedBox(
                      height: 40,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(25, (index) {
                              final progress = index / 25;
                              final isActive = progress <= _position;

                              double height;
                              if (_isPlaying) {
                                double wave = sin(progress * 4 +
                                    _waveController.value * 2 * pi);
                                height = 8 + (24 * (0.5 + 0.5 * wave.abs()));
                              } else {
                                height = 8.0 + (index % 4) * 4;
                              }

                              return Container(
                                width: 2,
                                height: height,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primaryOrange
                                      : AppColors.primaryOrange
                                          .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Barre de progression
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primaryOrange,
                        inactiveTrackColor:
                            AppColors.primaryOrange.withOpacity(0.3),
                        thumbColor: AppColors.primaryOrange,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 12),
                        trackHeight: 2,
                      ),
                      child: Slider(
                        value: _position,
                        onChanged: (value) {
                          setState(() {
                            _position = value;
                          });
                        },
                        min: 0.0,
                        max: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Bouton stop
              GestureDetector(
                onTap: _stop,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.stop,
                    color: AppColors.textGrey,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Durée et informations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(Duration(
                  milliseconds:
                      (widget.duration.inMilliseconds * _position).round(),
                )),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.graphic_eq,
                    size: 14,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(widget.duration),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
