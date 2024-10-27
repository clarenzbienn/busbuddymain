<?php
// Database connection
$servername = "localhost";
$username = "root";  // Replace with your MySQL username
$password = "";  // Replace with your MySQL password
$dbname = "flutter_auth";    // Replace with your MySQL database name

$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the data from the request
$data = json_decode(file_get_contents('php://input'), true);

// Check if userId is set in the request
if (isset($data['userId'])) {
    $userId = $data['userId'];

    // Prepare and execute the query
    $stmt = $conn->prepare("SELECT fullname FROM users WHERE id = ?");
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $result = $stmt->get_result();

    // Check if a row was returned
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response = array('fullname' => $row['fullname']);
    } else {
        $response = array('error' => 'User not found');
    }

    $stmt->close();
} else {
    $response = array('error' => 'User ID not provided');
}

$conn->close();

// Return the response as JSON
header('Content-Type: application/json');
echo json_encode($response);
?>
