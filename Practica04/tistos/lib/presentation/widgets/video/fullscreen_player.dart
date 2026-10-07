import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:tistos/domain/entities/video_post.dart';
import 'package:tistos/presentation/widgets/shared/video_buttons.dart';
import 'package:tistos/presentation/widgets/video/video_background.dart';
import 'package:tistos/presentation/widgets/glass/liquid_glass.dart';
import 'package:tistos/presentation/providers/playback_settings.dart';

class FullScreenPlayer extends StatefulWidget {
  final VideoPost videoPost;
  final bool isActive;

  const FullScreenPlayer({
    super.key,
    required this.videoPost,
    required this.isActive,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  late VideoPlayerController controller;
  late Future<void> _initializeFuture;
  
  bool _isSpeed2x = false;
  bool _isSpeedLocked = false;
  bool _showSpeedHint = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoPost.videoUrl),
      httpHeaders: const {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Mobile Safari/537.36',
      },
    );
    _initializeFuture = controller.initialize().then((_) async {
      final isMuted = context.read<PlaybackSettings>().isMuted;
      await controller.setVolume(isMuted ? 0 : 1);
      await controller.setLooping(true);
      if (mounted && widget.isActive) {
        await controller.play();
      }
    });
  }

  void _retry() {
    controller.dispose();
    setState(_initController);
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive &&
        controller.value.isInitialized) {
      final action = widget.isActive ? controller.play() : controller.pause();
      action.then((_) {
        if (mounted) setState(() {});
      });
      // Reset speed if we switch tabs
      if (!widget.isActive) {
        _isSpeedLocked = false;
        _isSpeed2x = false;
        _showSpeedHint = false;
        controller.setPlaybackSpeed(1.0);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Si estaba bloqueada en 2x, un tap simple la desbloquea y vuelve a 1x
    if (_isSpeedLocked) {
      setState(() {
        _isSpeedLocked = false;
        _isSpeed2x = false;
        _showSpeedHint = false;
        controller.setPlaybackSpeed(1.0);
      });
      return;
    }

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    if (!controller.value.isPlaying || !controller.value.isInitialized) return;
    
    // Solo activamos 2x si toca del lado derecho (mitad de pantalla en adelante)
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx > screenWidth * 0.3) {
      setState(() {
        _isSpeed2x = true;
        _showSpeedHint = true;
        _isSpeedLocked = false;
        controller.setPlaybackSpeed(2.0);
      });
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_showSpeedHint && details.localOffsetFromOrigin.dy > 60) {
      if (!_isSpeedLocked) {
        setState(() {
          _isSpeedLocked = true;
        });
      }
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (_isSpeedLocked) {
      setState(() {
        _showSpeedHint = false;
      });
    } else {
      setState(() {
        _isSpeed2x = false;
        _showSpeedHint = false;
        controller.setPlaybackSpeed(1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final playbackSettings = context.watch<PlaybackSettings>();
    
    if (_initializeFuture != null && controller.value.isInitialized) {
      controller.setVolume(playbackSettings.isMuted ? 0 : 1);
    }

    return FutureBuilder(
      future: _initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return VideoPlaceholder(
            coverUrl: widget.videoPost.coverUrl,
            showLoader: true,
          );
        }

        if (snapshot.hasError || !controller.value.isInitialized) {
          return Stack(
            children: [
              VideoPlaceholder(coverUrl: widget.videoPost.coverUrl),
              Center(
                child: TextButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'No se pudo cargar. Reintentar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }

        return GestureDetector(
          onTap: _handleTap,
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: _handleLongPressEnd,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                // Video centrado con su proporción real y zoom (InteractiveViewer)
                Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),

                // Gradiente
                IgnorePointer(
                  child: VideoBackground(stops: const [0.8, 1.0]),
                ),

                // Icono de Play (se muestra cuando está pausado)
                if (!controller.value.isPlaying)
                  IgnorePointer(
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        tween: Tween(begin: 0.5, end: 1.0),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: child,
                          );
                        },
                        child: LiquidGlass(
                          borderRadius: BorderRadius.circular(60),
                          tintOpacity: 0.2,
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Overlay de Velocidad 2x
                if (_isSpeed2x)
                  IgnorePointer(
                    child: Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 200),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 10 * (1 - value)),
                              child: child,
                            ),
                          ),
                          child: LiquidGlass(
                            borderRadius: BorderRadius.circular(30),
                            tintOpacity: 0.2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isSpeedLocked ? 'Velocidad 2x bloqueada' : 'Velocidad 2x',
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (!_isSpeedLocked && _showSpeedHint) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.swipe_down, color: Colors.white, size: 20),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Desliza para bloquear',
                                      style: TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ] else if (_isSpeedLocked) ...[
                                    const SizedBox(width: 12),
                                    const Icon(Icons.lock, color: Colors.white, size: 20),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Botones interactivos y mute
                Positioned(
                  bottom: 60,
                  right: 20,
                  child: VideoButtons(
                    video: widget.videoPost,
                    isMuted: playbackSettings.isMuted,
                    onToggleMute: playbackSettings.toggleMute,
                  ),
                ),
                
                // Texto
                Positioned(
                  bottom: 70,
                  left: 20,
                  child: _VideoCaption(caption: widget.videoPost.caption),
                ),

                // Barra de progreso interactiva (Scrubber)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _CustomVideoScrubber(controller: controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fondo que se muestra mientras el video carga o cuando la sección no está
/// visible: la portada del video (si existe) sobre fondo negro.
class VideoPlaceholder extends StatelessWidget {
  final String? coverUrl;
  final bool showLoader;

  const VideoPlaceholder({super.key, this.coverUrl, this.showLoader = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverUrl != null)
            Image.network(
              coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          if (showLoader)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}

class _VideoCaption extends StatelessWidget {
  final String caption;

  const _VideoCaption({required this.caption});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return IgnorePointer(
      child: SizedBox(
        width: size.width * 0.6,
        child: Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: titleStyle?.copyWith(shadows: [
            const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))
          ]),
        ),
      ),
    );
  }
}

class _CustomVideoScrubber extends StatefulWidget {
  final VideoPlayerController controller;

  const _CustomVideoScrubber({required this.controller});

  @override
  State<_CustomVideoScrubber> createState() => _CustomVideoScrubberState();
}

class _CustomVideoScrubberState extends State<_CustomVideoScrubber> {
  bool _isScrubbing = false;
  double _scrubValue = 0.0;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        if (!widget.controller.value.isInitialized) return const SizedBox.shrink();

        final duration = widget.controller.value.duration;
        final position = widget.controller.value.position;
        final maxVal = duration.inMilliseconds.toDouble();
        final currentVal = _isScrubbing ? _scrubValue : position.inMilliseconds.toDouble();
        
        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Tiempo en pantalla gigante al arrastrar
            if (_isScrubbing)
              Positioned(
                bottom: 40,
                child: Text(
                  '${_formatDuration(Duration(milliseconds: currentVal.toInt()))} / ${_formatDuration(duration)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))],
                  ),
                ),
              ),
            // Slider principal
            SizedBox(
              height: 30, // Área táctil amplia
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: _isScrubbing ? 6 : 3,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: _isScrubbing ? 8 : 0),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white38,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white.withValues(alpha: 0.2),
                ),
                child: Slider(
                  min: 0,
                  max: maxVal > 0 ? maxVal : 1.0,
                  value: currentVal.clamp(0.0, maxVal > 0 ? maxVal : 1.0),
                  onChangeStart: (val) {
                    setState(() {
                      _isScrubbing = true;
                      _scrubValue = val;
                    });
                  },
                  onChanged: (val) {
                    setState(() {
                      _scrubValue = val;
                    });
                  },
                  onChangeEnd: (val) {
                    setState(() {
                      _isScrubbing = false;
                    });
                    widget.controller.seekTo(Duration(milliseconds: val.toInt()));
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

