import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = '/product-details';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments
        as String; // id of product clicked
    final productSelectedData =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(productSelectedData.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(productSelectedData.title),
              background: Hero(
                tag: productSelectedData.id,
                child: Image.network(
                  productSelectedData.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$${productSelectedData.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  '${productSelectedData.description}',
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
            SizedBox(
              height: 800,
            )
          ])),
        ],
      ),
    );
  }
}
