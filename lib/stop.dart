import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchApp extends StatefulWidget {
  const StopwatchApp({Key? key}) : super(key: key);

  @override
  State<StopwatchApp> createState() => _StopwatchState();
}

class _StopwatchState extends State<StopwatchApp> {
  bool flag = true;
  bool isPaused = false;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hrsStr = '00';
  String minStr = '00';
  String secStr = '00';

  Stream<int> stopWatchStream() {
    late StreamController<int> streamController;
    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer?.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: () {
        if (isPaused) {
          // Resume from where it left off
          startTimer();
        } else {
          startTimer();
        }
      },
      onCancel: stopTimer,
      onResume: () {
        if (!isPaused) {
          startTimer();
        }
      },
      onPause: () {
        stopTimer();
        isPaused = true;
      },
    );
    return streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Stopwatch Application'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$hrsStr:$minStr:$secStr",
              style: TextStyle(
                fontSize: 80.0,
              ),
            ),
            SizedBox(height: 30.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    timerStream = stopWatchStream();
                    timerSubscription = timerStream!.listen((int newTick) {
                      setState(() {
                        hrsStr = ((newTick / (60 * 60)) % 60)
                            .floor()
                            .toString()
                            .padLeft(2, '0');
                        minStr = ((newTick / 60) % 60)
                            .floor()
                            .toString()
                            .padLeft(2, '0');
                        secStr = (newTick % 60).floor().toString().padLeft(2, '0');
                      });
                    });
                  },
                  child: Text(
                    'Start',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 15.0),
                ElevatedButton(
                  onPressed: () {
                    if (timerSubscription != null) {
                      timerSubscription!.pause();
                    }
                    setState(() {
                      isPaused = true;
                    });
                  },
                  child: Text(
                    'Pause',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                SizedBox(width: 10.0),
                /*ElevatedButton(
                  onPressed: () {
                    if (timerSubscription != null) {
                      timerSubscription!.resume();
                    }
                    setState(() {
                      isPaused = false;
                    });
                  },
                  child: Text(
                    'Resume',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),*/
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    flag = false;
                    timerStream = null;
                    timerSubscription?.cancel();
                    setState(() {
                      hrsStr = '00';
                      minStr = '00';
                      secStr = '00';
                      isPaused = false;
                    });
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
