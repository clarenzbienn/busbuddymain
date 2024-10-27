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

    // Step 1: Check the total number of seats reserved by the user for the specific bus
    $stmt = $pdo->prepare("SELECT COUNT(*) AS total_reserved FROM reserved_seats WHERE user_id = ? AND bus_number = ?");
    $stmt->execute([$data->userId, $data->busNumber]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $totalReserved = $row['total_reserved'] ?? 0;

    // Calculate the new total seats for this bus after this reservation
    $newTotal = $totalReserved + count($data->seats);

    // Step 2: Check if the new total exceeds the limit of 3 seats per bus
    if ($newTotal > 3) {
        echo json_encode(['error' => 'You can only reserve up to 3 seats per bus.']);
        exit;
    }

    // Step 3: Check if any of the selected seats are already reserved
    $placeholders = str_repeat('?,', count($data->seats) - 1) . '?';
    $stmt = $pdo->prepare("SELECT seat FROM reserved_seats WHERE bus_number = ? AND departure = ? AND seat IN ($placeholders)");
    $stmt->execute(array_merge([$data->busNumber, $data->departure], $data->seats));

    $reservedSeats = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    if (!empty($reservedSeats)) {
        echo json_encode([
            'error' => 'Some seats are already reserved',
            'reserved_seats' => $reservedSeats
        ]);
        exit;
    }

    // Step 4: Reserve the seats if within limit and seats are available
    $pdo->beginTransaction();

    foreach ($data->seats as $seat) {
        $stmt = $pdo->prepare("INSERT INTO reserved_seats (bus_number, departure, seat, user_id, terminal, destination, base_fare, service_class, fullname) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->execute([$data->busNumber, $data->departure, $seat, $data->userId, $data->terminal, $data->destination, $data->baseFare, $data->serviceClass, $data->fullname]);
    }

    $pdo->commit();

    echo json_encode(['message' => 'Reservation successful']);
} catch (PDOException $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo json_encode(['error' => $e->getMessage()]);
}
?>
