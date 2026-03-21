import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

// ══════════════════════════════════════════════════════════════════════════════
// SPLASH SCREEN — plays an MP4 video animation on startup
// ══════════════════════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  /// The screen to push after the splash completes
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _error = false;
  bool _navigating = false;
  bool _showSkip = false;

  @override
  void initState() {
    super.initState();

    // Force status bar transparent
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _initializeVideo();
    
    // Show skip button after 4 seconds as a safety measure
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && !_navigating) setState(() => _showSkip = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache the brand logo while the video is playing
    precacheImage(const AssetImage('assets/images/mrwater_logo.png'), context);
  }

  Future<void> _initializeVideo() async {
    debugPrint('Initializing splash video...');
    final startTime = DateTime.now();
    _controller = VideoPlayerController.asset('assets/videos/splash_video.mp4');

    try {
      await _controller.initialize();
      await _controller.setVolume(0.0); // Mute for better auto-play compatibility
      await _controller.setLooping(false);
      
      if (mounted) setState(() {});
      
      final dur = _controller.value.duration;
      debugPrint('Video initialized. Duration: $dur');
      
      if (dur == Duration.zero) {
        throw Exception('Video has zero duration');
      }
      
      // Small delay to ensure the UI has rendered the initialized state
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _controller.play();
      debugPrint('Video started playing.');

      // Listen for video completion
      _controller.addListener(_videoListener);
      
      // Ensure splash shows for at least 3 seconds if the video is too short or if we're on web
      // to avoid a sudden jump after the index.html loading screen.
      final elapsed = DateTime.now().difference(startTime);
      const minSplash = Duration(seconds: 3);
      if (elapsed < minSplash) {
        debugPrint('Waiting for minimum splash duration...');
        await Future.delayed(minSplash - elapsed);
      }
    } catch (e) {
      debugPrint('Error loading splash video: $e');
      if (mounted) setState(() => _error = true);
      // If video fails, wait 2 seconds then navigate anyway
      Future.delayed(const Duration(seconds: 2), _navigateToNext);
    }
  }

  void _videoListener() {
    if (!mounted || _navigating) return;
    
    final pos = _controller.value.position;
    final dur = _controller.value.duration;

    // debugPrint('Video position: $pos / $dur');

    // Only navigate if we have a valid duration and we reached it
    // Some players report pos as slightly greater than dur at the very end
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 100)) {
      debugPrint('Video finished. Navigating...');
      _navigateToNext();
    }
  }

  void _navigateToNext() {
    if (!mounted || _navigating) return;
    _navigating = true;
    
    debugPrint('Executing navigation to next screen.');
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, animation, __, child) => 
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background to prevent blue flashes
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            // Use FittedBox to fill the entire screen (BoxFit.cover)
            // This removes any "background" gaps/bars
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else if (_error)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('💧', style: TextStyle(fontSize: 60)),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            
          // ── Skip Button (Safety Measure) ───────────────────────────────────
          if (_showSkip)
            Positioned(
              bottom: 40,
              right: 20,
              child: TextButton(
                onPressed: _navigateToNext,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Skip ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
