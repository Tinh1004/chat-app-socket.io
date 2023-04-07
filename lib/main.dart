import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  // WebSocketChannel connect() {
  //   return WebSocketChannel.connect(Uri.parse('wss:demo-ws.onrender.com/'));
  // }
  // final WebSocketChannel channel = IOWebSocketChannel.connect(Uri.parse('ws://demo-ws.onrender.com/'));
  //
  // WebSocketChannel channel =
  // WebSocketChannel.connect(Uri.parse('ws:localhost:3000/'));
  StreamSubscription? streamSubscription;
  String receivedMessage = 'Waiting for messages...';

  // var io =WebSocketChannel.connect(Uri.parse('wss:demo-ws.onrender.com/'));
  late TextEditingController _controller;
  IO.Socket socket = IO.io('https://demo-ws.onrender.com', <String, dynamic>{
    'transports': ['websocket'],
  });

  bool isMySend = false;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
    // io = connect();
    // var channel = connect();
    // channel.stream.listen((data) {
    //   print("data: $data");
    // });
    // io.stream.listen((event) {
    //   print("Send: $event");
    // });
    // streamSubscription = channel.stream.listen(_onMessageReceived);
    try{
      socket.on('connect', (data) {
        print('Connected to Socket.IO server');
      });
      socket.on('event', (data) {
        print('Received event from server: $data');
      });
      socket.on('sendChat', (data) {
        _onMessageReceived(data);
      });
      socket.emit('event', 'Hello from Flutter!');
    }catch(e){
      print("Connect failed!!");
    }
  }

  void _onMessageReceived(dynamic message) {
    print("message $message");
    String a = message;
    if(!isMySend){
      if(a.isNotEmpty){
        array.add({
          'isMe': false,
          'message': message
        });
      }
    }
    setState(() {
      isMySend = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();
  }

  var array = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat app "),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text(receivedMessage)),
              TextField(
                controller: _controller,
              ),
              Center(
                child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendChat();
                    // socket.emit('event','long');
                  },
                ),
              ),
              SizedBox(height: 5,),
              Column(
                children: [
                  for(var i in array) Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(right: 10.0, left: 10.0, bottom: 10.0),
                    child: Column(
                      crossAxisAlignment: i['isMe'] ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(i['isMe'] ? 'Me' :'My Friend', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                        Text('${i['message']}', style: TextStyle(fontSize: 16.0),),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendChat() async{
    if(_controller.text.isNotEmpty){
      socket.emit('sendChat', '${_controller.text.isEmpty ? 'No data' : _controller.text}');
      isMySend = true;
      array.add({
        'isMe': true,
        'message': _controller.text
      });
      _controller.text = "";
    }

  }

  // sendChat() async {
  //   var userID = '222'; // Change this to send a message to another person.
  //   print("Send!!!");
  //   print('${_controller.text.isEmpty ? 'No data' : _controller.text}');
  //   String data =
  //       "{'update':'chatappauthkey231r4','cmd':'${_controller.text.isEmpty ? 'No data' : _controller.text}','msg':'123456','userid':'$userID'}";
  //   channel.sink.add(data);
  // }
}
