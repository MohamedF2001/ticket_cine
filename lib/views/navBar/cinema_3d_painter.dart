import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../seat/seat_layout.dart';

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

  // Couleurs des fauteuils (vus de dos, éclairés par l'écran).
  static const Color _chairFace = Color(0xFF2B0508);
  static const Color _chairBand = Color(0xFF450A0E);
  static const Color _chairRim = Color(0xFF6A0E13);
  static const Color _chairTop = Color(0xFF9B1D21);

  // Siège sélectionné : vert menthe.
  static const Color _selFace = Color(0xFF5CC389);
  static const Color _selBand = Color(0xFF7ADEA3);
  static const Color _selRim = Color(0xFF93EBB5);
  static const Color _selTop = Color(0xFFB9F6D1);

  static const Color _riser = Color(0xFF050304);
  static const Color _background = Color(0xFF050406);

  static const double _halfWidth = 0.285;
  static const double _backBottom = 0.40;
  static const double _backTop = 1.05;
  static const double _backThickness = 0.12;
  static const double _horizontalFov = 60 * math.pi / 180;

  static final Expando<ui.ImageShader> _shaders = Expando<ui.ImageShader>();

  /// Contour du dossier d'un fauteuil (coins supérieurs arrondis), en mètres,
  /// relatif au centre du siège (x) et au sol de la rangée (y).
  static final List<Offset> _faceOutline = _buildFaceOutline();

  static List<Offset> _buildFaceOutline() {
    const radius = 0.13;
    const steps = 4;
    final pts = <Offset>[
      const Offset(-_halfWidth, _backBottom),
      const Offset(-_halfWidth, _backTop - radius),
    ];
    for (var i = 1; i <= steps; i++) {
      final a = math.pi - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          -_halfWidth + radius + radius * math.cos(a),
          _backTop - radius + radius * math.sin(a),
        ),
      );
    }
    for (var i = 0; i <= steps; i++) {
      final a = math.pi / 2 - (math.pi / 2) * i / steps;
      pts.add(
        Offset(
          _halfWidth - radius + radius * math.cos(a),
          _backTop - radius + radius * math.sin(a),
        ),
      );
    }
    pts.add(const Offset(_halfWidth, _backBottom));
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
    Color tone(Color base) {
      final dimmed = selected
          ? base
          : (Color.lerp(base, const Color(0xFF000000), fog) ?? base);
      return dimmed.withAlpha((255 * fade).round());
    }

    final paint = Paint()..isAntiAlias = true;

    // Face arrière du dossier.
    paint.color = tone(selected ? _selFace : _chairFace);
    canvas.drawPath(_pathOf(face), paint);

    // Bande médiane, légèrement plus claire.
    final band = _projectAll(cam, [
      _V3(x - _halfWidth, floor + _backTop - 0.50, z),
      _V3(x + _halfWidth, floor + _backTop - 0.50, z),
      _V3(x + _halfWidth, floor + _backTop - 0.17, z),
      _V3(x - _halfWidth, floor + _backTop - 0.17, z),
    ]);
    if (band != null) {
      paint.color = tone(selected ? _selBand : _chairBand);
      canvas.drawPath(_pathOf(band), paint);
    }

    // Liseré sous le sommet du dossier.
    final rim = _projectAll(cam, [
      _V3(x - _halfWidth + 0.07, floor + _backTop - 0.11, z),
      _V3(x + _halfWidth - 0.07, floor + _backTop - 0.11, z),
      _V3(x + _halfWidth - 0.07, floor + _backTop - 0.01, z),
      _V3(x - _halfWidth + 0.07, floor + _backTop - 0.01, z),
    ]);
    if (rim != null) {
      paint.color = tone(selected ? _selRim : _chairRim);
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
        paint.color = tone(selected ? _selTop : _chairTop);
        canvas.drawPath(_pathOf(top), paint);
      }
    }
  }

  @override
  bool shouldRepaint(Cinema3DPainter oldDelegate) =>
      oldDelegate.row != row ||
      oldDelegate.col != col ||
      oldDelegate.screenImage != screenImage ||
      oldDelegate.animation != animation;
}
