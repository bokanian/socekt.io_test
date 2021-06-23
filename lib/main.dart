import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:websocket_flutter/socket_server.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> messageList = [];

  StreamSocket streamSocket = StreamSocket();
//STEP2: Add this function in main function in main.dart file and add incoming data to the stream
  void connectAndListen() {
    IO.Socket socket = IO.io(
        'https://api.exir.io/realtime',
        OptionBuilder().setTransports(['websocket']).setQuery(
            {'symbol': 'btc-irt'}).build());

    socket.onPing((_) {
      print('connect');
      socket.emit('method', 'server.ping');
    });

    socket.onConnectError((_) {
      print('onConnectError');
      socket.emit('msg', 'test');
    });

    // When an event recieved from server, data is added to the stream
    socket.on('trades', (data) => streamSocket.addResponse);
    print('trades');
    socket.onDisconnect((_) => print('disconnect'));
  }

  _MyHomePageState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('socket io'),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'send message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            connectAndListen();
                          });
                        },
                        child: Text('send'),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: streamSocket.getResponse,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    print(snapshot.data);
                    return Container(
                      child: Text('${snapshot.data}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
