import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:main/ticket_screens/ticket_dashboard.dart';

class SeatSelection extends StatefulWidget {
  final String userId; // User ID
  final Map ticket; // Ticket data

  SeatSelection({required this.userId, required this.ticket, required Map ticketDetails});

  @override
  _SeatSelectionState createState() => _SeatSelectionState();
}

class _SeatSelectionState extends State<SeatSelection> {
  List<String> selectedSeats = [];
  List<String> reservedSeats = []; // List to hold reserved seats

  @override
  void initState() {
    super.initState();
    // Fetch reserved seats when the widget is initialized
    fetchReservedSeats().then((seats) {
      setState(() {
        reservedSeats = seats;
      });
    }).catchError((error) {
      print('Error fetching reserved seats: $error');
    });
  }

  // Function to fetch reserved seats from the API
  Future<List<String>> fetchReservedSeats() async {
    final response = await http.post(
      Uri.parse('http://192.168.100.185/bbydb/fetch_reserved_seats.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'busNumber': widget.ticket['bus_number'],
        'departure': widget.ticket['departure'],
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return List<String>.from(responseData['reservedSeats']);
    } else {
      throw Exception('Failed to load reserved seats');
    }
  }

  // Function to reserve seats
  Future<void> reserveSeats() async {
  // Prepare the reservation data
  final reservationData = {
    'userId': widget.userId,
    'fullname': await fetchFullname(widget.userId),
    'terminal': widget.ticket['terminal'],
    'destination': widget.ticket['destination'],
    'busNumber': widget.ticket['bus_number'],
    'departure': widget.ticket['departure'],
    'serviceClass': widget.ticket['service_class'],
    'seats': selectedSeats,
    'totalFare': (double.tryParse(widget.ticket['base_fare'].toString()) ?? 0.0) * selectedSeats.length,
    'baseFare': widget.ticket['base_fare'],
  };

  // Send reservation data to the PHP API
  final response = await http.post(
    Uri.parse('http://192.168.100.185/bbydb/seatreservation.php'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(reservationData),
  );

  // Handle the response
  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData.containsKey('error')) {
      // Show error message if reservation limit is exceeded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['error'])),
      );
    } else {
      // Proceed with successful reservation logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );
      // Update reservedSeats and clear selectedSeats...
      // Redirect to TicketDashboard after successful reservation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TicketDashboard(userId: widget.userId)),
      );
    }
  } else {
      // Show error message
      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${responseData['error']}')),
      );
    }
  }

  // Function to fetch the fullname based on the userId
  Future<String> fetchFullname(String userId) async {
    final response = await http.post(
      Uri.parse('http://192.168.100.185/bbydb/get_fullname.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['fullname'];
    } else {
      throw Exception('Failed to fetch fullname');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime departureDateTime = DateTime.parse(widget.ticket['departure']);
    String formattedDeparture = DateFormat('h:mma - MMMM d, y').format(departureDateTime);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            'lib/icons/bg_new.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(0, 194, 194, 194).withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 50,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'AVAILABLE SEATS',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Segoe UI',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Seat selection UI
                    for (int i = 1; i <= 10; i++)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int j = 0; j < 2; j++)
                              buildSeat('${String.fromCharCode(65 + j)}$i'),
                            const SizedBox(width: 60),
                            for (int j = 2; j < 4; j++)
                              buildSeat('${String.fromCharCode(67 + (j - 2))}$i'),
                          ],
                        ),
                      ),
                    // Additional row with 5 seats at the back (row E)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int j = 0; j < 5; j++)
                            buildSeat('E${j + 1}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Reserve Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 0, 0),
                  ),
                  onPressed: () {
                    // Show modal with user ID, bus details, and selected seats
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          height: 400,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.ticket['terminal']} → ${widget.ticket['destination']}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text.rich(
                                TextSpan(
                                  text: 'Service Class: ',
                                  style: TextStyle(fontSize: 18),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${widget.ticket['service_class']}',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text.rich(
                                TextSpan(
                                  text: 'Bus Number: ',
                                  style: TextStyle(fontSize: 18),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${widget.ticket['bus_number']}',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text.rich(
                                TextSpan(
                                  text: 'Total Fare: ₱ ',
                                  style: TextStyle(fontSize: 18),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: '${(double.tryParse(widget.ticket['base_fare'].toString()) ?? 0.0) * selectedSeats.length}',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Departure Time: $formattedDeparture',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Selected Seats: ${selectedSeats.join(', ')}',
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (selectedSeats.isNotEmpty) {
                                    reserveSeats();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Please select at least one seat.')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 250, 38, 38), // Set button color to red
                                ),
                                child: const Text('Confirm Reservation',style: TextStyle(color: Colors.white),),
                              ),

                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text(
                  'Reserve Selected Seats',
                  style: TextStyle(color: Colors.white),
                ),
              ), 
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to build the seat widget
  Widget buildSeat(String seatNumber) {
    final isReserved = reservedSeats.contains(seatNumber);
    final isSelected = selectedSeats.contains(seatNumber);

    return GestureDetector(
      onTap: () {
        if (!isReserved) {
          if (isSelected) {
            // Deselect seat if it's already selected
            setState(() {
              selectedSeats.remove(seatNumber);
            });
          } else {
            // Check if the user is trying to select more than 3 seats
            if (selectedSeats.length < 3) {
              setState(() {
                selectedSeats.add(seatNumber);
              });
            } else {
              // Show a message if the maximum is reached
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You can only select up to 3 seats.')),
              );
            }
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isReserved
              ? const Color.fromARGB(255, 161, 161, 161) // Reserved seats in red
              : isSelected
                  ? Colors.green // Selected seats in green
                  : const Color.fromARGB(255, 255, 255, 255), // Available seats in grey
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            seatNumber,
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}


//timestamp - may limit na per bus