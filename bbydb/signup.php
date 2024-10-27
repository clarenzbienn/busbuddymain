<?php
$servername = "localhost";
$username = "root"; // Change to your database username
$password = ""; // Change to your database password
$dbname = "flutter_auth"; // Change to your database name

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get input data
$username = $_POST['username'];
$fullname = $_POST['fullname'];
$email = $_POST['email'];
$passwordInput = $_POST['password']; // Store the input password for validation

$response = ['status' => 'error', 'code' => '', 'message' => ''];

if ($username && $fullname && $email && $passwordInput) {
    // Validate password strength
    if (!preg_match('/[A-Z]/', $passwordInput) || // At least one uppercase letter
        !preg_match('/[0-9]/', $passwordInput) || // At least one number
        !preg_match('/[\W_]/', $passwordInput)) { // At least one special character
        $response['message'] = 'Password must contain at least one uppercase letter, one number, and one special character.';
    } else {
        // Hash the password
        $password = password_hash($passwordInput, PASSWORD_DEFAULT);

        // Check if username already exists
        $checkUsername = "SELECT * FROM users WHERE username='$username'";
        $resultUsername = $conn->query($checkUsername);
        
        if ($resultUsername->num_rows > 0) {
            $response['code'] = 'username_exists';
            $response['message'] = 'Username already exists';
        } else {
            // Check if email already exists
            $checkEmail = "SELECT * FROM users WHERE email='$email'";
            $resultEmail = $conn->query($checkEmail);
            
            if ($resultEmail->num_rows > 0) {
                $response['code'] = 'email_exists';
                $response['message'] = 'Email already exists';
            } else {
                // Insert new user into the database
                $insertUser = "INSERT INTO users (username, fullname, email, password) VALUES ('$username', '$fullname', '$email', '$password')";
                if ($conn->query($insertUser) === TRUE) {
                    $response['status'] = 'success';
                    $response['message'] = 'User registered successfully';
                } else {
                    $response['message'] = 'Error: ' . $conn->error;
                }
            }
        }
    }
} else {
    $response['message'] = 'All fields are required.';
}

$conn->close();
header('Content-Type: application/json');
echo json_encode($response);
?>
