import 'package:flutter/material.dart';

// tts
import 'package:flutter_tts/flutter_tts.dart';


// floating action button with tts
class FAB extends StatefulWidget {
  const FAB({super.key, required this.text});
  // text to be converted into speech
  final String text;

  @override
  State<FAB> createState() => _FABState();
}

class _FABState extends State<FAB> {
  // flutter tts engine
  FlutterTts flutterTts = FlutterTts();

  // speaking state
  bool isSpeaking = false;

  // if already speaking stop, else start
  Future<void> _toggleSpeaking() async {
    if (isSpeaking) {
      await flutterTts.stop();
    } else {
      await flutterTts.speak(widget.text);
    }

    setState(() {
      isSpeaking = !isSpeaking;
    });
  }

  // set speaking state to false when all text is read
  void _onComplete() {
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(_onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
      feedback: FloatingActionButton(
        onPressed: _toggleSpeaking,
        tooltip: isSpeaking ? 'Stop Speaking' : 'Speak',
        backgroundColor: isSpeaking ? Colors.red : Colors.blue,
        child: Icon(
          isSpeaking ? Icons.volume_off : Icons.volume_up,
          size: 28,
        ),
      ),
      childWhenDragging: Container(), // Empty container when dragging
      child: FloatingActionButton(
        onPressed: _toggleSpeaking,
        tooltip: isSpeaking ? 'Stop Speaking' : 'Speak',
        backgroundColor: isSpeaking ? Colors.red : Colors.blue,
        child: Icon(
          isSpeaking ? Icons.volume_off : Icons.volume_up,
        ),
      ),
    );
  }
}
