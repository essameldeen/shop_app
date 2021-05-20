import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = 'User_product-screen';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Yours Products'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: productsData.myProducts.length,
            itemBuilder: (ctx, index) => Column(
                  children: [
                    UserProductItem(
                      productsData.myProducts[index].title,
                      productsData.myProducts[index].imageUrl,
                    ),
                    const Divider(),
                  ],
                )),
      ),
    );
  }
}
