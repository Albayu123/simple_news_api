import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';
import 'models/article.dart';
import 'services/news_service.dart';
import 'widgets/category_chips.dart';
import 'widgets/empty_error_view.dart';
import 'widgets/featured_news_card.dart';
import 'widgets/news_card.dart';
import 'widgets/shimmer_loading.dart';

class MyHomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MyHomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    'Semua',
    'AI',
    'Startup',
    'Gadgets',
    'Cybersecurity',
    'Bisnis',
  ];
  String _selectedCategory = 'Semua';

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _bookmarkedUrls = {};

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryQuery = _selectedCategory == 'Semua' ? null : _selectedCategory;
      final results = await NewsService.getNews(categoryQuery: categoryQuery);

      if (mounted) {
        setState(() {
          _articles = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Article> get _filteredArticles {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _articles;
    }
    return _articles.where((article) {
      final titleMatch = article.title.toLowerCase().contains(query);
      final descMatch = article.description.toLowerCase().contains(query);
      final authorMatch = article.author?.toLowerCase().contains(query) ?? false;
      return titleMatch || descMatch || authorMatch;
    }).toList();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _searchController.clear();
      _isSearching = false;
    });
    _fetchNews();
  }

  void _toggleBookmark(Article article) {
    setState(() {
      if (_bookmarkedUrls.contains(article.url)) {
        _bookmarkedUrls.remove(article.url);
      } else {
        _bookmarkedUrls.add(article.url);
      }
    });

    final isSaved = _bookmarkedUrls.contains(article.url);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          isSaved ? 'Berita ditambahkan ke markah' : 'Markah dihapus',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDarkMode;
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Cari berita, topik, penulis...',
                  hintStyle: theme.textTheme.bodyMedium,
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TRENDING',
                        style: GoogleFonts.newsreader(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        ' • NEWS',
                        style: GoogleFonts.newsreader(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    todayFormatted.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: theme.textTheme.labelMedium?.color,
                    ),
                  ),
                ],
              ),
        actions: [
          // Search Action Toggle
          IconButton(
            tooltip: _isSearching ? 'Tutup Pencarian' : 'Cari Berita',
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: theme.textTheme.titleMedium?.color,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          // Dark Mode Toggle
          IconButton(
            tooltip: isDark ? 'Beralih ke Mode Terang' : 'Beralih ke Mode Gelap',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey<bool>(isDark),
                color: isDark ? Colors.amber : const Color(0xFF0F172A),
              ),
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNews,
        color: theme.colorScheme.primary,
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Category Selector Chips
            CategoryChips(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onSelected: _onCategorySelected,
            ),
            const SizedBox(height: 8),

            // Content Body (Loading, Error, Empty, or Feed)
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const NewsListSkeleton();
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return EmptyErrorView.error(
        onRetry: _fetchNews,
        message: _errorMessage,
      );
    }

    final filtered = _filteredArticles;

    if (filtered.isEmpty) {
      return EmptyErrorView.emptySearch(
        query: _searchController.text,
        onReset: () {
          setState(() {
            _searchController.clear();
            _isSearching = false;
            _selectedCategory = 'Semua';
          });
          _fetchNews();
        },
      );
    }

    final featuredArticle = filtered.first;
    final otherArticles = filtered.length > 1 ? filtered.sublist(1) : <Article>[];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // Featured Article (Hero) - Only if not filtering by search keyword
        if (_searchController.text.isEmpty) ...[
          FeaturedNewsCard(
            article: featuredArticle,
            onTap: () => _navigateToDetail(featuredArticle),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Berita Terkini',
                  style: GoogleFonts.newsreader(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filtered.length} Berita',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Other Articles Feed
        ...(_searchController.text.isEmpty ? otherArticles : filtered).map(
          (article) => NewsCard(
            key: ValueKey(article.url),
            article: article,
            isBookmarked: _bookmarkedUrls.contains(article.url),
            onBookmarkToggle: () => _toggleBookmark(article),
            onTap: () => _navigateToDetail(article),
          ),
        ),
      ],
    );
  }

  void _navigateToDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(article: article),
      ),
    );
  }
}
