<?php
session_start(); // Start the session

// Check if the user is logged in by checking if the session variable exists
if (isset($_SESSION['user_id'])) {
    // Clear session variables
    session_unset(); // Remove all session variables
    session_destroy(); // Destroy the session

    // Respond with a success message
    echo json_encode(['status' => 'success', 'message' => 'Logged out successfully.']);
} else {
    // Respond with an error message if there is no active session
    echo json_encode(['status' => 'error', 'message' => 'No active session.']);
}
?>
