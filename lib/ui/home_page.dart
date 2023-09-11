// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:search_gif/ui/gif_page.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;
  final _searchLimit = 19, _trendingLimit = 20;

  Future<Map> _getGifs() async {
    http.Response response;

    String _urlTrending =
        'https://api.giphy.com/v1/gifs/trending?api_key=HDCwvAS6eUQUMbdGNHeuwT3nI5KWm2sz&limit=$_trendingLimit&offset=0&rating=g&bundle=messaging_non_clips';
    final String _urlSearch =
        'https://api.giphy.com/v1/gifs/search?api_key=HDCwvAS6eUQUMbdGNHeuwT3nI5KWm2sz&q=$_search&limit=$_searchLimit&offset=$_offset&rating=g&lang=pt&bundle=messaging_non_clips';

    if (_search == null) {
      response = await http.get(Uri.parse(_urlTrending));
    } else {
      response = await http.get(Uri.parse(_urlSearch));
    }

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Buscador de Gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar',
                labelStyle: TextStyle(color: Colors.white),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
              textAlign: TextAlign.left,
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5,
                      ),
                    );
                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  // Future<void> share(String link) async {
  //   await FlutterShare.share(
  //       title: 'Compartilhar Gif',
  //       text: 'Compartilhe com quem desejar essa gif...',
  //       linkUrl: link,
  //       chooserTitle: null);
  // }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: Image.network(
              snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data['data'][index]),
                ),
              );
            },
            onLongPress: (){
              //Share.share(snapshot.data['data'][index]['images']['fixed_height']['url']);
            },
          );
        } else {
          return GestureDetector(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay, color: Colors.white, size: 50.0),
                Text(
                  'Recarregar',
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _offset += 19;
              });
            },
          );
        }
      },
    );
  }
}