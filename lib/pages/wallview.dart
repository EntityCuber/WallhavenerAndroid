import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:open_file/open_file.dart';

class WallView extends StatelessWidget {
  Future<void> setWallpaper(location, url) async {
    // Image url
    var file = await DefaultCacheManager()
        .getSingleFile(url); //image file//Choose screen type
    await WallpaperManagerFlutter().setwallpaperfromFile(file, location);
    Fluttertoast.showToast(msg: "Wallpaper Set");
  }

  @override
  Widget build(BuildContext context) {
    final Map data = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
        backgroundColor: Color(0xFF000000),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 20,
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained,
                  imageProvider: CachedNetworkImageProvider(data['path']),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle_outlined,
                                  size: 15, color: Color(0xFFFFFFFF)),
                              SizedBox(width: 5),
                              InkWell(
                                  onTap: () => launch(data['path']),
                                  child: Text(
                                    data['shortUrl'],
                                    style: TextStyle(fontSize: 13),
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.check_box_outline_blank,
                                  size: 15, color: Color(0xFFFFFFFF)),
                              SizedBox(width: 5),
                              Text(
                                "${data['resolution']}",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        insetPadding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 0),
                                        elevation: 0,
                                        backgroundColor: Color(0x00000000),
                                        content: InkWell(
                                          splashColor: Color(0x00000000),
                                          hoverColor: Color(0x00000000),
                                          focusColor: Color(0x00000000),
                                          highlightColor: Color(0x00000000),
                                          enableFeedback: false,
                                          onTap: () => Navigator.of(ctx).pop(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  setWallpaper(
                                                      WallpaperManagerFlutter
                                                          .HOME_SCREEN,
                                                      data['path']);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Text("Home Screen"),
                                                ),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Color(0xFF000000)),
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        23.0),
                                                            side: BorderSide(
                                                                color: Color(
                                                                    0xFF999999))))),
                                              ),
                                              SizedBox(height: 5),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setWallpaper(
                                                      WallpaperManagerFlutter
                                                          .LOCK_SCREEN,
                                                      data['path']);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Text("Lock Screen"),
                                                ),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Color(0xFF000000)),
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        23.0),
                                                            side: BorderSide(
                                                                color: Color(
                                                                    0xFF999999))))),
                                              ),
                                              SizedBox(height: 5),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setWallpaper(
                                                      WallpaperManagerFlutter
                                                          .BOTH_SCREENS,
                                                      data['path']);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Text("Both Screen"),
                                                ),
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty.all(
                                                            Color(0xFF000000)),
                                                    shape: MaterialStateProperty.all<
                                                            RoundedRectangleBorder>(
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        23.0),
                                                            side: BorderSide(
                                                                color: Color(
                                                                    0xFF999999))))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                            },
                            icon: Icon(Icons.wallpaper),
                          ),
                          SizedBox(width: 5),
                          IconButton(
                            onPressed: () async {
                              await Fluttertoast.showToast(
                                  msg: "Downloading Wallpaper");
                              var imageId = await ImageDownloader.downloadImage(
                                  data['path']);
                              await Fluttertoast.showToast(
                                  msg: "Wallpaper Downloaded");
                              var path =
                                  await ImageDownloader.findPath(imageId!);
                              await OpenFile.open(path!);
                            },
                            icon: Icon(Icons.download),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
