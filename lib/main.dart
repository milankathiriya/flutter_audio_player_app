import 'dart:ffi';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allSongs = [
    {
      'name': 'Gori Tame Manada Lidha Mohi Raj',
      'path': 'assets/audio/gori.mp3',
      'player': AssetsAudioPlayer(),
      'totalDuration': Duration.zero,
    },
    {
      'name': 'BAPS Kirtan',
      'path': 'assets/audio/baps.mp3',
      'player': AssetsAudioPlayer(),
      'totalDuration': Duration.zero,
    },
  ];

  initAudio() async {
    for (Map<String, dynamic> data in allSongs) {
      await data['player'].open(
        Audio(data['path']),
        autoStart: false,
      );
    }

    for (Map<String, dynamic> data in allSongs) {
      setState(() {
        data['totalDuration'] = data['player'].current.value!.audio.duration;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Player"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: allSongs.length,
          itemBuilder: (context, i) => Card(
            elevation: 3,
            margin: const EdgeInsets.all(8),
            child: ListTile(
              isThreeLine: true,
              leading: Text("${i + 1}"),
              title: Text("${allSongs[i]['name']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () async {
                          await allSongs[i]['player'].play();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause),
                        onPressed: () async {
                          await allSongs[i]['player'].pause();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () async {
                          await allSongs[i]['player'].stop();
                        },
                      ),
                    ],
                  ),
                  StreamBuilder(
                    stream: allSongs[i]['player'].currentPosition,
                    builder: (context, AsyncSnapshot<Duration> snapshot) {
                      Duration? currentPosition = snapshot.data;

                      return Column(
                        children: [
                          Text(
                              "${"$currentPosition".split(".")[0]}/${"${allSongs[i]['totalDuration']}".split(".")[0]}"),
                          Slider(
                            min: 0,
                            max: allSongs[i]['totalDuration']
                                .inSeconds
                                .toDouble(),
                            value: (currentPosition != null)
                                ? currentPosition.inSeconds.toDouble()
                                : 0,
                            onChanged: (val) async {
                              await allSongs[i]['player']
                                  .seek(Duration(seconds: val.toInt()));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
