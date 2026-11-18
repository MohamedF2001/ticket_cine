import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'seat_layout.dart';

/// Palette de l'écran de choix du siège (reprise de la vidéo de référence).
class SeatPalette {
  SeatPalette._();

  static const Color background = Color(0xFF0A090C);
  static const Color surface = Color(0xFF111013);
  static const Color chipBar = Color(0xFF141316);
  static const Color chipSelected = Color(0xFFF2F0EC);
  static const Color sheet = Color(0xFF171114);
  static const Color tile = Color(0xFF1F181B);
  static const Color seatAvailable = Color(0xFF29282D);
  static const Color seatTakenBorder = Color(0xFF38373D);
  static const Color recliner = Color(0xFF4A282F);
  static const Color reclinerTakenBorder = Color(0xFF4A282F);
  //siège sélectionné
  static const Color selected = Color(0xFF7ADEA3);
  static const Color onSelected = Color(0xFF0B1A12);
  static const Color muted = Color(0xFF8E8D93);
  static const Color faint = Color(0xFF4A494E);
  static const Color buttonLight = Color(0xFFE5E3DF);
}

/// Style de texte basé sur le thème de l'application (donc sur sa police).
TextStyle seatText(
  BuildContext context, {
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = Colors.white,
  double? letterSpacing,
  double? height,
}) {
  final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}

// -----------------------------------------------------------------------------
// Écran (arc lumineux)
// -----------------------------------------------------------------------------

class ScreenArc extends StatelessWidget {
  const ScreenArc({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ScreenArcPainter())),
          Align(
            alignment: const Alignment(0, 0.55),
            child: Text(
              'ÉCRAN',
              style: seatText(
                context,
                size: 9,
                weight: FontWeight.w500,
                color: SeatPalette.faint,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final arc = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w / 2, -h * 0.25, w, h * 0.62);

    // Lumière projetée sous l'arc.
    final glow = Path.from(arc)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      glow,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, h * 0.18), Offset(0, h), const [
          Color(0x1FFFFFFF),
          Color(0x00FFFFFF),
        ]),
    );

    // Halo de l'arc.
    final stroke = ui.Gradient.linear(
      Offset.zero,
      Offset(w, 0),
      const [Color(0x00FFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      const [0.0, 0.5, 1.0],
    );
    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..shader = stroke,
    );
    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..shader = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Plan de salle
// -----------------------------------------------------------------------------

class SeatMap extends StatelessWidget {
  const SeatMap({
    super.key,
    required this.reservedSeats,
    required this.selectedSeat,
    required this.onSeatTap,
  });

  final Set<String> reservedSeats;
  final String? selectedSeat;
  final ValueChanged<String> onSeatTap;

  static const double _labelWidth = 18;
  static const double _horizontalPadding = 20;
  static const double _aisleUnits = 0.9;

  bool _isAisleAfter(int col) {
    final blocks = CinemaLayout.blocks;
    var end = 0;
    for (var i = 0; i < blocks.length - 1; i++) {
      end += blocks[i];
      if (col == end) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available =
            constraints.maxWidth - 2 * _horizontalPadding - _labelWidth;
        final aisleCount = CinemaLayout.blocks.length - 1;
        final unit =
            available / (CinemaLayout.columns + aisleCount * _aisleUnits);
        final seatSize = unit * 0.7;
        final aisle = unit * _aisleUnits;
        var rowHeight = unit * 1.6;
        if (constraints.hasBoundedHeight) {
          rowHeight = math.min(
            rowHeight,
            constraints.maxHeight / CinemaLayout.rows,
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var r = 0; r < CinemaLayout.rows; r++)
              SizedBox(
                height: rowHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: _labelWidth,
                      child: Text(
                        CinemaLayout.rowLetter(r),
                        style: seatText(
                          context,
                          size: 9,
                          weight: FontWeight.w500,
                          color: SeatPalette.faint,
                        ),
                      ),
                    ),
                    for (var c = 1; c <= CinemaLayout.columns; c++) ...[
                      _buildSeat(context, r, c, unit, seatSize, rowHeight),
                      if (_isAisleAfter(c)) SizedBox(width: aisle),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSeat(
    BuildContext context,
    int r,
    int c,
    double unit,
    double seatSize,
    double rowHeight,
  ) {
    final id = CinemaLayout.seatId(r, c);
    final taken = reservedSeats.contains(id);
    final isSelected = selectedSeat == id;
    final recliner = CinemaLayout.kindOfRow(r) == SeatKind.recliner;

    final BoxDecoration decoration;
    if (isSelected) {
      decoration = BoxDecoration(
        color: SeatPalette.selected,
        borderRadius: BorderRadius.circular(seatSize * 0.3),
        boxShadow: const [
          BoxShadow(color: Color(0x667ADEA3), blurRadius: 12, spreadRadius: 1),
        ],
      );
    } else if (taken) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(seatSize * 0.3),
        border: Border.all(
          color: recliner
              ? SeatPalette.reclinerTakenBorder
              : SeatPalette.seatTakenBorder,
          width: 1.2,
        ),
      );
    } else {
      decoration = BoxDecoration(
        color: recliner ? SeatPalette.recliner : SeatPalette.seatAvailable,
        borderRadius: BorderRadius.circular(seatSize * 0.3),
      );
    }

    final seatLabel = '${CinemaLayout.rowLetter(r)}$c';
    return Semantics(
      button: !taken,
      selected: isSelected,
      label: taken
          ? 'Siège $seatLabel, occupé'
          : recliner
          ? 'Siège $seatLabel, recliner'
          : 'Siège $seatLabel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: taken ? null : () => onSeatTap(id),
        child: SizedBox(
          width: unit,
          height: rowHeight,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: seatSize,
              height: seatSize,
              decoration: decoration,
              alignment: Alignment.center,
              child: isSelected
                  ? Text(
                      '$c',
                      style: seatText(
                        context,
                        size: seatSize * 0.52,
                        weight: FontWeight.w700,
                        color: SeatPalette.onSelected,
                        height: 1,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Légende
// -----------------------------------------------------------------------------

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _item(context, 'Disponible', fill: SeatPalette.seatAvailable),
        const SizedBox(width: 14),
        _item(context, 'Occupé', border: SeatPalette.seatTakenBorder),
        const SizedBox(width: 14),
        _item(context, 'Recliner', fill: SeatPalette.recliner),
        const SizedBox(width: 14),
        _item(context, 'Sélectionné', fill: SeatPalette.selected),
      ],
    );
  }

  Widget _item(
    BuildContext context,
    String label, {
    Color? fill,
    Color? border,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(3),
            border: border == null ? null : Border.all(color: border, width: 1),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: seatText(context, size: 10, color: SeatPalette.muted),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Mini-plan (feuille d'infos de la vue 3D)
// -----------------------------------------------------------------------------

class MiniSeatMap extends StatelessWidget {
  const MiniSeatMap({super.key, required this.row, required this.col});

  final int row;
  final int col;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 58,
      child: CustomPaint(
        painter: _MiniMapPainter(row: row, col: col),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({required this.row, required this.col});

  final int row;
  final int col;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Arc de l'écran.
    final arc = Path()
      ..moveTo(2, 7)
      ..quadraticBezierTo(w / 2, -3, w - 2, 7);
    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xCCFFFFFF),
    );

    const aisleUnits = 0.9;
    final blocks = CinemaLayout.blocks;
    final unit =
        (w - 4) / (CinemaLayout.columns + (blocks.length - 1) * aisleUnits);
    const top = 14.0;
    final rowStep = (h - top - 2) / (CinemaLayout.rows - 1);

    final dot = Paint();
    for (var r = 0; r < CinemaLayout.rows; r++) {
      final y = top + r * rowStep;
      var x = 2 + unit / 2;
      var blockEnd = blocks.first;
      var blockIndex = 0;
      for (var c = 1; c <= CinemaLayout.columns; c++) {
        final isSelected = r == row && c == col;
        if (isSelected) {
          canvas.drawCircle(
            Offset(x, y),
            4.2,
            Paint()..color = const Color(0x557ADEA3),
          );
          dot.color = SeatPalette.selected;
          canvas.drawCircle(Offset(x, y), 2.2, dot);
        } else {
          dot.color = CinemaLayout.kindOfRow(r) == SeatKind.recliner
              ? const Color(0xFF5E3139)
              : const Color(0xFF3A383D);
          canvas.drawCircle(Offset(x, y), 1.25, dot);
        }
        x += unit;
        if (c == blockEnd && blockIndex < blocks.length - 1) {
          x += unit * aisleUnits;
          blockIndex++;
          blockEnd += blocks[blockIndex];
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) =>
      oldDelegate.row != row || oldDelegate.col != col;
}
