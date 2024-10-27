<?php
header('Content-Type: application/json');
include 'db_connection.php'; // Include your database connection script

if (isset($_GET['bus_number'])) {
    $bus_number = $_GET['bus_number'];

    // Prepare a SQL statement to fetch details for the specific bus
    $stmt = $conn->prepare("SELECT * FROM tickets WHERE bus_number = ?");
    $stmt->bind_param("s", $bus_number);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $ticketDetails = $result->fetch_assoc();
        echo json_encode($ticketDetails);
    } else {
        echo json_encode(['error' => 'No ticket found']);
    }
} else {
    echo json_encode(['error' => 'No bus number provided']);
}

$conn->close();
?>
