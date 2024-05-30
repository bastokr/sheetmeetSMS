import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:youngwonsms/sms_send.dart';
import 'api_client.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "App",
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _message, body;
  String sendMessage = "문자 발송";

  List<String> people = [];
  bool sendDirect = false;
  final MethodChannel _channel =
      const MethodChannel("com.shosft.youngwonsms/mms");
  List<DataRow> data = [];
  TextEditingController log = TextEditingController();

  var flag = {};
  @override
  void initState() {
    super.initState();
    initPlatformState();
    getData();
  }

  getData() async {
    // DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    //String string = dateFormat.format(DateTime.now());
    data = [];
    var jsonData =
        await NetworkHelper(url: '/api/list/okShop/MENU_MGT_MARKET_S004/mb4/Y')
            .getData();
    var jsonResponse = jsonData["rows"];

    for (var element in jsonResponse) {
      var mb0 = element["mb0"];
      var mb2 = element["mb2"];
      var mb3 = element["mb3"];
      var mb4 = element["mb4"];
      flag[mb2] = true;
      setState(() {
        data.add(DataRow(cells: [
          DataCell(Text(
            element["mb1"],
            style: const TextStyle(fontSize: 10),
          )),
          DataCell(Text(mb2)),
          DataCell(ElevatedButton(
            onPressed: () async {
              setState(() {
                flag[mb2] = false;
              });

              await NetworkHelper(
                      url:
                          "/SETDATA/okShop/MENU_MGT_MARKET_S004/update/mb0/$mb0")
                  .sendPostData({"mb4": "SendOK", "mb5": "발송완료"}, "").then(
                      (value) => {getData()});

              _channel.invokeMethod("sendMMS", {
                'phoneNumber': mb2,
                'message': mb3,
              });
              //getData();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(
                    mb4 == 'Y' ? Colors.blue : Colors.grey)),
            child: const Text(
              "발송",
              style: TextStyle(color: Colors.white),
            ),
          )),
        ]));
      });
    }
  }

  Future<void> initPlatformState() async {}

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
    return Scaffold(
      appBar: AppBar(title: const Text('영원무역 SMS  '), actions: [
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () {
            getData();
          },
        ),
        IconButton(
          icon: const Row(
            children: [Icon(Icons.sms_sharp), Text("SMS")],
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const SmsApp();
              },
            ));
          },
        ),
      ]),
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
          const Divider(),
          DataTable(
              columnSpacing: 0,
              columns: const [
                DataColumn(label: Text('이름')),
                DataColumn(label: Text('전화')),
                DataColumn(label: Text('발송')),
              ],
              rows: data),
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
    );
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var strToday = formatter.format(now);
    return strToday;
  }
}
