<?php
header('Content-Type: application/json');

// Connect to the database
$servername = "localhost";
$username = "root";
$password = "";
$database = "flutter_auth";

$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die(json_encode(array('error' => 'Database connection failed')));
}

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['userId'])) {
        $userId = $conn->real_escape_string($_GET['userId']);

        // Query to get user details
        $sql = "SELECT fullname, email, username FROM users WHERE id = '$userId'";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $user = $result->fetch_assoc();
            echo json_encode($user);
        } else {
            echo json_encode(array('error' => 'User not found'));
        }
    } else {
        echo json_encode(array('error' => 'No userId provided'));
    }
} else {
    echo json_encode(array('error' => 'Invalid request method'));
}

$conn->close();
?>
