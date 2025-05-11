// lib/screens/parking_spaces_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_bloc.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_event.dart';
import 'package:parking_app_flutter/blocs/parking_space/parking_space_state.dart';
import 'package:parking_app_flutter/models/parking_space.dart';
import 'dart:math';

class ParkingSpacesScreen extends StatefulWidget {
  const ParkingSpacesScreen({super.key});

  @override
  _ParkingSpacesScreenState createState() => _ParkingSpacesScreenState();
}

class _ParkingSpacesScreenState extends State<ParkingSpacesScreen> {
  // For filtering and sorting
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'price';
  bool _sortAscending = true;
  
  // List of example Malmö addresses
  final List<String> _malmoAddresses = [
    'Stortorget 1, Malmö',
    'Södergatan 22, Malmö',
    'Gustav Adolfs Torg 4, Malmö',
    'Drottninggatan 18, Malmö',
    'Amiralsgatan 35, Malmö',
    'Föreningsgatan 47, Malmö',
    'Triangeln 2, Malmö',
    'Pildammsvägen 12, Malmö',
    'Kalendegatan 14, Malmö',
    'Lilla Torg 9, Malmö',
    'Värnhemstorget 7, Malmö',
    'Södra Förstadsgatan 25, Malmö',
    'Limhamnsvägen 111, Malmö',
    'Möllevångstorget 2, Malmö',
    'Regementsgatan 40, Malmö',
    'Stora Nygatan 13, Malmö',
    'Baltzarsgatan 31, Malmö',
    'Bergsgatan 20, Malmö',
    'Kungsgatan 8, Malmö',
    'Östra Förstadsgatan 24, Malmö',
  ];

  @override
  void initState() {
    super.initState();
    _loadParkingSpaces();
  }
  
  void _loadParkingSpaces() {
    // Dispatch the event to load parking spaces
    context.read<ParkingSpaceBloc>().add(LoadParkingSpaces());
  }
  
  Future<void> _generateDefaultParkingSpaces() async {
    final random = Random();
    
    // Create 10 random parking spaces
    for (int i = 0; i < 10; i++) {
      // Randomly select an address from the list
      final address = _malmoAddresses[random.nextInt(_malmoAddresses.length)];
      
      // Generate a random price between 20 and 100 kr/h
      final price = 20 + random.nextInt(81);
      
      // Dispatch the event to add a parking space
      context.read<ParkingSpaceBloc>().add(
        AddParkingSpace(adress: address, pricePerHour: price)
      );
      
      // Add a small delay to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  
  List<ParkingSpace> _sortParkingSpaces(List<ParkingSpace> spaces) {
    final sortedSpaces = List<ParkingSpace>.from(spaces);
    
    sortedSpaces.sort((a, b) {
      if (_sortBy == 'price') {
        return _sortAscending 
            ? a.pricePerHour.compareTo(b.pricePerHour)
            : b.pricePerHour.compareTo(a.pricePerHour);
      } else { // sort by address
        return _sortAscending 
            ? a.adress.compareTo(b.adress)
            : b.adress.compareTo(a.adress);
      }
    });
    
    return sortedSpaces;
  }
  
  List<ParkingSpace> _filterParkingSpaces(List<ParkingSpace> spaces) {
    if (_searchQuery.isEmpty) {
      return spaces;
    }
    
    final query = _searchQuery.toLowerCase();
    return spaces.where((space) {
      return space.adress.toLowerCase().contains(query) || 
             space.pricePerHour.toString().contains(query);
    }).toList();
  }
  
  void _selectParkingSpace(ParkingSpace space) {
    // Navigate to the parkings tab (index 2) in the main navigation
    // and pass the selected parking space
    Navigator.pushNamed(
      context, 
      '/manage_parking',
      arguments: space,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ParkingSpaceBloc, ParkingSpaceState>(
        listener: (context, state) {
          // Show snackbar messages based on the state
          if (state is ParkingSpaceOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ParkingSpaceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is ParkingSpaceLoaded && state.parkingSpaces.isEmpty) {
            // If no parking spaces were loaded, generate default ones
            _generateDefaultParkingSpaces();
          }
        },
        builder: (context, state) {
          if (state is ParkingSpaceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ParkingSpaceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadParkingSpaces,
                    child: const Text('Försök igen'),
                  ),
                ],
              ),
            );
          } else if (state is ParkingSpaceLoaded) {
            // Sort and filter parking spaces
            final sortedSpaces = _sortParkingSpaces(state.parkingSpaces);
            final filteredSpaces = _filterParkingSpaces(sortedSpaces);
            
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lediga parkeringsplatser',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Search field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Sök parkeringsplats',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sort options
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Sortera efter:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: _sortBy,
                            items: const [
                              DropdownMenuItem(value: 'price', child: Text('Pris')),
                              DropdownMenuItem(value: 'name', child: Text('Adress')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                            tooltip: _sortAscending ? 'Stigande' : 'Fallande',
                            onPressed: () {
                              setState(() {
                                _sortAscending = !_sortAscending;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          // Add a refresh button
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Uppdatera',
                            onPressed: _loadParkingSpaces,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: filteredSpaces.isEmpty
                      ? const Center(child: Text('Inga parkeringsplatser hittades'))
                      : ListView.builder(
                          itemCount: filteredSpaces.length,
                          itemBuilder: (context, index) {
                            final space = filteredSpaces[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: InkWell(
                                onTap: () => _selectParkingSpace(space),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Price circle
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF0078D7),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${space.pricePerHour}kr',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Address and details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              space.adress,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${space.pricePerHour} kr per timme',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Arrow icon
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFF0078D7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          
          // Default state
          return Center(
            child: ElevatedButton(
              onPressed: _loadParkingSpaces,
              child: const Text('Ladda parkeringsplatser'),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}