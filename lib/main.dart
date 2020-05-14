import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  var qrText = "";
  QRViewController controller;
  List<String> qrList;
  var pref;
  bool qrStatus = true;

  @override
  void initState() {
    super.initState();
    getInstance();
  }

  getInstance() async {
    pref = await SharedPreferences.getInstance();
    final list = getList();
    print(list);
    setState(() {
      qrList = list != null ? list : new List();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Image.asset('assets/banner.jpg', fit: BoxFit.fill),
              ),
              Expanded(
                flex: 5,
                child: qrStatus
                    ? QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: qrList != null ? qrList.length : 0,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color:
                                            Color.fromRGBO(236, 236, 236, 1)))),
                            padding:
                                EdgeInsets.only(left: 5, right: 5, top: index == 0? 0: 10, bottom: 10),
                            child: Text(
                              qrList[(qrList.length - (index + 1))],
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          );
                        },
                      ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF42A5F5),
                      ),
                      child: Text(
                        qrStatus
                            ? "VER HISTORIAL DE ESCANEOS"
                            : "ABRIR LECTOR QR",
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.white),
                      ),
                    ),
                    onTap: () => goToQRScan(),
                  ),
                ),
              ),
            ],
          ),
        ),
        onWillPop: () => changePage());
  }

  changePage() {
    if (qrStatus) {
      setState(() {
        qrStatus = false;
      });
    }
  }

  goToQRScan() {
    if (qrStatus) {
      setState(() {
        qrStatus = false;
      });
    } else {
      setState(() {
        qrStatus = true;
      });
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    var count = 0;
    controller.scannedDataStream.listen((scanData) {
      if (count == 0) {
        setState(() {
          count++;
          saveList(scanData);
          qrStatus = false;
        });
      }
    });
  }

  saveList(text) async {
    qrList.add(text);
    if(qrList.length < 11){
    pref.setStringList("qr_app_key", qrList);
    }else{
      qrList.removeAt(0);
      pref.setStringList("qr_app_key", qrList);
    }
  }

  List<String> getList() {
    return pref.getStringList("qr_app_key");
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
