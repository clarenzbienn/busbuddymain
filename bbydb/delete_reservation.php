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

// Check if the reservation ID is set
if (isset($_GET['id'])) {
    $reservationId = $_GET['id'];

    // Get the bus number associated with the reservation
    $reservationQuery = "SELECT bus_number FROM reserved_seats WHERE id = ?";
    $stmt = $conn->prepare($reservationQuery);
    $stmt->bind_param("i", $reservationId);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $reservationData = $result->fetch_assoc();
        $busNumber = $reservationData['bus_number'];

        // Delete the reservation
        $deleteReservationQuery = "DELETE FROM reserved_seats WHERE id = ?";
        $deleteStmt = $conn->prepare($deleteReservationQuery);
        $deleteStmt->bind_param("i", $reservationId);
        $deleteStmt->execute();

        // Check if the deletion was successful
        if ($deleteStmt->affected_rows > 0) {
            // Check if there are any remaining reservations for the same bus number
            $checkReservationsQuery = "SELECT COUNT(*) AS total FROM reserved_seats WHERE bus_number = ?";
            $checkStmt = $conn->prepare($checkReservationsQuery);
            $checkStmt->bind_param("s", $busNumber);
            $checkStmt->execute();
            $countResult = $checkStmt->get_result();
            $countData = $countResult->fetch_assoc();

            // If no reservations left, delete the corresponding bus ticket
            if ($countData['total'] == 0) {
                $deleteBusTicketQuery = "DELETE FROM bus_tickets WHERE bus_number = ?";
                $deleteBusTicketStmt = $conn->prepare($deleteBusTicketQuery);
                $deleteBusTicketStmt->bind_param("s", $busNumber);
                $deleteBusTicketStmt->execute();
            }

            // Redirect to the admin_create_ticket.php page after successful deletion
            header("Location: admin_create_ticket.php?message=Reservation deleted successfully");
            exit(); // Always exit after header redirection
        } else {
            echo "Error deleting reservation.";
        }
    } else {
        echo "No reservation found.";
    }

    $stmt->close();
}

$conn->close();
?>
