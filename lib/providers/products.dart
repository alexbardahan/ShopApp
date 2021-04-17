import 'dart:convert';
//adds tools to convert the product to a json file
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    //   isFavorite: false,
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    //   isFavorite: false,
    // ),
  ];
  //I made this list private, so it can't be accesed or modified outside this file

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
    //I return a copy of that list, because if I only returned _items, I would return the pointer to that list,
    //so the list can be modified anywhere outside this file and I don't want that.
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://flutter-test-bc41e-default-rtdb.firebaseio.com/products.json');

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((theKey, value) {
        loadedProducts.add(Product(
          id: theKey,
          title: value['title'],
          description: value['description'],
          imageUrl: value['imageUrl'],
          price: value['price'],
          isFavorite: value['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    //if you add async to a function, it will automatically return a future, so we don't have to use return anymore
    final url = Uri.parse(
        'https://flutter-test-bc41e-default-rtdb.firebaseio.com/products.json');
    //return (doesn't need it anymore)
    try {
      final response = await http
          //response will take the value returned by the http request
          .post(url,
              //using await we tell dart that it has to wait for this function to finish untill it executes the next code
              //it's just like wrapping the following code into .then() method
              body: json.encode({
                //we use http because this is how we defined the http package that contains the post method
                //we can not encode directly the product, but we need to use a map
                'title': product.title,
                'description': product.description,
                'imageUrl': product.imageUrl,
                'price': product.price,
                'isFavorite': product.isFavorite,
              }));
      print(json.decode(response.body));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
    //we can only call notifyListeners from this class, because we added ChangeNotifier mixin
    //it will notify all the listeners that something has changed, so they will be rebuilt

    //to send it later to the next method
    //if you don't use the .then() method, dart will not wait for this action to be done and will execute the following code in the same time
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final _prodIndex = _items.indexWhere((element) => element.id == id);
    if (_prodIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-test-bc41e-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            //isFavorite will be kept, which is great
          }));
      _items[_prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-test-bc41e-default-rtdb.firebaseio.com/products/$id.json');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
      //throw acts like return. if it is called, the code after will not be executed
    }
    existingProduct = null;
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
}
