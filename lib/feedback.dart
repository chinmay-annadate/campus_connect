import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({Key? key}) : super(key: key);
  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _feedback;

  Future<void> _submitFeedback(Map feedback) async {
    try {
      FirebaseDatabase.instance.ref('feedback').push().set(feedback);

      Fluttertoast.showToast(
        msg: 'Feedback submitted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Failed to submit feedback',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
      ),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // name
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
          onSaved: (value) {
            _name = value!;
          },
        ),

        const SizedBox(height: 16.0),

        // email
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your email';
            }
            return null;
          },
          onSaved: (value) {
            _email = value!;
          },
        ),
        
        const SizedBox(height: 16.0),

        // feedback
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Feedback',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter your feedback';
            }
            return null;
          },
          onSaved: (value) {
            _feedback = value!;
          },
          maxLines: 5,
        ),

        const SizedBox(height: 16.0),

        // submit
        ElevatedButton(
          child: const Text('Submit',style: TextStyle(fontSize: 16),),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _submitFeedback({"name":_name, "email":_email, "feedback":_feedback});
            }
          },
        ),
      ],
    ),
  ),
),

    );
  }
}
