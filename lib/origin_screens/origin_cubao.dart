import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:main/ticket_screens/seatselection.dart';
import 'package:main/ticket_screens/ticket_dashboard.dart';
import 'package:main/user_page.dart'; // Import the UserPage
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CubaoOrigin extends StatefulWidget {
  final String origin;
  final String userId;

  const CubaoOrigin(this.origin, {Key? key, required this.userId}) : super(key: key);

  @override
  _CubaoOriginState createState() => _CubaoOriginState();
}

class _CubaoOriginState extends State<CubaoOrigin> {
  List tickets = [];
  String searchQuery = '';
  String userData = '';
  bool isLoading = true;
  bool userIdFetched = false;
  String busTicketId = '';

  @override
  void initState() {
    super.initState();
    fetchTickets();
    if (widget.userId.isNotEmpty) {
      userIdFetched = true;
      fetchUserData();
    } else {
      setState(() {
        userIdFetched = false;
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserData() async {
    var userId = widget.userId;
    var url = 'http://192.168.100.185/bbydb/getUserData.php?userId=$userId';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['user_info'] is Map) {
          userData = 'Email: ${data['user_info']['email']}';
        } else {
          userData = data['user_info'].toString();
        }

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          userData = 'Failed to load user data. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userData = 'Error fetching user data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchTickets() async {
    final response = await http.get(Uri.parse('http://192.168.100.185/bbydb/get_tickets.php'));
    //final response = await http.get(Uri.parse('http://192.168.128.41/bbydb/get_tickets.php'));

    if (response.statusCode == 200) {
      setState(() {
        // Parse the tickets from the response
        List<dynamic> fetchedTickets = json.decode(response.body);

        // Get the current date and time
        DateTime now = DateTime.now();

        // Filter out tickets whose departure time has already passed
        tickets = fetchedTickets.where((ticket) {
          DateTime departureDateTime = DateTime.parse(ticket['departure']);
          return departureDateTime.isAfter(now); // Keep only future tickets
        }).toList();
      });
    } else {
      throw Exception('Failed to load tickets');
    }
  }


  @override
  Widget build(BuildContext context) {
    List filteredTickets = tickets.where((ticket) {
      return ticket['destination'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();


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
                // Encircled user icon in the upper-left corner
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, // Background color of the circle
                    ),
                    padding: EdgeInsets.all(0), // Smaller padding to reduce the circle's size
                    width: 35, // Control the width to adjust the circle size
                    height: 35, // Control the height to match the width for a perfect circle
                    child: IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.user,
                        size: 15, // Adjust the icon size to fit the smaller circle
                        color: Colors.red, // Color of the user icon
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserPage(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(width: 60),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 0.0),
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
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
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
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: filteredTickets.isEmpty
                  ? Center(child: Text('No tickets available.')) // Changed message
                  : ListView.builder(
                      itemCount: filteredTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = filteredTickets[index];
                        return TicketCard(ticket: ticket, userId: widget.userId);
                      },
                    ),
                  ),








            SizedBox(height: 5), // Smaller gap between the tickets and bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Home Button
                Container(
                  width: 170,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 0, 0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      topRight: Radius.zero,
                      bottomRight: Radius.zero,
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
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: 20,
                    ),
                    onPressed: () {
                    },
                  ),
                ),
                SizedBox(width: 0),
                // Ticket Button
                Container(
                  width: 170,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      bottomLeft: Radius.zero,
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
                      color: const Color.fromARGB(255, 237, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TicketDashboard(userId: widget.userId)),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10), // Adjust bottom padding to bring content higher

            // Display User ID at the bottom
            /*Text(
              'User ID: ${widget.userId}', // Display the user ID
              style: TextStyle(
                color: const Color.fromARGB(255, 76, 0, 255),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),*/
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}




class TicketCard extends StatefulWidget {
  final Map ticket;
  final String userId; // Add userId to constructor

  TicketCard({required this.ticket, required this.userId}); // Accept userId as a parameter

  @override
  _TicketCardState createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  @override
  Widget build(BuildContext context) {
    // Parse the departure date-time string into a DateTime object
    DateTime departureDateTime = DateTime.parse(widget.ticket['departure']);
    
    // Format the date and time as "10:50 AM - October 24, 2024"
    String formattedDeparture = DateFormat('h:mma - MMMM d, y').format(departureDateTime);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            return Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    SizedBox(height: 25),
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
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Fare: ₱',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.ticket['base_fare']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Display formatted departure date and time
                    Text.rich(
                      TextSpan(
                        text: 'Departure: ',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: formattedDeparture,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Trip Duration: ',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.ticket['trip_hours']} hours',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    /*Text.rich(
                      TextSpan(
                        text: 'Available Seats: ',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.ticket['available_seats']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),*/
                    /*SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        text: 'Total Available Seats: ',
                        style: TextStyle(fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.ticket['totalavailable_seats']}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),*/
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        String userId = widget.userId; // Use the userId passed to the widget
                        print("Navigating to SeatSelectionScreen with userId: $userId"); // Debug log

                        // Pass the selected ticket data to SeatSelection
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SeatSelection(
                                userId: userId,
                                ticket: widget.ticket, // Pass the selected ticket details
                                ticketDetails: {}, // Assuming this is still needed
                              );
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Select Seats',
                        style: TextStyle(color: Colors.white), // Set the text color here
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 0, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        foregroundColor: Colors.white, // This will also affect the text color
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.ticket['terminal']} → ${widget.ticket['destination']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Service Class: ${widget.ticket['service_class']}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('Bus Number: ${widget.ticket['bus_number']}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('Fare: ₱${widget.ticket['base_fare']}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('Departure: ${formattedDeparture}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              //Text('Available Seats: ${widget.ticket['available_seats']}', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}


//timestamp -nadedelete na after departure time