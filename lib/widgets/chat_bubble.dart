import 'package:flutter/material.dart';
import '../models/salon_model.dart';
import '../utils/app_colors.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
  });

  String _getTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Aujourd'hui, afficher seulement l'heure
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Autre jour, afficher la date
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMyMessage) ...[
          // Avatar pour les autres utilisateurs
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
            child: Text(
              message.pseudoTemp.isNotEmpty
                  ? message.pseudoTemp[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],

        // Bulle de message
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isMyMessage ? AppColors.primaryOrange : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMyMessage
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isMyMessage
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: !isMyMessage
                  ? Border.all(
                      color: AppColors.textGrey.withOpacity(0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pseudo (seulement pour les autres utilisateurs)
                if (!isMyMessage) ...[
                  Text(
                    message.pseudoTemp,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                // Contenu du message
                if (message.type == MessageType.text) ...[
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isMyMessage ? Colors.white : AppColors.textBlack,
                    ),
                  ),
                ] else if (message.type == MessageType.audio) ...[
                  _buildAudioMessage(),
                ],

                const SizedBox(height: 4),

                // Heure
                Text(
                  _getTimeString(message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMyMessage
                        ? Colors.white.withOpacity(0.7)
                        : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (isMyMessage) ...[
          const SizedBox(width: 8),
          // Indicateur de statut pour mes messages
          Icon(
            Icons.done_all,
            size: 16,
            color: AppColors.textGrey,
          ),
        ],
      ],
    );
  }

  Widget _buildAudioMessage() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMyMessage
            ? Colors.white.withOpacity(0.2)
            : AppColors.primaryOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: isMyMessage ? Colors.white : AppColors.primaryOrange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message.audioDuration != null
                ? _formatDuration(message.audioDuration!)
                : '0:00',
            style: TextStyle(
              fontSize: 12,
              color: isMyMessage ? Colors.white : AppColors.primaryOrange,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.graphic_eq,
            color: isMyMessage ? Colors.white : AppColors.primaryOrange,
            size: 16,
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }
}
