import 'package:intl/intl.dart';

class ArticleSource {
  final String? id;
  final String name;

  const ArticleSource({
    this.id,
    required this.name,
  });

  factory ArticleSource.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ArticleSource(name: 'News');
    return ArticleSource(
      id: json['id'] as String?,
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'News',
    );
  }
}

class Article {
  final ArticleSource source;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String content;

  const Article({
    required this.source,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['publishedAt'] != null) {
      try {
        parsedDate = DateTime.parse(json['publishedAt'].toString());
      } catch (_) {}
    }

    return Article(
      source: ArticleSource.fromJson(json['source'] as Map<String, dynamic>?),
      author: json['author'] as String?,
      title: (json['title'] as String?)?.trim() ?? 'Tanpa Judul',
      description: (json['description'] as String?)?.trim() ?? '',
      url: (json['url'] as String?)?.trim() ?? '',
      urlToImage: (json['urlToImage'] as String?)?.trim(),
      publishedAt: parsedDate,
      content: (json['content'] as String?)?.trim() ?? '',
    );
  }

  /// Format waktu relatif yang ramah pengguna
  String get timeAgo {
    if (publishedAt == null) return 'Baru saja';
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('d MMM yyyy').format(publishedAt!);
    }
  }

  /// Tanggal lengkap terformat
  String get formattedDate {
    if (publishedAt == null) return 'Tanggal tidak tersedia';
    return DateFormat('EEEE, d MMMM yyyy • HH:mm').format(publishedAt!);
  }

  /// Estimasi waktu baca
  String get readingTime {
    final textLength = (title.length + description.length + content.length);
    final minutes = (textLength / 400).ceil();
    return '${minutes < 1 ? 1 : minutes} min baca';
  }

  /// Nama penerbit / sumber berita
  String get publisherName {
    if (source.name.isNotEmpty && source.name != 'News') {
      return source.name;
    }
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        return uri.host.replaceFirst('www.', '');
      } catch (_) {}
    }
    return 'Berita Teknologi';
  }

  /// Penulis yang diformat dengan baik
  String get authorDisplay {
    if (author != null && author!.trim().isNotEmpty && !author!.contains('http')) {
      return author!.trim();
    }
    return publisherName;
  }
}
