import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool Worker = false;
  bool updateWorker=false;
  TextEditingController nameController = TextEditingController();
  @override
  final db = FirebaseFirestore.instance;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Enter your name"
          ),
        ),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: ()async{
              await db.collection('Zain').add({'name': nameController.text, 'Work': Worker});
              setState(() {
                Worker = !Worker;
                ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Successfully update",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),), backgroundColor: Colors.green,));
    },
              );


            }, child: Worker == false
            ? const Text("Work")
            : const Text("Worker"),
              
    ),
            StreamBuilder(
              stream: db.collection('Zain').snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final docs = snapshot.data.docs;
                  print('Number of documents: ${docs.length}');
                  return Expanded(
                    child: ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, int index) {
                        final documentSnapshot = docs[index];
                        print('Document data: ${documentSnapshot.data()}');
                        if (!documentSnapshot.exists || !documentSnapshot.data().containsKey('name')) {
                          return SizedBox(); // or handle missing data appropriately
                        }
                        final name = documentSnapshot.data()['name'];
                        return ListTile(
                          title: Text(name),
                          trailing: IconButton(
                              onPressed: () {
                                db.collection('Zain').doc(documentSnapshot.id).delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Deleted"), backgroundColor: Colors.red,));
                              },
                              icon: const Icon(Icons.delete)),
                          leading: ElevatedButton(
                            onPressed: (){
                              setState(() async{
                                updateWorker = !updateWorker;
                              });
                              print(Worker);
                              db.collection('sharjeel').doc(documentSnapshot.id).update({
                                'subscribe': updateWorker,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Unsubscribed"), backgroundColor: Colors.amber,));

                            },
                            child:  documentSnapshot['Work'] != false
                                  ? const Text("Work")
                                  : const Text("Worker"),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            )

          ]
        ),
      ),
    );
  }
}
