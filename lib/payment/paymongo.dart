// paymongo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PayMongoService {
  final String apiKey = 'sk_test_pXJL8ffhGXU8HniETJ9x9UEE'; // Replace with your PayMongo secret key

  Future<String?> createPaymentIntent(double amount, String description) async {
    final url = Uri.parse('https://api.paymongo.com/v1/payment_intents');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:')),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'data': {
          'attributes': {
            'amount': (amount * 100).toInt(), // Convert to centavos
            'currency': 'PHP',
            'description': description,
            'payment_method_types': ['gcash'], // Specify your payment method
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['data']['attributes']['url'];
    } else {
      print('Error creating payment intent: ${response.body}');
      return null;
    }
  }
}
