import 'package:flutter/material.dart';
import 'agreement_generator/agreement_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NayabAgreementApp());
}

class NayabAgreementApp extends StatelessWidget {
  const NayabAgreementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نایاب ایگریمنٹ جنریٹر',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'JameelNoori',
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const AgreementPage(),
    );
  }
}