import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/article.dart';

class DetailPage extends StatefulWidget {
  final Article article;

  const DetailPage({
    super.key,
    required this.article,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isBookmarked = false;

  Future<void> _launchFullArticle() async {
    if (widget.article.url.isEmpty) return;
    try {
      final uri = Uri.parse(widget.article.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan browser')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _shareArticle() {
    Clipboard.setData(ClipboardData(text: '${widget.article.title} - ${widget.article.url}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Tautan berita berhasil disalin!'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Parallax Header with Hero Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildGlassIconButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildGlassIconButton(
                  icon: _isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _isBookmarked ? theme.colorScheme.primary : Colors.white,
                  onPressed: () {
                    setState(() {
                      _isBookmarked = !_isBookmarked;
                    });
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text(
                          _isBookmarked ? 'Berita disimpan ke Markah' : 'Markah dihapus',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: _buildGlassIconButton(
                  icon: Icons.share_rounded,
                  onPressed: _shareArticle,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'news-image-${article.url}',
                    child: article.urlToImage != null && article.urlToImage!.isNotEmpty
                        ? Image.network(
                            article.urlToImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Dark Scrim for Top Action readability & Bottom transition
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.35, 0.7, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Article Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Publisher Pill & Reading Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.publisherName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: theme.colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: theme.textTheme.labelMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.readingTime,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Headline Title
                  Text(
                    article.title,
                    style: GoogleFonts.newsreader(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: theme.textTheme.displayMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Author & Date Information
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.7),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                          child: Text(
                            article.authorDisplay.isNotEmpty
                                ? article.authorDisplay[0].toUpperCase()
                                : 'N',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.authorDisplay,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                article.formattedDate,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lead Paragraph / Description Quote
                  if (article.description.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Text(
                        article.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Article Main Content Body
                  Text(
                    article.content.isNotEmpty
                        ? article.content
                        : article.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.7,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Call to Action Card: Open Original Article
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF151D2A), const Color(0xFF1E293B)]
                            : [const Color(0xFFFFFFFF), const Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Ingin Membaca Lebih Lengkap?',
                          style: GoogleFonts.newsreader(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Akses laporan lengkap, galeri foto, dan liputan mendalam langsung di ${article.publisherName}.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _launchFullArticle,
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            label: Text(
                              'Buka di ${article.publisherName}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding for gesture navigation bar safety
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 0.8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(
          Icons.newspaper_rounded,
          color: Colors.white38,
          size: 64,
        ),
      ),
    );
  }
}
