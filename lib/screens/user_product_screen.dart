import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const String routeName = '/user_product-screen';

  Future<void> fetchDateFromServer(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchDataFromServer(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MainDrawer(),
        appBar: AppBar(
          title: const Text('Yours Products'),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                })
          ],
        ),
        body: FutureBuilder(
          future: fetchDateFromServer(context),
          builder: (ctx, snapShot) =>
              snapShot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: () => fetchDateFromServer(context),
                      child: Consumer<Products>(
                        builder: (ctx, productsData, _) => Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                              itemCount: productsData.myProducts.length,
                              itemBuilder: (ctx, index) => Column(
                                    children: [
                                      UserProductItem(
                                        productsData.myProducts[index].title,
                                        productsData.myProducts[index].imageUrl,
                                        productsData.myProducts[index].id,
                                      ),
                                      const Divider(),
                                    ],
                                  )),
                        ),
                      ),
                    ),
        ));
  }
}
