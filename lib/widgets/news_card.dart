import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/article.dart';

class NewsCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkToggle;
  final bool isBookmarked;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmarkToggle,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.6 : 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Gambar dengan Hero Tag
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: Hero(
                      tag: 'news-image-${article.url}',
                      child: article.urlToImage != null && article.urlToImage!.isNotEmpty
                          ? Image.network(
                              article.urlToImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            )
                          : _buildPlaceholder(context),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Informasi Konten
                Expanded(
                  child: SizedBox(
                    height: 95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sumber & Waktu
                        Row(
                          children: [
                            Text(
                              article.publisherName.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: theme.colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: theme.textTheme.labelMedium?.color?.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Text(
                              article.timeAgo,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        // Judul Berita
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.titleMedium?.color,
                            height: 1.3,
                          ),
                        ),

                        // Baris Bawah: Waktu Baca & Aksi Bookmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13,
                                  color: theme.textTheme.labelMedium?.color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  article.readingTime,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            if (onBookmarkToggle != null)
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  splashRadius: 18,
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    color: isBookmarked
                                        ? theme.colorScheme.primary
                                        : theme.textTheme.labelMedium?.color,
                                  ),
                                  onPressed: onBookmarkToggle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? Colors.white38 : Colors.grey.shade400,
          size: 28,
        ),
      ),
    );
  }
}
