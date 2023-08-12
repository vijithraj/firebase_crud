

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "name"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "price"),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final String name = _nameController.text;
                      final double? price = double.parse(_priceController.text);
                      if (price != null) {
                        await _products
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "price": price});
                        _nameController.text = '';
                        _priceController.text = '';
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Update"))
              ],
            ),
          );
        });
  }

    Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
      if (documentSnapshot != null) {
        _nameController.text = documentSnapshot['name'];
        _priceController.text = documentSnapshot['price'].toString();
      }
      await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'name'),
                  ),
                  TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'price'),
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          final String name = _nameController.text;
                          final double price =
                          double.parse(_priceController.text);
                          if (price != null) {
                            await _products.add({'name': name, 'price': price});
                            _nameController.text = '';
                            _priceController.text = '';
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add')),
                  )
                ],
              ),
            );
          });
    }

    Future<void> _delete(String productsId) async {
      await _products.doc(productsId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar
        (content: Text("You have successfully deleted a product")));
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Firebase CRUD",
            style: TextStyle(fontSize: 23, color: Colors.white),
          ),
          backgroundColor: Colors.brown.shade400,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.brown,
          onPressed: () {
            _create();
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: StreamBuilder(
            stream: _products.snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: false,
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        title: Text(
                          documentSnapshot['name'],
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          documentSnapshot['price'].toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _update(documentSnapshot);
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    )),
                                IconButton(
                                    onPressed: () {
                                      _delete(documentSnapshot.id);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    )),
                              ],
                            )),
                      );
                    });
              }
              return const CircularProgressIndicator();
            }),
      );
    }

}