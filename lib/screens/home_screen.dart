import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/place_model.dart';
import '../widgets/search_bar.dart';
import '../widgets/place_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  List<Place> _places = [];
  bool _isLoading = false;

  void _search() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.searchPlaces(keyword);
      setState(() {
        _places = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('오류'),
              content: Text('검색 중 오류 발생: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('장소 검색'), centerTitle: true),
      body: Column(
        children: [
          SearchBarWidget(controller: _controller, onSearch: _search),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_places.isEmpty)
            const Expanded(child: Center(child: Text('검색 결과가 없습니다.')))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  return PlaceItem(place: _places[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
