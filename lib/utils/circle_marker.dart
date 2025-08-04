import 'package:flutter/material.dart';

class CircleMarkerWithPin extends StatelessWidget {
  final String text;
  final String? imagePath; // sekarang nullable
  final String? imageUrl; // tambahan
  final Color borderColor;
  final double size;

  const CircleMarkerWithPin({
    super.key,
    required this.text,
    this.imagePath,
    this.imageUrl,
    this.borderColor = Colors.blue,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return imagePath != null
              ? Image.asset(imagePath!, fit: BoxFit.cover)
              : const Icon(Icons.error, size: 50);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else if (imagePath != null) {
      imageWidget = Image.asset(imagePath!, fit: BoxFit.cover);
    } else {
      imageWidget = const Icon(Icons.person, size: 50);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label di atas foto
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: Colors.black,
              shadows: [Shadow(blurRadius: 1, color: Colors.white)],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Foto profil dalam lingkaran
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 4),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
            ],
          ),
          child: ClipOval(child: imageWidget),
        ),
        // Kaki segitiga
        CustomPaint(
          size: const Size(25, 35),
          painter: _MarkerTrianglePainter(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MarkerTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.redAccent;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
