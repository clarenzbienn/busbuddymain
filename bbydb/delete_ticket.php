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



// Check if ticket ID is set
if (isset($_GET['id'])) {
    $ticket_id = $_GET['id'];

    // Delete the ticket
    $deleteSql = "DELETE FROM bus_tickets WHERE id = ?";
    $deleteStmt = $conn->prepare($deleteSql);
    $deleteStmt->bind_param("i", $ticket_id);

    if ($deleteStmt->execute()) {
        header("Location: admin_create_ticket.php?message=Ticket deleted successfully!");
        exit();
    } else {
        echo "Error deleting ticket: " . $conn->error;
    }

    $deleteStmt->close();
}

$conn->close();
?>
