import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/reservation.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

class LeTicket extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;

  const LeTicket({super.key, required this.user, required this.onLogout});

  @override
  State<LeTicket> createState() => LeTicketState();
}

class LeTicketState extends State<LeTicket> {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void refreshData() {
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    try {
      final response = await _reservationService.getReservationsByUser(widget.user.id);
      setState(() {
        _reservations = response.reservations;
      });
    } catch (e) {
      print("Erreur: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mes Réservations"),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: SpinKitFadingCircle(color: AppColors.primary))
          : _reservations.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = _reservations[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child: _buildTicketCard(reservation),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          const Text(
            "Aucun ticket trouvé",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w200${reservation.seance.imgFilm}',
                    width: 80,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 120,
                      color: Colors.white12,
                      child: const Icon(Icons.broken_image, color: Colors.white24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.seance.film,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _iconInfo(Icons.calendar_today, reservation.seance.formattedDate),
                      _iconInfo(Icons.access_time, reservation.seance.formattedTime),
                      _iconInfo(Icons.event_seat, "Siège: ${reservation.numeroSiege}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1, indent: 20, endIndent: 20),
          Padding(
            padding: const EdgeInsets.all(20),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: "RESERVATION-${reservation.id}",
              color: Colors.white,
              width: double.infinity,
              height: 60,
              drawText: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
