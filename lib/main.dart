import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Products {
  int? id;
  String title;
  String? description;
  int? price;
  double? discountPercentage;
  dynamic rating;
  int? stock;
  String? brand;
  String? category;
  String? thumbnail;
  List<dynamic> images;

  Products({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      description: json['description'],
      id: json['id'],
      title: json['title'],
      brand: json['brand'],
      price: json['price'],
      discountPercentage: json['discountPercentage'],
      rating: json['rating'],
      stock: json['stock'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      images: json['images'],
    );
  }
}

Future<List<Products>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if (response.statusCode == 200) {
    var data = json.decode(response.body)['products'] as List;
    List<Products> productsList =
        data.map((i) => Products.fromJson(i)).toList();
    return productsList;
  } else {
    throw Exception('Failed to load products');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Products',
      home: const MyHomePage(title: 'Products'),
    );
  }
}

void _bottomSheet(BuildContext context, Products data) {
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: data.images
                        .map((i) => Container(
                              width: 200, // Set your desired width
                              height: 200, // Set your desired height
                              child: Image.network(i),
                            ))
                        .toList(),
                  ),
                ),
                Row(children: [Text(data.title)]),
                Row(children: [
                  Flexible(
                      child: Text(
                          maxLines: 1, // Adjust the number of lines as needed
                          overflow: TextOverflow.clip,
                          data.description!))
                ]),
                Row(children: [Text("\$${data.price.toString()}")]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(color: Colors.yellow, Icons.star),
                          Text(data.rating.toString())
                        ],
                      ),
                      Row(
                        children: [
                          Text(data.discountPercentage.toString() + "%"),
                          Icon(color: Colors.blue, Icons.discount),
                        ],
                      )
                    ])
              ],
            ));
      });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(style: TextStyle(color: Colors.black), widget.title),
          centerTitle: true,
          elevation: 0,
        ),
        body: FutureBuilder<List<Products>>(
          future: fetchProducts(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Products>? data = snapshot.data;
              return ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 20,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      color: Colors.lightGreen.shade50,
                      child: Column(children: [
                        Image.network(data[index].thumbnail!),
                        Card(
                            clipBehavior: Clip.antiAlias,
                            color: Colors.lightGreen.shade50,
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data[index].title),
                                    Row(children: [
                                      Text(" ${data[index].price} USD "),
                                      GestureDetector(
                                          onTap: () {
                                            _bottomSheet(context, data[index]);
                                          },
                                          child:
                                              Icon(Icons.remove_red_eye_sharp))
                                    ])
                                  ]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                      child: Text(
                                          maxLines:
                                              1, // Adjust the number of lines as needed
                                          overflow: TextOverflow.clip,
                                          data[index].description!))
                                ],
                              )
                            ]))
                      ]),
                    );
                  });
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}
