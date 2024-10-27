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

// Check if ID is set
if (isset($_GET['id'])) {
    $id = $_GET['id'];
    
    // Prepare the delete statement
    $deleteSql = "DELETE FROM reserved_seats WHERE id = ?";
    $deleteStmt = $conn->prepare($deleteSql);
    $deleteStmt->bind_param("i", $id);
    
    if ($deleteStmt->execute()) {
        // Redirect back with success message
        header("Location: admin_dashboard.php?success=Seat deleted successfully.");
    } else {
        // Redirect back with error message
        header("Location: admin_dashboard.php?error=Error deleting seat: " . $conn->error);
    }
    
    $deleteStmt->close();
} else {
    // If ID not set, redirect back with error
    header("Location: admin_dashboard.php?error=No seat ID provided.");
}

$conn->close();
?>
