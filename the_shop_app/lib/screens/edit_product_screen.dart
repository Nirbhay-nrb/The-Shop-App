import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_shop_app/providers/product.dart';
import 'package:the_shop_app/providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );
  var _initValues = {
    // will be used to initialize the textFormFields in case of editing or new product
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    // you cannot use ModalRoute to access arguments in initstate so you have to use
    // didChangeDependencies
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // this will be run whenever there is any change
    // but this also runs before the build is execute just like initstate

    // as this will be executed multiple times, we need as bool variable to not let the code refresh the form again and again
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    // once the arguments are fetched we can just turn this to false so that we dont fetch the arguements again and refresh the form
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) {
        print(true);
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _saveForm() {
    final isValid = _form.currentState
        .validate(); // returns true if all are true else return false
    // triggers the validate function in every textFormField
    if (!isValid) {
      // incase the data is invalid, then the form wont be saved
      return;
    }
    _form.currentState
        .save(); // executes the onSaved function in every textFormField
    print(_editedProduct.title);
    print(_editedProduct.description);
    print(_editedProduct.price);
    print(_editedProduct.imageUrl);
    if (_editedProduct.id != null) {
      // a product will only have an ID if it is being edited
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      // editing the item
    } else {
      // adding a new product as the id is null
      Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  initialValue: _initValues['title'],
                  textInputAction: TextInputAction.next,
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: value,
                      description: _editedProduct.description,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                    );
                  },
                  validator: (value) {
                    // null means correct , any string means its wrong and thats the message displayed
                    if (value.isEmpty) {
                      return 'Please enter a value'; // error message
                      // if you want to change the style then add errorstyle attribute in decoration
                    }
                    return null; // valid title
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  initialValue: _initValues['price'],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: double.parse(value),
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      // tryParse returns null if it fails to validate a number
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      // if price is smaller than 0
                      return 'Please enter a number greater than zero';
                    }
                    return null; // valid number
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Description'),
                  initialValue: _initValues['description'],
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      description: value,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl,
                      id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter something';
                    }
                    if (value.length < 10) {
                      return 'Should be atleast 10 characters long';
                    }
                    return null; // valid description
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Center(child: Text('Enter a URL'))
                          : FittedBox(
                              child: Image.network(_imageUrlController.text),
                              fit: BoxFit.contain,
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        // initialValue: _initValues['imageUrl'], // you cannot set an initial value with a controller
                        // therefore set the controller's value equal to the initial value
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageUrlFocusNode,
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: value,
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter a URL';
                          }
                          if (!value.startsWith('http') &&
                              !value.startsWith('https')) {
                            return 'Please enter a valid URL';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
