import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slack_app_ui/pages/m_users/confirm.dart';
import 'package:slack_app_ui/pages/static_pages/deep_link_handler.dart';
import 'package:slack_app_ui/pages/static_pages/home.dart';
import 'package:slack_app_ui/pages/static_pages/welcome.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
//   // final username = prefs.getString('username');
//   final token = prefs.getString('token');
//   print("this is Token   $token");
//   if (token != null) {
//     runApp( Portal(
//       child: MaterialApp(
//         home: MyHomePage(
//           title: "Home",
//         ),
//         debugShowCheckedModeBanner: false,
//       ),
//     ));
//   } else {
//     runApp(const Portal(
//         child: MaterialApp(
//       home: Welcome(),
//       debugShowCheckedModeBanner: false,
//     )));
//   }
// }


void main() {
  WidgetsFlutterBinding.ensureInitialized();

    runApp( Portal(
      child: MaterialApp(
      home:  DeepLinkHandler(),
      debugShowCheckedModeBanner: false,
    )));
  
}

