import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:barcode_scan2/model/scan_result.dart';
import 'dart:ui';
import 'package:animate_do/animate_do.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_cine/theme/app_theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ticket_cine/auth/login_page.dart';
import 'package:ticket_cine/models/reservation.dart';
import 'package:ticket_cine/models/session_response.dart';
import 'package:ticket_cine/models/user_model.dart';
import 'package:ticket_cine/services/auth_service.dart';
import 'package:ticket_cine/services/reservation_service.dart';
import 'package:ticket_cine/services/seesion_service.dart';

class LeTicket extends StatefulWidget {
  final Reservation? reservation;
  final UserModel user;
  final VoidCallback? onTabPressed;
  final VoidCallback onLogout;

  const LeTicket({
    super.key,
    this.reservation,
    required this.user,
    this.onTabPressed,
    required this.onLogout,
  });
  @override
  State<LeTicket> createState() => LeTicketState();
}

class LeTicketState extends State<LeTicket> with TickerProviderStateMixin {
  double offsetX = 0;
  double offsetY = 0;
  bool isDragging = false;
  final AuthService _authService = AuthService();

  void _onDragEnd() {
    if (offsetY > 100 || offsetX.abs() > 100) {
      // Si on a glissé assez loin, on envoie la carte au fond
      setState(() {
        final first = _userReservations.removeAt(0);
        _userReservations.add(first);
        offsetX = 0;
        offsetY = 0;
        isDragging = false;
      });
    } else {
      // Sinon, on remet en place
      setState(() {
        offsetX = 0;
        offsetY = 0;
        isDragging = false;
      });
    }
  }

  final ReservationService _reservationService = ReservationService();
  final SessionService _sessionService = SessionService();

  Reservation? _reservation;
  Session? _session;
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  List<Reservation> _userReservations = [];

  // Permet d'appeler fetchSeances() depuis l'extérieur
  void refreshData() {
    _loadUserReservations();
  }

  @override
  void initState() {
    super.initState();
    _loadUserReservations();
    /* if (widget.reservation != null) {
      _reservation = widget.reservation;
      _loadTicketDetails();
    } else {
      // Si aucune réservation n'est fournie, charger toutes les réservations de l'utilisateur
      _loadUserReservations();
    } */
    // Ajoutez ceci pour gérer le premier chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onTabPressed != null) {
        widget.onTabPressed!();
      }
    });
  }

  Future<void> _loadTicketDetails() async {
    if (_reservation == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Charger les détails de la séance
      final session = await _sessionService.getSeanceById(
        _reservation!.seance.id,
      );

      // Charger les infos utilisateur
      final user = await _authService.getUser();

      setState(() {
        _session = session;
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de chargement des détails: $e";
        print(_errorMessage);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserReservations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer l'utilisateur actuel
      final user = await _authService.getUser();

      if (user == null) {
        throw Exception("Utilisateur non connecté");
      }

      setState(() {
        _user = user;
        print(" User: ${user.nom} ${user.prenom}");
      });

      // Récupérer toutes les réservations de l'utilisateur
      /* final reservations = await _reservationService.getReservationsByUser(
        user.id,
      );

      setState(() {
        _userReservations = reservations;
        _isLoading = false;
      }); */
      final reservationResponse = await _reservationService
          .getReservationsByUser(user.id);
      setState(() {
        _userReservations =
            reservationResponse.reservations; // Accéder via .reservations
        // ...
      });
      Text("Aucune réservation", style: TextStyle(color: Colors.white));
      // S'il y a des réservations, charger la première
      print("Réservations chargées: ${_userReservations.length}");
      if (_userReservations.isNotEmpty) {
        setState(() {
          _reservation = _userReservations.first;
        });
        print(
          "Première réservation film: ${_userReservations.first.seance.film}",
        );
        print(
          "Première réservation film: ${_userReservations.first.seance.imgFilm}",
        );
        await _loadTicketDetails();
      } else {
        setState(() {
          _errorMessage = "Aucune réservation trouvée";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de chargement des réservations: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _scanBarcode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });

        // Supposons que le code-barres contient l'ID de réservation
        final reservationId = result.rawContent;
        final reservation = await _reservationService.getReservationById(
          reservationId,
        );

        setState(() {
          _reservation = reservation;
          _isLoading = false;
        });

        await _loadTicketDetails();
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de scan: $e";
      });
    }
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

  Future<void> _downloadPdf() async {
    if (_reservation == null || _session == null || _user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Aucun ticket sélectionné")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final pdf = pw.Document();

      // Ajout d'une image de fond stylisée
      //final image = await networkImage(
      //  'https://image.tmdb.org/t/p/w500${_session!.imgFilm}',
      //);
      // Chargez l'image en bytes
      final imageBytes = await _loadImageBytes(
        'https://image.tmdb.org/t/p/w500${_userReservations.first.seance.imgFilm}',
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          build: (pw.Context context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2, color: PdfColors.black),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'TICKET CINÉMA',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    if (imageBytes != null)
                      pw.Image(
                        pw.MemoryImage(imageBytes),
                        height: 200,
                        width: 300,
                        fit: pw.BoxFit.cover,
                      )
                    else
                      pw.Container(
                        height: 200,
                        color: PdfColors.grey300,
                        child: pw.Center(
                          child: pw.Text('Affiche non disponible'),
                        ),
                      ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      _userReservations.first.seance.film,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Date: ${_formatDate(_session!.formattedDate)}',
                        ),
                        pw.Text(
                          'Heure: ${_formatTime(_session!.formattedTime)}',
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Salle: ${_userReservations.first.seance.salle}',
                        ),
                        pw.Text(
                          'Type: ${_userReservations.first.seance.typeSeance}',
                        ),
                        pw.Text('Siège: ${_reservation!.numeroSiege}'),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      '${_user!.prenom} ${_user!.nom}',
                      style: pw.TextStyle(fontSize: 16),
                    ),
                    pw.SizedBox(height: 10),
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: _reservation!.id,
                      width: 200,
                      height: 80,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Scannez ce code à l\'entrée',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Options de partage/impression
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'ticket_${_userReservations.first.seance.film}_${_reservation!.id}_${widget.user.nom}_${widget.user.prenom}.pdf',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PDF généré avec succès")));
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur ICI: ${e.toString()}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String date) {
    // Format la date selon vos besoins (peut nécessiter un package comme intl)
    return date;
  }

  String _formatTime(String time) {
    // Format l'heure selon vos besoins
    return time;
  }

  void _onMenuSelected(String value) async {
    switch (value) {
      case 'profile':
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Profil utilisateur'),
                content: Text(
                  'Nom : ${widget.user.nom}\n'
                  'Prénom : ${widget.user.prenom}\n'
                  'Numéro : ${widget.user.numero}',
                ),
              ),
        );
        break;

      case 'reservations':
        // Rediriger vers la page des réservations (à créer)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigation vers mes réservations (à faire)')),
        );
        break;

      case 'change_password':
        _showChangePasswordDialog();
        break;

      case 'logout':
        try {
          await AuthService().logout();
          widget.onLogout(); // Redirection propre
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la déconnexion : $e')),
          );
        }
        break;
    }
  }

  void _showChangePasswordDialog() {
    final _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Changer le mot de passe'),
            content: TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(onPressed: () async {}, child: const Text('Valider')),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.2),
              title: const Text("Mes Tickets"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUserReservations,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: _isLoading && _userReservations.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
            : _userReservations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 80, color: Colors.white10),
                        SizedBox(height: 20),
                        Text("Aucune réservation", style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 320,
                          height: 600,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: List.generate(_userReservations.length, (index) {
                              final ticket = _userReservations[index];
                              final isTop = index == 0;

                              final topOffset = index * 8.0;
                              final leftOffset = index * 4.0;
                              final rotation = (index % 2 == 0 ? -1 : 1) * 0.02 * index;

                              return AnimatedPositioned(
                                duration: Duration(milliseconds: isDragging ? 0 : 300),
                                top: isTop ? offsetY + 50 : topOffset + 50,
                                left: isTop ? offsetX : leftOffset,
                                child: Transform.rotate(
                                  angle: isTop ? offsetX * 0.001 : rotation,
                                  child: GestureDetector(
                                    onPanStart: (_) {
                                      if (isTop) setState(() => isDragging = true);
                                    },
                                    onPanUpdate: (details) {
                                      if (!isTop) return;
                                      setState(() {
                                        offsetX += details.delta.dx;
                                        offsetY += details.delta.dy;
                                      });
                                    },
                                    onPanEnd: (_) => _onDragEnd(),
                                    child: FadeInUp(
                                      duration: Duration(milliseconds: 500 + (index * 100)),
                                      child: _buildTicketCard(ticket),
                                    ),
                                  ),
                                ),
                              );
                            }).reversed.toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      floatingActionButton: _userReservations.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _downloadPdf,
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text("Télécharger PDF", style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTicketCard(Reservation ticket) {
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        width: 300,
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Stack(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w500${ticket.seance.imgFilm}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white.withOpacity(0.8)],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    ticket.seance.film,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTicketInfo("DATE", ticket.seance.formattedDate),
                      _buildTicketInfo("HEURE", ticket.seance.formattedTime),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTicketInfo("SALLE", ticket.seance.salle),
                      _buildTicketInfo("SIÈGE", ticket.numeroSiege),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(color: Colors.black12, thickness: 1),
                  const SizedBox(height: 15),
                  BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: ticket.id,
                    width: 200,
                    height: 80,
                    drawText: false,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.id.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 20;

    path.moveTo(0, 0);
    path.lineTo(0, size.height / 3 - radius);
    path.arcToPoint(
      Offset(0, size.height / 3 + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height - radius);
    path.arcToPoint(
      Offset(radius, size.height),
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width - radius, size.height);
    path.arcToPoint(
      Offset(size.width, size.height - radius),
      radius: Radius.circular(radius),
    );
    path.lineTo(size.width, size.height / 3 + radius);
    path.arcToPoint(
      Offset(size.width, size.height / 3 - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class TicketClipperr extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    double radius = 20;

    // Départ en haut à gauche avec arrondi
    path.moveTo(0 + radius, 0);
    path.arcToPoint(
      Offset(0, radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Entaille gauche
    path.lineTo(0, size.height / 3 - radius);
    path.arcToPoint(
      Offset(0, size.height / 3 + radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(0, size.height - radius);

    // Coin bas gauche arrondi
    path.arcToPoint(
      Offset(radius, size.height),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Bas droit
    path.lineTo(size.width - radius, size.height);

    // Coin bas droit arrondi
    path.arcToPoint(
      Offset(size.width, size.height - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Entaille droite
    path.lineTo(size.width, size.height / 3 + radius);
    path.arcToPoint(
      Offset(size.width, size.height / 3 - radius),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, radius);

    // Coin haut droit arrondi
    path.arcToPoint(
      Offset(size.width - radius, 0),
      radius: Radius.circular(radius),
      clockwise: false,
    );

    // Haut gauche
    path.lineTo(radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
