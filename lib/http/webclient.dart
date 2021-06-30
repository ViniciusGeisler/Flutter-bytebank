import 'dart:convert';
import 'package:bytebank/models/contact.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';
import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({RequestData data}) async {
    print(data);
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({ResponseData data}) async {
      print(data);
      return data;
  }
}

final Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);

Future<List<Transaction>> findAll() async {
  final Client client = InterceptedClient.build(interceptors: [LoggingInterceptor()]);
  final Response response = await client.get(Uri.http('http://192.168.0.54:8080', 'transactions')).timeout(Duration(seconds:  5));
  final List<dynamic> decodedJson = jsonDecode(response.body);
  final List<Transaction> transactions = List();
  for(Map<String, dynamic> transactionJson in decodedJson) {
    final Map<String, dynamic> contactJson = transactionJson['contact'];
    final transaction = Transaction(
      transactionJson['value'], 
      Contact(
        0, 
        contactJson['name'], 
        contactJson['accountNumber'],
      ),
    );
    transactions.add(transaction);
  }
  return transactions;
}

Future<Transaction> save(Transaction transaction) async {
  final Map<String, dynamic> transactionMap = {
    'value': transaction.value,
    'contact' : {
      'name': transaction.contact.name,
      'accountNumber': transaction.contact.accountNumber
    }
  };

 final String transactionJson = jsonEncode(transactionMap);

 final Response response = await client.post(Uri.http('http://192.168.0.54:8080', 'transactions'), headers: { 
    'Content-type' : 'application/json', 
    'password': '1000',
  }, body: transactionJson);

  Map<String, dynamic> json = jsonDecode(response.body);

  final Map<String, dynamic> contactJson = json['contact'];
    return Transaction(
      json['value'], 
      Contact(
        0, 
        contactJson['name'], 
        contactJson['accountNumber'],
      ),
    );
}