import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'webview_app.dart';

class TodayInHistoryPage extends StatefulWidget {
  @override
  _TodayInHistoryPageState createState() => _TodayInHistoryPageState();
}

class _TodayInHistoryPageState extends State<TodayInHistoryPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final response = await http.get(Uri.parse('https://60s.viki.moe/today_in_history'));
    if (response.statusCode == 200) {
      setState(() {
        _events = json.decode(response.body)['data'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _events.length,
            itemBuilder: (context, index) {
              final event = _events[index];
              return ListTile(
                title: Text('${event['year']} - ${event['title']}'),
                subtitle: Text(event['desc']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewApp(url: event['link']),
                      ),
                    );
                  },
                  child: Text('Read More'),
                ),
              );
            },
          );
  }
}
