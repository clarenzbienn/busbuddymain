<?php 
// Database connection
$servername = "localhost"; 
$username = "root";
$password = "";
$dbname = "flutter_auth";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle the form submission for updating reservation
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['id'])) {
    $reservation_id = $_POST['id'];
    $bus_number = $_POST['bus_number'];
    $seat = $_POST['seat'];
    $user_id = $_POST['user_id'];
    $created_at = $_POST['created_at'];
    $terminal = $_POST['terminal'];
    $destination = $_POST['destination'];
    $service_class = $_POST['service_class'];
    $base_fare = $_POST['base_fare'];
    $departure = $_POST['departure'];

    // Update reservation in the database
    $updateQuery = "UPDATE reserved_seats SET bus_number = ?, seat = ?, user_id = ?, created_at = ?, terminal = ?, destination = ?, service_class = ?, base_fare = ?, departure = ? WHERE id = ?";
    $updateStmt = $conn->prepare($updateQuery);

    if ($updateStmt) {
        $updateStmt->bind_param('ssssssssis', $bus_number, $seat, $user_id, $created_at, $terminal, $destination, $service_class, $base_fare, $departure, $reservation_id);
        $updateStmt->execute();
        
        if ($updateStmt->affected_rows > 0) {
            echo "Reservation updated successfully.";
        } else {
            echo "No changes made or reservation not found.";
        }

        $updateStmt->close();
    } else {
        echo "Error preparing update statement: " . $conn->error;
    }
}

// Fetch grouped reservation details from the database if GET request
if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['bus_number']) && isset($_GET['user_id'])) {
    $bus_number = $_GET['bus_number'];
    $user_id = $_GET['user_id'];

    // Debug: Check the GET parameters
    var_dump($_GET); // This will show the content of the $_GET array

    // Fetch reservation details grouped by bus number and user id
    $query = "SELECT * FROM reserved_seats WHERE bus_number = ? AND user_id = ?";
    $stmt = $conn->prepare($query);
    
    if ($stmt) {
        $stmt->bind_param('ss', $bus_number, $user_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            echo "<h1>Edit Reservations</h1>";
            while ($reservation = $result->fetch_assoc()) {
                ?>
                <form method="POST" action="">
                    <input type="hidden" name="id" value="<?php echo htmlspecialchars($reservation['id']); ?>">
                    <label for="bus_number">Bus Number:</label>
                    <input type="text" name="bus_number" value="<?php echo htmlspecialchars($reservation['bus_number'] ?? ''); ?>" required>
                    <label for="seat">Seat Numbers:</label>
                    <input type="text" name="seat" value="<?php echo htmlspecialchars($reservation['seat'] ?? ''); ?>" required>
                    <label for="user_id">Reserved By:</label>
                    <input type="text" name="user_id" value="<?php echo htmlspecialchars($reservation['user_id'] ?? ''); ?>" required>
                    <label for="created_at">Reservation Time:</label>
                    <input type="text" name="created_at" value="<?php echo htmlspecialchars($reservation['created_at'] ?? ''); ?>" required>
                    <label for="terminal">Terminal:</label>
                    <input type="text" name="terminal" value="<?php echo htmlspecialchars($reservation['terminal'] ?? ''); ?>" required>
                    <label for="destination">Destination:</label>
                    <input type="text" name="destination" value="<?php echo htmlspecialchars($reservation['destination'] ?? ''); ?>" required>
                    <label for="service_class">Service Class:</label>
                    <input type="text" name="service_class" value="<?php echo htmlspecialchars($reservation['service_class'] ?? ''); ?>" required>
                    <label for="base_fare">Total Fare:</label>
                    <input type="text" name="base_fare" value="<?php echo htmlspecialchars($reservation['base_fare'] ?? ''); ?>" required>
                    <label for="departure">Departure:</label>
                    <input type="text" name="departure" value="<?php echo htmlspecialchars($reservation['departure'] ?? ''); ?>" required>
                    
                    <button type="submit">Update</button>
                </form>
                <hr>
                <?php
            }
        } else {
            echo "No reservations found for this bus number and user ID.";
        }

        $stmt->close();
    } else {
        echo "Error preparing statement: " . $conn->error;
    }
} else {
    echo "Invalid request.";
}


$conn->close();
?>
