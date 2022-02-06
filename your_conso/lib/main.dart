import 'dart:collection';
import 'package:country_calling_code_picker/picker.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
void main()
{
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Conso',
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
  _MyHomePageState createState()
  {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime selectedDate_1 = DateTime.now();
  DateTime selectedDate_2 = DateTime.now();
  String conso = "";
  String entrant = "";
  String conso_alg = "";
  String entrant_alg = "";

  final List<Map<String, String>> listOfColumns = [];

  @override
  Widget build(BuildContext context) {
    //listOfColumns.removeWhere((element) => element.)
    //calllog(selectedDate_1,selectedDate_2);
    return Scaffold(
      appBar: AppBar(
        title: Text("Ta conso !"),
      ),
      body: Padding(padding: const EdgeInsets.all(30), child :
          ListView(
            children: <Widget>[Row(children: [Column(children: [ElevatedButton(
            onPressed: () {
              _selectDate_1(context);
            },
            child: Text("Début"),
          ),

            Text("${selectedDate_1.day}/${selectedDate_1.month}/${selectedDate_1.year}",style: TextStyle(height: 1.5, fontSize: 18))],),
            SizedBox(width: 115,),
            Column(children: [ElevatedButton(
            onPressed: () {
              _selectDate_2(context);
            },
            child: Text("Fin"),
          ),
            Text("${selectedDate_2.day}/${selectedDate_2.month}/${selectedDate_2.year}",style: TextStyle(height: 1.5, fontSize: 18))],)],
            ),
              SizedBox(height:30),
              Text("Statistiques de vos appels du " + "${selectedDate_1.day}/${selectedDate_1.month}/${selectedDate_1.year}" + " au " + "${selectedDate_2.day}/${selectedDate_2.month}/${selectedDate_2.year}",style: TextStyle(height: 1.5, fontSize: 24)),
              SizedBox(height:30),
              DataTable(columns: [DataColumn(label: Text("Pays")),
                                  DataColumn(label: Text("Entrant")),
                                  DataColumn(label: Text("Sortant")),
                                  ],
                  rows:  listOfColumns // Loops through dataColumnText, each iteration assigning the value to element
                      .map(
                    ((element) => DataRow(
                      cells: <DataCell>[
                        DataCell(Text(element["Pays"]!)), //Extracting from Map element the value
                        DataCell(Text(element["Entrant"]!)),
                        DataCell(Text(element["Sortant"]!)),
                      ],
                    )),
                  )
                      .toList()),

          ],
        ),

      )
    );
  }
  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }
  _selectDate_1(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate_1,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate_1)
      setState(() {
        selectedDate_1 = selected;
        calllog(selectedDate_1,selectedDate_2);
      });
  }

  _selectDate_2(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: selectedDate_2,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate_2)
      setState(() {
        selectedDate_2 = selected;
        calllog(selectedDate_1,selectedDate_2);
      });
  }

  void calllog(DateTime d1,DateTime d2) async{
    listOfColumns.removeRange(0, listOfColumns.length);
    List<Country> list = await getCountries(context);

    var now = DateTime.now();
    int from = d1.millisecondsSinceEpoch;
    int to = d2.add(Duration(days: 1)).millisecondsSinceEpoch;
    Iterable<CallLogEntry> entries = await CallLog.query(
      dateFrom: from,
      dateTo: to,
      type: CallType.outgoing,
    );
    Iterable<CallLogEntry> entries2 = await CallLog.query(
      dateFrom: from,
      dateTo: to,
      type: CallType.incoming,
    );
    //Iterable<CallLogEntry> entries = await CallLog.get();
    var temps = 0;
    var temps2 = 0;
    var temps_alg = 0;
    var temps2_alg = 0;
    HashMap liste_appel = new HashMap<String,String>();
    String indicatif = "";
    String date = "";
    DateTime date_time;
    bool existe = false;
    bool present = false;
    print("ca va");
  for(var i=0;i<list.length;i++){
    print("oHHH");
    present = false;
      for(var item in entries){
        if(item.number!.length>5)
          indicatif = item.number!.substring(0, 5);
        print(indicatif);
        print(list[i].name);
        if(indicatif.substring(0,2) == 00){
          indicatif.replaceRange(0, 2, "+");
        }
        if(indicatif.contains(list[i].callingCode)) {
          temps+=item.duration!;
          present = true;
        }
      }
    for(var item in entries2){
      if(item.number!.length>5)
        indicatif = item.number!.substring(0, 5);
      print(indicatif);
      print(list[i].name);
      if(indicatif.contains(list[i].callingCode)) {
        temps2+=item.duration!;
        present = true;
      }
    }
      if(present){
        print("OUI !!");
        setState(() {
          listOfColumns.add({"Pays":list[i].name,"Entrant":formatTime(temps),"Sortant":formatTime(temps2)});
        });

      }

  }
  /*  for (var item in entries) {
    existe = false;

      date_time = DateTime.fromMillisecondsSinceEpoch(item.timestamp!);
      date = date_time.toString().substring(0,10);

      if(item.number!.length > 5 ) {

        indicatif = item.number!.substring(0, 5);


          if(date_time.isAtSameMomentAs(d1)  || (date_time.isAfter(d1) && date_time.isBefore(d2.add(Duration(days: 1))))) {
            // ALG
            for(var i = 0; i<list.length;i++){
              if(indicatif.contains(list[i].callingCode)) {

                  print(list[i].name);
                  for(var i = 0; i<listOfColumns.length;i++){

                    if(listOfColumns[i]["Pays"]==list[i].name){
                      listOfColumns[i]["Entrant"] = (int.parse(listOfColumns[i]["Entrant"]!) +  item.duration!).toString();
                      existe = true;

                    }


                  }


                  if(!existe) {
                    setState(() {
                      listOfColumns.add(
                          {"Pays": list[i].name, "Entrant": item.duration.toString(), "Sortant": "Yes"});

                    });

                  }

              }

            }

            if(item.number?.substring(0,5) == "00213" || item.number?.substring(0,4) == "+213"){
                temps_alg += item.duration!;

                liste_appel.putIfAbsent("ALG", () => formatTime(temps_alg));
                liste_appel.update("ALG", (value) => formatTime(temps_alg));

            }
            // TOUS
            //listOfColumns.add({"Pays": "TOUS", "Entrant": "3", "Sortant": "Yes"});

              temps += item.duration!;
            liste_appel.putIfAbsent("TOUS", () => formatTime(temps));
            liste_appel.update("TOUS", (value) => formatTime(temps));

          }

      }
    }*/
    for (var item in entries2) {

      date_time = DateTime.fromMillisecondsSinceEpoch(item.timestamp!);
      date = date_time.toString().substring(0,10);

      if(item.number!.length > 5 ) {

        indicatif = item.number!.substring(0, 5);


        if(date_time.isAtSameMomentAs(d1)  || (date_time.isAfter(d1) && date_time.isBefore(d2.add(Duration(days: 1))))) {
          // ALG


          if(item.number?.substring(0,5) == "00213" || item.number?.substring(0,4) == "+213"){

            temps2_alg += item.duration!;

          }
          // TOUS
          temps2 += item.duration!;

        }

      }
    }

    setState(() {
      conso = formatTime(temps);
      entrant = formatTime(temps2);
      conso_alg = formatTime(temps_alg);
      entrant_alg = formatTime(temps2_alg);
    });

  }
}