<?php
// Database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "flutter_auth";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Initialize response array
$response = [];

// Check if form is submitted
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Get form data
    $serviceClass = $_POST['service_class'];
    $busNumber = $_POST['bus_number'];
    $departure = $_POST['departure'];
    $terminal = $_POST['terminal'];
    
    // Set destination based on the terminal
    $destination = ($terminal === "Cubao") ? "Dagupan" : "Cubao";

    // Determine available seats based on service class
    $availableSeats = ($serviceClass === "Regular") ? 49 : 45;
    $tripHours = $_POST['trip_hours'];
    $baseFare = $_POST['base_fare'];

    // Insert the ticket into the database
    $insertSql = "INSERT INTO tickets (service_class, bus_number, departure, terminal, destination, available_seats, trip_hours, base_fare) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $insertStmt = $conn->prepare($insertSql);
    $insertStmt->bind_param("sssssiis", $serviceClass, $busNumber, $departure, $terminal, $destination, $availableSeats, $tripHours, $baseFare);

    if ($insertStmt->execute()) {
        $response['message'] = "Ticket created successfully!";
    } else {
        $response['error'] = "Error creating ticket: " . $conn->error;
    }
}

// Fetch all existing tickets without filters
$sql = "SELECT * FROM tickets";
$result = $conn->query($sql);
$tickets = [];

while ($row = $result->fetch_assoc()) {
    $tickets[] = $row;
}

$response['tickets'] = $tickets;

$conn->close();

// Return JSON response
header('Content-Type: application/json');
echo json_encode($response);
?>
