import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';

import '../../theme/app_theme.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Session seance;

  const SeatSelectionScreen({super.key, required this.seance});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();

  String? _selectedSeat;
  List<String> _reservedSeats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReservedSeats();
  }

  Future<void> _loadReservedSeats() async {
    try {
      final seats = await _reservationService.getReservedSeats(
        widget.seance.id,
      );
      setState(() {
        _reservedSeats = seats;
      });
    } catch (e) {
      print('Erreur chargement sièges: $e');
    }
  }

  Future<void> _bookSeat() async {
    if (_selectedSeat == null) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authService.getUser();
      if (user == null) throw Exception('Utilisateur non connecté');

      await _reservationService.createReservation(
        userId: user.id,
        seanceId: widget.seance.id,
        numeroSiege: _selectedSeat!,
        prixTotal: widget.seance.prix,
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Choisir votre siège',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Écran de cinéma
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingLarge,
              vertical: AppTheme.paddingMedium,
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 50),
              painter: _ScreenPainter(),
            ),
          ),

          const SizedBox(height: 32),

          // Grille de sièges
          Expanded(
            child: SingleChildScrollView(
              /*padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingLarge,
              ),*/
              child: _buildSeatGrid(),
            ),
          ),

          // Légende
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _LegendItem(
                      color: AppTheme.surfaceColor.withOpacity(0.5),
                      label: 'Disponible',
                    ),
                    _LegendItem(
                      color: AppTheme.textSecondary,
                      label: 'Réservé',
                    ),
                    _LegendItem(
                      color: AppTheme.primaryColor,
                      label: 'Sélectionné',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Infos de la réservation
                if (_selectedSeat != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.paddingMedium),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Siège $_selectedSeat',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                            Text(
                              widget.seance.film,
                              //style: Theme.of(context).textTheme.bodyMedium,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.25,
                                color: Colors.white
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${widget.seance.prix} F CFA',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Bouton de réservation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedSeat == null || _isLoading
                        ? null
                        : _bookSeat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor:
                      AppTheme.textSecondary.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Réserver',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    const rows = 8;
    const seatsPerRow = 7;
    const totalSeats = rows * seatsPerRow;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lettre de la rangée
              SizedBox(
                width: 30,
                child: Text(
                  String.fromCharCode(65 + rowIndex),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Sièges
              ...List.generate(seatsPerRow, (seatIndex) {
                final seatNumber =
                    '${String.fromCharCode(65 + rowIndex)}${seatIndex + 1}';
                final isReserved = _reservedSeats.contains(seatNumber);
                final isSelected = _selectedSeat == seatNumber;

                return GestureDetector(
                  onTap: isReserved
                      ? null
                      : () {
                    setState(() {
                      _selectedSeat =
                      isSelected ? null : seatNumber;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isReserved
                          ? AppTheme.textSecondary
                          : isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.surfaceColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.event_seat,
                      size: 20,
                      color: isReserved
                          ? AppTheme.backgroundColor
                          : isSelected
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}

class _ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height,
    );

    canvas.drawPath(path, paint);

    // Texte "ÉCRAN"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ÉCRAN',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height + 8,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.event_seat,
            size: 14,
            color: color == AppTheme.textSecondary
                ? AppTheme.backgroundColor
                : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 0.4
          )
        ),
      ],
    );
  }
}