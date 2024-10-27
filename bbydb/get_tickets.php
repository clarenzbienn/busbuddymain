<?php
// Database connection
$servername = "localhost"; // Change if your database is hosted elsewhere
$username = "root";
$password = "";
$dbname = "flutter_auth";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Fetch tickets
$sql = "SELECT terminal, destination, service_class, bus_number, base_fare, departure, available_seats, trip_hours, totalavailable_seats FROM bus_tickets";
$result = $conn->query($sql);

$tickets = [];
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $tickets[] = $row;
    }
}

$conn->close();

// Return the tickets as JSON
header('Content-Type: application/json');
echo json_encode($tickets);
?>
