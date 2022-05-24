import 'package:aquarium/utilities/constants.dart';
import 'package:aquarium/widgets/clock.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DatabaseReference led = FirebaseDatabase.instance.ref();
  String _scheduledTime = "";
  bool led_status = false;
  bool feed = false;

  void _showTimePicker() {
    showTimePicker(context: context, initialTime: TimeOfDay.now()).then(
      (value) {
        setState(() {
          String time = value!.format(context).toString();
          if (time[1] == ":") {
            _scheduledTime = "0$time";
          } else {
            _scheduledTime = time;
          }
          led.child('devices').update({
            'scheduled_time': _scheduledTime,
          });
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();

    led.child('devices').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (mounted) {
        setState(() {
          _scheduledTime = (data as Map)['scheduled_time'];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Clock(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton(
              onPressed: () async {
                led.child('devices').update({
                  'led_status': true,
                });
                await Future.delayed(Duration(milliseconds: 1000));
                setState(() => feed = true);
                await Future.delayed(Duration(milliseconds: 1500));
                setState(() => feed = false);
                print('feeded');
              },
              child: feed
                  ? Row(
                      children: [
                        Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                        Text(
                          'FEEDED',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Text("FEED NOW"),
              style: TextButton.styleFrom(
                  primary: kmaincolor,
                  backgroundColor: feed ? Colors.green : Colors.white,
                  textStyle: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: _showTimePicker,
              child: Text("SCHEDULE"),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: kmaincolor,
                  textStyle: TextStyle(fontSize: 20)),
            )
          ]),
          Text(
            "Scheduled Time : $_scheduledTime",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ],
      ),
    );
  }
}