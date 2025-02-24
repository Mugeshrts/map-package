import 'package:flutter/material.dart';
import 'package:mappackage/mappage/mapcircle.dart';
import 'package:mappackage/mappage/maprectangle.dart';
import 'package:mappackage/mappage/mapstar.dart';
import 'package:mappackage/mappage/maptriangle.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
 final List<Map<String, dynamic>> cardItems = [
    {'icon': Icons.arrow_drop_up, 'text': 'Triangle', 'page': Maptriangle()},
    {'icon': Icons.rectangle, 'text': 'Rectangle', 'page': Maprectpage()},
    {'icon': Icons.star, 'text': 'Star', 'page': Mapstar()},
    {'icon': Icons.circle, 'text': 'Circle', 'page': Mapcircle()},
   // {'icon': Icons.info, 'text': 'About', 'page': AboutScreen()},
  ];


  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Page')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: cardItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => cardItems[index]['page']),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cardItems[index]['icon'], size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text(
                            cardItems[index]['text'],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

