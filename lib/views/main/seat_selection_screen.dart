import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/movie_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';

import '../../theme/app_theme.dart';
import '../seat/cinema_3d_painter.dart';
import '../seat/seat_layout.dart';
import '../seat/seat_widgets.dart';

/// Choix du siège : plan de salle, puis vue 3D depuis le siège sélectionné.
///
/// Parcours : un tap sur un siège le sélectionne ; la caméra s'envole ensuite
/// vers ce siège (automatiquement après un court instant, ou via « Continuer »)
/// et la feuille d'infos propose « Changer de siège » ou « Réserver ».
class SeatSelectionScreen extends StatefulWidget {
  final Session seance;

  const SeatSelectionScreen({super.key, required this.seance});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen>
    with SingleTickerProviderStateMixin {
  /// Ouvre la vue 3D automatiquement après la sélection d'un siège.
  static const bool _autoOpenView = true;
  static const Duration _autoOpenDelay = Duration(milliseconds: 650);

  /// Multiplicateur de prix des rangées « recliner ».
  /// 1.0 = même prix que les sièges standard (comportement historique).
  static const double _reclinerPriceFactor = 1.0;

  static const List<String> _weekdays = [
    'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.', //
  ];
  static const List<String> _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', //
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.', //
  ];

  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();
  final SessionService _sessionService = SessionService();
  final MovieService _movieService = MovieService();

  late Session _seance;
  List<Session> _sessions = [];
  Set<String> _reservedSeats = {};
  String? _selectedSeat;
  bool _isLoading = false;

  /// Vrai quand la vue 3D est affichée (ou en cours d'ouverture).
  bool _view3d = false;
  int _viewRow = 0;
  int _viewCol = 1;

  ui.Image? _screenImage;
  Cinema3DPainter? _painter;
  Timer? _autoOpenTimer;
  int _seatsRequest = 0;

  /// 0 = plan de salle, 1 = vue depuis le siège.
  late final AnimationController _flight;

  @override
  void initState() {
    super.initState();
    _seance = widget.seance;
    _flight = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 700),
    );
    _loadReservedSeats();
    _loadSessions();
    _loadScreenImage();
  }

  @override
  void dispose() {
    _autoOpenTimer?.cancel();
    _flight.dispose();
    _screenImage?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Données
  // ---------------------------------------------------------------------------

  Future<void> _loadReservedSeats() async {
    final request = ++_seatsRequest;
    try {
      final seats = await _reservationService.getReservedSeats(_seance.id);
      if (!mounted || request != _seatsRequest) return;
      setState(() {
        _reservedSeats = seats.toSet();
        if (_selectedSeat != null && _reservedSeats.contains(_selectedSeat)) {
          _selectedSeat = null;
        }
      });
      if (_view3d && _selectedSeat == null) _closeView();
    } catch (e) {
      debugPrint('Erreur chargement sièges: $e');
    }
  }

  /// Autres horaires du même film, dans la même salle et le même jour.
  Future<void> _loadSessions() async {
    try {
      final base = widget.seance;
      final response = await _sessionService.getSeancesByFilm(
        base.filmId.toString(),
      );
      final sameDay = response.seances
          .where(
            (s) =>
                s.salle == base.salle &&
                s.date.year == base.date.year &&
                s.date.month == base.date.month &&
                s.date.day == base.date.day,
          )
          .toList();
      if (!sameDay.any((s) => s.id == base.id)) sameDay.add(base);
      sameDay.sort((a, b) => a.horaire.compareTo(b.horaire));
      if (!mounted) return;
      setState(() => _sessions = sameDay);
    } catch (e) {
      debugPrint('Erreur chargement séances: $e');
    }
  }

  /// Image affichée sur l'écran de cinéma : fond du film, sinon l'affiche.
  Future<void> _loadScreenImage() async {
    try {
      String? url;
      try {
        final details = await _movieService.fetchMovieDetails(
          widget.seance.filmId,
        );
        final backdrop = details.backdropPath;
        if (backdrop != null && backdrop.isNotEmpty) {
          url = 'https://image.tmdb.org/t/p/w780$backdrop';
        }
      } catch (_) {
        // On retombe sur l'affiche ci-dessous.
      }
      if (url == null && widget.seance.imgFilm.isNotEmpty) {
        url = 'https://image.tmdb.org/t/p/w500${widget.seance.imgFilm}';
      }
      if (url == null) return;
      final image = await _resolveImage(NetworkImage(url));
      if (!mounted) {
        image.dispose();
        return;
      }
      _screenImage?.dispose();
      setState(() => _screenImage = image);
    } catch (e) {
      debugPrint('Erreur chargement image écran: $e');
    }
  }

  Future<ui.Image> _resolveImage(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (completer.isCompleted) {
          stream.removeListener(listener);
          return;
        }
        // Référence propre à cet écran : l'image reste valide même si le cache
        // d'images de Flutter l'évince.
        completer.complete(info.image.clone());
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (!completer.isCompleted) completer.completeError(error, stackTrace);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _switchSession(Session session) {
    if (session.id == _seance.id || _isLoading) return;
    _autoOpenTimer?.cancel();
    setState(() {
      _seance = session;
      _selectedSeat = null;
      _reservedSeats = {};
    });
    _loadReservedSeats();
  }

  void _onSeatTap(String id) {
    if (_reservedSeats.contains(id) || _view3d) return;
    HapticFeedback.selectionClick();
    _autoOpenTimer?.cancel();
    setState(() => _selectedSeat = _selectedSeat == id ? null : id);
    if (_selectedSeat != null && _autoOpenView) {
      _autoOpenTimer = Timer(_autoOpenDelay, () {
        if (mounted && !_view3d && _selectedSeat != null) _openView();
      });
    }
  }

  void _openView() {
    final seat = _selectedSeat;
    if (seat == null || _view3d) return;
    final position = CinemaLayout.parse(seat);
    if (position == null) return;
    _autoOpenTimer?.cancel();
    setState(() {
      _view3d = true;
      _viewRow = position.row;
      _viewCol = position.col;
    });
    _flight.forward();
  }

  void _closeView() {
    if (!_view3d) return;
    setState(() => _view3d = false);
    _flight.reverse();
  }

  int _priceFor(String seatId) {
    final position = CinemaLayout.parse(seatId);
    final recliner =
        position != null &&
        CinemaLayout.kindOfRow(position.row) == SeatKind.recliner;
    return (_seance.prix * (recliner ? _reclinerPriceFactor : 1.0)).round();
  }

  Future<void> _bookSeat() async {
    final seat = _selectedSeat;
    if (seat == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.getUser();
      if (user == null) throw Exception('Utilisateur non connecté');

      await _reservationService.createReservation(
        userId: user.id,
        seanceId: _seance.id,
        numeroSiege: seat,
        prixTotal: _priceFor(seat),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Réservation effectuée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        Widget line(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: seatText(
                    dialogContext,
                    size: 13,
                    color: SeatPalette.muted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: seatText(
                    dialogContext,
                    size: 13,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );

        return AlertDialog(
          backgroundColor: SeatPalette.sheet,
          title: Text(
            _seance.film,
            style: seatText(dialogContext, size: 17, weight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_seance.salle.isNotEmpty) line('Salle', _seance.salle),
              line('Date', _formatDay(_seance.date)),
              line('Heure', _formatTime(_seance.horaire)),
              line('Type', _seance.typeSeance),
              line('Prix', '${_seance.prix} F CFA'),
              const SizedBox(height: 12),
              Text(
                'Touchez un siège pour voir la salle depuis votre place.',
                style: seatText(
                  dialogContext,
                  size: 12,
                  color: SeatPalette.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Fermer',
                style: seatText(
                  dialogContext,
                  size: 14,
                  weight: FontWeight.w600,
                  color: SeatPalette.selected,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Formats
  // ---------------------------------------------------------------------------

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  String _formatDay(DateTime d) =>
      '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

  String _qualityLabel(SeatViewQuality quality) {
    switch (quality) {
      case SeatViewQuality.upClose:
        return 'DE PRÈS';
      case SeatViewQuality.sweetSpot:
        return 'PLACE IDÉALE';
      case SeatViewQuality.fullPicture:
        return "VUE D'ENSEMBLE";
    }
  }

  double _smooth(double a, double b, double t) {
    final x = ((t - a) / (b - a)).clamp(0.0, 1.0).toDouble();
    return x * x * (3 - 2 * x);
  }

  Cinema3DPainter _painterFor() {
    final current = _painter;
    if (current != null &&
        current.row == _viewRow &&
        current.col == _viewCol &&
        identical(current.screenImage, _screenImage)) {
      return current;
    }
    return _painter = Cinema3DPainter(
      animation: _flight,
      row: _viewRow,
      col: _viewCol,
      screenImage: _screenImage,
    );
  }

  // ---------------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scene = RepaintBoundary(
      child: CustomPaint(painter: _painterFor(), size: Size.infinite),
    );
    final mapLayer = _buildMapLayer(context);
    final overlay = _buildViewOverlay(context);
    final sheet = _buildSheet(context);

    return PopScope<Object?>(
      canPop: !_view3d,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeView();
      },
      child: Scaffold(
        backgroundColor: SeatPalette.background,
        body: AnimatedBuilder(
          animation: _flight,
          builder: (context, _) {
            final t = _flight.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                Opacity(opacity: _smooth(0.02, 0.3, t), child: scene),
                IgnorePointer(
                  ignoring: _view3d,
                  child: Opacity(
                    opacity: 1 - _smooth(0.0, 0.32, t),
                    child: mapLayer,
                  ),
                ),
                IgnorePointer(
                  ignoring: !_view3d,
                  child: Opacity(opacity: _smooth(0.7, 1.0, t), child: overlay),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: IgnorePointer(
                    ignoring: !_view3d,
                    child: Transform.translate(
                      offset: Offset(0, (1 - _smooth(0.55, 1.0, t)) * 460),
                      child: sheet,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- Plan de salle ----------------------------------------------------------

  Widget _buildMapLayer(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildTimeChips(context),
            ],
          ),
        ),
        const ScreenArc(),
        Expanded(
          child: SeatMap(
            reservedSeats: _reservedSeats,
            selectedSeat: _selectedSeat,
            onSeatTap: _onSeatTap,
          ),
        ),
        const SeatLegend(),
        const SizedBox(height: 16),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final subtitle = [
      if (_seance.salle.isNotEmpty) _seance.salle,
      _formatDay(_seance.date),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: 'Retour',
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  _seance.film,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: seatText(context, size: 16, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: seatText(context, size: 11, color: SeatPalette.muted),
                ),
              ],
            ),
          ),
          _CircleButton(
            icon: Icons.info_outline_rounded,
            semanticLabel: 'Informations sur la séance',
            onTap: _showInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChips(BuildContext context) {
    final sessions = _sessions.isEmpty ? [_seance] : _sessions;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: SeatPalette.chipBar,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (final s in sessions) _buildTimeChip(context, s)],
        ),
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, Session session) {
    final active = session.id == _seance.id;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchSession(session),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? SeatPalette.chipSelected : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _formatTime(session.horaire),
              style: seatText(
                context,
                size: 13,
                weight: FontWeight.w600,
                color: active ? const Color(0xFF0B0B0D) : SeatPalette.muted,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              session.typeSeance.toUpperCase(),
              style: seatText(
                context,
                size: 8,
                weight: FontWeight.w600,
                color: active ? const Color(0xFF6B6A70) : SeatPalette.faint,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final seat = _selectedSeat;
    final position = seat == null ? null : CinemaLayout.parse(seat);
    final enabled = position != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        18,
        18,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: SeatPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  position == null
                      ? 'Choisissez votre siège'
                      : 'Rangée ${CinemaLayout.rowLetter(position.row)} · Siège ${position.col}',
                  style: seatText(context, size: 11, color: SeatPalette.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  seat == null ? '—' : '${_priceFor(seat)} F CFA',
                  style: seatText(context, size: 19, weight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: enabled ? SeatPalette.selected : const Color(0xFF1C1B1F),
            borderRadius: BorderRadius.circular(26),
            child: InkWell(
              borderRadius: BorderRadius.circular(26),
              onTap: enabled ? _openView : null,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                alignment: Alignment.center,
                child: Text(
                  'Continuer',
                  style: seatText(
                    context,
                    size: 15,
                    weight: FontWeight.w600,
                    color: enabled ? SeatPalette.onSelected : SeatPalette.faint,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Vue 3D -------------------------------------------------------------------

  Widget _buildViewOverlay(BuildContext context) {
    final seatId = CinemaLayout.seatId(_viewRow, _viewCol);
    return Align(
      alignment: Alignment.topCenter,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              _CircleButton(
                icon: Icons.chevron_left_rounded,
                semanticLabel: 'Revenir au plan de salle',
                background: const Color(0x99000000),
                onTap: _closeView,
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: SeatPalette.selected,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vue depuis $seatId',
                          style: seatText(
                            context,
                            size: 12,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final stats = CinemaLayout.statsFor(_viewRow, _viewCol);
    final seatId = stats.id;
    final recliner = stats.kind == SeatKind.recliner;
    final price = _priceFor(seatId);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: SeatPalette.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3338),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _qualityLabel(stats.quality),
                      style: seatText(
                        context,
                        size: 10,
                        weight: FontWeight.w600,
                        color: SeatPalette.selected,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rangée ${CinemaLayout.rowLetter(stats.row)}, Siège ${stats.col}',
                      style: seatText(
                        context,
                        size: 23,
                        weight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${recliner ? 'Recliner' : 'Standard'} · $price F CFA',
                      style: seatText(
                        context,
                        size: 12,
                        color: SeatPalette.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MiniSeatMap(row: stats.row, col: stats.col),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatTile(context, stats.distanceLabel, "à l'écran"),
              const SizedBox(width: 8),
              _buildStatTile(
                context,
                '${stats.fieldOfView}°',
                'champ de vision',
              ),
              const SizedBox(width: 8),
              _buildStatTile(context, stats.offsetLabel, stats.offsetCaption),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _closeView,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF3A3338)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Changer de siège',
                      style: seatText(
                        context,
                        size: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 14,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookSeat,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: SeatPalette.buttonLight,
                    disabledBackgroundColor: SeatPalette.buttonLight,
                    foregroundColor: const Color(0xFF0B0B0D),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Color(0xFF0B0B0D),
                          ),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Réserver · $price F CFA',
                            style: seatText(
                              context,
                              size: 14,
                              weight: FontWeight.w600,
                              color: const Color(0xFF0B0B0D),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(BuildContext context, String value, String caption) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: SeatPalette.tile,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x0DFFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: seatText(context, size: 19, weight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                caption,
                style: seatText(context, size: 10, color: SeatPalette.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.background = const Color(0xFF1A191D),
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
