import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';

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
      backgroundColor: Colors.grey.withOpacity(0.3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Choisir votre siège",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildScreenView(),
          Expanded(child: _buildSeatGrid()),
          _buildLegend(),
          _buildInfoCard(prixTotal),
          _buildBuyButton(prixTotal),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: totalSeats,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        final seatNumber = (index + 1).toString();
        final isReserved = reservedSeats.contains(seatNumber);
        final isSelected = selectedSeats.contains(seatNumber);

        Color color;
        if (isReserved) {
          color = Colors.pink;
        } else if (isSelected) {
          color = Colors.cyanAccent;
        } else {
          color = Colors.grey[300]!;
        }

        return GestureDetector(
          onTap: isReserved ? null : () => _toggleSeat(seatNumber),
          child: Container(
            decoration: BoxDecoration(
              //color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              // Dessine une forme de siège miniature
              child: Icon(Icons.event_seat, color: color),
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendDot(Colors.grey[300]!, "Disponible"),
          _legendDot(Colors.pink, "Réservé"),
          _legendDot(Colors.cyanAccent, "Sélectionné"),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildInfoCard(int prixTotal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                selectedSeats.isEmpty
                    ? "Choisissez votre siège"
                    : "Siège • ${selectedSeats.first}",
                style: const TextStyle(color: Colors.white),
              ),
              //const SizedBox(height: 8),
              if (selectedSeats.isNotEmpty)
                Text(
                  "Total: €$prixTotal",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuyButton(int prixTotal) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed:
            selectedSeats.isEmpty || _isLoading ? null : _submitReservation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.5),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isLoading
                ? const SpinKitPulse(
              duration: Duration(seconds: 3),
              color: Colors.white70,
            )
                : const Text(
                  "Réserver",
                  style: TextStyle(fontSize: 18, color: Colors.white),
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
