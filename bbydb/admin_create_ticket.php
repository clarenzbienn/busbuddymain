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

// Create an array of bus numbers from 101 to 170
$busNumbers = range(101, 170); // Generates an array [101, 102, ..., 170]

// Initialize message variables
$successMessage = "";
$errorMessage = "";

// Check if form is submitted
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    // Get form data
    $serviceClass = $_POST['service_class'];
    $busNumber = $_POST['bus_number'];
    $departure = $_POST['departure'];
    $terminal = $_POST['terminal'];
    
    // Set destination based on the terminal
    $destination = ($terminal === "Cubao") ? "Dagupan" : "Cubao";

    // Determine available seats based on service class
    $availableSeats = ($serviceClass === "Regular") ? 49 : 45;

    // Check if trip_hours is set, if not set a default value (e.g., 4 hours)
    $tripHours = isset($_POST['trip_hours']) ? $_POST['trip_hours'] : 4;
    $baseFare = $_POST['base_fare'];

    // Set total available seats (assuming it equals available seats here)
    $totalAvailableSeats = $availableSeats; // Update this logic as needed

    // Insert the ticket into the database
    $insertSql = "INSERT INTO bus_tickets (service_class, bus_number, departure, terminal, destination, available_seats, trip_hours, base_fare, totalavailable_seats) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $insertStmt = $conn->prepare($insertSql);
    $insertStmt->bind_param("sssssiisi", $serviceClass, $busNumber, $departure, $terminal, $destination, $availableSeats, $tripHours, $baseFare, $totalAvailableSeats);

    if ($insertStmt->execute()) {
        $successMessage = "Ticket created successfully!";
        echo "<script>displayMessage('success', '$successMessage');</script>";
    } else {
        $errorMessage = "Error creating ticket: " . $conn->error;
        echo "<script>displayMessage('error', '$errorMessage');</script>";
    }
}

// Fetch all existing tickets without filters
$sql = "SELECT * FROM bus_tickets";
$result = $conn->query($sql);

// Fetch reserved seats
$reservedSeatsSql = "SELECT * FROM reserved_seats";
$reservedSeatsResult = $conn->query($reservedSeatsSql);

// Fetch admin profile info (Assuming admin id is 1 for demo purposes)
$admin_id = 1; 
$admin_sql = "SELECT * FROM admins WHERE id = ?";
$admin_stmt = $conn->prepare($admin_sql);
$admin_stmt->bind_param("i", $admin_id);
$admin_stmt->execute();
$admin_result = $admin_stmt->get_result();
$admin_data = $admin_result->fetch_assoc();

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="styles/create_ticket.css">
    <script>
        function showPage(pageId) {
            const pages = document.getElementsByClassName('page');
            for (let i = 0; i < pages.length; i++) {
                pages[i].style.display = 'none';
            }
            document.getElementById(pageId).style.display = 'block';
            hideMessage(); // Hide the message when switching pages
        }

        function hideMessage() {
            const messageBox = document.getElementById('success-message');
            messageBox.style.display = 'none';
            messageBox.innerHTML = ''; // Clear the message
        }

        function displayMessage(type, message) {
            const messageBox = document.getElementById('success-message');
            messageBox.style.display = 'block';
            messageBox.style.color = type === 'success' ? 'green' : 'red';
            messageBox.innerHTML = message;
        }

        function updateFareAndSeats() {
            const serviceClass = document.getElementById("service_class").value;
            const baseFareField = document.getElementById("base_fare");
            const availableSeatsField = document.getElementById("available_seats");

            // Update base fare and available seats based on the selected service class
            if (serviceClass === "Regular") {
                baseFareField.value = 450; // Set fare for Regular
                availableSeatsField.value = 49; // Set available seats for Regular
            } else if (serviceClass === "Deluxe") {
                baseFareField.value = 520; // Set fare for Deluxe
                availableSeatsField.value = 45; // Set available seats for Deluxe
            }
        }

        function updateDestination() {
            const terminal = document.getElementById("terminal").value;
            const destinationField = document.getElementById("destination");

            // Set destination based on the terminal
            if (terminal === "Cubao") {
                destinationField.value = "Dagupan";
            } else {
                destinationField.value = "Cubao";
            }
        }

        window.onload = function() {
            showPage('create-ticket-page'); // Default to the create ticket page
            updateFareAndSeats(); // Initialize base fare and available seats
            updateDestination(); // Initialize destination based on default terminal
        };
    </script>
</head>
<body>
    <!-- Sidebar Menu -->
    <div class="sidebar">
        <h2>Admin Dashboard</h2>
        <a href="#" onclick="showPage('create-ticket-page')">Create Ticket</a>
        <a href="#" onclick="showPage('view-tickets-page')">Created Tickets</a>
        <a href="#" onclick="showPage('reserved-seats-page')">Reserved Seats</a> <!-- New link for Reserved Seats -->
        <a href="#" onclick="showPage('profile-page')">Profile</a>
    </div>

    <!-- Main Content -->
    <div class="content">
        <!-- Success Message -->
        <div id="success-message" style="display: none;">
            <p></p>
        </div>

        <!-- Create Ticket Page -->
        <div id="create-ticket-page" class="page">
            <h1>Create Bus Ticket</h1>
            <form method="POST" action="">
                <label for="service_class">Service Class:</label><br>
                <select id="service_class" name="service_class" onchange="updateFareAndSeats()" required>
                    <option value="Regular">Regular</option>
                    <option value="Deluxe">Deluxe</option>
                </select><br><br>

                <label for="bus_number">Bus Number:</label><br>
                <select id="bus_number" name="bus_number" required>
                    <?php foreach ($busNumbers as $busNumber): ?>
                        <option value="<?= $busNumber; ?>"><?= $busNumber; ?></option>
                    <?php endforeach; ?>
                </select><br><br>

                <label for="departure">Departure:</label><br>
                <input type="datetime-local" id="departure" name="departure" required><br><br>

                <label for="terminal">Terminal:</label><br>
                <select id="terminal" name="terminal" required onchange="updateDestination()">
                    <option value="Cubao">Cubao</option>
                    <option value="Dagupan">Dagupan</option>
                </select><br><br>

                <label for="destination">Destination:</label><br>
                <input type="text" id="destination" name="destination" value="" required readonly><br><br>

                <label for="available_seats">Available Seats:</label><br>
                <input type="number" id="available_seats" name="available_seats" value="" readonly required><br><br>

                <label for="trip_hours">Trip Hours:</label><br>
                <input type="text" id="trip_hours" name="trip_hours" value="4" readonly><br><br>

                <label for="base_fare">Base Fare:</label><br>
                <input type="number" id="base_fare" name="base_fare" value="" readonly required><br><br>

                <input type="submit" value="Create Ticket">
            </form>
        </div>

        <!-- View Tickets Page -->
        <div id="view-tickets-page" class="page" style="display:none;">
            <h1>Created Tickets</h1>
            <table>
                <tr>
                    <th>Service Class</th>
                    <th>Bus Number</th>
                    <th>Departure</th>
                    <th>Terminal</th>
                    <th>Destination</th>
                    <th>Trip Hours</th>
                    <th>Base Fare</th>
                    <th>Total Available Seats</th>
                    <th>Actions</th>
                </tr>
                <?php while ($row = $result->fetch_assoc()): ?>
                <tr>
                    <td><?php echo htmlspecialchars($row['service_class']); ?></td>
                    <td><?php echo htmlspecialchars($row['bus_number']); ?></td>
                    <td><?php echo htmlspecialchars($row['departure']); ?></td>
                    <td><?php echo htmlspecialchars($row['terminal']); ?></td>
                    <td><?php echo htmlspecialchars($row['destination']); ?></td>
                    <td><?php echo htmlspecialchars($row['trip_hours']); ?></td>
                    <td><?php echo htmlspecialchars($row['base_fare']); ?></td>
                    <td><?php echo htmlspecialchars($row['totalavailable_seats']); ?></td>
                    <td>
                        <!--<a href="edit_ticket.php?id=<?php echo $row['id']; ?>">Edit</a>-->
                        <a href="delete_ticket.php?id=<?php echo $row['id']; ?>" onclick="return confirm('Are you sure you want to delete this ticket?');">Delete</a>
                    </td>
                </tr>
                <?php endwhile; ?>
            </table>
        </div>

       <!-- Reserved Seats Page -->
        <div id="reserved-seats-page" class="page" style="display:none;">
            <h1>Reserved Seats</h1>
            <table>
                <tr>
                    <th>Bus Number</th>
                    <th>Seat Numbers</th> <!-- Change header to indicate concatenated seats -->
                    <th>Reserved By</th>
                    <th>Reservation Time</th>
                    <th>Terminal</th>
                    <th>Destination</th>
                    <th>Service Class</th>
                    <th>Total Fare</th>
                    <th>Actions</th> <!-- New header for actions -->
                </tr>

                <?php
                // Initialize an array to hold combined reservations
                $combinedReservations = [];

                // Fetch and combine reserved seats
                while ($reservedRow = $reservedSeatsResult->fetch_assoc()) {
                    $key = $reservedRow['bus_number'] . '|' . $reservedRow['user_id'];
                    if (!isset($combinedReservations[$key])) {
                        // Initialize a new entry if it doesn't exist
                        $combinedReservations[$key] = [
                            'bus_number' => htmlspecialchars($reservedRow['bus_number']),
                            'seat' => htmlspecialchars($reservedRow['seat']),
                            'user_id' => htmlspecialchars($reservedRow['user_id']),
                            'created_at' => htmlspecialchars($reservedRow['created_at']),
                            'terminal' => htmlspecialchars($reservedRow['terminal']),
                            'destination' => htmlspecialchars($reservedRow['destination']),
                            'service_class' => htmlspecialchars($reservedRow['service_class']),
                            'base_fare' => htmlspecialchars($reservedRow['base_fare']),
                            'reservation_id' => htmlspecialchars($reservedRow['id']) // Assuming there's an ID for the reservation
                        ];
                    } else {
                        // Concatenate the seat numbers if the entry already exists
                        $combinedReservations[$key]['seat'] .= ', ' . htmlspecialchars($reservedRow['seat']);
                    }
                }

                // Display the combined reservations
                foreach ($combinedReservations as $reservation) {
                    echo '<tr>';
                    echo '<td>' . $reservation['bus_number'] . '</td>';
                    echo '<td>' . $reservation['seat'] . '</td>';
                    echo '<td>' . $reservation['user_id'] . '</td>';
                    echo '<td>' . $reservation['created_at'] . '</td>';
                    echo '<td>' . $reservation['terminal'] . '</td>';
                    echo '<td>' . $reservation['destination'] . '</td>';
                    echo '<td>' . $reservation['service_class'] . '</td>';
                    echo '<td>₱ ' . $reservation['base_fare'] . '</td>';
                    echo '<td>'; // Actions column
                    echo '<a href="delete_reservation.php?id=' . $reservation['reservation_id'] . '" onclick="return confirm(\'Are you sure you want to delete this reservation?\');">Delete</a>';
                    echo '</td>';
                    echo '</tr>';
                }
                ?>
            </table>
        </div>




        <!-- Profile Page -->
        <div id="profile-page" class="page" style="display:none;">
            <h1>Admin Profile</h1>
            <p><strong>Full Name:</strong> <?php echo htmlspecialchars($admin_data['fullname']); ?></p>
            <p><strong>Username:</strong> <?php echo htmlspecialchars($admin_data['username']); ?></p>
            <p><strong>Email:</strong> <?php echo htmlspecialchars($admin_data['email']); ?></p>
        </div>
    </div>
</body>
</html>
