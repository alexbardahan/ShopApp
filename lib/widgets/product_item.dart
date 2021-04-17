import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;
  // ProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    //listen is set to false, so it is not listening for changes to be rebuilt
    //it will rebuilt only the Icon Button, by using the Consumer class
    final cart = Provider.of<Cart>(context, listen: false);
    //we will use it here only to use its methods, so we set the listen to false
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await product.toggleFavoriteStatus();
                  } catch (error) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text(error.toString())));
                  }
                },
                color: Theme.of(context).accentColor,
              ),
            ),
            //a widget to display before the title
            backgroundColor: Colors.black87,
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.price, product.title);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                //so the current snackbar will be hidden if you press again in less than 2 seconds
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Item added to the cart!',
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    )));
              },
              color: Theme.of(context).accentColor,
            )
            //a widget to display after the title
            ),
      ),
    );
  }
}
