<?php
header('Content-Type: application/json');

// Database configuration
$host = 'localhost';
$db_name = 'flutter_auth';
$username = 'root';
$password = '';

try {
    // Create a new PDO instance
    $pdo = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Get the request body
    $data = json_decode(file_get_contents("php://input"));

    // Fetch reserved seats for the bus trip
    $stmt = $pdo->prepare("SELECT seat FROM reserved_seats WHERE bus_number = ? AND departure = ?");
    $stmt->execute([$data->busNumber, $data->departure]);

    $reservedSeats = $stmt->fetchAll(PDO::FETCH_COLUMN);

    echo json_encode(['reservedSeats' => $reservedSeats]);
} catch (PDOException $e) {
    echo json_encode(['error' => $e->getMessage()]);
}
?>
