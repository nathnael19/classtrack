import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:classtrack/theme/design_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

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
  }

  @override
  void dispose() {
    controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                debugPrint('Barcode found! ${barcode.rawValue}');
                // TODO: Handle successful scan
                if (barcode.rawValue != null) {
                  _onScanSuccess(barcode.rawValue!);
                }
              }
            },
          ),

          // Dark Overlay with Cutout
          const QRScannerOverlay(
            borderColor: ClassTrackTheme.primaryBlue,
            borderRadius: 24,
            borderLength: 40,
            borderWidth: 6,
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
                  vertical: 16.0,
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
                      'Scan QR Code',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
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
                  'Align QR Code',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    "Position the lecturer's QR code within the frame to mark your attendance.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.7),
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF059669,
                            ).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Science Building - Room 402',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'INSIDE GEOFENCE',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF10B981),
                                  letterSpacing: 0.5,
                                ),
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
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  void _onScanSuccess(String code) {
    // Prevent multiple scans
    controller.stop();

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance Marked for: $code'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );

    // Navigate back
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
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
    this.borderRadius = 24,
    this.borderLength = 40,
    this.cutOutSize = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.5),
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
          child: Container(
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
      ..strokeWidth = 2;

    final double y = progress * size.height;

    // Draw horizontal line
    canvas.drawLine(Offset(16, y), Offset(size.width - 16, y), paint);

    // Draw shadow/glow for the line
    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ClassTrackTheme.primaryBlue.withValues(alpha: 0),
          ClassTrackTheme.primaryBlue.withValues(alpha: 0.5),
          ClassTrackTheme.primaryBlue.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 20, size.width, 40));

    canvas.drawRect(
      Rect.fromLTWH(16, y - 20, size.width - 32, 40),
      shadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanningLinePainter oldDelegate) => true;
}
