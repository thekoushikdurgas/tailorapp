import 'package:flutter/material.dart';
import 'dart:math' as math;

class DrawingLayer {
  final String id;
  final String name;
  final List<DrawingStroke> strokes;
  bool isVisible;
  double opacity;
  BlendMode blendMode;

  DrawingLayer({
    required this.id,
    required this.name,
    this.strokes = const [],
    this.isVisible = true,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
  });

  DrawingLayer copyWith({
    String? id,
    String? name,
    List<DrawingStroke>? strokes,
    bool? isVisible,
    double? opacity,
    BlendMode? blendMode,
  }) {
    return DrawingLayer(
      id: id ?? this.id,
      name: name ?? this.name,
      strokes: strokes ?? List.from(this.strokes),
      isVisible: isVisible ?? this.isVisible,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
    );
  }
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String tool;
  final double opacity;
  final BlendMode blendMode;

  const DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
  });
}

class DesignCanvasPainter extends CustomPainter {
  final String garmentType;
  final Color selectedColor;
  final String selectedFabric;
  final String selectedPattern;
  final List<Offset> designPoints;
  final double brushSize;
  final String selectedTool;
  final List<DrawingLayer> layers;
  final double zoom;
  final Offset panOffset;
  final bool showGrid;
  final bool showSymmetryGuide;
  final Map<String, dynamic> canvasSettings;

  DesignCanvasPainter({
    required this.garmentType,
    required this.selectedColor,
    required this.selectedFabric,
    required this.selectedPattern,
    required this.designPoints,
    this.brushSize = 3.0,
    this.selectedTool = 'pen',
    this.layers = const [],
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.showGrid = false,
    this.showSymmetryGuide = false,
    this.canvasSettings = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Apply zoom and pan transformations
    canvas.save();
    canvas.translate(panOffset.dx, panOffset.dy);
    canvas.scale(zoom);

    // Draw background
    _drawBackground(canvas, size);

    // Draw grid if enabled
    if (showGrid) {
      _drawAdvancedGrid(canvas, size);
    }

    // Draw garment silhouette with enhanced details
    _drawEnhancedGarmentSilhouette(canvas, size);

    // Draw fabric texture
    _drawFabricTexture(canvas, size);

    // Draw enhanced patterns
    if (selectedPattern != 'Solid') {
      _drawEnhancedPattern(canvas, size);
    }

    // Draw symmetry guide
    if (showSymmetryGuide) {
      _drawSymmetryGuide(canvas, size);
    }

    // Draw layers
    _drawLayers(canvas, size);

    // Draw current stroke (legacy support)
    if (designPoints.isNotEmpty) {
      _drawUserStrokes(canvas);
    }

    // Draw garment construction details
    _drawConstructionDetails(canvas, size);

    // Restore canvas transformations
    canvas.restore();
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }

  void _drawAdvancedGrid(Canvas canvas, Size size) {
    final majorGridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.8;

    final minorGridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.4;

    const majorSpacing = 50.0;
    const minorSpacing = 10.0;

    // Minor grid
    for (double x = 0; x < size.width; x += minorSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        minorGridPaint,
      );
    }

    for (double y = 0; y < size.height; y += minorSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        minorGridPaint,
      );
    }

    // Major grid
    for (double x = 0; x < size.width; x += majorSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        majorGridPaint,
      );
    }

    for (double y = 0; y < size.height; y += majorSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        majorGridPaint,
      );
    }
  }

  void _drawEnhancedGarmentSilhouette(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final silhouettePaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final detailPaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    switch (garmentType) {
      case 'shirt':
        _drawEnhancedShirt(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
      case 'dress':
        _drawEnhancedDress(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
      case 'suit':
        _drawEnhancedSuit(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
      case 'jacket':
        _drawEnhancedJacket(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
      case 'trousers':
        _drawEnhancedTrousers(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
      case 'skirt':
        _drawEnhancedSkirt(canvas, centerX, centerY, silhouettePaint,
            outlinePaint, detailPaint);
        break;
    }
  }

  void _drawEnhancedShirt(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    final path = Path();

    // Enhanced shirt body with curves
    path.moveTo(centerX - 80, centerY - 120); // Left shoulder
    path.quadraticBezierTo(centerX - 105, centerY - 85, centerX - 100,
        centerY - 80); // Left armpit curve
    path.lineTo(centerX - 85, centerY + 70); // Left side
    path.quadraticBezierTo(centerX - 80, centerY + 85, centerX - 70,
        centerY + 85); // Left hem curve
    path.lineTo(centerX + 70, centerY + 85); // Bottom hem
    path.quadraticBezierTo(centerX + 80, centerY + 85, centerX + 85,
        centerY + 70); // Right hem curve
    path.lineTo(centerX + 100, centerY - 80); // Right side
    path.quadraticBezierTo(centerX + 105, centerY - 85, centerX + 80,
        centerY - 120); // Right armpit curve
    path.lineTo(centerX + 45, centerY - 135); // Right neck
    path.quadraticBezierTo(
        centerX + 20, centerY - 145, centerX, centerY - 145); // Neck curve
    path.quadraticBezierTo(centerX - 20, centerY - 145, centerX - 45,
        centerY - 135); // Left neck curve
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Enhanced collar with depth
    _drawShirtCollar(canvas, centerX, centerY, detailPaint);

    // Enhanced sleeves with proper curves
    _drawEnhancedSleeves(canvas, centerX, centerY, fillPaint, outlinePaint);

    // Add shirt details
    _drawShirtDetails(canvas, centerX, centerY, detailPaint);
  }

  void _drawShirtCollar(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    final collarPath = Path();
    collarPath.moveTo(centerX - 35, centerY - 135);
    collarPath.quadraticBezierTo(
        centerX - 25, centerY - 125, centerX - 15, centerY - 120);
    collarPath.lineTo(centerX + 15, centerY - 120);
    collarPath.quadraticBezierTo(
        centerX + 25, centerY - 125, centerX + 35, centerY - 135);

    canvas.drawPath(collarPath, paint);

    // Collar fold line
    canvas.drawLine(
      Offset(centerX - 25, centerY - 130),
      Offset(centerX + 25, centerY - 130),
      paint,
    );
  }

  void _drawShirtDetails(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    // Button placket
    for (int i = 0; i < 6; i++) {
      final buttonY = centerY - 120 + (i * 25);
      canvas.drawCircle(Offset(centerX, buttonY), 3, paint);
    }

    // Pocket
    final pocketPath = Path();
    pocketPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - 40, centerY - 60),
        width: 30,
        height: 25,
      ),
      const Radius.circular(3),
    ));
    canvas.drawPath(pocketPath, paint);
  }

  void _drawEnhancedSleeves(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint) {
    // Left sleeve with proper volume
    final leftSleevePath = Path();
    leftSleevePath.moveTo(centerX - 80, centerY - 120);
    leftSleevePath.quadraticBezierTo(
        centerX - 140, centerY - 105, centerX - 130, centerY - 85);
    leftSleevePath.quadraticBezierTo(
        centerX - 125, centerY - 60, centerX - 115, centerY - 65);
    leftSleevePath.lineTo(centerX - 100, centerY - 80);
    leftSleevePath.close();

    // Right sleeve
    final rightSleevePath = Path();
    rightSleevePath.moveTo(centerX + 80, centerY - 120);
    rightSleevePath.quadraticBezierTo(
        centerX + 140, centerY - 105, centerX + 130, centerY - 85);
    rightSleevePath.quadraticBezierTo(
        centerX + 125, centerY - 60, centerX + 115, centerY - 65);
    rightSleevePath.lineTo(centerX + 100, centerY - 80);
    rightSleevePath.close();

    canvas.drawPath(leftSleevePath, fillPaint);
    canvas.drawPath(rightSleevePath, fillPaint);
    canvas.drawPath(leftSleevePath, outlinePaint);
    canvas.drawPath(rightSleevePath, outlinePaint);
  }

  void _drawEnhancedDress(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    final path = Path();

    // Enhanced dress silhouette with curves
    path.moveTo(centerX - 65, centerY - 125); // Left shoulder
    path.quadraticBezierTo(
        centerX - 85, centerY - 85, centerX - 80, centerY - 80); // Left armpit
    path.quadraticBezierTo(
        centerX - 75, centerY - 20, centerX - 70, centerY); // Waist curve
    path.quadraticBezierTo(
        centerX - 90, centerY + 80, centerX - 130, centerY + 160); // Left hem
    path.lineTo(centerX + 130, centerY + 160); // Bottom hem
    path.quadraticBezierTo(
        centerX + 90, centerY + 80, centerX + 70, centerY); // Right waist
    path.quadraticBezierTo(
        centerX + 75, centerY - 20, centerX + 80, centerY - 80); // Right side
    path.quadraticBezierTo(centerX + 85, centerY - 85, centerX + 65,
        centerY - 125); // Right armpit
    path.lineTo(centerX + 35, centerY - 140); // Right neck
    path.quadraticBezierTo(
        centerX, centerY - 150, centerX - 35, centerY - 140); // Neck curve
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Waistline
    canvas.drawLine(
      Offset(centerX - 70, centerY),
      Offset(centerX + 70, centerY),
      detailPaint,
    );

    // Dress details
    _drawDressDetails(canvas, centerX, centerY, detailPaint);
  }

  void _drawDressDetails(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    // Neckline detail
    final necklinePath = Path();
    necklinePath.moveTo(centerX - 25, centerY - 140);
    necklinePath.quadraticBezierTo(
        centerX, centerY - 135, centerX + 25, centerY - 140);
    canvas.drawPath(necklinePath, paint);
  }

  // Additional enhanced garment methods would go here...
  void _drawEnhancedSuit(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    // Enhanced suit implementation
    _drawEnhancedJacket(
        canvas, centerX, centerY - 40, fillPaint, outlinePaint, detailPaint);
    _drawEnhancedTrousers(
        canvas, centerX, centerY + 100, fillPaint, outlinePaint, detailPaint);
  }

  void _drawEnhancedJacket(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    // Enhanced jacket with lapels and construction details
    final path = Path();

    path.moveTo(centerX - 95, centerY - 125);
    path.quadraticBezierTo(
        centerX - 120, centerY - 85, centerX - 115, centerY - 80);
    path.lineTo(centerX - 100, centerY + 65);
    path.lineTo(centerX + 100, centerY + 65);
    path.lineTo(centerX + 115, centerY - 80);
    path.quadraticBezierTo(
        centerX + 120, centerY - 85, centerX + 95, centerY - 125);
    path.lineTo(centerX + 55, centerY - 145);
    path.quadraticBezierTo(centerX, centerY - 150, centerX - 55, centerY - 145);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Lapels with detail
    _drawJacketLapels(canvas, centerX, centerY, detailPaint);
    _drawJacketButtons(canvas, centerX, centerY, detailPaint);
  }

  void _drawJacketLapels(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    // Left lapel
    final leftLapel = Path();
    leftLapel.moveTo(centerX - 55, centerY - 145);
    leftLapel.quadraticBezierTo(
        centerX - 45, centerY - 120, centerX - 35, centerY - 100);
    leftLapel.lineTo(centerX - 15, centerY - 110);
    leftLapel.close();

    // Right lapel
    final rightLapel = Path();
    rightLapel.moveTo(centerX + 55, centerY - 145);
    rightLapel.quadraticBezierTo(
        centerX + 45, centerY - 120, centerX + 35, centerY - 100);
    rightLapel.lineTo(centerX + 15, centerY - 110);
    rightLapel.close();

    canvas.drawPath(leftLapel, paint);
    canvas.drawPath(rightLapel, paint);
  }

  void _drawJacketButtons(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    // Double-breasted buttons
    for (int i = 0; i < 3; i++) {
      final buttonY = centerY - 90 + (i * 30);
      canvas.drawCircle(Offset(centerX - 20, buttonY), 4, paint);
      canvas.drawCircle(Offset(centerX + 20, buttonY), 4, paint);
    }
  }

  void _drawEnhancedTrousers(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    // Enhanced trousers with realistic proportions
    final leftLeg = Path();
    leftLeg.moveTo(centerX - 65, centerY - 45);
    leftLeg.quadraticBezierTo(
        centerX - 45, centerY + 20, centerX - 40, centerY + 80);
    leftLeg.lineTo(centerX - 35, centerY + 130);
    leftLeg.lineTo(centerX - 15, centerY + 130);
    leftLeg.lineTo(centerX - 5, centerY + 80);
    leftLeg.quadraticBezierTo(centerX, centerY + 20, centerX, centerY - 45);
    leftLeg.close();

    final rightLeg = Path();
    rightLeg.moveTo(centerX, centerY - 45);
    rightLeg.quadraticBezierTo(
        centerX, centerY + 20, centerX + 5, centerY + 80);
    rightLeg.lineTo(centerX + 15, centerY + 130);
    rightLeg.lineTo(centerX + 35, centerY + 130);
    rightLeg.lineTo(centerX + 40, centerY + 80);
    rightLeg.quadraticBezierTo(
        centerX + 45, centerY + 20, centerX + 65, centerY - 45);
    rightLeg.close();

    canvas.drawPath(leftLeg, fillPaint);
    canvas.drawPath(rightLeg, fillPaint);
    canvas.drawPath(leftLeg, outlinePaint);
    canvas.drawPath(rightLeg, outlinePaint);

    // Trouser details
    _drawTrouserDetails(canvas, centerX, centerY, detailPaint);
  }

  void _drawTrouserDetails(
      Canvas canvas, double centerX, double centerY, Paint paint) {
    // Waistband
    canvas.drawLine(
      Offset(centerX - 65, centerY - 45),
      Offset(centerX + 65, centerY - 45),
      paint,
    );

    // Creases
    canvas.drawLine(
      Offset(centerX - 22, centerY - 30),
      Offset(centerX - 25, centerY + 120),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + 22, centerY - 30),
      Offset(centerX + 25, centerY + 120),
      paint,
    );
  }

  void _drawEnhancedSkirt(Canvas canvas, double centerX, double centerY,
      Paint fillPaint, Paint outlinePaint, Paint detailPaint) {
    final path = Path();

    // Enhanced skirt with realistic curves
    path.moveTo(centerX - 75, centerY - 45); // Left waist
    path.quadraticBezierTo(
        centerX - 85, centerY + 20, centerX - 110, centerY + 85); // Left curve
    path.lineTo(centerX + 110, centerY + 85); // Bottom hem
    path.quadraticBezierTo(
        centerX + 85, centerY + 20, centerX + 75, centerY - 45); // Right curve
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Waistband
    canvas.drawLine(
      Offset(centerX - 75, centerY - 45),
      Offset(centerX + 75, centerY - 45),
      detailPaint,
    );
  }

  void _drawFabricTexture(Canvas canvas, Size size) {
    final texturePaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    switch (selectedFabric.toLowerCase()) {
      case 'denim':
        _drawDenimTexture(canvas, size, texturePaint);
        break;
      case 'silk':
        _drawSilkTexture(canvas, size, texturePaint);
        break;
      case 'wool':
        _drawWoolTexture(canvas, size, texturePaint);
        break;
      case 'linen':
        _drawLinenTexture(canvas, size, texturePaint);
        break;
      case 'velvet':
        _drawVelvetTexture(canvas, size, texturePaint);
        break;
    }
  }

  void _drawDenimTexture(Canvas canvas, Size size, Paint paint) {
    // Create crosshatch pattern for denim
    const spacing = 4.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x ~/ spacing + y ~/ spacing) % 2 == 0) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + spacing / 2, y + spacing / 2),
            paint,
          );
        }
      }
    }
  }

  void _drawSilkTexture(Canvas canvas, Size size, Paint paint) {
    // Create smooth wave pattern for silk
    for (double y = 0; y < size.height; y += 8) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 10) {
        path.quadraticBezierTo(x + 5, y + 2, x + 10, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawWoolTexture(Canvas canvas, Size size, Paint paint) {
    // Create fuzzy texture for wool
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < (size.width * size.height / 100).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  void _drawLinenTexture(Canvas canvas, Size size, Paint paint) {
    // Create loose weave pattern for linen
    const spacing = 6.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawVelvetTexture(Canvas canvas, Size size, Paint paint) {
    // Create pile texture for velvet
    final random = math.Random(123);
    paint.strokeWidth = 1.0;
    for (int i = 0; i < (size.width * size.height / 50).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = random.nextDouble() * 3 + 1;
      final angle = random.nextDouble() * math.pi;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * length, y + math.sin(angle) * length),
        paint,
      );
    }
  }

  void _drawEnhancedPattern(Canvas canvas, Size size) {
    final patternPaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    switch (selectedPattern) {
      case 'Stripes':
        _drawEnhancedStripes(canvas, size, patternPaint);
        break;
      case 'Checkered':
        _drawEnhancedCheckered(canvas, size, patternPaint);
        break;
      case 'Polka Dots':
        _drawEnhancedPolkaDots(canvas, size, patternPaint);
        break;
      case 'Houndstooth':
        _drawHoundstooth(canvas, size, patternPaint);
        break;
      case 'Paisley':
        _drawPaisley(canvas, size, patternPaint);
        break;
      case 'Floral':
        _drawFloral(canvas, size, patternPaint);
        break;
    }
  }

  void _drawEnhancedStripes(Canvas canvas, Size size, Paint paint) {
    const spacing = 25.0;
    paint.strokeWidth = 8.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawEnhancedCheckered(Canvas canvas, Size size, Paint paint) {
    const spacing = 35.0;
    paint.style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing * 2) {
      for (double y = 0; y < size.height; y += spacing * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, spacing, spacing),
          paint,
        );
        canvas.drawRect(
          Rect.fromLTWH(x + spacing, y + spacing, spacing, spacing),
          paint,
        );
      }
    }
  }

  void _drawEnhancedPolkaDots(Canvas canvas, Size size, Paint paint) {
    const spacing = 45.0;
    const radius = 12.0;
    paint.style = PaintingStyle.fill;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  void _drawHoundstooth(Canvas canvas, Size size, Paint paint) {
    const spacing = 20.0;
    paint.style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final path = Path();
        path.moveTo(x, y);
        path.lineTo(x + spacing / 2, y);
        path.lineTo(x + spacing, y + spacing / 2);
        path.lineTo(x + spacing, y + spacing);
        path.lineTo(x + spacing / 2, y + spacing);
        path.lineTo(x, y + spacing / 2);
        path.close();

        if ((x ~/ spacing + y ~/ spacing) % 2 == 0) {
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  void _drawPaisley(Canvas canvas, Size size, Paint paint) {
    const spacing = 60.0;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final path = Path();
        path.moveTo(x, y);
        path.quadraticBezierTo(x - 15, y - 10, x - 10, y - 20);
        path.quadraticBezierTo(x + 5, y - 25, x + 15, y - 15);
        path.quadraticBezierTo(x + 20, y, x + 10, y + 10);
        path.quadraticBezierTo(x - 5, y + 15, x, y);

        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawFloral(Canvas canvas, Size size, Paint paint) {
    const spacing = 50.0;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        // Flower petals
        for (int i = 0; i < 5; i++) {
          final angle = (i * 2 * math.pi / 5);
          final petalX = x + math.cos(angle) * 8;
          final petalY = y + math.sin(angle) * 8;

          canvas.drawCircle(Offset(petalX, petalY), 6, paint);
        }

        // Flower center
        canvas.drawCircle(Offset(x, y), 3, paint);
      }
    }
  }

  void _drawSymmetryGuide(Canvas canvas, Size size) {
    final guidePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );
  }

  void _drawLayers(Canvas canvas, Size size) {
    for (final layer in layers) {
      if (!layer.isVisible) continue;

      canvas.saveLayer(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withValues(alpha: layer.opacity),
      );

      for (final stroke in layer.strokes) {
        _drawStroke(canvas, stroke);
      }

      canvas.restore();
    }
  }

  void _drawStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color.withValues(alpha: stroke.opacity)
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = stroke.blendMode;

    // Apply tool-specific modifications
    switch (stroke.tool) {
      case 'pen':
        paint.strokeCap = StrokeCap.round;
        break;
      case 'brush':
        paint.strokeWidth *= 1.5;
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.8);
        break;
      case 'pencil':
        paint.strokeWidth *= 0.8;
        paint.strokeCap = StrokeCap.square;
        break;
      case 'marker':
        paint.strokeWidth *= 2.0;
        paint.color = stroke.color.withValues(alpha: stroke.opacity * 0.7);
        break;
      case 'eraser':
        paint.blendMode = BlendMode.clear;
        break;
    }

    final path = Path();
    path.moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      final point = stroke.points[i];
      if (point.isInfinite) break;

      if (i == 1) {
        path.lineTo(point.dx, point.dy);
      } else {
        final previousPoint = stroke.points[i - 1];
        final controlPoint = Offset(
          (previousPoint.dx + point.dx) / 2,
          (previousPoint.dy + point.dy) / 2,
        );
        path.quadraticBezierTo(
          previousPoint.dx,
          previousPoint.dy,
          controlPoint.dx,
          controlPoint.dy,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawUserStrokes(Canvas canvas) {
    if (designPoints.isEmpty) return;

    final paint = Paint()
      ..color = selectedColor
      ..strokeWidth = brushSize
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _configureToolPaint(paint);

    for (int i = 0; i < designPoints.length - 1; i++) {
      final currentPoint = designPoints[i];
      final nextPoint = designPoints[i + 1];

      if (currentPoint.isInfinite || nextPoint.isInfinite) {
        continue;
      }

      canvas.drawLine(currentPoint, nextPoint, paint);
    }
  }

  void _configureToolPaint(Paint paint) {
    switch (selectedTool) {
      case 'pen':
        paint.strokeCap = StrokeCap.round;
        break;
      case 'brush':
        paint.strokeWidth = brushSize * 1.5;
        paint.color = selectedColor.withValues(alpha: 0.8);
        break;
      case 'pencil':
        paint.strokeWidth = brushSize * 0.8;
        paint.strokeCap = StrokeCap.square;
        break;
      case 'marker':
        paint.strokeWidth = brushSize * 2;
        paint.color = selectedColor.withValues(alpha: 0.7);
        break;
      case 'eraser':
        paint.blendMode = BlendMode.clear;
        paint.strokeWidth = brushSize * 1.5;
        break;
    }
  }

  void _drawConstructionDetails(Canvas canvas, Size size) {
    // Add fabric and pattern labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Fabric label
    textPainter.text = TextSpan(
      text: 'Fabric: $selectedFabric',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height - 50));

    // Pattern label
    textPainter.text = TextSpan(
      text: 'Pattern: $selectedPattern',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height - 35));

    // Garment type label
    textPainter.text = TextSpan(
      text: 'Type: ${garmentType.toUpperCase()}',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height - 20));
  }

  @override
  bool shouldRepaint(DesignCanvasPainter oldDelegate) {
    return oldDelegate.garmentType != garmentType ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.selectedFabric != selectedFabric ||
        oldDelegate.selectedPattern != selectedPattern ||
        oldDelegate.designPoints != designPoints ||
        oldDelegate.brushSize != brushSize ||
        oldDelegate.selectedTool != selectedTool ||
        oldDelegate.layers != layers ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showSymmetryGuide != showSymmetryGuide;
  }
}
