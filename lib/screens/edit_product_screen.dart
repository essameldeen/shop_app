import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  var _imageUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var isInit = true;
  var _editProduct = Product(
    id: null,
    title: '',
    imageUrl: '',
    price: 0,
    description: '',
  );
  var initValue = {
    'title': '',
    'desc': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrlFocus);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute
          .of(context)
          .settings
          .arguments as String;
      if (productId != null) {
        _editProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValue = {
          'title': _editProduct.title,
          'desc': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrlFocus);
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrlFocus() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _formKey.currentState.validate();
    if (!isValid) return;
    _formKey.currentState.save();

    if(_editProduct.id!=null){
      Provider.of<Products>(context, listen: false).updateProduct(_editProduct.id,_editProduct);

    }else{
      Provider.of<Products>(context, listen: false).addProduct(_editProduct);
    }


    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: initValue['title'],
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Please Enter Title.";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editProduct = Product(
                        id: _editProduct.id,
                        isFavourite: _editProduct.isFavourite,
                        title: value,
                        imageUrl: _editProduct.imageUrl,
                        description: _editProduct.description,
                        price: _editProduct.price);
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  initialValue: initValue['price'],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter the price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'please enter the valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'please enter the valid price';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editProduct = Product(
                      id: _editProduct.id,
                      isFavourite: _editProduct.isFavourite,
                      title: _editProduct.title,
                      imageUrl: _editProduct.imageUrl,
                      description: _editProduct.description,
                      price: double.tryParse(value),
                    );
                  },
                ),
                TextFormField(
                  initialValue: initValue['desc'],
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  focusNode: _descriptionFocusNode,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter the Description';
                    }
                    if (value.length < 10) {
                      return 'should be at least 10 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _editProduct = Product(
                      id: _editProduct.id,
                      isFavourite: _editProduct.isFavourite,
                      title: _editProduct.title,
                      imageUrl: _editProduct.imageUrl,
                      description: value,
                      price: _editProduct.price,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 10, right: 10),
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: _imageUrlController.text.isEmpty
                          ? Text('Enter image url')
                          : FittedBox(
                        child: Image.network(_imageUrlController.text),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'please enter an image url';
                            }
                            if (!value.startsWith('http') &&
                                !value.endsWith('https')) {
                              return 'please enter a valid  url';
                            }
                            if (!value.endsWith('.jpg') &&
                                !value.endsWith('.png')) {
                              return 'please enter a valid image url';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onSaved: (value) {
                            _editProduct = Product(
                              id: _editProduct.id,
                              isFavourite: _editProduct.isFavourite,
                              title: _editProduct.title,
                              imageUrl: value,
                              description: _editProduct.description,
                              price: _editProduct.price,
                            );
                          },
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
