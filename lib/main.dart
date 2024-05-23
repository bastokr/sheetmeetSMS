import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'api_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late TextEditingController _controllerPeople, _controllerMessage;
  String? _message, body;
  String sendMessage = "문자 발송";

  final String _canSendSMSMessage = 'Check is not run.';
  List<String> people = [];
  bool sendDirect = false;
  final MethodChannel _channel =
      const MethodChannel("com.example.native_connection_study");

  String _resultData = "";
  TextEditingController log = TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    _controllerPeople = TextEditingController();
    _controllerMessage = TextEditingController();
  }

  Future<void> _sendSMS(List<String> recipients) async {
    /*
      String _result = await sendSMS(
        message: _controllerMessage.text,
        recipients: recipients,
        sendDirect: sendDirect,
      );
*/
    var status = await Permission.sms.status;

    if (status.isDenied) {
      await [
        Permission.sms,
        Permission.phone,
      ].request();
    }
    if (!status.isDenied) {
      recipients.forEach((element) async {
        final result = await _channel.invokeMethod(
            "sendInvokeMessage", [element, _controllerMessage.text]);
        setState(() {
          _resultData = result.toString();
        });
      });
    }
  }

  Future<bool> _canSendSMS() async {
    // bool _result = await canSendSMS();

    return true;
  }

  Widget _phoneTile(String name) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Container(
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
            top: BorderSide(color: Colors.grey.shade300),
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
          )),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => people.remove(name)),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Text(
                    name,
                    textScaleFactor: 1,
                    style: const TextStyle(fontSize: 12),
                  ),
                )
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SMS/MMS Example'),
        ),
        body: ListView(
          children: <Widget>[
            if (people.isEmpty)
              const SizedBox(height: 0)
            else
              SizedBox(
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List<Widget>.generate(people.length, (int index) {
                      return _phoneTile(people[index]);
                    }),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.people),
              title: TextField(
                controller: _controllerPeople,
                decoration: const InputDecoration(labelText: '테스트 전번 추가'),
                keyboardType: TextInputType.number,
                onChanged: (String value) => setState(() {}),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _controllerPeople.text.isEmpty
                    ? null
                    : () => setState(() {
                          people.add(_controllerPeople.text.toString());
                          _controllerPeople.clear();
                        }),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.message),
              title: TextField(
                decoration: const InputDecoration(labelText: '테스트 메세지'),
                controller: _controllerMessage,
                onChanged: (String value) => setState(() {}),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Can send SMS'),
              subtitle: Text(_canSendSMSMessage),
              trailing: IconButton(
                padding: const EdgeInsets.symmetric(vertical: 16),
                icon: const Icon(Icons.check),
                onPressed: () {
                  _canSendSMS();
                },
              ),
            ),
            SwitchListTile(
                title: const Text('서버메세지 보내기'),
                subtitle: const Text(
                    'Should we skip the additional dialog? (Android only)'),
                value: sendDirect,
                onChanged: (bool newValue) {
                  setState(() {
                    sendDirect = newValue;
                  });
                }),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Theme.of(context).colorScheme.secondary),
                  padding: MaterialStateProperty.resolveWith(
                      (states) => const EdgeInsets.symmetric(vertical: 16)),
                ),
                onPressed: () {
                  _send();
                },
                child: Text(
                  sendMessage,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
            TextFormField(
              controller: log,
              minLines:
                  6, // any number you need (It works as the rows for the textarea)
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
            Visibility(
              visible: _message != null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _message ?? 'No Data',
                        maxLines: null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var strToday = formatter.format(now);
    return strToday;
  }

  void _send() async {
    Iterable jsonResponse = [];
    if (sendDirect) {
      setState(() {
        sendMessage = "발송 시작";
      });

      var status = await Permission.sms.status;
      if (status.isDenied) {
        await [
          Permission.sms,
          Permission.phone,
        ].request();
      }
      setState(() {
        sendMessage = "발송 시작1";
      });
      var jsonData = await NetworkHelper(
              url: '/api/list/okShop/MENU_MGT_MARKET_S004/mb4/Y')
          .getData();
      jsonResponse = jsonData["rows"];

      setState(() {
        sendMessage = "발송 시작2";
      });

      int i = 1;
      for (var element in jsonResponse) {
        var mb2 = element["mb2"];
        var mb3 = element["mb3"];
        var mb0 = element["mb0"];

        final result =
            await _channel.invokeMethod("sendInvokeMessage", [mb2, mb3]);

        _resultData = result.toString();
        setState(() {
          sendMessage = "문자 발송완료 ${i++}건";
          log.text = "${log.text + mb2 + mb3}\n";
        });

        await NetworkHelper(
                url: "/SETDATA/okShop/MENU_MGT_MARKET_S004/update/mb0/$mb0")
            .sendPostData({"mb4": "SendOK", "mb5": _resultData.toString()}, "");
      }

      setState(() {
        sendMessage = "문자 발송완료 ${jsonResponse.length}건";
      });
    } else {
      if (people.isEmpty) {
        setState(() => _message = 'At Least 1 Person or Message Required');
      } else {
        _sendSMS(people);
      }
    }
  }
}
