import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';

class SeatSelectionPage extends StatefulWidget {
  final Session seance;

  const SeatSelectionPage({Key? key, required this.seance}) : super(key: key);

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();

  List<String> selectedSeats = [];
  List<String> reservedSeats = [];
  bool _isLoading = false;
  bool _isReserving = false;

  @override
  void initState() {
    super.initState();
    _loadReservedSeats();
  }

  Future<void> _loadReservedSeats() async {
    setState(() => _isLoading = true);
    try {
      final seats = await _reservationService.getReservedSeats(widget.seance.id);
      setState(() {
        reservedSeats = seats;
      });
    } catch (e) {
      print("Erreur chargement sièges: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prixTotal = selectedSeats.length * widget.seance.prix;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Choisir vos places"),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildScreenView(),
          const SizedBox(height: 40),
          Expanded(
            child: _isLoading
              ? const Center(child: SpinKitPulse(color: AppColors.primary))
              : FadeInUp(child: _buildSeatGrid()),
          ),
          _buildLegend(),
          _buildBottomPanel(prixTotal),
        ],
      ),
    );
  }

  Widget _buildScreenView() {
    return Column(
      children: [
        Container(
          height: 5,
          width: MediaQuery.of(context).size.width * 0.7,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "ÉCRAN",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: 48, // 6 rows of 8 seats
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final seatNumber = (index + 1).toString();
        final isReserved = reservedSeats.contains(seatNumber);
        final isSelected = selectedSeats.contains(seatNumber);

        return GestureDetector(
          onTap: isReserved ? null : () => _toggleSeat(seatNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isReserved
                  ? Colors.white12
                  : isSelected
                      ? AppColors.primary
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isReserved
                    ? Colors.transparent
                    : isSelected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.event_seat_rounded,
                size: 20,
                color: isReserved
                    ? Colors.white24
                    : isSelected
                        ? Colors.black
                        : AppColors.primary.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleSeat(String seatNumber) {
    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(Colors.transparent, "Libre", borderColor: AppColors.primary.withOpacity(0.3)),
          const SizedBox(width: 24),
          _legendItem(AppColors.primary, "Choisi"),
          const SizedBox(width: 24),
          _legendItem(Colors.white12, "Occupé"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomPanel(int prixTotal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total", style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                Text(
                  "$prixTotal FCFA",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedSeats.isEmpty || _isReserving ? null : _submitReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: _isReserving
                  ? const SpinKitThreeBounce(color: Colors.black, size: 20)
                  : const Text("Réserver", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReservation() async {
    setState(() => _isReserving = true);
    try {
      final user = await _authService.getUser();
      if (user == null) throw Exception("Non connecté");

      for (var seat in selectedSeats) {
        await _reservationService.createReservation(
          userId: user.id,
          seanceId: widget.seance.id,
          numeroSiege: seat,
          prixTotal: widget.seance.prix,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Réservation effectuée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString()}"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isReserving = false);
    }
  }
}
