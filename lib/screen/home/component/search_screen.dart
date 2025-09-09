import 'package:dms/model/entity/search_feature.dart';
import 'package:dms/services/navigation_service.dart';
import 'package:dms/services/search_history_service.dart';
import 'package:dms/services/search_service.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final SearchService _searchService = SearchService();
  final NavigationService _navigationService = NavigationService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  
  List<SearchFeature> _searchResults = [];
  List<SearchFeature> _recentSearches = [];
  List<String> _categories = [];
  String _selectedCategory = 'Tất cả';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _categories = ['Tất cả', ..._searchService.getCategories()];
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    _recentSearches = _searchHistoryService.getSearchHistory();
  }

  void _performSearch(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _searchService.searchFeatures(query);
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Tất cả') {
        _searchResults = _searchService.searchFeatures(_searchController.text);
      } else {
        _searchResults = _searchService.getFeaturesByCategory(category);
      }
    });
  }

  void _navigateToFeature(SearchFeature feature) {
    _searchHistoryService.saveToHistory(feature);
    _navigateToRoute(feature.route, feature.parameters);
  }

  void _navigateToRoute(String route, Map<String, dynamic>? parameters) {
    _navigationService.navigateToRoute(context, route, parameters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: subColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm chức năng...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: _performSearch,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: subColor),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          if (_searchResults.isNotEmpty || _searchController.text.isEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _filterByCategory(category),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          // Search results or recent searches
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildRecentSearches()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tìm kiếm gần đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: subColor,
          ),
        ),
        const SizedBox(height: 16),
        ..._recentSearches.map((feature) => _buildFeatureTile(feature)),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final feature = _searchResults[index];
        return _buildFeatureTile(feature);
      },
    );
  }

  Widget _buildFeatureTile(SearchFeature feature) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            feature.icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          feature.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: subColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feature.description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feature.category,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _navigateToFeature(feature),
      ),
    );
  }
}
