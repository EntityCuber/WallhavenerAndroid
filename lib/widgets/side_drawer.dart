import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String _categories = '111';
  String _purity = '100';
  String _sorting = 'hot';
  String _ratios = '';
  String _apikey = '';
  String _q = '';

  Color on = Color(0xFFFFFFFF);
  Color off = Color(0xFF999999);

  final apiInputController = TextEditingController();
  final queryInputController = TextEditingController();

  Future<void> setWallpaper(location, url) async {
    // Image url
    var file = await DefaultCacheManager().getSingleFile(url);
    await WallpaperManagerFlutter().setwallpaperfromFile(file, location);
    Fluttertoast.showToast(msg: "Wallpaper Set");
  }

  Future<void> _setAutoWall() async {
    Fluttertoast.showToast(msg: 'Searching Wallpapers');
    try {
      Response response =
          await get(Uri.parse('https://wallhaven.cc/api/v1/search?'
              'categories=$_categories'
              '&purity=$_purity'
              '&sorting=$_sorting'
              '&ratios=$_ratios'
              '&apikey=$_apikey'
              '&q=$_q'
              '&page=1'),
              headers: {'Access-Control-Allow-Origin': '*'}
          );

      print('https://wallhaven.cc/api/v1/search?'
          'categories=$_categories'
          '&purity=$_purity'
          '&sorting=$_sorting'
          '&ratios=$_ratios'
          '&apikey=$_apikey'
          '&q=$_q'
          '&page=1');
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);

        List walls = data['data'].map((wall) {
          return wall['path'];
        }).toList();
        print(walls.length);
        if (walls.length != 0) {
          String path = walls[Random().nextInt(walls.length)];
          await setWallpaper(WallpaperManagerFlutter.HOME_SCREEN, path);
        } else {
          Fluttertoast.showToast(msg: 'No results found');
        }
      } else if (response.statusCode == 401) {
        Fluttertoast.showToast(msg: 'Invalid api key');
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(msg: 'Failed to load');
    }
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  Future<void> _savePreferences(key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

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
        apiInputController.text = _apikey;
      });
    }
    if (prefs.containsKey('q')) {
      final String savedQ = prefs.getString('q')!;
      setState(() {
        _q = savedQ;
        queryInputController.text = _q;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveSavedPreferences();
  }

  @override
  void dispose() {
    apiInputController.dispose();
    queryInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Drawer(
              elevation: 5,
              child: Container(
                color: Color(0xFF000000),
                child: SafeArea(
                  child: Container(
                      padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
                      color: Color(0xFF000000),
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 230.0,
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      controller: queryInputController,
                                      onChanged: (key) {
                                        _savePreferences(
                                            'q', queryInputController.text);
                                      },
                                      textAlign: TextAlign.center,
                                      showCursor: false,
                                      cursorColor: Color(0xFF999999),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        hintText: 'Query',
                                      ),
                                      style: TextStyle(
                                          height: 1,
                                          fontSize: 14,
                                          letterSpacing: 3,
                                          color: Color(0xFF999999)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 230.0,
                                    height: 70.0,
                                    child: TextField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      obscureText: true,
                                      obscuringCharacter: '*',
                                      controller: apiInputController,
                                      onChanged: (key) {
                                        _savePreferences(
                                            'apikey', apiInputController.text);
                                        if (key == '') {
                                          setState(() {
                                            if ('${_purity[0]}' == '0' &&
                                                '${_purity[1]}' == '0') {
                                              _purity = replaceCharAt(
                                                  _purity, 0, '1');
                                            }
                                            _purity =
                                                replaceCharAt(_purity, 2, '0');
                                            _savePreferences('purity', _purity);
                                          });
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                      textAlign: TextAlign.center,
                                      showCursor: false,
                                      cursorColor: Color(0xFF999999),
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(0),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color(0xFF999999),
                                              width: 1.0),
                                        ),
                                        hintText: 'Wallhaven api key',
                                      ),
                                      style: TextStyle(
                                          height: 1,
                                          fontSize: 14,
                                          letterSpacing: 3,
                                          color: Color(0xFF999999)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: Color(0xFF999999),
                              height: 0.0,
                              thickness: 1,
                              endIndent: 34,
                            ),
                            SizedBox(height: 20),
                            Text('Category'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replaceCharAt(
                                                _categories, 0, '0') !=
                                            '000') {
                                          '${_categories[0]}' == '1'
                                              ? _categories = replaceCharAt(
                                                  _categories, 0, '0')
                                              : _categories = replaceCharAt(
                                                  _categories, 0, '1');
                                        }
                                        _savePreferences(
                                            'categories', _categories);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              '${_categories[0]}' == '1'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('General',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replaceCharAt(
                                                _categories, 1, '0') !=
                                            '000') {
                                          '${_categories[1]}' == '1'
                                              ? _categories = replaceCharAt(
                                                  _categories, 1, '0')
                                              : _categories = replaceCharAt(
                                                  _categories, 1, '1');
                                        }
                                        _savePreferences(
                                            'categories', _categories);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              '${_categories[1]}' == '1'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('Anime',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replaceCharAt(
                                                _categories, 2, '0') !=
                                            '000') {
                                          '${_categories[2]}' == '1'
                                              ? _categories = replaceCharAt(
                                                  _categories, 2, '0')
                                              : _categories = replaceCharAt(
                                                  _categories, 2, '1');
                                        }
                                        _savePreferences(
                                            'categories', _categories);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              '${_categories[2]}' == '1'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text(
                                      'People',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text('Purity'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replaceCharAt(_purity, 0, '0') !=
                                            '000') {
                                          '${_purity[0]}' == '1'
                                              ? _purity =
                                                  replaceCharAt(_purity, 0, '0')
                                              : _purity = replaceCharAt(
                                                  _purity, 0, '1');
                                        }
                                        _savePreferences('purity', _purity);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              '${_purity[0]}' == '1'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('SFW',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replaceCharAt(_purity, 1, '0') !=
                                            '000') {
                                          '${_purity[1]}' == '1'
                                              ? _purity =
                                                  replaceCharAt(_purity, 1, '0')
                                              : _purity = replaceCharAt(
                                                  _purity, 1, '1');
                                        }
                                        _savePreferences('purity', _purity);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              '${_purity[1]}' == '1'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('Sketchy',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  apiInputController.text != ''
                                      ? ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              if (replaceCharAt(
                                                      _purity, 2, '0') !=
                                                  '000') {
                                                '${_purity[2]}' == '1'
                                                    ? _purity = replaceCharAt(
                                                        _purity, 2, '0')
                                                    : _purity = replaceCharAt(
                                                        _purity, 2, '1');
                                              }
                                              _savePreferences(
                                                  'purity', _purity);
                                            });
                                          },
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<
                                                    RoundedRectangleBorder>(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            13.0))),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    '${_purity[2]}' == '1'
                                                        ? on
                                                        : off),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Color(0xFF000000)),
                                          ),
                                          child: Text('NSFW',
                                              style: TextStyle(fontSize: 12)),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                            Divider(
                              color: Color(0xFF999999),
                              height: 20.0,
                              thickness: 1,
                              endIndent: 34,
                            ),
                            SizedBox(height: 5),
                            Text('Ratios'),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _ratios = '';
                                        _savePreferences('ratios', _ratios);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _ratios == '' ? on : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('Any',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _ratios = 'portrait';
                                        _savePreferences('ratios', _ratios);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _ratios == 'portrait' ? on : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('Portrait',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _ratios = 'landscape';
                                        _savePreferences('ratios', _ratios);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _ratios == 'landscape'
                                                  ? on
                                                  : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text('Wide',
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text('Sorting'),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _sorting = 'random';
                                        _savePreferences('sorting', _sorting);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _sorting == 'random' ? on : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.random,
                                      size: 15,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _sorting = 'hot';
                                        _savePreferences('sorting', _sorting);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _sorting == 'hot' ? on : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.fire,
                                      size: 15,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _sorting = 'toplist';
                                        _savePreferences('sorting', _sorting);
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              _sorting == 'toplist' ? on : off),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.solidGem,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _sorting = 'favorites';
                                      _savePreferences('sorting', _sorting);
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.0))),
                                    backgroundColor: MaterialStateProperty.all(
                                        _sorting == 'favorites' ? on : off),
                                    foregroundColor: MaterialStateProperty.all(
                                        Color(0xFF000000)),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.solidHeart,
                                    size: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _sorting = 'date_added';
                                      _savePreferences('sorting', _sorting);
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.0))),
                                    backgroundColor: MaterialStateProperty.all(
                                        _sorting == 'date_added' ? on : off),
                                    foregroundColor: MaterialStateProperty.all(
                                        Color(0xFF000000)),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.solidClock,
                                    size: 15,
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _sorting = 'views';
                                      _savePreferences('sorting', _sorting);
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(13.0))),
                                    backgroundColor: MaterialStateProperty.all(
                                        _sorting == 'views' ? on : off),
                                    foregroundColor: MaterialStateProperty.all(
                                        Color(0xFF000000)),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.solidEye,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(
                              color: Color(0xFF999999),
                              height: 0.0,
                              thickness: 1,
                              endIndent: 34,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text('Auto Wallpaper'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _setAutoWall();
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(13.0))),
                                      backgroundColor:
                                          MaterialStateProperty.all(on),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xFF000000)),
                                    ),
                                    child: Text(
                                      'Random',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              )),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
