import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyErrorView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const EmptyErrorView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  factory EmptyErrorView.error({
    required VoidCallback onRetry,
    String? message,
  }) {
    return EmptyErrorView(
      icon: Icons.wifi_off_rounded,
      title: 'Koneksi Terkendala',
      message: message ??
          'Tidak dapat memuat berita terkini. Periksa sambungan internet Anda atau coba sesaat lagi.',
      actionLabel: 'Muat Ulang',
      onAction: onRetry,
    );
  }

  factory EmptyErrorView.emptySearch({
    required VoidCallback onReset,
    String? query,
  }) {
    return EmptyErrorView(
      icon: Icons.search_off_rounded,
      title: 'Berita Tidak Ditemukan',
      message: query != null && query.isNotEmpty
          ? 'Tidak ada artikel yang cocok dengan kata kunci "$query". Coba kata kunci lainnya.'
          : 'Belum ada berita yang tersedia untuk kategori ini.',
      actionLabel: 'Tampilkan Semua Berita',
      onAction: onReset,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.newsreader(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
