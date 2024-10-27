<?php
header('Content-Type: application/json');

$ticket_id = $_GET['ticket_id'];
// Replace with your database connection
$connection = new mysqli("localhost", 
"root", 
"", 
"flutter_auth");

if ($connection->connect_error) {
    die("Connection failed: " . $connection->connect_error);
}

$query = "SELECT seat_number FROM occupied_seats WHERE ticket_id = ?";
$stmt = $connection->prepare($query);
$stmt->bind_param("i", $ticket_id);
$stmt->execute();
$result = $stmt->get_result();

$occupiedSeats = [];
while ($row = $result->fetch_assoc()) {
    $occupiedSeats[] = $row['seat_number'];
}

echo json_encode($occupiedSeats);
$stmt->close();
$connection->close();
?>
