<?php
$message = "";
$messageClass = ""; // CSS class for styling the message

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $fullname = $_POST['fullname'];
    $email = $_POST['email'];
    $password = password_hash($_POST['password'], PASSWORD_BCRYPT); // Hash the password

    // Database connection
    $conn = new mysqli('localhost', 'root', '', 'flutter_auth');

    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Insert admin details into the admins table
    $sql = "INSERT INTO admins (username, fullname, email, password) VALUES ('$username', '$fullname', '$email', '$password')";

    if ($conn->query($sql) === TRUE) {
        $message = "Signup successful.";
        $messageClass = "success"; // Apply success class
    } else {
        $message = "Error: " . $sql . "<br>" . $conn->error;
        $messageClass = "error"; // Apply error class
    }

    $conn->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Signup</title>
    <!-- Link to external CSS -->
    <link rel="stylesheet" href="styles/style.css">
</head>
<body>
    <div class="container">
        <!-- Notification area -->
        <?php if ($message != ""): ?>
            <div class="notification <?php echo $messageClass; ?>">
                <?php echo $message; ?>
            </div>
        <?php endif; ?>
        
        <h2>Admin Signup</h2>
        <form method="POST" action="">
            <label>Full Name:</label>
            <input type="text" name="fullname" required>

            <label>Email:</label>
            <input type="email" name="email" required>

            <label>Username:</label>
            <input type="text" name="username" required>

            <label>Password:</label>
            <input type="password" name="password" required>

            <button type="submit">Signup</button>
        </form>
        <p>Already have an account? <a href="admin_login.php">Login here</a></p>
    </div>
</body>
</html>
