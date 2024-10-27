<?php
// Database connection
$servername = "localhost"; // Change if your database is hosted elsewhere
$username = "root";
$password = "";
$dbname = "flutter_auth";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $reservation_id = $_POST['id'];
    $bus_number = $_POST['bus_number'];
    $seat = $_POST['seat'];
    $user_id = $_POST['user_id'];
    $created_at = $_POST['created_at'];
    $terminal = $_POST['terminal'];
    $destination = $_POST['destination'];
    $service_class = $_POST['service_class'];
    $base_fare = $_POST['base_fare'];

    // Update the reservation in the database
    $query = "UPDATE reserved_seats SET bus_number = ?, seat = ?, user_id = ?, created_at = ?, terminal = ?, destination = ?, service_class = ?, base_fare = ? WHERE id = ?";
    $stmt = $conn->prepare($query);
    
    // Check if prepare() was successful
    if ($stmt) {
        $stmt->bind_param('ssssssssi', $bus_number, $seat, $user_id, $created_at, $terminal, $destination, $service_class, $base_fare, $reservation_id);
        
        if ($stmt->execute()) {
            echo "Reservation updated successfully.";
            // Optionally redirect to another page
            header('Location: reserved_seats_page.php'); // Change to your desired redirection page
            exit();
        } else {
            echo "Error updating reservation: " . $stmt->error; // Show error if execution fails
        }

        $stmt->close(); // Close the prepared statement
    } else {
        echo "Error preparing statement: " . $conn->error; // Show error if prepare fails
    }
} else {
    echo "Invalid request.";
}

// Close the database connection
$conn->close();
?>
