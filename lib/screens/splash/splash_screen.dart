import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isNavigated = false;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/splash_screen/Intario_Splash_Screen.mp4',
    );

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.setVolume(0.0);

      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
        
        // Start playback
        await _controller.play();
        
        // Listen for video completion
        _controller.addListener(_videoListener);
        
        // Remove native white splash only when the first video frame is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            FlutterNativeSplash.remove();
          }
        });
      }
    } catch (e) {
      debugPrint('Splash video error: $e');
      FlutterNativeSplash.remove();
      _finishSplash();
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (_controller.value.position >= _controller.value.duration) {
      _finishSplash();
    }
  }

  void _finishSplash() {
    if (_isNavigated) return;
    _isNavigated = true;
    
    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRITICAL: Set background to WHITE to match the native splash handover
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          // Dark icons for white background
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SizedBox.expand(
          child: _isVideoReady
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.white),
                ),
        ),
      ),
    );
  }
}
