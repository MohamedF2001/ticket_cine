/*
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../seat/seat_layout.dart';

/// Teinte d'une couleur de fauteuil selon la distance et le fondu. Les pièces en
/// plastique (accoudoirs) gardent leur couleur même sur le siège sélectionné.
typedef _Tone = Color Function(Color base, {bool plastic});

/// Vecteur 3D minimal. Repère : x vers la droite, y vers le haut, z vers le
/// fond de la salle (l'écran est dans le plan z = 0).
class _V3 {
  const _V3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);

  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;

  _V3 cross(_V3 o) =>
      _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
}

/// Point projeté à l'écran, avec sa profondeur dans le repère de la caméra.
class _Pt {
  const _Pt(this.x, this.y, this.depth);

  final double x;
  final double y;
  final double depth;
}

/// Caméra à sténopé : position, lacet (yaw) et tangage (pitch).
class _Camera {
  _Camera({
    required this.pos,
    required double yaw,
    required double pitch,
    required this.focal,
    required this.cx,
    required this.cy,
  }) {
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    fwd = _V3(sinYaw * cosPitch, sinPitch, -cosYaw * cosPitch);
    right = _V3(cosYaw, 0, sinYaw);
    up = right.cross(fwd);
  }

  static const double near = 0.12;

  final _V3 pos;
  final double focal;
  final double cx;
  final double cy;

  late final _V3 fwd;
  late final _V3 right;
  late final _V3 up;

  /// Retourne null si le point est derrière la caméra.
  _Pt? project(_V3 p) {
    final d = p - pos;
    final depth = d.dot(fwd);
    if (depth < near) return null;
    return _Pt(
      cx + focal * d.dot(right) / depth,
      cy - focal * d.dot(up) / depth,
      depth,
    );
  }
}

/// Dessine la salle vue depuis un siège.
///
/// [animation] va de 0 (caméra en hauteur derrière le siège) à 1 (caméra posée
/// à hauteur des yeux dans le siège, regard vers l'écran). Le peintre se
/// redessine à chaque valeur de l'animation, sans reconstruire de widget.
class Cinema3DPainter extends CustomPainter {
  Cinema3DPainter({
    required this.animation,
    required this.row,
    required this.col,
    this.screenImage,
  }) : super(repaint: animation);

  final Animation<double> animation;

  /// Rangée (0 = A) et numéro (à partir de 1) du siège sélectionné.
  final int row;
  final int col;

  /// Image projetée sur l'écran (affiche ou fond du film). Facultative.
  final ui.Image? screenImage;

  // Fauteuils rouges, vus de dos et éclairés par l'écran.
  static const _ChairPalette _normalPalette = _ChairPalette(
    flat: Color(0xFF2B0508),
    band: Color(0xFF450A0E),
    rim: Color(0xFF6A0E13),
    flatTop: Color(0xFF9B1D21),
    faceTop: Color(0xFF5E0C11),
    faceMid: Color(0xFF3B080B),
    faceBottom: Color(0xFF150203),
    capDark: Color(0xFF3C080C),
    capLight: Color(0xFFC02A2F),
    bevel: Color(0xFFD2383D),
    cushion: Color(0xFF3D0A0E),
  );

  // Siège sélectionné : vert menthe.
  static const _ChairPalette _selectedPalette = _ChairPalette(
    flat: Color(0xFF5CC389),
    band: Color(0xFF7ADEA3),
    rim: Color(0xFF93EBB5),
    flatTop: Color(0xFFB9F6D1),
    faceTop: Color(0xFF9BEDBC),
    faceMid: Color(0xFF6ED197),
    faceBottom: Color(0xFF2F8A5B),
    capDark: Color(0xFF3E9D6A),
    capLight: Color(0xFFC9FADF),
    bevel: Color(0xFFE1FFEF),
    cushion: Color(0xFF4FB27C),
  );

  // Accoudoirs (rouge sombre, entre les sièges).
  static const Color _armrestTop = Color(0xFF5A2A30);
  static const Color _armrestEnd = Color(0xFF2A1115);

  static const Color _riser = Color(0xFF050304);
  static const Color _background = Color(0xFF050406);

  static const double _halfWidth = 0.285;
  static const double _backBottom = 0.40;
  static const double _backTop = 1.05;
  static const double _backThickness = 0.12;
  static const double _horizontalFov = 60 * math.pi / 180;
  static const double _topRadius = 0.22;
  static const double _bottomRadius = 0.06;

  static final Expando<ui.ImageShader> _shaders = Expando<ui.ImageShader>();

  /// Contour du dossier d'un fauteuil (coins supérieurs et inférieurs arrondis), en mètres,
  /// relatif au centre du siège (x) et au sol de la rangée (y).
  static final List<Offset> _faceOutline = _buildOutline(
    _halfWidth,
    _backBottom,
    _backTop,
    _topRadius,
    bottomRadius: _bottomRadius,
  );

  /// Contour réduit, utilisé pour la couture du capitonnage.
  static final List<Offset> _insetOutline = _buildOutline(
    _halfWidth - 0.045,
    _backBottom + 0.09,
    _backTop - 0.045,
    0.16,
    bottomRadius: 0.04,
  );

  static List<Offset> _buildOutline(
    double halfWidth,
    double bottom,
    double top,
    double topRadius, {
    double bottomRadius = 0.06,
  }) {
    const steps = 4;
    final pts = <Offset>[];

    // Bottom-left corner
    for (var i = 0; i <= steps; i++) {
      final a = 1.5 * math.pi - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          -halfWidth + bottomRadius + bottomRadius * math.cos(a),
          bottom + bottomRadius + bottomRadius * math.sin(a),
        ),
      );
    }

    // Left side up to top-left corner start
    pts.add(Offset(-halfWidth, top - topRadius));

    // Top-left corner
    for (var i = 0; i <= steps; i++) {
      final a = math.pi - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          -halfWidth + topRadius + topRadius * math.cos(a),
          top - topRadius + topRadius * math.sin(a),
        ),
      );
    }

    // Top-right corner
    for (var i = 0; i <= steps; i++) {
      final a = math.pi / 2 - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          halfWidth - topRadius + topRadius * math.cos(a),
          top - topRadius + topRadius * math.sin(a),
        ),
      );
    }

    // Right side down to bottom-right corner start
    pts.add(Offset(halfWidth, bottom + bottomRadius));

    // Bottom-right corner
    for (var i = 0; i <= steps; i++) {
      final a = 0.0 - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          halfWidth - bottomRadius + bottomRadius * math.cos(a),
          bottom + bottomRadius + bottomRadius * math.sin(a),
        ),
      );
    }

    return pts;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = Curves.easeInOutCubic.transform(
      animation.value.clamp(0.0, 1.0).toDouble(),
    );

    canvas.drawRect(Offset.zero & size, Paint()..color = _background);

    final cam = _cameraFor(size, t);
    final roll = _lerp(-0.12, 0.0, t);

    canvas.save();
    canvas.translate(cam.cx, cam.cy);
    canvas.rotate(roll);
    canvas.translate(-cam.cx, -cam.cy);

    _paintScreen(canvas, cam);
    for (var r = 0; r < CinemaLayout.rows; r++) {
      _paintRow(canvas, size, cam, r);
    }

    canvas.restore();

    // Halo vert au bas de l'écran une fois installé dans le siège.
    if (t > 0.6) {
      final alpha = ((t - 0.6) / 0.4) * 0.16;
      final center = Offset(size.width / 2, size.height);
      final rect = Rect.fromCircle(center: center, radius: size.width * 0.8);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(center, size.width * 0.8, [
            const Color(0xFF7ADEA3).withAlpha((alpha * 255).round()),
            const Color(0x007ADEA3),
          ]),
      );
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  _Camera _cameraFor(Size size, double t) {
    final x = CinemaLayout.seatX(col);
    final z = CinemaLayout.rowDistance(row);
    final floor = CinemaLayout.rowFloor(row);

    // Arrivée : yeux dans le siège, regard dirigé vers le centre de l'écran.
    final endPos = _V3(x, floor + 1.15, z + 0.05);
    final endYaw = math.atan2(-x, z);
    const endPitch = 0.07;

    // Départ : en hauteur, derrière le siège, regard vers le bas.
    final startPos = _V3(x * 0.55, floor + 3.0, z + 3.2);
    final startYaw = endYaw * 0.35;
    const startPitch = -0.30;

    return _Camera(
      pos: _V3(
        _lerp(startPos.x, endPos.x, t),
        _lerp(startPos.y, endPos.y, t),
        _lerp(startPos.z, endPos.z, t),
      ),
      yaw: _lerp(startYaw, endYaw, t),
      pitch: _lerp(startPitch, endPitch, t),
      focal: size.width / 2 / math.tan(_horizontalFov / 2),
      cx: size.width / 2,
      cy: size.height * 0.40,
    );
  }

  List<_Pt>? _projectAll(_Camera cam, Iterable<_V3> points) {
    final out = <_Pt>[];
    for (final p in points) {
      final q = cam.project(p);
      if (q == null) return null;
      out.add(q);
    }
    return out;
  }

  Path _pathOf(List<_Pt> pts) {
    final path = Path()..moveTo(pts.first.x, pts.first.y);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].x, pts[i].y);
    }
    return path..close();
  }

  // ---------------------------------------------------------------------------
  // Écran
  // ---------------------------------------------------------------------------

  void _paintScreen(Canvas canvas, _Camera cam) {
    const gx = 10;
    const gy = 6;
    final halfW = CinemaLayout.screenWidth / 2;
    final bottom = CinemaLayout.screenBottom;
    final height = CinemaLayout.screenHeight;

    final grid = <_Pt>[];
    for (var j = 0; j <= gy; j++) {
      for (var i = 0; i <= gx; i++) {
        final u = i / gx;
        final v = j / gy;
        final p = cam.project(
          _V3(-halfW + 2 * halfW * u, bottom + height * (1 - v), 0),
        );
        if (p == null) return;
        grid.add(p);
      }
    }

    final topLeft = grid[0];
    final topRight = grid[gx];
    final bottomLeft = grid[gy * (gx + 1)];
    final bottomRight = grid[grid.length - 1];

    // Lueur diffuse autour de l'écran.
    final glowCenter = Offset(
      (topLeft.x + topRight.x + bottomLeft.x + bottomRight.x) / 4,
      (topLeft.y + topRight.y + bottomLeft.y + bottomRight.y) / 4,
    );
    final glowRadius = math.max(
      (topRight.x - topLeft.x).abs(),
      (bottomRight.x - bottomLeft.x).abs(),
    );
    if (glowRadius > 1) {
      canvas.drawCircle(
        glowCenter,
        glowRadius,
        Paint()
          ..shader = ui.Gradient.radial(glowCenter, glowRadius, [
            const Color(0x30D8C2AE),
            const Color(0x00D8C2AE),
          ]),
      );
    }

    final image = screenImage;
    if (image == null) {
      final quad = Path()
        ..moveTo(topLeft.x, topLeft.y)
        ..lineTo(topRight.x, topRight.y)
        ..lineTo(bottomRight.x, bottomRight.y)
        ..lineTo(bottomLeft.x, bottomLeft.y)
        ..close();
      canvas.drawPath(
        quad,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset((topLeft.x + topRight.x) / 2, topLeft.y),
            Offset((bottomLeft.x + bottomRight.x) / 2, bottomLeft.y),
            const [Color(0xFFD1BEB0), Color(0xFF6B5647)],
          ),
      );
      return;
    }

    // Recadrage centré de l'image au format de l'écran.
    final targetAspect = CinemaLayout.screenWidth / CinemaLayout.screenHeight;
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    var srcW = imgW;
    var srcH = imgH;
    if (imgW / imgH > targetAspect) {
      srcW = imgH * targetAspect;
    } else {
      srcH = imgW / targetAspect;
    }
    final srcLeft = (imgW - srcW) / 2;
    final srcTop = (imgH - srcH) / 2;

    final positions = Float32List(grid.length * 2);
    final texCoords = Float32List(grid.length * 2);
    for (var j = 0; j <= gy; j++) {
      for (var i = 0; i <= gx; i++) {
        final index = j * (gx + 1) + i;
        positions[index * 2] = grid[index].x;
        positions[index * 2 + 1] = grid[index].y;
        texCoords[index * 2] = srcLeft + srcW * (i / gx);
        texCoords[index * 2 + 1] = srcTop + srcH * (j / gy);
      }
    }
    final indices = Uint16List(gx * gy * 6);
    var k = 0;
    for (var j = 0; j < gy; j++) {
      for (var i = 0; i < gx; i++) {
        final a = j * (gx + 1) + i;
        final b = a + 1;
        final c = a + (gx + 1);
        final d = c + 1;
        indices[k++] = a;
        indices[k++] = b;
        indices[k++] = c;
        indices[k++] = b;
        indices[k++] = d;
        indices[k++] = c;
      }
    }

    final shader = _shaders[image] ??= ui.ImageShader(
      image,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Float64List.fromList(const [
        1, 0, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1, //
      ]),
      filterQuality: ui.FilterQuality.medium,
    );
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: texCoords,
      indices: indices,
    );
    canvas.drawVertices(
      vertices,
      ui.BlendMode.srcOver,
      Paint()..shader = shader,
    );
  }

  // ---------------------------------------------------------------------------
  // Rangées et fauteuils
  // ---------------------------------------------------------------------------

  void _paintRow(Canvas canvas, Size size, _Camera cam, int r) {
    final z = CinemaLayout.rowDistance(r);
    final floor = CinemaLayout.rowFloor(r);

    // Contremarche pleine : masque ce qui se trouve derrière la rangée.
    final riser = _projectAll(cam, [
      _V3(-9, floor - 0.3, z),
      _V3(9, floor - 0.3, z),
      _V3(9, floor + _backBottom, z),
      _V3(-9, floor + _backBottom, z),
    ]);
    if (riser != null) {
      canvas.drawPath(_pathOf(riser), Paint()..color = _riser);
    }

    for (var c = 1; c <= CinemaLayout.columns; c++) {
      final selected = r == row && c == col;
      _paintChair(canvas, size, cam, r, c, selected);
    }
  }

  void _paintChair(
    Canvas canvas,
    Size size,
    _Camera cam,
    int r,
    int c,
    bool selected,
  ) {
    final x = CinemaLayout.seatX(c);
    final z = CinemaLayout.rowDistance(r);
    final floor = CinemaLayout.rowFloor(r);

    final face = _projectAll(
      cam,
      _faceOutline.map((p) => _V3(x + p.dx, floor + p.dy, z)),
    );
    if (face == null) return;

    // Élimination des fauteuils entièrement hors du cadre.
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;
    for (final p in face) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    const margin = 80.0;
    if (maxX < -margin ||
        minX > size.width + margin ||
        maxY < -margin ||
        minY > size.height + margin) {
      return;
    }

    // Fondu des fauteuils tout proches de la caméra (fin du vol).
    final fade = math.min(1.0, math.max(0.0, (face.first.depth - 0.12) / 0.35));
    if (fade < 0.02) return;

    // Assombrissement avec la distance.
    final fog = math.min(0.55, math.max(0.0, (face.first.depth - 2.0) / 16.0));
    Color tone(Color base, {bool plastic = false}) {
      final keep = selected && !plastic;
      final dimmed = keep
          ? base
          : (Color.lerp(base, const Color(0xFF000000), fog) ?? base);
      return dimmed.withAlpha((255 * fade).round());
    }

    final palette = selected ? _selectedPalette : _normalPalette;

    // Niveau de détail selon la taille du fauteuil à l'écran :
    // 2 = dégradés, courbure, coutures, dessus arrondi (fauteuils proches)
    // 1 = faces unies + accoudoirs et assise
    // 0 = faces unies (fauteuils lointains)
    final width = maxX - minX;
    final detail = width > 70 ? 2 : (width > 28 ? 1 : 0);

    if (detail >= 1) {
      _paintArmrest(canvas, cam, x + _halfWidth + 0.03, floor, z, tone);
      final startsBlock =
          c == 1 ||
          x - CinemaLayout.seatX(c - 1) > CinemaLayout.seatPitch + 0.01;
      if (startsBlock) {
        _paintArmrest(canvas, cam, x - _halfWidth - 0.03, floor, z, tone);
      }
      _paintCushion(canvas, cam, x, floor, z, palette, tone);
    }

    if (detail == 2) {
      _paintDetailedBack(
        canvas,
        cam,
        face,
        x,
        floor,
        z,
        palette,
        tone,
        fade,
        width,
      );
      _paintRoundedCap(canvas, cam, x, floor, z, palette, tone);
    } else {
      _paintFlatBack(canvas, cam, face, x, floor, z, palette, tone);
    }
  }

  /// Dossier simple (fauteuils lointains) : trois aplats et un dessus plat.
  void _paintFlatBack(
    Canvas canvas,
    _Camera cam,
    List<_Pt> face,
    double x,
    double floor,
    double z,
    _ChairPalette palette,
    _Tone tone,
  ) {
    final paint = Paint()..isAntiAlias = true;

    paint.color = tone(palette.flat);
    canvas.drawPath(_pathOf(face), paint);

    final band = _projectAll(cam, [
      _V3(x - _halfWidth, floor + _backTop - 0.50, z),
      _V3(x + _halfWidth, floor + _backTop - 0.50, z),
      _V3(x + _halfWidth, floor + _backTop - 0.17, z),
      _V3(x - _halfWidth, floor + _backTop - 0.17, z),
    ]);
    if (band != null) {
      paint.color = tone(palette.band);
      canvas.drawPath(_pathOf(band), paint);
    }

    final rim = _projectAll(cam, [
      _V3(x - _halfWidth + 0.07, floor + _backTop - 0.11, z),
      _V3(x + _halfWidth - 0.07, floor + _backTop - 0.11, z),
      _V3(x + _halfWidth - 0.07, floor + _backTop - 0.01, z),
      _V3(x - _halfWidth + 0.07, floor + _backTop - 0.01, z),
    ]);
    if (rim != null) {
      paint.color = tone(palette.rim);
      canvas.drawPath(_pathOf(rim), paint);
    }

    // Dessus du dossier, visible uniquement si la caméra est plus haute.
    if (cam.pos.y > floor + _backTop) {
      final top = _projectAll(cam, [
        _V3(x - _halfWidth + 0.04, floor + _backTop, z - _backThickness),
        _V3(x + _halfWidth - 0.04, floor + _backTop, z - _backThickness),
        _V3(x + _halfWidth - 0.04, floor + _backTop, z),
        _V3(x - _halfWidth + 0.04, floor + _backTop, z),
      ]);
      if (top != null) {
        paint.color = tone(palette.flatTop);
        canvas.drawPath(_pathOf(top), paint);
      }
    }
  }

  /// Dossier détaillé (fauteuils proches) : dégradé vertical, bords assombris
  /// pour la courbure, couture de capitonnage.
  void _paintDetailedBack(
    Canvas canvas,
    _Camera cam,
    List<_Pt> face,
    double x,
    double floor,
    double z,
    _ChairPalette palette,
    _Tone tone,
    double fade,
    double width,
  ) {
    final facePath = _pathOf(face);
    final paint = Paint()..isAntiAlias = true;

    final top = cam.project(_V3(x, floor + _backTop, z));
    final bottom = cam.project(_V3(x, floor + _backBottom, z));
    if (top == null || bottom == null) {
      paint.color = tone(palette.flat);
      canvas.drawPath(facePath, paint);
      return;
    }

    // Velours : plus clair en haut (lumière de l'écran), sombre en bas.
    paint.shader = ui.Gradient.linear(
      Offset(top.x, top.y),
      Offset(bottom.x, bottom.y),
      [tone(palette.faceTop), tone(palette.faceMid), tone(palette.faceBottom)],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawPath(facePath, paint);

    // Bords latéraux assombris : donne l'impression d'un dossier bombé.
    final left = cam.project(_V3(x - _halfWidth, floor + 0.7, z));
    final right = cam.project(_V3(x + _halfWidth, floor + 0.7, z));
    if (left != null && right != null) {
      final edge = Color.fromARGB((110 * fade).round(), 0, 0, 0);
      paint.shader = ui.Gradient.linear(
        Offset(left.x, left.y),
        Offset(right.x, right.y),
        [edge, const Color(0x00000000), const Color(0x00000000), edge],
        const [0.0, 0.28, 0.72, 1.0],
      );
      canvas.drawPath(facePath, paint);
    }
    paint.shader = null;

    // Coutures du capitonnage.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = math.max(1.0, width * 0.007)
      ..color = Color.fromARGB((90 * fade).round(), 0, 0, 0);
    final inset = _projectAll(
      cam,
      _insetOutline.map((p) => _V3(x + p.dx, floor + p.dy, z)),
    );
    if (inset != null) canvas.drawPath(_pathOf(inset), stroke);
    final seam = _projectAll(cam, [
      _V3(x - _halfWidth + 0.03, floor + _backTop - 0.30, z),
      _V3(x + _halfWidth - 0.03, floor + _backTop - 0.30, z),
    ]);
    if (seam != null) {
      canvas.drawLine(
        Offset(seam[0].x, seam[0].y),
        Offset(seam[1].x, seam[1].y),
        stroke,
      );
    }
  }

  /// Dessus arrondi du dossier : une bande de facettes suivant le contour,
  /// éclairées selon leur orientation, plus un biseau brillant.
  void _paintRoundedCap(
    Canvas canvas,
    _Camera cam,
    double x,
    double floor,
    double z,
    _ChairPalette palette,
    _Tone tone,
  ) {
    final paint = Paint()..isAntiAlias = true;

    for (var i = 1; i < _faceOutline.length - 2; i++) {
      final p0 = _faceOutline[i];
      final p1 = _faceOutline[i + 1];
      final dx = p1.dx - p0.dx;
      final dy = p1.dy - p0.dy;
      final length = math.sqrt(dx * dx + dy * dy);
      if (length == 0) continue;

      // Normale sortante de la facette (dans le plan x-y) : on ne dessine que
      // celles qui regardent la caméra.
      final nx = -dy / length;
      final ny = dx / length;
      final toCamX = cam.pos.x - (x + p0.dx);
      final toCamY = cam.pos.y - (floor + p0.dy);
      if (nx * toCamX + ny * toCamY <= 0) continue;

      final quad = _projectAll(cam, [
        _V3(x + p0.dx, floor + p0.dy, z),
        _V3(x + p1.dx, floor + p1.dy, z),
        _V3(x + p1.dx, floor + p1.dy, z - _backThickness),
        _V3(x + p0.dx, floor + p0.dy, z - _backThickness),
      ]);
      if (quad == null) continue;

      final light = 0.35 + 0.65 * math.max(0.0, ny);
      paint.color = tone(
        Color.lerp(palette.capDark, palette.capLight, light) ??
            palette.capLight,
      );
      canvas.drawPath(_pathOf(quad), paint);
    }

    // Biseau à l'arrière du dessus (arête arrondie qui accroche la lumière).
    if (cam.pos.y > floor + _backTop - 0.045) {
      final bevel = _projectAll(cam, [
        _V3(x - _halfWidth + _topRadius, floor + _backTop - 0.045, z),
        _V3(x + _halfWidth - _topRadius, floor + _backTop - 0.045, z),
        _V3(x + _halfWidth - _topRadius, floor + _backTop, z - 0.045),
        _V3(x - _halfWidth + _topRadius, floor + _backTop, z - 0.045),
      ]);
      if (bevel != null) {
        paint.color = tone(palette.bevel);
        canvas.drawPath(_pathOf(bevel), paint);
      }
    }
  }

  /// Accoudoir : bout visible de dos et dessus qui file vers l'écran.
  void _paintArmrest(
    Canvas canvas,
    _Camera cam,
    double xCenter,
    double floor,
    double z,
    _Tone tone,
  ) {
    const halfWidth = 0.03;
    const bottom = 0.50;
    const top = 0.74;
    const length = 0.55;
    final paint = Paint()..isAntiAlias = true;

    final end = _projectAll(cam, [
      _V3(xCenter - halfWidth, floor + bottom, z),
      _V3(xCenter + halfWidth, floor + bottom, z),
      _V3(xCenter + halfWidth, floor + top, z),
      _V3(xCenter - halfWidth, floor + top, z),
    ]);
    if (end != null) {
      paint.color = tone(_armrestEnd, plastic: true);
      canvas.drawPath(_pathOf(end), paint);
    }

    if (cam.pos.y > floor + top) {
      final upper = _projectAll(cam, [
        _V3(xCenter - halfWidth, floor + top, z),
        _V3(xCenter + halfWidth, floor + top, z),
        _V3(xCenter + halfWidth, floor + top, z - length),
        _V3(xCenter - halfWidth, floor + top, z - length),
      ]);
      if (upper != null) {
        paint.color = tone(_armrestTop, plastic: true);
        canvas.drawPath(_pathOf(upper), paint);
      }
    }
  }

  /// Assise relevée, visible depuis les points de vue en hauteur (vol).
  void _paintCushion(
    Canvas canvas,
    _Camera cam,
    double x,
    double floor,
    double z,
    _ChairPalette palette,
    _Tone tone,
  ) {
    const height = 0.46;
    if (cam.pos.y <= floor + height) return;
    final seat = _projectAll(cam, [
      _V3(x - _halfWidth + 0.02, floor + height, z - 0.55),
      _V3(x + _halfWidth - 0.02, floor + height, z - 0.55),
      _V3(x + _halfWidth - 0.02, floor + height, z - 0.10),
      _V3(x - _halfWidth + 0.02, floor + height, z - 0.10),
    ]);
    if (seat == null) return;
    canvas.drawPath(
      _pathOf(seat),
      Paint()
        ..isAntiAlias = true
        ..color = tone(palette.cushion),
    );
  }

  @override
  bool shouldRepaint(Cinema3DPainter oldDelegate) =>
      oldDelegate.row != row ||
      oldDelegate.col != col ||
      oldDelegate.screenImage != screenImage ||
      oldDelegate.animation != animation;
}

/// Couleurs d'un type de fauteuil (normal ou sélectionné).
class _ChairPalette {
  const _ChairPalette({
    required this.flat,
    required this.band,
    required this.rim,
    required this.flatTop,
    required this.faceTop,
    required this.faceMid,
    required this.faceBottom,
    required this.capDark,
    required this.capLight,
    required this.bevel,
    required this.cushion,
  });

  // Rendu simple (fauteuils lointains).
  final Color flat;
  final Color band;
  final Color rim;
  final Color flatTop;

  // Rendu détaillé (fauteuils proches).
  final Color faceTop;
  final Color faceMid;
  final Color faceBottom;
  final Color capDark;
  final Color capLight;
  final Color bevel;

  // Assise.
  final Color cushion;
}
*/


import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'seat_layout.dart';

/// Teinte d'une couleur de fauteuil selon la distance et le fondu. Les pièces en
/// plastique (accoudoirs) gardent leur couleur même sur le siège sélectionné.
typedef _Tone = Color Function(Color base, {bool plastic});

/// Vecteur 3D minimal. Repère : x vers la droite, y vers le haut, z vers le
/// fond de la salle (l'écran est dans le plan z = 0).
class _V3 {
  const _V3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _V3 operator -(_V3 o) => _V3(x - o.x, y - o.y, z - o.z);

  double dot(_V3 o) => x * o.x + y * o.y + z * o.z;

  _V3 cross(_V3 o) =>
      _V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
}

/// Point projeté à l'écran, avec sa profondeur dans le repère de la caméra.
class _Pt {
  const _Pt(this.x, this.y, this.depth);

  final double x;
  final double y;
  final double depth;
}

/// Caméra à sténopé : position, lacet (yaw) et tangage (pitch).
class _Camera {
  _Camera({
    required this.pos,
    required double yaw,
    required double pitch,
    required this.focal,
    required this.cx,
    required this.cy,
  }) {
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    fwd = _V3(sinYaw * cosPitch, sinPitch, -cosYaw * cosPitch);
    right = _V3(cosYaw, 0, sinYaw);
    up = right.cross(fwd);
  }

  static const double near = 0.12;

  final _V3 pos;
  final double focal;
  final double cx;
  final double cy;

  late final _V3 fwd;
  late final _V3 right;
  late final _V3 up;

  /// Retourne null si le point est derrière la caméra.
  _Pt? project(_V3 p) {
    final d = p - pos;
    final depth = d.dot(fwd);
    if (depth < near) return null;
    return _Pt(
      cx + focal * d.dot(right) / depth,
      cy - focal * d.dot(up) / depth,
      depth,
    );
  }
}

/// Dessine la salle vue depuis un siège.
///
/// [animation] va de 0 (caméra en hauteur derrière le siège) à 1 (caméra posée
/// à hauteur des yeux dans le siège, regard vers l'écran). Le peintre se
/// redessine à chaque valeur de l'animation, sans reconstruire de widget.
class Cinema3DPainter extends CustomPainter {
  Cinema3DPainter({
    required this.animation,
    required this.row,
    required this.col,
    this.screenImage,
  }) : super(repaint: animation);

  final Animation<double> animation;

  /// Rangée (0 = A) et numéro (à partir de 1) du siège sélectionné.
  final int row;
  final int col;

  /// Image projetée sur l'écran (affiche ou fond du film). Facultative.
  final ui.Image? screenImage;

  // Fauteuils rouges, vus de dos et éclairés par l'écran.
  static const _ChairPalette _normalPalette = _ChairPalette(
    flat: Color(0xFF2B0508),
    flatTop: Color(0xFF9B1D21),
    faceTop: Color(0xFF5E0C11),
    faceMid: Color(0xFF3B080B),
    faceBottom: Color(0xFF150203),
    capDark: Color(0xFF4A0A0F),
    capLight: Color(0xFFC02A2F),
    bevel: Color(0xFFD2383D),
    cushion: Color(0xFF3D0A0E),
  );

  // Siège sélectionné : vert menthe.
  static const _ChairPalette _selectedPalette = _ChairPalette(
    flat: Color(0xFF5CC389),
    flatTop: Color(0xFFB9F6D1),
    faceTop: Color(0xFF9BEDBC),
    faceMid: Color(0xFF6ED197),
    faceBottom: Color(0xFF2F8A5B),
    capDark: Color(0xFF6ED197),
    capLight: Color(0xFFD6FBE6),
    bevel: Color(0xFFEFFFF6),
    cushion: Color(0xFF4FB27C),
  );

  // Accoudoirs (rouge sombre, entre les sièges).
  static const Color _armrestTop = Color(0xFF5A2A30);
  static const Color _armrestEnd = Color(0xFF2A1115);

  static const Color _riser = Color(0xFF050304);
  static const Color _background = Color(0xFF050406);

  static const double _halfWidth = 0.285;
  static const double _backBottom = 0.40;
  static const double _backTop = 1.05;
  static const double _backThickness = 0.12;
  static const double _horizontalFov = 60 * math.pi / 180;
  static const double _topRadius = 0.14;
  static const double _bottomRadius = 0.06;

  /// Rayon du bord rembourré du dossier (moitié de l'épaisseur).
  static const double _rimRadius = 0.06;

  /// Direction de la lumière (vers l'écran, légèrement par le haut) : les
  /// surfaces tournées vers le haut sont éclairées, la face arrière reste sombre.
  static const _V3 _lightDir = _V3(0.0, 0.9701, -0.2425);

  static final Expando<ui.ImageShader> _shaders = Expando<ui.ImageShader>();

  /// Contour du dossier d'un fauteuil (coins supérieurs et inférieurs arrondis), en mètres,
  /// relatif au centre du siège (x) et au sol de la rangée (y).
  static final List<Offset> _faceOutline = _buildOutline(
    _halfWidth,
    _backBottom,
    _backTop,
    _topRadius,
    bottomRadius: _bottomRadius,
  );

  /// Contour réduit, utilisé pour la couture du capitonnage (juste à l'intérieur
  /// du bord rembourré).
  static final List<Offset> _insetOutline = _buildOutline(
    _halfWidth - 0.085,
    _backBottom + 0.10,
    _backTop - 0.085,
    math.max(0.05, _topRadius - 0.04),
    bottomRadius: 0.04,
  );

  /// Normale sortante (dans le plan x-y) de chaque sommet du contour.
  static final List<Offset> _faceNormals = _buildNormals(_faceOutline);

  /// Segments du contour (indice de départ) qui reçoivent le bord arrondi :
  /// les côtés et le dessus, pas les coins du bas.
  static final List<int> _rimSegments = _buildRimSegments();

  static List<Offset> _buildNormals(List<Offset> pts) {
    final n = pts.length;
    return [
      for (var i = 0; i < n; i++)
            () {
          final d = pts[(i + 1) % n] - pts[(i + n - 1) % n];
          final len = d.distance;
          return len == 0
              ? const Offset(0, 1)
              : Offset(-d.dy / len, d.dx / len);
        }(),
    ];
  }

  static List<int> _buildRimSegments() {
    final minY = _backBottom + _bottomRadius - 1e-9;
    return [
      for (var i = 0; i < _faceOutline.length - 1; i++)
        if (_faceOutline[i].dy >= minY &&
            _faceOutline[i + 1].dy >= minY &&
            (_faceOutline[i + 1] - _faceOutline[i]).distance > 1e-9)
          i,
    ];
  }

  static List<Offset> _buildOutline(
      double halfWidth,
      double bottom,
      double top,
      double topRadius, {
        double bottomRadius = 0.06,
      }) {
    const steps = 4;
    final pts = <Offset>[];

    // Bottom-left corner
    for (var i = 0; i <= steps; i++) {
      final a = 1.5 * math.pi - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          -halfWidth + bottomRadius + bottomRadius * math.cos(a),
          bottom + bottomRadius + bottomRadius * math.sin(a),
        ),
      );
    }

    // Left side up to top-left corner start
    pts.add(Offset(-halfWidth, top - topRadius));

    // Top-left corner
    for (var i = 0; i <= steps; i++) {
      final a = math.pi - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          -halfWidth + topRadius + topRadius * math.cos(a),
          top - topRadius + topRadius * math.sin(a),
        ),
      );
    }

    // Top-right corner
    for (var i = 0; i <= steps; i++) {
      final a = math.pi / 2 - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          halfWidth - topRadius + topRadius * math.cos(a),
          top - topRadius + topRadius * math.sin(a),
        ),
      );
    }

    // Right side down to bottom-right corner start
    pts.add(Offset(halfWidth, bottom + bottomRadius));

    // Bottom-right corner
    for (var i = 0; i <= steps; i++) {
      final a = 0.0 - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          halfWidth - bottomRadius + bottomRadius * math.cos(a),
          bottom + bottomRadius + bottomRadius * math.sin(a),
        ),
      );
    }

    return pts;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = Curves.easeInOutCubic.transform(
      animation.value.clamp(0.0, 1.0).toDouble(),
    );

    canvas.drawRect(Offset.zero & size, Paint()..color = _background);

    final cam = _cameraFor(size, t);
    final roll = _lerp(-0.12, 0.0, t);

    canvas.save();
    canvas.translate(cam.cx, cam.cy);
    canvas.rotate(roll);
    canvas.translate(-cam.cx, -cam.cy);

    _paintScreen(canvas, cam);
    for (var r = 0; r < CinemaLayout.rows; r++) {
      _paintRow(canvas, size, cam, r);
    }

    canvas.restore();

    // Halo vert au bas de l'écran une fois installé dans le siège.
    if (t > 0.6) {
      final alpha = ((t - 0.6) / 0.4) * 0.16;
      final center = Offset(size.width / 2, size.height);
      final rect = Rect.fromCircle(center: center, radius: size.width * 0.8);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(center, size.width * 0.8, [
            const Color(0xFF7ADEA3).withAlpha((alpha * 255).round()),
            const Color(0x007ADEA3),
          ]),
      );
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  _Camera _cameraFor(Size size, double t) {
    final x = CinemaLayout.seatX(col);
    final z = CinemaLayout.rowDistance(row);
    final floor = CinemaLayout.rowFloor(row);

    // Arrivée : yeux dans le siège, regard dirigé vers le centre de l'écran.
    final endPos = _V3(x, floor + 1.15, z + 0.05);
    final endYaw = math.atan2(-x, z);
    const endPitch = 0.07;

    // Départ : en hauteur, derrière le siège, regard vers le bas.
    final startPos = _V3(x * 0.55, floor + 3.0, z + 3.2);
    final startYaw = endYaw * 0.35;
    const startPitch = -0.30;

    return _Camera(
      pos: _V3(
        _lerp(startPos.x, endPos.x, t),
        _lerp(startPos.y, endPos.y, t),
        _lerp(startPos.z, endPos.z, t),
      ),
      yaw: _lerp(startYaw, endYaw, t),
      pitch: _lerp(startPitch, endPitch, t),
      focal: size.width / 2 / math.tan(_horizontalFov / 2),
      cx: size.width / 2,
      cy: size.height * 0.40,
    );
  }

  List<_Pt>? _projectAll(_Camera cam, Iterable<_V3> points) {
    final out = <_Pt>[];
    for (final p in points) {
      final q = cam.project(p);
      if (q == null) return null;
      out.add(q);
    }
    return out;
  }

  Path _pathOf(List<_Pt> pts) {
    final path = Path()..moveTo(pts.first.x, pts.first.y);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].x, pts[i].y);
    }
    return path..close();
  }

  /// Comme [_pathOf], mais avec des coins adoucis.
  ///
  /// [softness] (de 0 à 0.5) est la part de la plus petite arête que chaque
  /// coin consomme pour s'arrondir : 0 = coins vifs, 0.3 = légèrement arrondis.
  Path _softPathOf(List<_Pt> pts, {double softness = 0.3}) {
    final o = [for (final p in pts) Offset(p.x, p.y)];
    final n = o.length;
    var shortest = double.infinity;
    for (var i = 0; i < n; i++) {
      shortest = math.min(shortest, (o[(i + 1) % n] - o[i]).distance);
    }
    final radius = shortest * softness;

    final path = Path();
    for (var i = 0; i < n; i++) {
      final prev = o[(i + n - 1) % n];
      final cur = o[i];
      final next = o[(i + 1) % n];
      final dPrev = (prev - cur).distance;
      final dNext = (next - cur).distance;
      final start = dPrev == 0
          ? cur
          : cur + (prev - cur) * math.min(0.5, radius / dPrev);
      final end = dNext == 0
          ? cur
          : cur + (next - cur) * math.min(0.5, radius / dNext);
      if (i == 0) {
        path.moveTo(start.dx, start.dy);
      } else {
        path.lineTo(start.dx, start.dy);
      }
      path.quadraticBezierTo(cur.dx, cur.dy, end.dx, end.dy);
    }
    return path..close();
  }

  // ---------------------------------------------------------------------------
  // Écran
  // ---------------------------------------------------------------------------

  void _paintScreen(Canvas canvas, _Camera cam) {
    const gx = 10;
    const gy = 6;
    final halfW = CinemaLayout.screenWidth / 2;
    final bottom = CinemaLayout.screenBottom;
    final height = CinemaLayout.screenHeight;

    final grid = <_Pt>[];
    for (var j = 0; j <= gy; j++) {
      for (var i = 0; i <= gx; i++) {
        final u = i / gx;
        final v = j / gy;
        final p = cam.project(
          _V3(-halfW + 2 * halfW * u, bottom + height * (1 - v), 0),
        );
        if (p == null) return;
        grid.add(p);
      }
    }

    final topLeft = grid[0];
    final topRight = grid[gx];
    final bottomLeft = grid[gy * (gx + 1)];
    final bottomRight = grid[grid.length - 1];

    // Lueur diffuse autour de l'écran.
    final glowCenter = Offset(
      (topLeft.x + topRight.x + bottomLeft.x + bottomRight.x) / 4,
      (topLeft.y + topRight.y + bottomLeft.y + bottomRight.y) / 4,
    );
    final glowRadius = math.max(
      (topRight.x - topLeft.x).abs(),
      (bottomRight.x - bottomLeft.x).abs(),
    );
    if (glowRadius > 1) {
      canvas.drawCircle(
        glowCenter,
        glowRadius,
        Paint()
          ..shader = ui.Gradient.radial(glowCenter, glowRadius, [
            const Color(0x30D8C2AE),
            const Color(0x00D8C2AE),
          ]),
      );
    }

    final image = screenImage;
    if (image == null) {
      final quad = Path()
        ..moveTo(topLeft.x, topLeft.y)
        ..lineTo(topRight.x, topRight.y)
        ..lineTo(bottomRight.x, bottomRight.y)
        ..lineTo(bottomLeft.x, bottomLeft.y)
        ..close();
      canvas.drawPath(
        quad,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset((topLeft.x + topRight.x) / 2, topLeft.y),
            Offset((bottomLeft.x + bottomRight.x) / 2, bottomLeft.y),
            const [Color(0xFFD1BEB0), Color(0xFF6B5647)],
          ),
      );
      return;
    }

    // Recadrage centré de l'image au format de l'écran.
    final targetAspect = CinemaLayout.screenWidth / CinemaLayout.screenHeight;
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    var srcW = imgW;
    var srcH = imgH;
    if (imgW / imgH > targetAspect) {
      srcW = imgH * targetAspect;
    } else {
      srcH = imgW / targetAspect;
    }
    final srcLeft = (imgW - srcW) / 2;
    final srcTop = (imgH - srcH) / 2;

    final positions = Float32List(grid.length * 2);
    final texCoords = Float32List(grid.length * 2);
    for (var j = 0; j <= gy; j++) {
      for (var i = 0; i <= gx; i++) {
        final index = j * (gx + 1) + i;
        positions[index * 2] = grid[index].x;
        positions[index * 2 + 1] = grid[index].y;
        texCoords[index * 2] = srcLeft + srcW * (i / gx);
        texCoords[index * 2 + 1] = srcTop + srcH * (j / gy);
      }
    }
    final indices = Uint16List(gx * gy * 6);
    var k = 0;
    for (var j = 0; j < gy; j++) {
      for (var i = 0; i < gx; i++) {
        final a = j * (gx + 1) + i;
        final b = a + 1;
        final c = a + (gx + 1);
        final d = c + 1;
        indices[k++] = a;
        indices[k++] = b;
        indices[k++] = c;
        indices[k++] = b;
        indices[k++] = d;
        indices[k++] = c;
      }
    }

    final shader = _shaders[image] ??= ui.ImageShader(
      image,
      ui.TileMode.clamp,
      ui.TileMode.clamp,
      Float64List.fromList(const [
        1, 0, 0, 0, //
        0, 1, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1, //
      ]),
      filterQuality: ui.FilterQuality.medium,
    );
    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: texCoords,
      indices: indices,
    );
    canvas.drawVertices(
      vertices,
      ui.BlendMode.srcOver,
      Paint()..shader = shader,
    );
  }

  // ---------------------------------------------------------------------------
  // Rangées et fauteuils
  // ---------------------------------------------------------------------------

  void _paintRow(Canvas canvas, Size size, _Camera cam, int r) {
    final z = CinemaLayout.rowDistance(r);
    final floor = CinemaLayout.rowFloor(r);

    // Contremarche pleine : masque ce qui se trouve derrière la rangée.
    final riser = _projectAll(cam, [
      _V3(-9, floor - 0.3, z),
      _V3(9, floor - 0.3, z),
      _V3(9, floor + _backBottom, z),
      _V3(-9, floor + _backBottom, z),
    ]);
    if (riser != null) {
      canvas.drawPath(_pathOf(riser), Paint()..color = _riser);
    }

    for (var c = 1; c <= CinemaLayout.columns; c++) {
      final selected = r == row && c == col;
      _paintChair(canvas, size, cam, r, c, selected);
    }
  }

  void _paintChair(
      Canvas canvas,
      Size size,
      _Camera cam,
      int r,
      int c,
      bool selected,
      ) {
    final x = CinemaLayout.seatX(c);
    final z = CinemaLayout.rowDistance(r);
    final floor = CinemaLayout.rowFloor(r);

    final face = _projectAll(
      cam,
      _faceOutline.map((p) => _V3(x + p.dx, floor + p.dy, z)),
    );
    if (face == null) return;

    // Élimination des fauteuils entièrement hors du cadre.
    var minX = double.infinity;
    var maxX = -double.infinity;
    var minY = double.infinity;
    var maxY = -double.infinity;
    for (final p in face) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    const margin = 80.0;
    if (maxX < -margin ||
        minX > size.width + margin ||
        maxY < -margin ||
        minY > size.height + margin) {
      return;
    }

    // Fondu des fauteuils tout proches de la caméra (fin du vol).
    final fade = math.min(1.0, math.max(0.0, (face.first.depth - 0.12) / 0.35));
    if (fade < 0.02) return;

    // Assombrissement avec la distance.
    final fog = math.min(0.55, math.max(0.0, (face.first.depth - 2.0) / 16.0));
    Color tone(Color base, {bool plastic = false}) {
      final keep = selected && !plastic;
      final dimmed = keep
          ? base
          : (Color.lerp(base, const Color(0xFF000000), fog) ?? base);
      return dimmed.withAlpha((255 * fade).round());
    }

    final palette = selected ? _selectedPalette : _normalPalette;

    // Niveau de détail selon la taille du fauteuil à l'écran :
    // 2 = dégradés, courbure, coutures, dessus arrondi (fauteuils proches)
    // 1 = faces unies + accoudoirs et assise
    // 0 = faces unies (fauteuils lointains)
    final width = maxX - minX;
    final detail = width > 70 ? 2 : (width > 28 ? 1 : 0);

    if (detail >= 1) {
      _paintArmrest(canvas, cam, x + _halfWidth + 0.03, floor, z, tone);
      final startsBlock =
          c == 1 ||
              x - CinemaLayout.seatX(c - 1) > CinemaLayout.seatPitch + 0.01;
      if (startsBlock) {
        _paintArmrest(canvas, cam, x - _halfWidth - 0.03, floor, z, tone);
      }
      _paintCushion(canvas, cam, x, floor, z, palette, tone);
    }

    if (detail == 2) {
      _paintDetailedBack(
        canvas,
        cam,
        face,
        x,
        floor,
        z,
        palette,
        tone,
        fade,
        width,
      );
      _paintRim(canvas, cam, x, floor, z, palette, tone, steps: 5);
    } else {
      _paintFlatBack(
        canvas,
        cam,
        face,
        x,
        floor,
        z,
        palette,
        tone,
        drawTop: detail == 0,
      );
      if (detail == 1) {
        _paintRim(canvas, cam, x, floor, z, palette, tone, steps: 3);
      }
    }
  }

  /// Dossier simple : un aplat. Pour les fauteuils très lointains ([drawTop]),
  /// un petit dessus clair suffit.
  void _paintFlatBack(
      Canvas canvas,
      _Camera cam,
      List<_Pt> face,
      double x,
      double floor,
      double z,
      _ChairPalette palette,
      _Tone tone, {
        required bool drawTop,
      }) {
    final paint = Paint()..isAntiAlias = true;

    paint.color = tone(palette.flat);
    canvas.drawPath(_pathOf(face), paint);

    if (drawTop && cam.pos.y > floor + _backTop) {
      final top = _projectAll(cam, [
        _V3(x - _halfWidth + 0.08, floor + _backTop, z - _backThickness),
        _V3(x + _halfWidth - 0.08, floor + _backTop, z - _backThickness),
        _V3(x + _halfWidth - 0.08, floor + _backTop, z),
        _V3(x - _halfWidth + 0.08, floor + _backTop, z),
      ]);
      if (top != null) {
        paint.color = tone(palette.flatTop);
        canvas.drawPath(_softPathOf(top), paint);
      }
    }
  }

  /// Dossier détaillé (fauteuils proches) : dégradé vertical, bords assombris
  /// pour la courbure, couture de capitonnage.
  void _paintDetailedBack(
      Canvas canvas,
      _Camera cam,
      List<_Pt> face,
      double x,
      double floor,
      double z,
      _ChairPalette palette,
      _Tone tone,
      double fade,
      double width,
      ) {
    final facePath = _pathOf(face);
    final paint = Paint()..isAntiAlias = true;

    final top = cam.project(_V3(x, floor + _backTop, z));
    final bottom = cam.project(_V3(x, floor + _backBottom, z));
    if (top == null || bottom == null) {
      paint.color = tone(palette.flat);
      canvas.drawPath(facePath, paint);
      return;
    }

    // Velours : plus clair en haut (lumière de l'écran), sombre en bas.
    paint.shader = ui.Gradient.linear(
      Offset(top.x, top.y),
      Offset(bottom.x, bottom.y),
      [tone(palette.faceTop), tone(palette.faceMid), tone(palette.faceBottom)],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawPath(facePath, paint);

    // Bords latéraux assombris : donne l'impression d'un dossier bombé.
    final left = cam.project(_V3(x - _halfWidth, floor + 0.7, z));
    final right = cam.project(_V3(x + _halfWidth, floor + 0.7, z));
    if (left != null && right != null) {
      final edge = Color.fromARGB((70 * fade).round(), 0, 0, 0);
      paint.shader = ui.Gradient.linear(
        Offset(left.x, left.y),
        Offset(right.x, right.y),
        [edge, const Color(0x00000000), const Color(0x00000000), edge],
        const [0.0, 0.28, 0.72, 1.0],
      );
      canvas.drawPath(facePath, paint);
    }
    paint.shader = null;

    // Coutures du capitonnage.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = math.max(1.0, width * 0.007)
      ..color = Color.fromARGB((90 * fade).round(), 0, 0, 0);
    final inset = _projectAll(
      cam,
      _insetOutline.map((p) => _V3(x + p.dx, floor + p.dy, z)),
    );
    if (inset != null) canvas.drawPath(_pathOf(inset), stroke);
    final seam = _projectAll(cam, [
      _V3(x - _halfWidth + 0.03, floor + _backTop - 0.30, z),
      _V3(x + _halfWidth - 0.03, floor + _backTop - 0.30, z),
    ]);
    if (seam != null) {
      canvas.drawLine(
        Offset(seam[0].x, seam[0].y),
        Offset(seam[1].x, seam[1].y),
        stroke,
      );
    }
  }

  /// Bord rembourré du dossier : un quart de tore qui suit le contour (côtés et
  /// dessus). Chaque facette est éclairée selon son orientation, du sombre (face
  /// arrière) au clair (dessus), ce qui donne l'aspect arrondi et rembourré.
  void _paintRim(
      Canvas canvas,
      _Camera cam,
      double x,
      double floor,
      double z,
      _ChairPalette palette,
      _Tone tone, {
        required int steps,
      }) {
    const sweep = 0.75 * math.pi;
    final paint = Paint()..isAntiAlias = true;
    final count = _faceOutline.length;
    final rings3 = List<List<_V3>?>.filled(count, null);
    final rings2 = List<List<_Pt?>?>.filled(count, null);

    List<_V3> ring3(int i) {
      final cached = rings3[i];
      if (cached != null) return cached;
      final p = _faceOutline[i];
      final nrm = _faceNormals[i];
      final ring = <_V3>[];
      for (var k = 0; k <= steps; k++) {
        final phi = sweep * k / steps;
        final s = math.sin(phi);
        ring.add(
          _V3(
            x + p.dx - nrm.dx * _rimRadius + nrm.dx * _rimRadius * s,
            floor + p.dy - nrm.dy * _rimRadius + nrm.dy * _rimRadius * s,
            z - _rimRadius + _rimRadius * math.cos(phi),
          ),
        );
      }
      return rings3[i] = ring;
    }

    List<_Pt?> ring2(int i) {
      final cached = rings2[i];
      if (cached != null) return cached;
      return rings2[i] = [for (final p in ring3(i)) cam.project(p)];
    }

    for (final i in _rimSegments) {
      final a3 = ring3(i);
      final b3 = ring3(i + 1);
      final a2 = ring2(i);
      final b2 = ring2(i + 1);

      // Normale moyenne du segment dans le plan x-y.
      var mx = _faceNormals[i].dx + _faceNormals[i + 1].dx;
      var my = _faceNormals[i].dy + _faceNormals[i + 1].dy;
      final ml = math.sqrt(mx * mx + my * my);
      if (ml == 0) continue;
      mx /= ml;
      my /= ml;

      for (var k = 0; k < steps; k++) {
        final p0 = a2[k];
        final p1 = b2[k];
        final p2 = b2[k + 1];
        final p3 = a2[k + 1];
        if (p0 == null || p1 == null || p2 == null || p3 == null) continue;

        // Normale 3D de la facette, et test de face visible.
        final phiMid = sweep * (k + 0.5) / steps;
        final n3 = _V3(
          mx * math.sin(phiMid),
          my * math.sin(phiMid),
          math.cos(phiMid),
        );
        final toCam = _V3(
          cam.pos.x - (a3[k].x + b3[k + 1].x) / 2,
          cam.pos.y - (a3[k].y + b3[k + 1].y) / 2,
          cam.pos.z - (a3[k].z + b3[k + 1].z) / 2,
        );
        if (n3.dot(toCam) <= 0) continue;

        final diffuse = math.max(0.0, n3.dot(_lightDir));
        final light = math.min(1.0, 0.2 + 0.85 * diffuse);
        var color =
            Color.lerp(palette.capDark, palette.capLight, light) ??
                palette.capLight;
        if (light > 0.85) {
          color =
              Color.lerp(color, palette.bevel, (light - 0.85) / 0.15 * 0.6) ??
                  color;
        }

        paint.color = tone(color);
        canvas.drawPath(
          Path()
            ..moveTo(p0.x, p0.y)
            ..lineTo(p1.x, p1.y)
            ..lineTo(p2.x, p2.y)
            ..lineTo(p3.x, p3.y)
            ..close(),
          paint,
        );
      }
    }
  }

  /// Accoudoir : bout visible de dos et dessus qui file vers l'écran.
  void _paintArmrest(
      Canvas canvas,
      _Camera cam,
      double xCenter,
      double floor,
      double z,
      _Tone tone,
      ) {
    const halfWidth = 0.03;
    const bottom = 0.50;
    const top = 0.74;
    const length = 0.55;
    final paint = Paint()..isAntiAlias = true;

    final end = _projectAll(cam, [
      _V3(xCenter - halfWidth, floor + bottom, z),
      _V3(xCenter + halfWidth, floor + bottom, z),
      _V3(xCenter + halfWidth, floor + top, z),
      _V3(xCenter - halfWidth, floor + top, z),
    ]);
    if (end != null) {
      paint.color = tone(_armrestEnd, plastic: true);
      canvas.drawPath(_softPathOf(end), paint);
    }

    if (cam.pos.y > floor + top) {
      final upper = _projectAll(cam, [
        _V3(xCenter - halfWidth, floor + top, z),
        _V3(xCenter + halfWidth, floor + top, z),
        _V3(xCenter + halfWidth, floor + top, z - length),
        _V3(xCenter - halfWidth, floor + top, z - length),
      ]);
      if (upper != null) {
        paint.color = tone(_armrestTop, plastic: true);
        canvas.drawPath(_softPathOf(upper), paint);
      }
    }
  }

  /// Assise relevée, visible depuis les points de vue en hauteur (vol).
  void _paintCushion(
      Canvas canvas,
      _Camera cam,
      double x,
      double floor,
      double z,
      _ChairPalette palette,
      _Tone tone,
      ) {
    const height = 0.46;
    if (cam.pos.y <= floor + height) return;
    final seat = _projectAll(cam, [
      _V3(x - _halfWidth + 0.02, floor + height, z - 0.55),
      _V3(x + _halfWidth - 0.02, floor + height, z - 0.55),
      _V3(x + _halfWidth - 0.02, floor + height, z - 0.10),
      _V3(x - _halfWidth + 0.02, floor + height, z - 0.10),
    ]);
    if (seat == null) return;
    canvas.drawPath(
      _softPathOf(seat),
      Paint()
        ..isAntiAlias = true
        ..color = tone(palette.cushion),
    );
  }

  @override
  bool shouldRepaint(Cinema3DPainter oldDelegate) =>
      oldDelegate.row != row ||
          oldDelegate.col != col ||
          oldDelegate.screenImage != screenImage ||
          oldDelegate.animation != animation;
}

/// Couleurs d'un type de fauteuil (normal ou sélectionné).
class _ChairPalette {
  const _ChairPalette({
    required this.flat,
    required this.flatTop,
    required this.faceTop,
    required this.faceMid,
    required this.faceBottom,
    required this.capDark,
    required this.capLight,
    required this.bevel,
    required this.cushion,
  });

  // Rendu simple (fauteuils lointains).
  final Color flat;
  final Color flatTop;

  // Rendu détaillé (fauteuils proches).
  final Color faceTop;
  final Color faceMid;
  final Color faceBottom;
  final Color capDark;
  final Color capLight;
  final Color bevel;

  // Assise.
  final Color cushion;
}