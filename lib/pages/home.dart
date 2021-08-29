import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'dart:convert';
import 'package:wallhavener/services/thumbs.dart';
import 'package:wallhavener/widgets/side_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Thumbs> thumbnails = [];

  int _lastPage = 0;
  int _currentPage = 1;

  String _categories = '111';
  String _purity = '100';
  String _sorting = 'hot';
  String _ratios = '';
  String _apikey = '';
  String _q = '';

  Future<void> _retrieveSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('categories')) {
      final String savedCategories = prefs.getString('categories')!;
      setState(() {
        _categories = savedCategories;
      });
    }
    if (prefs.containsKey('purity')) {
      final String savedPurity = prefs.getString('purity')!;
      setState(() {
        _purity = savedPurity;
      });
    }
    if (prefs.containsKey('sorting')) {
      final String savedSorting = prefs.getString('sorting')!;
      setState(() {
        setState(() {
          _sorting = savedSorting;
        });
      });
    }
    if (prefs.containsKey('ratios')) {
      final String savedRatios = prefs.getString('ratios')!;
      setState(() {
        _ratios = savedRatios;
      });
    }
    if (prefs.containsKey('apikey')) {
      final String savedApikey = prefs.getString('apikey')!;
      setState(() {
        _apikey = savedApikey;
      });
    }
    if (prefs.containsKey('q')) {
      final String savedQ = prefs.getString('q')!;
      setState(() {
        _q = savedQ;
      });
    }
  }

  Future<void> _refresh() async {
    print('refreshing list');
    setState(() {
      thumbnails = [];
    });
    _currentPage = 1;
    _getThumbnails(_currentPage);
  }

  Future<void> _getThumbnails(currentPage) async {
    await _retrieveSavedPreferences();
    print('https://wallhaven.cc/api/v1/search?'
        'categories=$_categories'
        '&purity=$_purity'
        '&sorting=$_sorting'
        '&ratios=$_ratios'
        '&apikey=$_apikey'
        '&q=$_q'
        '&page=$currentPage');

    try {
      Response response =
          await get(Uri.parse('https://wallhaven.cc/api/v1/search?'
              'categories=$_categories'
              '&purity=$_purity'
              '&sorting=$_sorting'
              '&ratios=$_ratios'
              '&apikey=$_apikey'
              '&q=$_q'
              '&page=$currentPage'));

      print(response.statusCode);

      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        print(data);
        setState(() {
          thumbnails += data['data'].map<Thumbs>((wall) {
            return Thumbs(
              path: wall['path'],
              resolution: wall['resolution'],
              ratio: wall['ratio'],
              shortUrl: wall['short_url'],
              thumbsOriginal: wall['thumbs']['original'],
              thumbsLarge: wall['thumbs']['large'],
              dimensionX: wall['dimension_x'],
              dimensionY: wall['dimension_y'],
              purity: wall['purity'],
            );
          }).toList();
          if (thumbnails.length == 0) {
            Fluttertoast.showToast(msg: 'No results found');
          }
        });
        _lastPage = data['meta']['last_page'];
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Invalid api key');
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(msg: 'Failed to load');
    }
  }

  @override
  void initState() {
    super.initState();
    _getThumbnails(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      drawer: SideBar(),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              thumbnails = [];
              _getThumbnails(1);
            },
          )
        ],
        title: Text('Wallhavener'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Color(0xFF000000),
      ),
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 500 &&
              _currentPage < _lastPage) {
            print('more');
            _currentPage += 1;
            print('$_currentPage current, $_lastPage last');
            _getThumbnails(_currentPage);
          } else {
            print('$_currentPage current, $_lastPage last');
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () => _refresh(),
          strokeWidth: 2,
          color: Color(0xFFFFFFFF),
          backgroundColor: Color(0xFF000000),
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: WaterfallFlow.builder(
            itemCount: thumbnails.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                print(thumbnails[index].path);
                Navigator.pushNamed(context, '/wallview', arguments: {
                  'path': thumbnails[index].path,
                  'resolution': thumbnails[index].resolution,
                  'shortUrl': thumbnails[index].shortUrl,
                  'dimensionX': thumbnails[index].dimensionX,
                  'dimensionY': thumbnails[index].dimensionY,
                  'purity': thumbnails[index].purity,
                });
              },
              child: Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(0),
                child: Container(
                  color: Color(0xFF101010),
                  height: (thumbnails[index].dimensionX.toDouble() * 6) /
                      (double.parse(thumbnails[index].ratio)) *
                      50 /
                      (thumbnails[index].dimensionY.toDouble() *
                          1.5 *
                          (double.parse(thumbnails[index].ratio))),
                  child: CachedNetworkImage(
                    imageUrl: thumbnails[index].thumbsOriginal,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 5),
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
          ),
        ),
      ),
    );
  }
}
