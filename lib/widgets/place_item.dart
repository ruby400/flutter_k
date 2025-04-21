import 'package:flutter/material.dart';
import '../models/place_model.dart';
import '../screens/webview_screen.dart';

class PlaceItem extends StatelessWidget {
  final Place place;

  const PlaceItem({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(place.name),
        subtitle: Text('${place.address}'),
        onTap: () {
          if (place.link != null && place.link!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        WebViewScreen(url: place.link!, title: place.name),
              ),
            );
          }
        },
      ),
    );
  }
}
