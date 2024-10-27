import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class TicketDashboard extends StatefulWidget {
  final String userId;

  TicketDashboard({required this.userId});

  @override
  _TicketDashboardState createState() => _TicketDashboardState();
}

class _TicketDashboardState extends State<TicketDashboard> {
  List<dynamic> _reservations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.185/bbydb/fetch_reservations.php?userId=${widget.userId}'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log the response body

      if (response.statusCode == 200) {
        setState(() {
          _reservations = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupReservations(List<dynamic> reservations) {
    Map<String, List<Map<String, dynamic>>> groupedReservations = {};

    for (var reservation in reservations) {
      String key = '${reservation['terminal']}-${reservation['destination']}-${reservation['service_class']}-${reservation['bus_number']}';
      if (!groupedReservations.containsKey(key)) {
        groupedReservations[key] = [];
      }
      groupedReservations[key]!.add(reservation);
    }

    return groupedReservations;
  }

  String _checkTicketStatus(DateTime departureTime) {
    DateTime now = DateTime.now();
    return departureTime.isAfter(now) ? 'Active' : 'Expired';
  }

  Widget _buildReservationCard(List<Map<String, dynamic>> reservations) {
    var firstReservation = reservations[0];
    String terminal = firstReservation['terminal'] ?? 'Unknown Terminal';
    String destination = firstReservation['destination'] ?? 'Unknown Destination';
    String serviceClass = firstReservation['service_class'] ?? 'N/A';
    String busNumber = firstReservation['bus_number'] ?? 'N/A';
    double totalFare = reservations.fold(0, (sum, res) => sum + (res['base_fare'] ?? 0));

    String seatNumbers = reservations.map((res) => res['seat']).join(', ');

    String formattedFare = '₱${totalFare.toStringAsFixed(2)}';
    String formattedDeparture = DateFormat('h:mm a - MMMM d, y').format(
        DateTime.parse(firstReservation['departure']));

    DateTime departureTime = DateTime.parse(firstReservation['departure']);
    String ticketStatus = _checkTicketStatus(departureTime);

    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$terminal → $destination',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Seats: $seatNumbers', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Service Class: $serviceClass', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Bus Number: $busNumber', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Total Fare: $formattedFare', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Departure: $formattedDeparture', style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Status: $ticketStatus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ticketStatus == 'Active' ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current date and time
    DateTime now = DateTime.now();

    // Include all reservations, regardless of status
    List<dynamic> filteredReservations = _reservations.where((reservation) {
      DateTime departureTime = DateTime.parse(reservation['departure']);
      return reservation['destination']?.toLowerCase()?.contains(_searchQuery.toLowerCase()) == true;
    }).toList();

    // Group the filtered reservations
    Map<String, List<Map<String, dynamic>>> groupedReservations = _groupReservations(filteredReservations);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/icons/bg_new.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 40.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(width: 70),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset(
                    'lib/icons/logo.png',
                    height: 35,
                    width: 150,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for a destination',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.red),
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (groupedReservations.isEmpty)
              Center(child: Text('No reservations found.'))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: groupedReservations.length,
                  itemBuilder: (context, index) {
                    String key = groupedReservations.keys.elementAt(index);
                    List<Map<String, dynamic>> reservations = groupedReservations[key]!;
                    return _buildReservationCard(reservations);
                  },
                ),
              ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Adjust this value as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Home Button
                  Container(
                    width: 170,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.home,
                        color: const Color.fromARGB(255, 237, 0, 0),
                        size: 20,
                      ),
                      onPressed: () {
                        // Handle home button press
                      },
                    ),
                  ),
                  SizedBox(width: 0),
                  // Ticket Button
                  Container(
                    width: 170,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 237, 0, 0),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.ticketAlt,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 20,
                      ),
                      onPressed: () {
                        // Handle ticket button press
                      },
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
}
