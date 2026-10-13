import 'package:flutter/material.dart';
import 'package:tistos/config/helpers/human_formats.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/presentation/widgets/glass/liquid_glass_button.dart';
import 'package:tistos/infrastructure/services/local_storage_service.dart';

class VideoButtons extends StatefulWidget {

  final VideoPost video;
  final bool isMuted;
  final VoidCallback onToggleMute;

  const VideoButtons({
    super.key, 
    required this.video,
    required this.isMuted,
    required this.onToggleMute,
  });

  @override
  State<VideoButtons> createState() => _VideoButtonsState();
}

class _VideoButtonsState extends State<VideoButtons> {

  void _toggleLike() {
    setState(() {
      widget.video.isLiked = !widget.video.isLiked;
      if (widget.video.isLiked) {
        widget.video.likes++;
      } else {
        widget.video.likes--;
      }
    });
    LocalStorageService.saveVideoData(widget.video);
    LocalStorageService.toggleFavorite(widget.video.id, widget.video.isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CustomGlassButton(
          value: widget.video.likes, 
          iconData: widget.video.isLiked ? Icons.favorite : Icons.favorite_border, 
          iconColor: widget.video.isLiked ? Colors.red : Colors.white,
          tint: widget.video.isLiked ? Colors.red.withValues(alpha: 0.5) : null,
          onTap: _toggleLike,
        ),
        const SizedBox( height: 20 ),
        _CustomGlassButton(
          value: widget.video.comments, 
          iconData: Icons.chat_bubble_outline,
        ),
        const SizedBox( height: 20 ),
        _CustomGlassButton(
          value: widget.video.views, 
          iconData: Icons.remove_red_eye_outlined,
        ),

        const SizedBox( height: 20 ),
        
        // Mute button
        Column(
          children: [
            LiquidGlassButton(
              onTap: widget.onToggleMute,
              size: 52,
              child: Icon(
                widget.isMuted ? Icons.volume_off : Icons.volume_up, 
                color: Colors.white, 
                size: 26,
              ),
            ),
            // Espaciador para alinear con los otros botones que tienen texto abajo
            const SizedBox(height: 18), 
          ],
        ),
      ],
    );
  }
}

class _CustomGlassButton extends StatelessWidget {

  final int value;
  final IconData iconData;
  final Color? color;
  final Color? tint;
  final VoidCallback? onTap;

  const _CustomGlassButton({
    required this.value, 
    required this.iconData, 
    this.tint,
    this.onTap,
    iconColor
  }): color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LiquidGlassButton(
          onTap: onTap ?? () {}, 
          size: 52,
          tint: tint,
          child: Icon(iconData, color: color, size: 26),
        ),
        
        const SizedBox(height: 4),

        if ( value > 0 )
          Text(
            HumanFormats.humanReadbleNumber(value.toDouble()),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1))],
            ),
          ),
      ],
    );
  }
}

