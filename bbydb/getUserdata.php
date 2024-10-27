<?php
// Database connection
$servername = "localhost"; // Change to your database server if different
$username = "root"; // Your database username
$password = ""; // Your database password
$dbname = "flutter_auth"; // Your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// Set content type to JSON
header('Content-Type: application/json');

// Check if userId parameter is set
if (isset($_GET['userId'])) {
    $userId = $_GET['userId'];

    // Query to get user data from database based on userId
    $sql = "SELECT * FROM users WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $userId); // Bind the userId as an integer
    $stmt->execute();
    $result = $stmt->get_result();

    // Check if any data is returned
    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc(); // Fetch user data

        // Return user data as a JSON response
        echo json_encode([
            'status' => 'success',
            'user_info' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $user['email'],
                // Include any other necessary fields
            ],
        ]);
    } else {
        // No user found for the given userId
        echo json_encode(['status' => 'error', 'message' => 'User not found']);
    }
} else {
    // Missing userId parameter
    echo json_encode(['status' => 'error', 'message' => 'userId parameter is missing']);
}

// Close the database connection
$conn->close();
?>
