import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PlatformFile? pickedFile;

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return null;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  // upload file to firebase
  Future uploadFile1() async {
    if (pickedFile == null) {
      print("file is null");
      return;
    }
    final file = File(pickedFile!.path!);
    final metaData = SettableMetadata(contentType: 'image/jpeg');
    final storageRef = FirebaseStorage.instance.ref();
    Reference ref = storageRef
        .child('picture/${DateTime.now().microsecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(file, metaData);

    uploadTask.snapshotEvents.listen((event) {
      switch (event.state) {
        case TaskState.running:
          print("File is uploading");
          break;
        case TaskState.success:
          ref.getDownloadURL().then((value) => print(value));
          break;
        case TaskState.error:
          print("error");
          break;
      }
    });

    /* UploadTask uploadTask = 
    // lỗi putFile ko đc
    TaskSnapshot taskSnapshot = await uploadTask;
    print("Da up xong");
    print(taskSnapshot.ref.getDownloadURL());
    return taskSnapshot.ref.getDownloadURL(); */
  }

  Future uploadFile() async {
    // ham nay em thu code của chat gpt
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File(pickedFile!.path!);
      // Get reference to Firebase Storage
      final Reference storageReference =
          FirebaseStorage.instance.ref().child(fileName);

      // Upload file
      final UploadTask uploadTask = storageReference.putFile(file);
      print("dong nay chua bi loi");
      // Wait for upload to complete
      final TaskSnapshot storageTaskSnapshot = await uploadTask;
      print("dong nay bi loi");
      // duong dan downloadUrl
      print(storageTaskSnapshot.ref.getDownloadURL());
    } on FirebaseException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              if (pickedFile != null)
                Expanded(
                  child: Container(
                      color: Colors.blue[100],
                      child: Image.file(
                        File(pickedFile!.path!),
                        fit: BoxFit.cover,
                      )),
                ),
              ElevatedButton(
                onPressed: selectFile,
                child: Text('Selecte file'),
              ),
              ElevatedButton(
                onPressed: uploadFile1,
                child: Text('Upload file'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
