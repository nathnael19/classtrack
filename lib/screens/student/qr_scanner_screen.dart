import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:dio/dio.dart';

class QRScannerScreen extends StatefulWidget {
  final int? sessionId;
  const QRScannerScreen({super.key, this.sessionId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = false;
  Map<String, dynamic>? _sessionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    setState(() => _isLoading = true);
    try {
      final api = ApiService();
      if (widget.sessionId != null) {
        final data = await api.getSession(widget.sessionId!);
        if (mounted) {
          setState(() {
            _sessionData = data;
            _isLoading = false;
          });
        }
      } else {
        // Try to fetch active sessions if none provided
        final active = await api.getActiveSessions();
        if (active.isNotEmpty && mounted) {
          setState(() {
            _sessionData = active[0];
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Error fetching session details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onScanSuccess(barcode.rawValue!);
                }
              }
            },
          ),

          if (_isLoading || _isProcessing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: ClassTrackTheme.primaryBlue,
                      strokeWidth: 3,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Initializing camera...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Dark Overlay with Cutout
          const QRScannerOverlay(
            borderColor: ClassTrackTheme.primaryBlue,
            borderRadius: 32,
            borderLength: 48,
            borderWidth: 8,
            cutOutSize: 280,
          ),

          // Scanning Line
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanningLinePainter(
                    progress: _animation.value,
                    cutOutSize: 280,
                  ),
                  size: const Size(280, 280),
                );
              },
            ),
          ),

          // Header UI
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Close Button
                    _buildIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    // Title
                    Text(
                      'Scan Attendance',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    // Torch Button
                    _buildIconButton(
                      icon: controller.torchEnabled
                          ? Icons.flashlight_on_rounded
                          : Icons.flashlight_off_rounded,
                      onTap: () {
                        setState(() {
                          controller.toggleTorch();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instructions and Status
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Instruction Text
                Text(
                  'Center the QR Code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 56.0),
                  child: Text(
                    "Position the lecturer's QR code within the frame to mark your attendance.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Bottom Status Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF10B981),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _sessionData?['room'] ?? (_isLoading ? 'Locating...' : 'Unspecified Venue'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _sessionData != null 
                                  ? (_sessionData?['course_name'] ?? _sessionData?['topic'] ?? 'ONGOING SESSION')
                                  : (_isLoading ? 'SYNCHRONIZING...' : 'NO ACTIVE SESSION'),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: _sessionData != null ? const Color(0xFF10B981) : Colors.amberAccent,
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Padding for Nav Bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Future<void> _onScanSuccess(String code) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final api = ApiService();

      // The QR encodes a JSON payload: {"s": sessionId, "t": "HMACTOKEN", "ts": timestamp}
      // Parse the payload and extract the token and session ID.
      String token;
      int? idToMark;

      try {
        final Map<String, dynamic> payload = jsonDecode(code);
        token = payload['t']?.toString() ?? '';
        if (payload['s'] != null) {
          idToMark = int.tryParse(payload['s'].toString());
        }
      } catch (_) {
        // Fallback: treat the raw value as the token (legacy plain QR)
        token = code;
      }

      if (token.isEmpty) {
        throw Exception('Invalid QR code format.');
      }

      // Prefer: QR payload session ID → widget arg → fetched session
      idToMark ??= widget.sessionId ?? (_sessionData?['id'] as int?);

      if (idToMark == null) {
        throw Exception('No active session identified.');
      }

      // 1. Check Location Services & Permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
      }

      // 2. Fetch Real GPS Coordinates
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      final double currentLat = position.latitude;
      final double currentLng = position.longitude;

      await api.dio.post(
        api.v1('/attendance/mark'),
        data: {
          'session_id': idToMark,
          'qr_code_content': token, // Send only the HMAC token
          'latitude': currentLat,
          'longitude': currentLng,
        },
      );

      controller.stop();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance Recorded Successfully!'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      debugPrint('Attendance Marking Error: $e');
      String errorMsg = 'Failed to process attendance';
      if (e is DioException) {
        errorMsg = e.response?.data['detail']?.toString() ?? errorMsg;
      } else if (e is Exception) {
        errorMsg = e.toString().replaceFirst('Exception: ', '');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }
}

class QRScannerOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlay({
    super.key,
    required this.borderColor,
    this.borderWidth = 8,
    this.borderRadius = 32,
    this.borderLength = 48,
    this.cutOutSize = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: cutOutSize,
                  width: cutOutSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Border Corners
        Center(
          child: SizedBox(
            height: cutOutSize,
            width: cutOutSize,
            child: CustomPaint(
              painter: BorderPainter(
                color: borderColor,
                width: borderWidth,
                radius: borderRadius,
                length: borderLength,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double radius;
  final double length;

  BorderPainter({
    required this.color,
    required this.width,
    required this.radius,
    required this.length,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double l = length;
    final double r = radius;

    // Top Left
    final path1 = Path()
      ..moveTo(0, l)
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(l, 0);

    // Top Right
    final path2 = Path()
      ..moveTo(size.width - l, 0)
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, l);

    // Bottom Right
    final path3 = Path()
      ..moveTo(size.width, size.height - l)
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(
        Offset(size.width - r, size.height),
        radius: Radius.circular(r),
      )
      ..lineTo(size.width - l, size.height);

    // Bottom Left
    final path4 = Path()
      ..moveTo(l, size.height)
      ..lineTo(r, size.height)
      ..arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r))
      ..lineTo(0, size.height - l);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanningLinePainter extends CustomPainter {
  final double progress;
  final double cutOutSize;

  ScanningLinePainter({required this.progress, required this.cutOutSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ClassTrackTheme.primaryBlue
      ..strokeWidth = 3;

    final double y = progress * size.height;

    // Draw horizontal line
    canvas.drawLine(Offset(20, y), Offset(size.width - 20, y), paint);

    // Draw shadow/glow for the line
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ClassTrackTheme.primaryBlue.withValues(alpha: 0),
          ClassTrackTheme.primaryBlue.withValues(alpha: 0.4),
          ClassTrackTheme.primaryBlue.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 30, size.width, 60));

    canvas.drawRect(
      Rect.fromLTWH(20, y - 30, size.width - 40, 60),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanningLinePainter oldDelegate) => true;
}
