import 'dart:convert';
import 'package:http/http.dart' as http;

class PayMongoService {
  final String publicKey = 'pk_test_qtcHXr3WsjcwaJuYvDVSFmjz';
  final String secretKey = 'sk_test_pXJL8ffhGXU8HniETJ9x9UEE';

  // Function to create a payment intent
  Future<String?> createPaymentIntent(double amount) async {
    final url = Uri.parse('https://api.paymongo.com/v1/payment_intents');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$secretKey:'))}',
      'Content-Type': 'application/json'
    };
    final body = json.encode({
      'data': {
        'attributes': {
          'amount': (amount * 100).toInt(), // Amount in centavos
          'payment_method_allowed': ['card', 'paymaya'],
          'currency': 'PHP',
        }
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data']['id']; // Payment Intent ID
    } else {
      print('Failed to create payment intent: ${response.body}');
      return null;
    }
  }

  // Function to attach payment method and get checkout URL
  Future<String?> getCheckoutUrl(String paymentIntentId) async {
    final url = Uri.parse('https://api.paymongo.com/v1/payment_intents/$paymentIntentId/attach');
    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$secretKey:'))}',
      'Content-Type': 'application/json'
    };
    final body = json.encode({
      'data': {
        'attributes': {
          'payment_method': 'YOUR_PAYMENT_METHOD_ID',
          'return_url': 'YOUR_RETURN_URL',
        }
      }
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['data']['attributes']['next_action']['redirect']['url'];
    } else {
      print('Failed to get checkout URL: ${response.body}');
      return null;
    }
  }
}
