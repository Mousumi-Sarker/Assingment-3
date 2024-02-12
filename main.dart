import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PhotoListScreen(),
    );
  }
}

class PhotoListScreen extends StatefulWidget {
  const PhotoListScreen({super.key});

  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoListScreenState extends State<PhotoListScreen> {
  late Future<List<Photo>> _photoListFuture;

  @override
  void initState() {
    super.initState();
    _photoListFuture = fetchPhotos();
  }

  Future<List<Photo>> fetchPhotos() async {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return List<Photo>.from(list.map((model) => Photo.fromJson(model)));
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Photo Gallery App'),
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  leading: Image.network(
                    snapshot.data![index].thumbnailUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PhotoDetailScreen(photo: snapshot.data![index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PhotoDetailScreen extends StatelessWidget {
  final Photo photo;

  const PhotoDetailScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Photo Details'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(photo.url),
          const SizedBox(height: 10),
          Text('Title: ${photo.title}'),
          const SizedBox(height: 10),
          Text('ID: ${photo.id}'),
        ],
      ),
    );
  }
}

class Photo {
  final String title;
  final String url;
  final String thumbnailUrl;
  final int id;

  Photo(
      {required this.title,
      required this.url,
      required this.thumbnailUrl,
      required this.id});

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      id: json['id'],
    );
  }
}
