<?php
header('Content-Type: application/json');

// Database configuration
$host = 'localhost';
$dbname = 'flutter_auth';
$username = 'root';
$password = '';

// Create a connection
$conn = new mysqli($host, $username, $password, $dbname);

// Check for a connection error
if ($conn->connect_error) {
    die(json_encode(['error' => 'Database connection failed']));
}

// Get the userId parameter from the query string
$userId = isset($_GET['userId']) ? $_GET['userId'] : '';

// Ensure userId is provided
if (empty($userId)) {
    echo json_encode(['error' => 'User ID is required']);
    exit;
}

// Query to fetch reservations based on userId
$sql = "SELECT bus_number, seat, departure, created_at, destination, terminal, service_class, base_fare FROM reserved_seats WHERE user_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $userId);
$stmt->execute();
$result = $stmt->get_result();

// Fetch all reservations
$reservations = [];
while ($row = $result->fetch_assoc()) {
    $reservations[] = $row;
}

// Output the reservations as JSON
echo json_encode($reservations);

// Close the statement and connection
$stmt->close();
$conn->close();
?>
