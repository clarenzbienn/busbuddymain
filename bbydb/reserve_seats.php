<?php
header('Content-Type: application/json');

// Database connection parameters
$servername = "localhost"; // Replace with your server name
$username = "root"; // Replace with your database username
$password = ""; // Replace with your database password
$dbname = "flutter_auth"; // Replace with your database name

// Create a database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check the connection
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed: ' . $conn->connect_error]));
}

// Retrieve the raw POST data
$data = json_decode(file_get_contents('php://input'), true);

// Validate input data
if (!isset($data['userId'], $data['ticket'], $data['selectedSeats'], $data['totalFare'])) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid input']);
    exit;
}

// Sanitize input
$userId = $conn->real_escape_string($data['userId']);
$ticketId = (int)$data['ticket']['id']; // Assuming ticket details include an 'id' field
$ticketDetails = $conn->real_escape_string(json_encode($data['ticket']));
$selectedSeats = $conn->real_escape_string(implode(',', $data['selectedSeats']));
$totalFare = (float)$data['totalFare'];

// Check if seats are already reserved (Optional, depending on your requirements)
$reservedQuery = "SELECT selected_seats FROM reservations WHERE FIND_IN_SET('$selectedSeats', selected_seats)";
$reservedResult = $conn->query($reservedQuery);

if ($reservedResult->num_rows > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Some of the selected seats are already reserved']);
    exit;
}

// Prepare SQL to insert reservation
$sql = "INSERT INTO reservations (user_id, ticket_id, selected_seats, total_fare, ) VALUES ('$userId', '$ticketId', '$selectedSeats', '$totalFare')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Reservation confirmed']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Error: ' . $conn->error]);
}

// Close the database connection
$conn->close();
?>
