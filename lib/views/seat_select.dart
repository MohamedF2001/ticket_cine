import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
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
  List<String> reservedSeats = []; // Exemple
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadReservedSeats();
  }

  Future<void> _loadReservedSeats() async {
    try {
      final seats = await _reservationService.getReservedSeats(
        widget.seance.id,
      );
      setState(() {
        reservedSeats = seats;
      });
    } catch (e) {
      print("Erreur chargement sièges: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final prixTotal = selectedSeats.length * widget.seance.prix;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.2),
              title: const Text("Choisir votre siège"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            FadeInDown(child: _buildScreenView()),
            const SizedBox(height: 30),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildSeatGrid(),
              ),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildLegend(),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildInfoCard(prixTotal),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildBuyButton(prixTotal),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenView() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: CustomPaint(
        painter: GlowingArcPainter(),
        //ArcPainter(),
        child: const SizedBox(height: 50),
      ),
    );
  }

  Widget _buildSeatGrid() {
    const totalSeats = 40;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      itemCount: totalSeats,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final seatNumber = (index + 1).toString();
        final isReserved = reservedSeats.contains(seatNumber);
        final isSelected = selectedSeats.contains(seatNumber);

        Color iconColor;
        if (isReserved) {
          iconColor = Colors.white24;
        } else if (isSelected) {
          iconColor = AppTheme.primaryColor;
        } else {
          iconColor = Colors.white;
        }

        return GestureDetector(
          onTap: isReserved ? null : () => _toggleSeat(seatNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white10,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.chair_rounded,
              color: iconColor,
              size: 24,
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
        selectedSeats = [seatNumber]; // Remplace la liste par le nouveau siège
      }
    });
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(Colors.white, "Libre"),
          _legendItem(Colors.white24, "Occupé"),
          _legendItem(AppTheme.primaryColor, "Choisi"),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.chair_rounded, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoCard(int prixTotal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration(radius: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SIÈGE SÉLECTIONNÉ",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.2,
                      color: Colors.white54,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                selectedSeats.isEmpty ? "Aucun" : "Siège N°${selectedSeats.first}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "PRIX TOTAL",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      letterSpacing: 1.2,
                      color: Colors.white54,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                "${prixTotal.toStringAsFixed(2)} €",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(int prixTotal) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: selectedSeats.isEmpty || _isLoading ? null : _submitReservation,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            disabledBackgroundColor: Colors.white10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 20,
                )
              : const Text(
                  "Confirmer la réservation",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _submitReservation() async {
    if (selectedSeats.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    //try {
      final user = await _authService.getUser();
      if (user == null) {
        throw Exception("User not logged in");
      }

      /* // Vérifier si l'utilisateur a déjà une réservation
      final hasExistingReservation = await _reservationService
          .checkExistingReservation(
            userId: user.id,
            seanceId: widget.seance.id,
          );

      if (hasExistingReservation) {
        print("You already have a reservation for this session");
      } */

      // Créer une seule réservation
      await _reservationService.createReservation(
        userId: user.id,
        seanceId: widget.seance.id,
        numeroSiege: selectedSeats.first,
        prixTotal: widget.seance.prix,
      );
      _isLoading = false;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Reservaté avec succès!")));

    // } catch (e) {
    //   setState(() {
    //     _errorMessage = "Error: ${e.toString()}";
    //     print("icii: $e");
    //   });
    // } finally {
    //   setState(() {
    //     _isLoading = false;
    //   });
    // }
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      4,
      -size.height * 5,
      size.width,
      size.height * 6,
    );
    canvas.drawArc(rect, 2.4, -1.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlowingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      size.height,
    ); // courbe

    // glow (ombre floue rose)
    final glowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 10
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // ligne principale (arc)
    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint); // lueur
    canvas.drawPath(path, linePaint); // ligne
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
