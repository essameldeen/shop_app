import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart' show Cart;
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const String routeName = '/cart-screen';

  @override
  Widget build(BuildContext context) {
    final cartProduct = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartProduct.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.title.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartProduct: cartProduct)
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                itemCount: cartProduct.items.length,
                itemBuilder: (ctx, index) => CartItem(
                    id: cartProduct.items.values.toList()[index].id,
                    productId: cartProduct.items.keys.toList()[index],
                    title: cartProduct.items.values.toList()[index].title,
                    price: cartProduct.items.values.toList()[index].price,
                    quantity:
                        cartProduct.items.values.toList()[index].quantity)),
          ),
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartProduct,
  }) : super(key: key);

  final Cart cartProduct;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}



class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Text(
              'ORDER NOW',
            ),
      textColor: Theme.of(context).primaryColor,
      onPressed: (widget.cartProduct.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cartProduct.items.values.toList(),
                  widget.cartProduct.totalAmount);
              setState(() {
                _isLoading = false;
              });

              widget.cartProduct.clear();
            },
    );
  }
}
