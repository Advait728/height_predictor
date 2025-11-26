import 'package:flutter/material.dart';

class Results extends StatelessWidget {
  final double expectedHeight; // in inches
  final bool isIn;

  const Results({super.key, required this.expectedHeight, required this.isIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      appBar: AppBar(title: Text("Results"), backgroundColor: Colors.amber),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(50),
            child: Text("The expected height of your child is between:"),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Center(
                child: Text(
                  isIn
                      ? "${(expectedHeight - 2) ~/ 12}'${((expectedHeight - 2) % 12).toInt()}\" - ${(expectedHeight + 2) ~/ 12}'${((expectedHeight + 2) % 12).toInt()}\" in"
                      : '${((expectedHeight - 2) * 2.54).round()} - ${((expectedHeight + 2) * 2.54).round()} cm',
                  style: TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
