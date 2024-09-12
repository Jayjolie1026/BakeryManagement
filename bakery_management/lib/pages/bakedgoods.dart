import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<List<BakedGood>> fetchBakedGoods() async {
  final response = await http.get(Uri.parse('https://bakerymanagement-efgmhebnd5aggagn.eastus-01.azurewebsites.net/finalproducts'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => BakedGood.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load baked goods');
  }
}

class BakedGood {
  final int id;
  final String name;
  final String description;
  final int maxAmount;
  final int remakeAmount;
  final int minAmount;
  final int quantity;
  final double price;

  BakedGood({
    required this.id,
    required this.name,
    required this.description,
    required this.maxAmount,
    required this.remakeAmount,
    required this.minAmount,
    required this.quantity,
    required this.price,
  });

  factory BakedGood.fromJson(Map<String, dynamic> json) {
    return BakedGood(
      id: json['ProductID'],
      name: json['Name'],
      description: json['Description'],
      maxAmount: json['MaxAmount'],
      remakeAmount: json['RemakeAmount'],
      minAmount: json['MinAmount'],
      quantity: json['Quantity'],
      price: json['Price'],
    );
  }
}





class BakedGoodsSearchScreen extends StatefulWidget {
  @override
  _BakedGoodsSearchScreenState createState() => _BakedGoodsSearchScreenState();
}

class _BakedGoodsSearchScreenState extends State<BakedGoodsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BakedGood> _bakedGoods = [];
  List<BakedGood> _filteredBakedGoods = [];

  @override
  void initState() {
    super.initState();
    _fetchBakedGoods();
     _searchController.addListener(() {
      _filterBakedGoods(_searchController.text);
    });
  }

  void _fetchBakedGoods() async {
     try {
       console.log("before fetch");
      final bakedGoods = await fetchBakedGoods();
       console.log("after fetch");
      setState(() {
        _bakedGoods = bakedGoods;
        _filteredBakedGoods = bakedGoods; // Initialize with all baked goods
      });
    } catch (e) {
      // Handle the error
      print('Error fetching baked goods: $e');
    }
  }
  

  void _filterBakedGoods(String query) {
    final filtered = _bakedGoods
        .where((good) => good.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredBakedGoods = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Baked Goods'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterBakedGoods,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBakedGoods.length,
              itemBuilder: (context, index) {
                final good = _filteredBakedGoods[index];
                return ListTile(
                  title: Text(good.name),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BakedGoodDetailScreen(good: good),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class BakedGoodDetailScreen extends StatelessWidget {
  final BakedGood good;

  BakedGoodDetailScreen({required this.good});

  @override
  Widget build(BuildContext context) {
    final remakeNeeded = good.quantity < good.minAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(good.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${good.name}', style: TextStyle(fontSize: 18)),
            Text('Description: ${good.description}', style: TextStyle(fontSize: 16)),
            Text('Max Amount: ${good.maxAmount}', style: TextStyle(fontSize: 16)),
            Text('Remake Amount: ${good.remakeAmount}', style: TextStyle(fontSize: 16)),
            Text('Min Amount: ${good.minAmount}', style: TextStyle(fontSize: 16)),
            Text('Quantity: ${good.quantity}', style: TextStyle(fontSize: 16)),
            Text('Price: \$${good.price}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text(
              remakeNeeded ? 'Needs to be remade!' : 'Stock is sufficient',
              style: TextStyle(
                fontSize: 18,
                color: remakeNeeded ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
