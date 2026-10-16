import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'detail_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _get = [];

  var apiKey = 'b9ec834722234d08a61f1f340d4a227c'; 

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/everything?domains=techcrunch.com,thenextweb.com&apiKey=$apiKey',));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _get = data['articles'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('News API')),
          backgroundColor: Colors.white,
        ),
        body: ListView.builder(
          itemCount: _get.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListTile(
                leading: SizedBox(
                  width: 100,
                  height: 100,
                  child: (_get[index]['urlToImage'] != null && _get[index]['urlToImage'].toString().isNotEmpty)
                      ? Image.network(
                          _get[index]['urlToImage'],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.white),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                        ),
                ),
                title: Text(
                  _get[index]['title'] ?? 'Tidak ada judul',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _get[index]['description'] ?? 'Tidak ada deskripsi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        url: _get[index]['url'] ?? '',
                        title: _get[index]['title'] ?? 'Tidak ada judul',
                        content: _get[index]['content'] ?? 'Tidak ada konten',
                        urlToImage: _get[index]['urlToImage'] ?? 'https://cdn.pixabay.com/photo/2023/10/12/14/41/town-8310950_960_720.png',
                        author: _get[index]['author'] ?? 'Tidak ada penulis',
                        publishedAt: _get[index]['publishedAt'] ?? 'Tidak ada tanggal publikasi',
                      ),
                    ),
                  );
                },
              )
            );
          },
        ),
      ),
    );
  }
}