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

// Fetch the ticket details for editing
$ticket = [];
if (isset($_GET['id'])) {
    $ticket_id = $_GET['id'];

    $sql = "SELECT * FROM bus_tickets WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $ticket_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $ticket = $result->fetch_assoc();

    // Debug line to check the fetched ticket details
    if (!$ticket) {
        die("No ticket found with that ID.");
    }
}

// Update the ticket in the database
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $serviceClass = $_POST['service_class'];
    $busNumber = $_POST['bus_number'];
    $departure = $_POST['departure'];
    $terminal = $_POST['terminal'];
    $destination = $_POST['destination']; // Comes from the input
    $availableSeats = $_POST['available_seats'];
    $tripHours = $_POST['trip_hours'];
    $baseFare = $_POST['base_fare'];

    // Update query
    $updateSql = "UPDATE bus_tickets SET service_class=?, bus_number=?, departure=?, terminal=?, destination=?, available_seats=?, trip_hours=?, base_fare=? WHERE id=?";
    $updateStmt = $conn->prepare($updateSql);
    $updateStmt->bind_param("ssssiiiii", $serviceClass, $busNumber, $departure, $terminal, $destination, $availableSeats, $tripHours, $baseFare, $ticket_id);

    if ($updateStmt->execute()) {
        header("Location: admin_create_ticket.php?message=Ticket updated successfully!");
        exit();
    } else {
        echo "Error updating ticket: " . $conn->error;
    }

    $updateStmt->close();
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Ticket</title>
</head>
<body>
    <h1>Edit Bus Ticket</h1>
    <form method="POST">
        <label for="service_class">Service Class:</label><br>
        <select id="service_class" name="service_class" required>
            <option value="Regular" <?php if ($ticket['service_class'] === 'Regular') echo 'selected'; ?>>Regular</option>
            <option value="Deluxe" <?php if ($ticket['service_class'] === 'Deluxe') echo 'selected'; ?>>Deluxe</option>
        </select><br><br>

        <label for="bus_number">Bus Number:</label><br>
        <input type="number" id="bus_number" name="bus_number" value="<?php echo htmlspecialchars($ticket['bus_number']); ?>" required><br><br>

        <label for="departure">Departure:</label><br>
        <input type="datetime-local" id="departure" name="departure" value="<?php echo htmlspecialchars($ticket['departure']); ?>" required><br><br>

        <label for="terminal">Terminal:</label><br>
        <select id="terminal" name="terminal" required onchange="updateDestination()">
            <option value="Cubao" <?php if ($ticket['terminal'] === 'Cubao') echo 'selected'; ?>>Cubao</option>
            <option value="Dagupan" <?php if ($ticket['terminal'] === 'Dagupan') echo 'selected'; ?>>Dagupan</option>
        </select><br><br>

        <label for="destination">Destination:</label><br>
        <input type="text" id="destination" name="destination" value="<?php echo htmlspecialchars($ticket['destination']); ?>" required><br><br>

        <label for="available_seats">Available Seats:</label><br>
        <input type="number" id="available_seats" name="available_seats" value="<?php echo htmlspecialchars($ticket['available_seats']); ?>" required><br><br>

        <label for="trip_hours">Trip Hours:</label><br>
        <input type="number" id="trip_hours" name="trip_hours" value="<?php echo htmlspecialchars($ticket['trip_hours']); ?>" required><br><br>

        <label for="base_fare">Base Fare:</label><br>
        <input type="number" id="base_fare" name="base_fare" value="<?php echo htmlspecialchars($ticket['base_fare']); ?>" required><br><br>

        <input type="submit" value="Update Ticket">
    </form>

    <script>
        function updateDestination() {
            const terminalSelect = document.getElementById('terminal');
            const destinationInput = document.getElementById('destination');
            
            let newDestination = (terminalSelect.value === 'Cubao') ? 'Dagupan' : 'Cubao';
            destinationInput.value = newDestination;
        }
        
        // Initial set the destination based on the selected terminal
        document.addEventListener('DOMContentLoaded', function() {
            updateDestination();
        });
    </script>
</body>
</html>
