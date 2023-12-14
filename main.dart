import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _user1MessageController = TextEditingController();
  TextEditingController _user2MessageController = TextEditingController();
  List<Map<String, String>> _user1Messages = [];
  List<Map<String, String>> _user2Messages = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward(); // Start the animation for "ChatApp" text
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _sendMessage(String sender, TextEditingController controller) {
    setState(() {
      if (sender == 'user1') {
        _user1Messages.add({
          'sender': 'User1',
          'text': controller.text,
        });
      } else {
        _user2Messages.add({
          'sender': 'User2',
          'text': controller.text,
        });
      }
      controller.clear();
      _animationController.forward(from: 0.0);
    });
  }

  void _toggleEmojiPicker() {
    setState(() {
      showEmojiPicker = !showEmojiPicker;
    });
  }

  void _insertEmojiOrGif(String emojiOrGif, TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;

    final newText =
        text.replaceRange(selection.start, selection.end, emojiOrGif);
    final newSelection =
        TextSelection.collapsed(offset: selection.start + emojiOrGif.length);

    setState(() {
      controller.text = newText;
      controller.selection = newSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Lottie.asset(
              'assets/hii.json',
              height: 100,
              width: 100,
            ),
            SizedBox(height: 8),
            FadeAnimatedTextKit(
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 100),
              displayFullTextOnTap: true,
              text: ['ChatApp'],
              textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: _buildChatArea(
              _user1MessageController,
              _user1Messages,
              'User1: Type a message...',
              'User1',
            ),
          ),
          Expanded(
            child: _buildChatArea(
              _user2MessageController,
              _user2Messages,
              'User2: Type a message...',
              'User2',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(
    TextEditingController messageController,
    List<Map<String, String>> userMessages,
    String hintText,
    String sender,
  ) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: userMessages.length,
              itemBuilder: (BuildContext context, int index) {
                final messageSender = userMessages[index]['sender'];
                final messageText = userMessages[index]['text'];

                if (messageSender == sender) {
                  return FadeTransition(
                    opacity: _animation,
                    child: _buildMessageBubble(
                      messageText!,
                      messageSender!,
                      sender == 'User1'
                          ? 'assets/icons/icon1.png'
                          : 'assets/icons/icon2.png',
                      sender == 'User1',
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Hide messages not for this user
                }
              },
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions),
                onPressed: () {
                  _toggleEmojiPicker();
                },
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  _sendMessage(sender.toLowerCase(), messageController);
                },
              ),
            ],
          ),
          showEmojiPicker
              ? Container(
                  height: 200,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _insertEmojiOrGif(emoji.emoji, messageController);
                    },
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    String text,
    String sender,
    String iconPath,
    bool isUser1,
  ) {
    Color bubbleColor = isUser1 ? Colors.pink[100]! : Colors.purple[100]!;
    Color textColor =
        isUser1 ? Colors.pinkAccent[700]! : Colors.purpleAccent[700]!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage(iconPath),
          ),
        ),
        Expanded(
          child: Align(
            alignment: isUser1 ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(8.0),
              margin: EdgeInsets.symmetric(vertical: 4.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    sender,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
