import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  ProductsGrid(this.showFavs);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavs ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: products.length,
      // itemBuilder: (ctx, i) => ChangeNotifierProvider(
      //     create: (c) => products[i],
      //child: ProductItem(),)
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        //aici arunca un obiect de tip Product, ce va fi prins de unul dintre copii, in cazul asta, ProductItem()
        //in this case we have to use that .value constructor because we are inside an single GridView item/List item
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      //I define that I have a certain amount of columns and it will squeze the items onto the screen so
      //this criteria will be met
    );
  }
}
