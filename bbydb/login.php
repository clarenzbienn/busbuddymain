<?php
header('Access-Control-Allow-Origin: *'); // Allow any origin
header('Access-Control-Allow-Methods: POST, GET, OPTIONS'); // Allow specific methods
header('Access-Control-Allow-Headers: Content-Type'); // Allow specific headers

include 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Trim whitespace from identifier and password
    $identifier = trim($_POST['identifier']); 
    $password = trim($_POST['password']); 

    // Check if identifier is empty after trimming or contains any whitespace
    if (empty($identifier) || preg_match('/\s/', $identifier)) {
        echo json_encode(["status" => "error", "message" => "Username or email cannot contain spaces"]);
        exit; // Stop further execution
    }

    // Check if password is empty after trimming or contains any whitespace
    if (empty($password) || preg_match('/\s/', $password)) {
        echo json_encode(["status" => "error", "message" => "Password cannot contain spaces"]);
        exit; // Stop further execution
    }

    // Use prepared statements to prevent SQL injection
    $query = "SELECT * FROM users WHERE email=? OR username=?";
    $stmt = $conn->prepare($query);
    
    // Bind parameters as strings
    $stmt->bind_param("ss", $identifier, $identifier);
    
    // Execute the statement
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        // Verify the password
        if (password_verify($password, $user['password'])) {
            // Return success response with user ID as a string
            echo json_encode([
                "status" => "success", 
                "message" => "Login successful", 
                "user_id" => (string)$user['id'] // Ensure user_id is a string
            ]);
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid password"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }

    // Close the prepared statement
    $stmt->close();
}

// Close the database connection
$conn->close();
?>
