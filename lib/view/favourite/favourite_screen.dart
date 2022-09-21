import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/colors/colors.dart';
import 'package:music_player/controller/favourite_screen%20_controller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavouriteScreen extends GetView<FavouriteScreenController> {
  FavouriteScreen({Key? key}) : super(key: key);

  final favcontroller = Get.put(FavouriteScreenController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavouriteScreenController>(
      builder: (controller) => Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: appgradientcolor)),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              title: const Text(
                'Favourite',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
              child: controller.favoriteSongs.isEmpty
                  ? const Center(
                      child: Text('No FavouriteSongs Found'),
                    )
                  : GetBuilder<FavouriteScreenController>(
                      builder: (controller) => SingleChildScrollView(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: controller.favoriteSongs.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              leading: QueryArtworkWidget(
                                id: controller.favoriteSongs[index].id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: const Icon(
                                  Icons.music_note_outlined,
                                  color: Colors.black,
                                  size: 35,
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                   controller.deletesong(index);
                                  },
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Colors.black,
                                  )),
                              title: Text(
                                controller.favoriteSongs[index].title,
                                maxLines: 1,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                              subtitle: Text(
                                controller.favoriteSongs[index].album!,
                                style: const TextStyle(color: Colors.black54),
                              ),
                              onTap: () {
                               controller.listileOntap(index);
                               
                              },
                            );
                          },
                        ),
                      ),
                    ),
            )),
      ),
    );
  }
}
