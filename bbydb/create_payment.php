<?php
header("Content-Type: application/json");

// Replace this with your actual PayMongo secret key
$secretKey = "sk_test_pXJL8ffhGXU8HniETJ9x9UEE";

// Get the JSON input from the Flutter app
$input = json_decode(file_get_contents("php://input"), true);

if (!isset($input['amount']) || !is_numeric($input['amount'])) {
    echo json_encode(['error' => 'Invalid amount specified']);
    exit;
}

$amount = $input['amount'];
$currency = $input['currency'] ?? 'PHP';

// Prepare the payment intent data
$data = [
    "data" => [
        "attributes" => [
            "amount" => $amount,
            "payment_method_allowed" => ["card", "gcash"],
            "payment_method_options" => ["card" => ["request_three_d_secure" => "any"]],
            "currency" => $currency,
            "description" => "Bus ticket reservation payment",
            "statement_descriptor" => "BusBuddy",
        ]
    ]
];

// Initialize cURL
$ch = curl_init("https://api.paymongo.com/v1/payment_intents");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Basic " . base64_encode($secretKey . ":"),
    "Content-Type: application/json"
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

// Execute the request
$response = curl_exec($ch);
curl_close($ch);

// Check if the request was successful
if ($response) {
    $responseData = json_decode($response, true);

    // Check for errors in the response
    if (isset($responseData['errors'])) {
        echo json_encode(['error' => 'Failed to create payment intent']);
    } else {
        // Retrieve the payment intent ID and generate the redirect URL
        $paymentIntentId = $responseData['data']['id'];
        $redirectUrl = "https://paymongo.page.link/payment/" . $paymentIntentId;

        echo json_encode(['redirect_url' => $redirectUrl]);
    }
} else {
    echo json_encode(['error' => 'Failed to connect to PayMongo']);
}
?>
