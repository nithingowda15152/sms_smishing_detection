// import 'dart:math';   // ✅ for random values
// import 'package:flutter/material.dart';
// import 'package:another_telephony/telephony.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'ml/model_loader.dart';
// import 'ml/classifier.dart';
// import 'notification_service.dart';   // ✅ notifications

// final Telephony telephony = Telephony.instance;

// /// ✅ Background SMS handler (runs even if app is closed)
// @pragma('vm:entry-point')
// Future<void> smsBackgroundHandler(SmsMessage message) async {
//   if (message.body == null) return;

//   final model = await SmishModel.load();
//   final clf = SmishClassifier(model);

//   final text = message.body ?? "";
//   bool isSmish = isSmishingUrl(text);
//   double prob = 0.0;

//   // ✅ Check for trusted bank or legit transaction before classifying
//   if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
//     isSmish = false;
//     prob = 0.1;
//   } else if (!isSmish) {
//     prob = clf.predictProba(text);
//     isSmish = prob >= clf.threshold;
//   } else {
//     prob = 0.6 + Random().nextDouble() * 0.3;
//   }

//   await NotificationService.show(
//     isSmish ? "⚠️ Smishing Detected" : "✅ Safe Message",
//     text,
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.init();   // ✅ init notifications

//   final model = await SmishModel.load();
//   final clf = SmishClassifier(model);

//   runApp(SmishApp(clf: clf));
// }

// class SmishApp extends StatelessWidget {
//   final SmishClassifier clf;
//   const SmishApp({super.key, required this.clf});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SMS Smishing Detector',
//       theme: ThemeData(useMaterial3: true),
//       home: SmsHomePage(clf: clf),
//     );
//   }
// }

// class SmsHomePage extends StatefulWidget {
//   final SmishClassifier clf;
//   const SmsHomePage({super.key, required this.clf});

//   @override
//   State<SmsHomePage> createState() => _SmsHomePageState();
// }

// class _SmsHomePageState extends State<SmsHomePage> {
//   final List<_Classified> _items = [];

//   @override
//   void initState() {
//     super.initState();
//     _setup();
//   }

//   Future<void> _setup() async {
//     // Request runtime permissions
//     final smsStatus = await Permission.sms.request();
//     if (!smsStatus.isGranted) return;

//     // ✅ Load existing inbox SMS
//     final inbox = await telephony.getInboxSms(
//       columns: [SmsColumn.BODY, SmsColumn.ADDRESS],
//       sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
//     );

//     for (final sms in inbox) {
//       final text = sms.body ?? "";
//       if (text.isEmpty) continue;

//       bool isSmish = isSmishingUrl(text);
//       double prob = 0.0;

//       // ✅ Check for trusted bank or legit transaction
//       if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
//         isSmish = false;
//         prob = 0.1;
//       } else if (!isSmish) {
//         prob = widget.clf.predictProba(text);
//         isSmish = prob >= widget.clf.threshold;
//       } else {
//         prob = 0.6 + Random().nextDouble() * 0.3;
//       }

//       setState(() {
//         _items.add(_Classified(text, prob, isSmish));
//       });
//     }

//     // ✅ Start listening to new incoming SMS
//     telephony.listenIncomingSms(
//       onNewMessage: (SmsMessage msg) {
//         final text = msg.body ?? "";
//         if (text.isEmpty) return;

//         bool isSmish = isSmishingUrl(text);
//         double prob = 0.0;

//         // ✅ Safe transaction & bank filter
//         if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
//           isSmish = false;
//           prob = 0.1;
//         } else if (!isSmish) {
//           prob = widget.clf.predictProba(text);
//           isSmish = prob >= widget.clf.threshold;
//         } else {
//           prob = 0.6 + Random().nextDouble() * 0.3;
//         }

//         setState(() {
//           _items.insert(0, _Classified(text, prob, isSmish));
//         });

//         debugPrint("🔍 SMS: $text | Prob=$prob | ${isSmish ? "SMISHING" : "SAFE"}");
//         if (isTrustedBankMessage(text)) debugPrint("✅ Trusted Bank Message detected");
//         if (isLegitTransactionFormat(text)) debugPrint("✅ Legit Transaction format detected");
//       },
//       onBackgroundMessage: smsBackgroundHandler,
//       listenInBackground: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("SMS Smishing Detector")),
//       floatingActionButton: FloatingActionButton(
//       onPressed: () async {
//         await _loadMessages(); // your existing function
//         setState(() {});
//       },
//       child: const Icon(Icons.refresh),
//     ),
//       body: _items.isEmpty
//           ? const Center(child: Text("No messages yet..."))
//           : ListView.builder(
//         itemCount: _items.length,
//         itemBuilder: (_, i) {
//           final item = _items[i];
//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             child: ListTile(
//               leading: Icon(
//                 item.isSmish
//                     ? Icons.warning_amber_rounded
//                     : Icons.check_circle,
//                 color: item.isSmish ? Colors.red : Colors.green,
//               ),
//               title: Text(item.text),
//               subtitle: Text("Prob: ${item.prob.toStringAsFixed(3)}"),
//               trailing: Text(
//                 item.isSmish ? "⚠️ Smishing" : "✅ Safe",
//                 style: TextStyle(
//                   color: item.isSmish ? Colors.red : Colors.green,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _Classified {
//   final String text;
//   final double prob;
//   final bool isSmish;
//   _Classified(this.text, this.prob, this.isSmish);
// }

// /// ✅ Trusted Bank and Transaction Filters
// bool isTrustedBankMessage(String text) {
//   final trustedPatterns = [
//     "CANARA BANK",
//     "CANBNK",
//     "HDFCBK",
//     "SBIINB",
//     "AXISBK",
//     "ICICIB",
//     "KOTAK",
//     "PAYTM",
//     "GPAY",
//     "PHONEPE"
//   ];

//   for (final bank in trustedPatterns) {
//     if (text.toUpperCase().contains(bank)) return true;
//   }
//   return false;
// }

// bool isLegitTransactionFormat(String text) {
//   final pattern = RegExp(
//     r'(INR|Rs\.?)\s?\d+(\.\d{1,2})?\s?(has been|credited|debited)',
//     caseSensitive: false,
//   );
//   return pattern.hasMatch(text);
// }

// /// ✅ Function to detect smishing URLs
// bool isSmishingUrl(String text) {
//   // Capture URL-like patterns
//   final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
//   final matches = urlRegex.allMatches(text);

//   for (final match in matches) {
//     final url = match.group(0) ?? "";
//     final lowerUrl = url.toLowerCase();

//     // ✅ Step 1: Whitelisted safe domains (trusted)
//     final safeDomains = [
//       "canarabank.com",
//       "onlinesbi.sbi",
//       "hdfcbank.com",
//       "axisbank.com",
//       "icicibank.com",
//       "kotak.com",
//       "paytm.com",
//       "phonepe.com",
//       "gpay.app.goo.gl",
//       "amazon.in",
//       "google.com",
//       "upi",
//     ];
//     for (final safe in safeDomains) {
//       if (lowerUrl.contains(safe)) return false;
//     }

//     // 🚨 Step 2: suspicious keywords
//     final suspiciousKeywords = [
//       "free", "win", "offer", "gift", "bonus", "urgent",
//       "verify", "update", "account", "login", "secure",
//       "prize", "money", "credit", "bank", "unlock", "claim"
//     ];
//     for (var word in suspiciousKeywords) {
//       if (lowerUrl.contains(word)) return true;
//     }

//     // 🚨 Step 3: insecure http
//     if (url.startsWith("http://")) return true;

//     // 🚨 Step 4: long or complex URLs
//     if (url.length > 60) return true;
//     if (url.split(".").length > 3) return true;

//     // 🚨 Step 5: uncommon/suspicious TLDs
//     final suspiciousTlds = [".xyz", ".tk", ".top", ".club", ".pw", ".cn"];
//     for (var tld in suspiciousTlds) {
//       if (lowerUrl.endsWith(tld)) return true;
//     }

//     // 🚨 Step 6: special characters or IP-based
//     if (url.contains("@") || url.contains("_") ||
//         url.contains(">") || url.contains("<") ||
//         url.contains("{") || url.contains("}") ||
//         url.contains(" ")) return true;

//     final ipRegex = RegExp(r'https?:\/\/(\d{1,3}\.){3}\d{1,3}');
//     if (ipRegex.hasMatch(url)) return true;
//   }

//   return false;
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ml/model_loader.dart';
import 'ml/classifier.dart';
import 'notification_service.dart';

final Telephony telephony = Telephony.instance;

/// ✅ Background SMS handler
@pragma('vm:entry-point')
Future<void> smsBackgroundHandler(SmsMessage message) async {
  if (message.body == null) return;

  final model = await SmishModel.load();
  final clf = SmishClassifier(model);

  final text = message.body ?? "";
  bool isSmish = isSmishingUrl(text);
  double prob = 0.0;

  if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
    isSmish = false;
    prob = 0.1;
  } else if (!isSmish) {
    prob = clf.predictProba(text);
    isSmish = prob >= clf.threshold;
  } else {
    prob = 0.6 + Random().nextDouble() * 0.3;
  }

  await NotificationService.show(
    isSmish ? "⚠️ Smishing Detected" : "✅ Safe Message",
    text,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  final model = await SmishModel.load();
  final clf = SmishClassifier(model);

  runApp(SmishApp(clf: clf));
}

class SmishApp extends StatelessWidget {
  final SmishClassifier clf;
  const SmishApp({super.key, required this.clf});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Smishing Detector',
      theme: ThemeData(useMaterial3: true),
      home: SmsHomePage(clf: clf),
    );
  }
}

class SmsHomePage extends StatefulWidget {
  final SmishClassifier clf;
  const SmsHomePage({super.key, required this.clf});

  @override
  State<SmsHomePage> createState() => _SmsHomePageState();
}

class _SmsHomePageState extends State<SmsHomePage> {
  final List<_Classified> _items = [];

  @override
  void initState() {
    super.initState();
    _setup();
  }

  /// ✅ Clean SMS loader (USED for both init + refresh)
  Future<void> _loadMessages() async {
    final inbox = await telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.ADDRESS],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    final List<_Classified> temp = [];

    for (final sms in inbox) {
      final text = sms.body ?? "";
      if (text.isEmpty) continue;

      bool isSmish = isSmishingUrl(text);
      double prob = 0.0;

      if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
        isSmish = false;
        prob = 0.1;
      } else if (!isSmish) {
        prob = widget.clf.predictProba(text);
        isSmish = prob >= widget.clf.threshold;
      } else {
        prob = 0.6 + Random().nextDouble() * 0.3;
      }

      temp.add(_Classified(text, prob, isSmish));
    }

    setState(() {
      _items.clear();
      _items.addAll(temp);
    });
  }

  /// ✅ Setup permissions + listener
  Future<void> _setup() async {
    final smsStatus = await Permission.sms.request();
    if (!smsStatus.isGranted) return;

    await _loadMessages();

    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage msg) {
        final text = msg.body ?? "";
        if (text.isEmpty) return;

        bool isSmish = isSmishingUrl(text);
        double prob = 0.0;

        if (isTrustedBankMessage(text) || isLegitTransactionFormat(text)) {
          isSmish = false;
          prob = 0.1;
        } else if (!isSmish) {
          prob = widget.clf.predictProba(text);
          isSmish = prob >= widget.clf.threshold;
        } else {
          prob = 0.6 + Random().nextDouble() * 0.3;
        }

        setState(() {
          _items.insert(0, _Classified(text, prob, isSmish));
        });
      },
      onBackgroundMessage: smsBackgroundHandler,
      listenInBackground: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMS Smishing Detector"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadMessages();
            },
          ),
        ],
      ),
      body: _items.isEmpty
          ? const Center(child: Text("No messages yet..."))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      item.isSmish
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle,
                      color: item.isSmish ? Colors.red : Colors.green,
                    ),
                    title: Text(item.text),
                    subtitle: Text("Prob: ${item.prob.toStringAsFixed(3)}"),
                    trailing: Text(
                      item.isSmish ? "⚠️ Smishing" : "✅ Safe",
                      style: TextStyle(
                        color: item.isSmish ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _Classified {
  final String text;
  final double prob;
  final bool isSmish;
  _Classified(this.text, this.prob, this.isSmish);
}

/// ✅ Trusted bank filter
bool isTrustedBankMessage(String text) {
  final trustedPatterns = [
    "CANARA BANK",
    "CANBNK",
    "HDFCBK",
    "SBIINB",
    "AXISBK",
    "ICICIB",
    "KOTAK",
    "PAYTM",
    "GPAY",
    "PHONEPE"
  ];

  for (final bank in trustedPatterns) {
    if (text.toUpperCase().contains(bank)) return true;
  }
  return false;
}

/// ✅ Transaction format filter
bool isLegitTransactionFormat(String text) {
  final pattern = RegExp(
    r'(INR|Rs\.?)\s?\d+(\.\d{1,2})?\s?(has been|credited|debited)',
    caseSensitive: false,
  );
  return pattern.hasMatch(text);
}

/// ✅ URL-based smishing detection
bool isSmishingUrl(String text) {
  final urlRegex = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
  final matches = urlRegex.allMatches(text);

  for (final match in matches) {
    final url = match.group(0) ?? "";
    final lowerUrl = url.toLowerCase();

    final safeDomains = [
      "canarabank.com",
      "onlinesbi.sbi",
      "hdfcbank.com",
      "axisbank.com",
      "icicibank.com",
      "kotak.com",
      "paytm.com",
      "phonepe.com",
      "gpay.app.goo.gl",
      "amazon.in",
      "google.com",
      "upi",
    ];

    for (final safe in safeDomains) {
      if (lowerUrl.contains(safe)) return false;
    }

    final suspiciousKeywords = [
      "free","win","offer","gift","bonus","urgent",
      "verify","update","account","login","secure",
      "prize","money","credit","bank","unlock","claim"
    ];

    for (var word in suspiciousKeywords) {
      if (lowerUrl.contains(word)) return true;
    }

    if (url.startsWith("http://")) return true;
    if (url.length > 60) return true;
    if (url.split(".").length > 3) return true;

    final suspiciousTlds = [".xyz", ".tk", ".top", ".club", ".pw", ".cn"];
    for (var tld in suspiciousTlds) {
      if (lowerUrl.endsWith(tld)) return true;
    }

    if (url.contains("@") || url.contains("_") ||
        url.contains(">") || url.contains("<")) return true;

    final ipRegex = RegExp(r'https?:\/\/(\d{1,3}\.){3}\d{1,3}');
    if (ipRegex.hasMatch(url)) return true;
  }

  return false;
}