import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  const About({Key? key, required this.title, required this.about})
      : super(key: key);

  // acronym of institute
  final String title;

  // institute information in map format
  final Map about;

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {

  // opens url
  Future<void> _openURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // address
            const Text(
              'Address:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.about['address'],
              style: const TextStyle(fontSize: 16),
            ),

            // separator
            const SizedBox(height: 20.0),

            // email: inkwell hyperlink
            const Text(
              'Email:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            InkWell(
              // opens mail app
              onTap: () => _openURL('mailto:${widget.about['email']}'),
              child: Text(
                widget.about['email'],
                style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16),
              ),
            ),

            // separator
            const SizedBox(height: 20.0),

            // phone: inkwell hyperlink list
            const Text(
              'Phone:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.about['phone'].length, (index) {
                return InkWell(
                  // opens phone app
                  onTap: () => _openURL('tel:${widget.about['phone'][index]}'),
                  child:  Text(
                    widget.about['phone'][index],
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: 16),
                  ),
                );
              }),
            ),
            
            // separator            
            const SizedBox(height: 20.0),
            
            // placement report: inkwell hyperlink
            const Text(
              'Placement Report:',
              style:
                  TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _openURL(widget.about['placement-report']),
              child: const Text(
                'Placement Report',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16),
              ),
            ),

            // separator
            const SizedBox(height: 20.0),

            // programmes list
            const Text(
              'Programmes:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  List.generate(widget.about['programmes'].length, (index) {
                return Text(
                  widget.about['programmes'][index],
                  style: const TextStyle(fontSize: 16),
                );
              }),
            ),

            // separator
            const SizedBox(height: 20.0),

            // clubs list
            const Text(
              'Clubs:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.about['clubs'].length, (index) {
                return Text(
                  widget.about['clubs'][index],
                  style: const TextStyle(fontSize: 16),
                );
              }),
            ),

            // separator
            const SizedBox(height: 20.0),

            // website: inkwell hyperlink
            const Text(
              'Website:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () => _openURL(widget.about['website']),
              child: Text(
                widget.about['website'],
                style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
