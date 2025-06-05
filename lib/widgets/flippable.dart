import 'package:flutter/material.dart';
import 'package:ticket_cine/models/session_response.dart';

class FlippableCard extends StatefulWidget {
  final Session session;
  final VoidCallback onTap;

  const FlippableCard({super.key, required this.session, required this.onTap});

  @override
  _FlippableCardState createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isFront) {
          widget.onTap(); // Aller à la réservation
        } else {
          _flipCard(); // Retourner à l'avant
        }
      },
      onDoubleTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.1416;
          final isBack = angle > 3.1416 / 2;

          return Transform(
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
            alignment: Alignment.center,
            child:
                isBack
                    ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(3.1416),
                      child: _buildBack(),
                    )
                    : _buildFront(),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCard(
      imageUrl: 'https://image.tmdb.org/t/p/w500${widget.session.imgFilm}',
      overlay: true,
      extraWidget: Positioned(
        bottom: 8,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Double-cliquez pour voir les détails',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildBack() {
    return _buildCard(
      child: Container(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                widget.session.film,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        //Text('Heure : ${widget.session.formattedTime}'),
                        _buildInfoRow(
                          Icons.calendar_today,
                          widget.session.formattedTime.toString() +
                              " ${widget.session.formattedDate}",
                        ),
                        const SizedBox(height: 5),
                        //Text('Type : ${widget.session.typeSeance.toUpperCase()}'),
                        _buildInfoRow(
                          Icons.movie_filter,
                          widget.session.typeSeance.toUpperCase(),
                        ),
                        const SizedBox(height: 5),
                        //Text('Salle : ${widget.session.salle}'),
                        _buildInfoRow(Icons.room, widget.session.salle),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoRow(
                          Icons.event_seat,
                          widget.session.placesDisponibles.toString(),
                        ),
                        const SizedBox(height: 5),
                        //Text('Prix : ${widget.session.prix} €'),
                        _buildInfoRow(Icons.euro, widget.session.prix.toString()),
                        const SizedBox(height: 8),

                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Couleur du bouton
                  foregroundColor: Colors.white, // Couleur du texte
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordures arrondies
                  ),

                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: widget.onTap,
                child: const Text(
                  'Réserver',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle( color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    String? imageUrl,
    Widget? child,
    bool overlay = false,
    Widget? extraWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: SizedBox(
        height: 200,
        child: Card(
          color: Colors.grey,
          //margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: Colors.white.withOpacity(0.5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child:
                imageUrl != null
                    ? Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          //height: double.infinity,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                        ),
                        if (overlay)
                          Container(
                            padding: const EdgeInsets.all(12),
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                  image: NetworkImage(imageUrl)
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                              ),
                            ),
                            child: Text(
                              widget.session.film,
                              //"",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (extraWidget != null) extraWidget,
                      ],
                    )
                    : Container(color: Colors.white, child: child),
          ),
        ),
      ),
    );
  }
}
