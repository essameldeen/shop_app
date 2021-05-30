import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/main_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const String routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      drawer: MainDrawer(),
      body: FutureBuilder(
        future:
            Provider.of<Orders>(context, listen: false).fetchDataFromServer(),
        builder: (ctx, currentState) {
          if (currentState.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (currentState.error != null) {
            return Center(
              child: Text("An Error Happened!"),
            );
          } else {
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.items.length,
                  itemBuilder: (ctx, index) =>
                      OrderItem(orderData.items[index])),
            );
          }
        },
      ),
    );
  }
}
