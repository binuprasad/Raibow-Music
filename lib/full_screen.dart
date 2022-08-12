import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/favourite/favourite_button.dart';
import 'package:music_player/favourite/favourite_db.dart';
import 'package:music_player/get_all_songs.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({Key? key, required this.playersong}) : super(key: key);
  final List<SongModel> playersong;

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  bool _isshuffle = false;
  int currentIndexes = 0;

  @override
  void initState() {
    super.initState();
    GetAllSongs.player.currentIndexStream.listen((index) {
      if (index != null && mounted()) {
        setState(() {
          currentIndexes = index;
        });
        GetAllSongs.currentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
        final width= MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              FavouriteDB.favoriteSongs.notifyListeners();
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  QueryArtworkWidget(
                    artworkHeight: height/2.3,
                    artworkWidth:width,
                    artworkFit: BoxFit.fill,
                    keepOldArtwork: true,
                    id: widget.playersong[currentIndexes].id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget:  Container(
                      color: Colors.white,
                      height: height/2.5,
                      width: width,
                      child: Icon(
                        Icons.music_note,
                        size: height/4,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top:10.0),
                    child: Text(
                      widget.playersong[ currentIndexes].displayNameWOExt,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                  Text(
                    widget.playersong[ currentIndexes].artist.toString(),
                    maxLines: 1,
                  )
                ],
              ),
              SizedBox(
                height: height / 12,
              ),
              Column(
                children: [
                  StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;
                        return ProgressBar(
                            timeLabelTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                            progress: progress,
                            total: total,
                            barHeight: 3.0,
                            thumbRadius: 5,
                            progressBarColor: Colors.black,
                            thumbColor: Colors.black,
                            baseBarColor: Colors.grey,
                            bufferedBarColor: Colors.grey,
                            buffered: const Duration(milliseconds: 2000),
                            onSeek: (duration) {
                              GetAllSongs.player.seek(duration);
                            });
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () async {
                          GetAllSongs.player.loopMode == LoopMode.one
                              ? GetAllSongs.player.setLoopMode(LoopMode.all)
                              : GetAllSongs.player.setLoopMode(LoopMode.one);
                        },
                        icon: StreamBuilder(
                          stream: GetAllSongs.player.loopModeStream,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            final loopMode = snapshot.data;
                            if (LoopMode.one == loopMode) {
                              return const Icon(
                                Icons.repeat_one,
                                color: Colors.black,
                              );
                            } else {
                              return const Icon(
                                Icons.repeat,
                                color: Colors.grey,
                              );
                            }
                          },
                        ),
                      ),
                      FavouriteBtn(song: widget.playersong[currentIndexes]),
                      IconButton(
                        onPressed: () {
                          _isshuffle == false
                              ? GetAllSongs.player.setShuffleModeEnabled(true)
                              : GetAllSongs.player.setShuffleModeEnabled(false);
                              setState(() {
                                    _isshuffle = !_isshuffle;
                                  });
                        },
                        icon: StreamBuilder <bool>(
                          stream: GetAllSongs.player.shuffleModeEnabledStream,
                          builder:
                              ( context, AsyncSnapshot snapshot) {
                            _isshuffle = snapshot.data;
                            if (_isshuffle) {
                              return const Icon(
                                Icons.shuffle,
                                color: Colors.black,
                              );
                            } else {
                              return const Icon(
                                Icons.shuffle,
                                color: Colors.grey,
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (GetAllSongs.player.hasPrevious) {
                            await GetAllSongs.player.seekToPrevious();
                            await GetAllSongs.player.play();
                          } else {
                            await GetAllSongs.player.play();
                          }
                        },
                        icon: const Icon(
                          Icons.skip_previous,
                        ),
                        iconSize: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 29,right: 25 ),
                        child: IconButton(
                          onPressed: () async {
                            if (GetAllSongs.player.playing) {
                              await GetAllSongs.player.pause();
                              setState(() {});
                            } else {
                              await GetAllSongs.player.play();
                              setState(() {});
                            }
                          },
                          icon: StreamBuilder(
                            stream: GetAllSongs.player.playingStream,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              bool? playingStage = snapshot.data;
                              if (playingStage != null && playingStage) {
                                return const Icon(
                                  Icons.pause,
                                  size: 60,
                                );
                              } else {
                                return const Icon(
                                  Icons.play_arrow,
                                  size: 60,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (GetAllSongs.player.hasNext) {
                            await GetAllSongs.player.seekToNext();
                            await GetAllSongs.player.play();
                          } else {
                            GetAllSongs.player.play();
                          }
                        },
                        icon: const Icon(Icons.skip_next),
                        iconSize: 50,
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeInSeeconds(int second) {
    Duration duration = Duration(seconds: second);
    GetAllSongs.player.seek(duration);
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          GetAllSongs.player.positionStream,
          GetAllSongs.player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
