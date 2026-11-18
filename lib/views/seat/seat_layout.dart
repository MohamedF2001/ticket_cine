import 'dart:math' as math;

/// Type de siège.
enum SeatKind { standard, recliner }

/// Qualité de la vue, affichée dans la feuille d'infos (UP CLOSE / SWEET SPOT /
/// FULL PICTURE dans la vidéo de référence).
enum SeatViewQuality { upClose, sweetSpot, fullPicture }

/// Statistiques d'un siège, calculées à partir de la géométrie de la salle.
class SeatStats {
  const SeatStats({
    required this.row,
    required this.col,
    required this.distance,
    required this.fieldOfView,
    required this.offset,
    required this.quality,
    required this.kind,
  });

  /// Index de rangée (0 = A, la plus proche de l'écran).
  final int row;

  /// Numéro de siège (1 à [CinemaLayout.columns]).
  final int col;

  /// Distance à l'écran, en mètres.
  final double distance;

  /// Angle sous lequel l'écran est vu, en degrés.
  final int fieldOfView;

  /// Décalage par rapport à l'axe central, en mètres (négatif = à gauche).
  final double offset;

  final SeatViewQuality quality;
  final SeatKind kind;

  String get id => CinemaLayout.seatId(row, col);

  String get distanceLabel => '${distance.toStringAsFixed(1)} m';

  String get offsetLabel => '${offset.abs().toStringAsFixed(1)} m';

  String get offsetCaption {
    if (offset.abs() < 0.05) return 'au centre';
    return offset < 0 ? 'à gauche du centre' : 'à droite du centre';
  }
}

/// Géométrie de la salle (en mètres) et conventions de numérotation.
///
/// Les identifiants de sièges gardent le format historique de l'application :
/// lettre de rangée + numéro, par exemple `B4`. Le serveur et les réservations
/// existantes restent donc compatibles.
class CinemaLayout {
  CinemaLayout._();

  static const int rows = 9;
  static const int columns = 14;

  /// Répartition des sièges en blocs séparés par des allées (3 + 8 + 3).
  static const List<int> blocks = [3, 8, 3];

  /// Nombre de rangées « recliner » à l'arrière de la salle.
  static const int reclinerRows = 2;

  /// Écart entre deux sièges voisins.
  static const double seatPitch = 0.63;

  /// Décalage supplémentaire des blocs latéraux (largeur d'une allée).
  static const double aisleExtra = 0.46;

  static const double screenWidth = 11.4;
  static const double screenHeight = 6.9;

  /// Hauteur du bord bas de l'écran par rapport au sol de la première rangée.
  static const double screenBottom = 1.9;

  /// Dénivelé entre deux rangées successives (gradins).
  static const double rake = 0.2;

  static const double _firstRowDistance = 5.425;
  static const double _standardRowGap = 0.875;
  static const double _reclinerRowGap = 1.3125;

  static String rowLetter(int row) => String.fromCharCode(65 + row);

  /// Identifiant d'un siège. [col] commence à 1.
  static String seatId(int row, int col) => '${rowLetter(row)}$col';

  static SeatKind kindOfRow(int row) =>
      row >= rows - reclinerRows ? SeatKind.recliner : SeatKind.standard;

  /// Analyse un identifiant comme `B4`. Retourne null s'il est invalide ou
  /// hors de la salle.
  static ({int row, int col})? parse(String id) {
    if (id.length < 2) return null;
    final row = id.codeUnitAt(0) - 65;
    final col = int.tryParse(id.substring(1));
    if (col == null || row < 0 || row >= rows || col < 1 || col > columns) {
      return null;
    }
    return (row: row, col: col);
  }

  /// Distance entre l'écran et la rangée, en mètres.
  static double rowDistance(int row) {
    var z = _firstRowDistance;
    for (var i = 1; i <= row; i++) {
      z += kindOfRow(i) == SeatKind.recliner
          ? _reclinerRowGap
          : _standardRowGap;
    }
    return z;
  }

  /// Hauteur du sol de la rangée.
  static double rowFloor(int row) => row * rake;

  /// Position latérale du siège par rapport à l'axe central (négatif = gauche).
  static double seatX(int col) {
    var x = (col - (columns + 1) / 2) * seatPitch;
    if (col <= blocks.first) {
      x -= aisleExtra;
    } else if (col > columns - blocks.last) {
      x += aisleExtra;
    }
    return x;
  }

  static SeatStats statsFor(int row, int col) {
    final distance = rowDistance(row);
    final fov = 2 * math.atan((screenWidth / 2) / distance) * 180 / math.pi;
    final SeatViewQuality quality;
    if (distance <= 7.5) {
      quality = SeatViewQuality.upClose;
    } else if (distance <= 11.0) {
      quality = SeatViewQuality.sweetSpot;
    } else {
      quality = SeatViewQuality.fullPicture;
    }
    return SeatStats(
      row: row,
      col: col,
      distance: distance,
      fieldOfView: fov.round(),
      offset: seatX(col),
      quality: quality,
      kind: kindOfRow(row),
    );
  }
}
