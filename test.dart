import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Widget Tree Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Widget Tree'),
          centerTitle: true,
          backgroundColor: Color(0xFF478ADF)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: <Widget>[
                // top line separate from the title
                SizedBox(height: 16.0),
                Divider (
                  height: 1.0,
                  thickness: 1.0,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),

                // First Row with multiple child widgets
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: Color(0xFFA9DAF6),
                      height: 40.0,
                      width: 40.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                    ),
                    Expanded(
                      child: Container(
                        color: Color(0xFF5BB1D9),
                        height: 40.0,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                    ),
                    Container(
                      color: Color(0xFF2E4F94),
                      height: 40.0,
                      width: 40.0,
                    ),
                  ],
                ),

                // bottom line separate from the title
                SizedBox(height: 16.0),
                Divider (
                  height: 1.0,
                  thickness: 1.0,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),

                // Padding between rows
                Padding(
                  padding: EdgeInsets.all(6.0),
                ),

                // Second Row containing a nested Column
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // first container, defines the width reference
                          Container(
                            color: Color(0xFFA9DAF6),
                            height: 60.0,
                            width: 60.0,
                          ),

                          SizedBox(height: 16.0),

                          // second container, centered under the first
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              color: Color(0xFF5BB1D9),
                              height: 40.0,
                              width: 40.0,
                            ),
                          ),

                          SizedBox(height: 16.0),

                          // third container, also centered under the first
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              color: Color(0xFF2E4F94),
                              height: 20.0,
                              width: 20.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // bottom line separate from the title
                SizedBox(height: 16.0),
                Divider (
                  height: 1.0,
                  thickness: 1.0,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.0),

                // Nested Row with a CircleAvatar and Stack
                Center(
                  child: CircleAvatar(
                    backgroundColor: Color(0xFF9FA0D3),
                    radius: 100.0,

                    child: Stack(
                      children: <Widget>[
                        // bottom square, centered
                        Center(
                          child: Container(
                            height: 130.0,
                            width: 130.0,
                            color: Color(0xFFBFE7FA),
                          ),
                        ),

                        // middle square, offset down and right
                        Positioned(
                            bottom: 50.0,
                            right: 50.0,
                            child: Container(
                                height: 70.0,
                                width: 75.0,
                                color: Color(0xFF7EC6E3)
                            )
                        ),

                        // top square, offset up and left
                        Positioned(
                          top: 60.0,
                          left: 60.0,
                          child: Container(
                            height: 70.0,
                            width: 75.0,
                            color: Color(0xFF2E4F94),
                          ),
                        ),


                      ],
                    ),
                  ),
                )
                ,
                SizedBox(height: 16.0),

                Divider(
                  height: 1.0,
                  thickness: 1.0,
                  color: Colors.grey,
                ),

                SizedBox(height: 16.0),

                // Final Text widget
                Text('End of the Line'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
