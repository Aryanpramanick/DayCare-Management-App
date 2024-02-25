import 'dart:convert';
import 'package:http/http.dart' as http;

// used for authorization of api calls
late String username; // late initialization
late String password; // late initialization

/* 
*  createAuth: creates a basic authorization string for the header in api calls 
* 
*  USAGE EXAMPLE FOR API CALLS
*  final response = await http.get(
*    Uri.parse('$apiUrl/your-endpoint'),
*    headers: {'authorization': basicAuth},
*  );
*/
String createAuth() {
  final String basicAuth =
      'Basic ' + base64Encode(utf8.encode('$username:$password'));
  return basicAuth;
}
