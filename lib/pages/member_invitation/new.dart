import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:slack_app_ui/pages/layouts/appbar.dart';
import 'package:slack_app_ui/pages/leftpannels/leftpannel.dart';
import 'package:slack_app_ui/pages/share_pref_utils.dart';
import "package:http/http.dart" as http;
import 'package:slack_app_ui/pages/static_pages/home.dart';

class MemberInvite extends StatefulWidget {
  MemberInvite({super.key, required this.userworkspace});
  dynamic userworkspace;

  @override
  State<MemberInvite> createState() => _MemberInviteState();
}

class _MemberInviteState extends State<MemberInvite> {
  String? selectedItem;
  int? selectedItemValue;
  String? token;
  int? workspace_id;
  int? user_id;
  dynamic m_workspace = {};
  List<dynamic> m_channels = [];

  // post member data
  Map<String, dynamic> user_workspace = {};
  String error = '';
  bool _isTextBoxVisible = false;

  late TextEditingController channelNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();

  Future<void> _fetchMemberData() async {
    token = await SharedPrefUtils.getStr("token");
    workspace_id = await SharedPrefUtils.getInt("workspaceid");
    user_id = await SharedPrefUtils.getInt("userid");

    try {
      final response = await http.get(
        Uri.parse(
            "http://10.0.2.2:8000/home?workspace_id=$workspace_id&user_id=$user_id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          final dynamic data = jsonDecode(response.body);
          m_workspace = data['m_workspace'];
          m_channels = data['m_channels'];
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _postMemberData(
    String channelid,
    String email,
  ) async {
    final response = await http.post(
        Uri.parse(
            "http://10.0.2.2:8000/member_invitation?workspace_id=$workspace_id"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'email': email,
          'channelid': selectedItemValue,
        }));
    final body = json.decode(response.body);
    if (body['error'] == null) {
      // token = body['token'];
      // error = body['errors'];
      // user_workspace = body['user_workspace'];
      // SharedPrefUtils.saveStr("token", body['token']);
      // SharedPrefUtils.saveInt("userid", body['user_workspace']['userid']);
      // SharedPrefUtils.saveInt("workspaceid", body['user_workspace']['workspaceid']);
      error = '';
      _isTextBoxVisible = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invitation sent successfully'),
        ),
      );
    } else {
      error = body['error'];
      _isTextBoxVisible = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              const Center(
                child: Text(
                  'メンバーを招待する',
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Visibility(
                visible: _isTextBoxVisible,
                child: Container(
                  width: 450.0,
                  color: const Color.fromARGB(
                      255, 233, 201, 211), // Background color
                  padding: const EdgeInsets.all(8.0), // Padding around the text
                  child: Center(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 223, 59, 47), // Text color
                        // Add more text styling as needed
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Workspace Name : ${widget.userworkspace}',
                style: const TextStyle(
                  fontSize: 23,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Channel Name  ',
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) {
                  return m_channels.map((item) {
                    // selectedItemValue = item['id'];
                    return PopupMenuItem(
                      value: item['id'],
                      child: Text(item['channel_name']),
                    );
                  }).toList();
                },
                onSelected: (value) {
                  setState(() {
                    selectedItemValue = value as int;
          
                    // You may want to retrieve the corresponding channel name as well
                    selectedItem = m_channels.firstWhere(
                        (item) => item['id'] == value)['channel_name'];
                  });
                },
                child: ListTile(
                  title: Text(
                    selectedItem ?? 'Select Channel',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // const Text(
              //   'Email',
              //   style: TextStyle(
              //     fontSize: 23,
              //   ),
              // ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 600,
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 400,
                height: 65,
                child: TextButton(
                  onPressed: () async {
                    await _postMemberData(
                        channelNameController.text, emailController.text);
                    if (error == '') {
                      setState(() {
                        _isTextBoxVisible = false;
                      });
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(
                              title: "SLACK APP",
                            ),
                          ),
                          (route) => false);
                    } else {
                      setState(() {
                        _isTextBoxVisible = true;
                      });
                    }
                  },
                  style: TextButton.styleFrom(
                    
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    'Invite Member',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const Leftpannel(),
    );
  }
}
