/*
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/models/reservation.dart';
import 'package:ticket_cine/services/reservation_service.dart';

import '../../theme/app_theme.dart';

class ReservationsScreen extends StatefulWidget {
  final UserModel user;

  const ReservationsScreen({super.key, required this.user});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  late Future<ReservationResponse> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      _reservationsFuture = _reservationService.getReservationsByUser(
        widget.user.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes billets',
                      //style: Theme.of(context).textTheme.displaySmall,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 48,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos réservations en cours',
                      //style: Theme.of(context).textTheme.bodyMedium,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des réservations
              Expanded(
                child: FutureBuilder<ReservationResponse>(
                  future: _reservationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadReservations,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.reservations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 80,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune réservation',
                              //style: Theme.of(context).textTheme.titleLarge,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  letterSpacing: 0.15,
                                  color: Colors.white
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vos billets apparaîtront ici',
                              //style: Theme.of(context).textTheme.bodyMedium,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final reservations = snapshot.data!.reservations;

                    return RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: () async {
                        _loadReservations();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];

                          return _TicketCard(
                            reservation: reservation,
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.surfaceColor,
                                  title: const Text('Annuler la réservation',style: TextStyle(
                                    color: Colors.white
                                  ),),
                                  content: const Text(
                                    'Êtes-vous sûr de vouloir annuler cette réservation ?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Non'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Oui'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await _reservationService.deleteReservation(
                                    reservation.id,
                                  );
                                  _loadReservations();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Réservation annulée'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onDelete;

  const _TicketCard({
    required this.reservation,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Partie supérieure avec l'affiche
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Row(
                  children: [
                    // Affiche du film
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${reservation.seance.imgFilm}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 120,
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.movie,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Informations
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.seance.film,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            text: reservation.seance.formattedDate,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.access_time,
                            text: reservation.seance.formattedTime,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.meeting_room,
                            text: '${reservation.seance.salle}',
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.event_seat,
                            text: 'Siège ${reservation.numeroSiege}',
                          ),
                        ],
                      ),
                    ),

                    // Bouton supprimer
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Ligne de séparation pointillée
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                ),
                child: Row(
                  children: List.generate(
                    50,
                        (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index % 2 == 0
                            ? AppTheme.textSecondary.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              // Partie inférieure avec le code-barres
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prix',
                              //style: Theme.of(context).textTheme.bodySmall,
                              style:TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              '${reservation.prixTotal}€',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reservation.statut,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Code-barres
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: reservation.id,
                      height: 60,
                      drawText: false,
                      color: AppTheme.textPrimary,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      reservation.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          //style: Theme.of(context).textTheme.bodyMedium,
          style:TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              color: Colors.white
          ),
        ),
      ],
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 20.0;
    const notchRadius = 15.0;
    final notchY = size.height * 0.65;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );

    // Encoche droite
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );

    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );

    // Encoche gauche
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: const Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}*/


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/models/reservation.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../theme/app_theme.dart';

class ReservationsScreen extends StatefulWidget {
  final UserModel user;

  const ReservationsScreen({super.key, required this.user});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  late Future<ReservationResponse> _reservationsFuture;
  final Set<String> _downloadedTickets = {}; // Stocke les IDs des tickets téléchargés

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    setState(() {
      _reservationsFuture = _reservationService.getReservationsByUser(
        widget.user.id,
      );
    });
  }

  Future<Uint8List?> _loadImageBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      print('Erreur de chargement image: $e');
      return null;
    }
  }

  Future<void> _downloadTicketPdf(Reservation reservation) async {
    try {
      setState(() {
        // Optionnel: afficher un loading
      });

      final pdf = pw.Document();

      // Charger l'image du film
      final imageBytes = await _loadImageBytes(
        'https://image.tmdb.org/t/p/w500${reservation.seance.imgFilm}',
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2, color: PdfColors.black),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    // pw.Text(
                    //   'MOVIEPASS',
                    //   style: pw.TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: pw.FontWeight.bold,
                    //     color: PdfColors.red,
                    //   ),
                    // ),
                    // pw.SizedBox(height: 5),
                    pw.Text(
                      'BILLET DE CINÉMA',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 10),

                    // Affiche du film
                    if (imageBytes != null)
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 1, color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 8,
                          verticalRadius: 8,
                          child: pw.Image(
                            pw.MemoryImage(imageBytes),
                            height: 180,
                            width: 280,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      pw.Container(
                        height: 180,
                        width: 280,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Affiche non disponible',
                            style: pw.TextStyle(color: PdfColors.grey600),
                          ),
                        ),
                      ),

                    pw.SizedBox(height: 5),

                    // Titre du film
                    pw.Text(
                      reservation.seance.film,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 2),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 2),

                    // Informations de la séance
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Date: ',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              reservation.seance.formattedDate,
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Heure: ',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              reservation.seance.formattedTime,
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 5),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Salle: ',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              reservation.seance.salle,
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Type: ',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              reservation.seance.typeSeance,
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Siège: ',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              reservation.numeroSiege,
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 2),
                    pw.Divider(thickness: 1),
                    pw.SizedBox(height: 2),

                    // Client et prix
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Client: ',
                              style: pw.TextStyle(
                                //fontSize: 10,
                                //color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              '${widget.user.prenom} ${widget.user.nom}',
                              style: pw.TextStyle(
                                //fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              '',
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.SizedBox(width: 2),
                            pw.Text(
                              '${reservation.prixTotal.toStringAsFixed(0)} F CFA',
                              style: pw.TextStyle(
                                //fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    // Code-barres
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: reservation.id,
                      width: 200,
                      height: 80,
                    ),

                    pw.SizedBox(height: 5),

                    /*pw.Text(
                      reservation.id,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                        letterSpacing: 1,
                      ),
                    ),

                    pw.SizedBox(height: 5),*/

                    pw.Text(
                      'Présentez ce billet à l\'entrée de la salle',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Sauvegarder et partager le PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ticket_${reservation.seance.film}_${widget.user.nom}_${widget.user.prenom}.pdf',
      );

      // Marquer le ticket comme téléchargé
      setState(() {
        _downloadedTickets.add(reservation.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket téléchargé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /*Future<void> _downloadTicketPdf(Reservation reservation) async {
    try {
      setState(() {
        // Optionnel: afficher un loading
      });

      final pdf = pw.Document();

      // Charger l'image du film
      final imageBytes = await _loadImageBytes(
        'https://image.tmdb.org/t/p/w500${reservation.seance.imgFilm}',
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 3, color: PdfColors.black),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(24),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    // Header
                    pw.Text(
                      'BILLET DE CINÉMA',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 20),

                    // Affiche du film
                    if (imageBytes != null)
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 2, color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 8,
                          verticalRadius: 8,
                          child: pw.Image(
                            pw.MemoryImage(imageBytes),
                            height: 200,
                            width: 300,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      pw.Container(
                        height: 200,
                        width: 300,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey300,
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Affiche non disponible',
                            style: pw.TextStyle(color: PdfColors.grey600),
                          ),
                        ),
                      ),

                    pw.SizedBox(height: 20),

                    // Titre du film
                    pw.Text(
                      reservation.seance.film,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),

                    pw.SizedBox(height: 15),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 15),

                    // Informations de la séance avec icônes
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        // Date
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe878), // calendar_today
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              reservation.seance.formattedDate,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Heure
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe192), // access_time
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Heure',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              reservation.seance.formattedTime,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),

                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        // Salle
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe30e), // meeting_room
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Salle',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              reservation.seance.salle,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Type
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe63e), // movie
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Type',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              reservation.seance.typeSeance,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Siège
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe1db), // event_seat
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Siège',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              reservation.numeroSiege,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 15),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 15),

                    // Client et prix
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        // Client
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe7fd), // person
                              size: 24,
                              color: PdfColors.grey800,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Client',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              '${widget.user.prenom} ${widget.user.nom}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Prix
                        pw.Column(
                          children: [
                            pw.Icon(
                              pw.IconData(0xe227), // attach_money
                              size: 24,
                              color: PdfColors.red,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Prix',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                            pw.Text(
                              '${reservation.prixTotal.toStringAsFixed(0)} F CFA',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 20),
                    pw.Divider(thickness: 2),
                    pw.SizedBox(height: 20),

                    // Code-barres
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.BarcodeWidget(
                        barcode: pw.Barcode.code128(),
                        data: reservation.id,
                        width: 300,
                        height: 80,
                        drawText: false,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text(
                      reservation.id,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey600,
                        letterSpacing: 2,
                      ),
                    ),

                    pw.SizedBox(height: 15),

                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Icon(
                            pw.IconData(0xe88f), // info
                            size: 16,
                            color: PdfColors.grey700,
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            'Présentez ce billet à l\'entrée de la salle',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Sauvegarder et partager le PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'ticket_${reservation.seance.film}_${widget.user.nom}_${widget.user.prenom}.pdf',
      );

      // Marquer le ticket comme téléchargé
      setState(() {
        _downloadedTickets.add(reservation.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket téléchargé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes billets',
                      //style: Theme.of(context).textTheme.displaySmall,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 28,
                          color: Colors.white
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vos réservations en cours',
                      //style: Theme.of(context).textTheme.bodyMedium,
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
          
              // Liste des réservations
              Expanded(
                child: FutureBuilder<ReservationResponse>(
                  future: _reservationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }
          
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erreur de chargement',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadReservations,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      );
                    }
          
                    if (!snapshot.hasData ||
                        snapshot.data!.reservations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 80,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune réservation',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vos billets apparaîtront ici',
                              //style: Theme.of(context).textTheme.bodyMedium,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  letterSpacing: 0.25,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      );
                    }
          
                    final reservations = snapshot.data!.reservations;
          
                    return RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: () async {
                        _loadReservations();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.paddingLarge),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          final isDownloaded = _downloadedTickets.contains(reservation.id);
          
                          return _TicketCard(
                            reservation: reservation,
                            isDownloaded: isDownloaded,
                            onDownload: () => _downloadTicketPdf(reservation),
                            onDelete: isDownloaded ? null : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: AppTheme.surfaceColor,
                                  title: const Text(
                                    'Annuler la réservation',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Êtes-vous sûr de vouloir annuler cette réservation ?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  actions: [
                                    TextButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Non'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusMedium,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Oui'),
                                    ),
                                  ],
                                ),
                              );
          
                              if (confirm == true) {
                                try {
                                  await _reservationService.deleteReservation(
                                    reservation.id,
                                  );
                                  _loadReservations();
          
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Réservation annulée'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Reservation reservation;
  final bool isDownloaded;
  final VoidCallback onDownload;
  final VoidCallback? onDelete;

  const _TicketCard({
    required this.reservation,
    required this.isDownloaded,
    required this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipPath(
        clipper: _TicketClipper(),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Partie supérieure avec l'affiche
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Row(
                  children: [
                    // Affiche du film
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${reservation.seance.imgFilm}',
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 120,
                          color: AppTheme.surfaceColor,
                          child: const Icon(
                            Icons.movie,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Informations
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reservation.seance.film,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            text: reservation.seance.formattedDate,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.access_time,
                            text: reservation.seance.formattedTime,
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.meeting_room,
                            text: '${reservation.seance.salle}',
                          ),
                          const SizedBox(height: 6),
                          _InfoRow(
                            icon: Icons.event_seat,
                            text: 'Siège ${reservation.numeroSiege}',
                          ),
                        ],
                      ),
                    ),

                    // Boutons d'action
                    Column(
                      children: [
                        // Bouton télécharger
                        IconButton(
                          onPressed: onDownload,
                          icon: Icon(
                            isDownloaded ? Icons.download_done : Icons.download,
                            color: isDownloaded ? Colors.green : AppTheme.primaryColor,
                          ),
                          tooltip: isDownloaded ? 'Déjà téléchargé' : 'Télécharger le ticket',
                        ),
                        // Bouton supprimer (désactivé si téléchargé)
                        IconButton(
                          onPressed: onDelete,
                          icon: Icon(
                            Icons.delete_outline,
                            color: onDelete == null
                                ? AppTheme.textSecondary.withOpacity(0.3)
                                : AppTheme.textSecondary,
                          ),
                          tooltip: onDelete == null
                              ? 'Impossible d\'annuler un ticket téléchargé'
                              : 'Annuler la réservation',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ligne de séparation pointillée
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingLarge,
                ),
                child: Row(
                  children: List.generate(
                    50,
                        (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index % 2 == 0
                            ? AppTheme.textSecondary.withOpacity(0.3)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),

              // Partie inférieure avec le code-barres
              Container(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prix',
                              //style: Theme.of(context).textTheme.bodySmall,
                              style:TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                  color: Colors.white
                              ),
                            ),
                            Text(
                              '${reservation.prixTotal.toStringAsFixed(0)}F CFA',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDownloaded
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDownloaded ? Colors.blue : Colors.green,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isDownloaded ? Icons.lock : Icons.check_circle,
                                color: isDownloaded ? Colors.blue : Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isDownloaded ? 'Validé' : reservation.statut,
                                style: TextStyle(
                                  color: isDownloaded ? Colors.blue : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Code-barres
                    BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: reservation.id,
                      height: 60,
                      drawText: false,
                      color: AppTheme.textPrimary,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      reservation.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        letterSpacing: 1,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          text,
          //style: Theme.of(context).textTheme.bodyMedium,
          style:TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              letterSpacing: 0.25,
              color: Colors.white
          ),
        ),
      ],
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 20.0;
    const notchRadius = 15.0;
    final notchY = size.height * 0.65;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );

    // Encoche droite
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );

    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );

    // Encoche gauche
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: const Radius.circular(radius),
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}