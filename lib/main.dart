import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'webview_app.dart';
import 'author_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Today in History 历史上的今天',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    AuthorPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Today in History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Author',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _events = fetchEvents();
  }

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('https://60s.viki.moe/today_in_history'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Event> events = [];
      for (var item in data['data']) {
        events.add(Event.fromJson(item));
      }
      return events;
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _events = fetchEvents();
    });
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Year: ${event.year}'),
              SizedBox(height: 10),
              Text(event.description),
              SizedBox(height: 10),
              if (event.link != null) ...[
                GestureDetector(
                  child: Text(
                    'Read More',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WebViewApp(url: event.link!),
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today in History'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: FutureBuilder<List<Event>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No events found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data![index];
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text('Year: ${event.year}'),
                    onTap: () => _showEventDetails(event),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final String year;
  final String description;
  final String? link;

  Event({
    required this.title,
    required this.year,
    required this.description,
    this.link,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      year: json['year'],
      description: json['desc'],
      link: json['link'],
    );
  }
}
