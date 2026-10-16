import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final String? title ;
  final String? urlToImage ;
  final String? publishedAt ;
  final String? content ;
  final String? author ;
  final String? url ;

  const DetailPage({
    super.key,
    this.title = "",
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.author,
    this.url = "",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Detail News',
            style: TextStyle(color: Colors.black),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: <Widget>[
          urlToImage != null && urlToImage!.isNotEmpty
              ? Image.network(urlToImage!)
              : Container (
            margin: EdgeInsets.all(20),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$publishedAt',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text('$content'),
                const Divider(),
                Text('$author'),
                Text('$url'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
