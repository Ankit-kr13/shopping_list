import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final formKey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables]!;
  void saveItem() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      final url = Uri.https('shopping-list-a2ff1-default-rtdb.firebaseio.com',
          'shoppinh-list.json');
      http.post(
        url,
        headers: {
          'content-type': 'application/json',
        },
        body: json.encode(
          {
            'name': enteredName,
            'quantity': enteredQuantity,
            'category': selectedCategory.title,
          },
        ),
      );

      // Locally storin the data.
      // Navigator.of(context).pop(GroceryItem(
      //     id: DateTime.now().toString(),
      //     name: enteredName,
      //     quantity: enteredQuantity,
      //     category: selectedCategory));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: InputDecoration(label: Text('Name')),
                  validator: (Value) {
                    if (Value == null ||
                        Value.isEmpty ||
                        Value.trim().length <= 1 ||
                        Value.trim().length >= 50) {
                      return 'Must be between 1 to 50 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // if (value == null) {
                    //   return;
                    // }
                    enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('Quantity'),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: enteredQuantity.toString(),
                        validator: (Value) {
                          if (Value == null ||
                              Value.isEmpty ||
                              int.tryParse(Value) == null ||
                              int.tryParse(Value)! <= 0) {
                            return 'Must be a valid positive number.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: Row(children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ]),
                            ),
                        ],
                        onChanged: (Category? value) {
                          setState(() {
                            selectedCategory = value ?? selectedCategory;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        formKey.currentState!.reset();
                      },
                      child: const Text('Reset'),
                    ),
                    SizedBox(width: 15),
                    ElevatedButton(
                      onPressed: saveItem,
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
