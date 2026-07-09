// Dart imports:
import 'dart:math';
import 'dart:io';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/gen_l10n/app_localizations.dart';

// Project imports:
// NOTE: These imports are crucial and must exist in your project structure.
import 'package:openlib/services/annas_archieve.dart';
import 'package:openlib/services/database.dart';
import 'package:openlib/services/files.dart';
import 'package:openlib/services/open_library.dart';
import 'package:openlib/services/goodreads.dart';
import 'package:openlib/services/instance_manager.dart';
import 'package:openlib/services/download_manager.dart';
// Assuming OpenLibrary, Goodreads, PenguinRandomHouse, BookDigits, and SubCategoriesTypeList are defined
// or are simple placeholder services/models that work as intended.

MyLibraryDb dataBase = MyLibraryDb.instance;

// ====================================================================
// DROPDOWN/FILTER MAPPING DATA (LOCALIZED)
// ====================================================================

Map<String, String> getTypeValues(AppLocalizations l10n) {
  return {
    l10n.all: '',
    l10n.anyBooks: 'book_any',
    l10n.unknownBooks: 'book_unknown',
    l10n.fictionBooks: 'book_fiction',
    l10n.nonFictionBooks: 'book_nonfiction',
    l10n.comicBooks: 'book_comic',
    l10n.magazine: 'magazine',
    l10n.standardsDocument: 'standards_document',
    l10n.journalArticle: 'journal_article'
  };
}

Map<String, String> getSortValues(AppLocalizations l10n) {
  return {
    l10n.mostRelevant: '',
    l10n.newest: 'newest',
    l10n.oldest: 'oldest',
    l10n.largest: 'largest',
    l10n.smallest: 'smallest',
  };
}

List<String> getFileType(AppLocalizations l10n) {
  return [l10n.all, "PDF", "Epub", "Cbr", "Cbz"];
}

// Language filter values (display name: code)
Map<String, String> getLanguageValues(AppLocalizations l10n) {
  return {
    l10n.all: "",
    l10n.english: "en",
    l10n.spanish: "es",
    l10n.french: "fr",
    l10n.german: "de",
    l10n.italian: "it",
    l10n.portuguese: "pt",
    l10n.russian: "ru",
    l10n.chinese: "zh",
    l10n.japanese: "ja",
    l10n.korean: "ko",
    l10n.arabic: "ar",
    l10n.hindi: "hi",
    l10n.malayalam: "ml",
    l10n.dutch: "nl",
    l10n.polish: "pl",
    l10n.turkish: "tr",
    l10n.swedish: "sv",
    l10n.indonesian: "id",
    l10n.vietnamese: "vi",
    l10n.czech: "cs",
    l10n.greek: "el",
    l10n.romanian: "ro",
    l10n.hungarian: "hu",
    l10n.ukrainian: "uk",
    l10n.hebrew: "he",
    l10n.thai: "th",
    l10n.persian: "fa",
    l10n.bengali: "bn",
    l10n.finnish: "fi",
    l10n.norwegian: "no",
    l10n.danish: "da",
  };
}

// Reverse map: language code to uppercase display code
Map<String, String> languageCodeToDisplay = {
  "en": "EN",
  "es": "ES",
  "fr": "FR",
  "de": "DE",
  "it": "IT",
  "pt": "PT",
  "ru": "RU",
  "zh": "ZH",
  "ja": "JA",
  "ko": "KO",
  "ar": "AR",
  "hi": "HI",
  "ml": "ML",
  "nl": "NL",
  "pl": "PL",
  "tr": "TR",
  "sv": "SV",
  "id": "ID",
  "vi": "VI",
  "cs": "CS",
  "el": "EL",
  "ro": "RO",
  "hu": "HU",
  "uk": "UK",
  "he": "HE",
  "th": "TH",
  "fa": "FA",
  "bn": "BN",
  "fi": "FI",
  "no": "NO",
  "da": "DA",
};

// Year filter values for publishing year range
List<String> getYearValues(AppLocalizations l10n) {
  return [
    l10n.all,
    "2025",
    "2024",
    "2023",
    "2022",
    "2021",
    "2020",
    "2019",
    "2018",
    "2017",
    "2016",
    "2015",
    "2010-2014",
    "2005-2009",
    "2000-2004",
    "1990-1999",
    "1980-1989",
    l10n.before1980,
  ];
}

// ====================================================================
// ENUMS AND DATA CLASSES
// ====================================================================

enum ProcessState { waiting, running, complete }

enum CheckSumProcessState { waiting, running, failed, success }

class FileName {
  final String md5;
  final String format;
  final String? fileName;

  FileName({required this.md5, required this.format, this.fileName});
}

// ====================================================================
// UI AND SIMPLE STATE PROVIDERS
// ====================================================================

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.state);

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;

    // Save to DB
    String pref = 'system';
    if (mode == ThemeMode.light) pref = 'light';
    if (mode == ThemeMode.dark) pref = 'dark';
    await MyLibraryDb.instance.savePreference('themeMode', pref);

    updateSystemUi(mode);
  }

  static void updateSystemUi(ThemeMode mode) {
    if (Platform.isAndroid) {
      bool isDark = mode == ThemeMode.dark;
      if (mode == ThemeMode.system) {
        isDark = ui.PlatformDispatcher.instance.platformBrightness ==
            Brightness.dark;
      }
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor:
              isDark ? Colors.black : Colors.grey.shade200));
    }
  }

  static Future<ThemeMode> getInitialTheme() async {
    try {
      MyLibraryDb dataBase = MyLibraryDb.instance;
      // Check for new theme mode preference
      var themePref =
          await dataBase.getPreference('themeMode').catchError((e) => null);
      if (themePref != null) {
        switch (themePref) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          default:
            return ThemeMode.system;
        }
      }

      // Legacy: check old 'theme' preference
      var theme = await dataBase.getPreference('theme').catchError((e) => null);
      if (theme == 'true') return ThemeMode.dark;
      return ThemeMode.system;
    } catch (e) {
      return ThemeMode.system;
    }
  }
}

// ====================================================================
// SEARCH FILTER STATE PROVIDERS
// ====================================================================

// These providers now use the localized getter functions.
// The UI (e.g., SearchPage) must call these getters with the current
// AppLocalizations to populate the dropdown items.

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTypeState = StateProvider<String>((ref) => '');
final selectedSortState = StateProvider<String>((ref) => '');
final selectedFileTypeState = StateProvider<String>((ref) => '');
final selectedLanguageState = StateProvider<String>((ref) => '');
final selectedYearState = StateProvider<String>((ref) => '');
final enableFiltersState = StateProvider<bool>((ref) => false);

// ====================================================================
// BOOK DETAIL STATE (Example of more complex state)
// ====================================================================

// This is a simplified example. A real app would likely use a more robust
// state management solution for async data fetching.
class BookDetailState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? bookData;

  BookDetailState({this.isLoading = false, this.error, this.bookData});

  BookDetailState copyWith({bool? isLoading, String? error, Map<String, dynamic>? bookData}) {
    return BookDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      bookData: bookData ?? this.bookData,
    );
  }
}

final bookDetailProvider = StateProvider<BookDetailState>((ref) {
  return BookDetailState();
});

// ====================================================================
// DOWNLOAD STATE
// ====================================================================

class DownloadState {
  final bool isDownloading;
  final double progress;
  final String? error;
  final String? filePath;

  DownloadState({this.isDownloading = false, this.progress = 0.0, this.error, this.filePath});
}

final downloadProvider = StateProvider<DownloadState>((ref) {
  return DownloadState();
});

// ====================================================================
// PDF VIEWER STATE
// ====================================================================

final pdfCurrentPage = StateProvider<int>((ref) => 0);
final totalPdfPage = StateProvider<int>((ref) => 0);

// ====================================================================
// PDF EXTERNAL APP PROVIDER
// ====================================================================

final openPdfWithExternalAppProvider = StateProvider<bool>((ref) => false);

// ====================================================================
// DOWNLOAD STATE PROVIDERS
// ====================================================================

final mirrorStatusProvider = StateProvider<bool>((ref) => false);
final downloadState = StateProvider<ProcessState>((ref) => ProcessState.waiting);
final checkSumState = StateProvider<CheckSumProcessState>((ref) => CheckSumProcessState.waiting);
final cancelCurrentDownload = StateProvider<CancelToken?>((ref) => null);
final downloadProgressProvider = StateProvider<double>((ref) => 0.0);
final totalFileSizeInBytes = StateProvider<int>((ref) => 0);
final downloadedFileSizeInBytes = StateProvider<int>((ref) => 0);
final getTotalFileSize = Provider<int>((ref) => ref.watch(totalFileSizeInBytes));
final getDownloadedFileSize = Provider<int>((ref) => ref.watch(downloadedFileSizeInBytes));

// ====================================================================
// MY LIBRARY PROVIDER
// ====================================================================

final myLibraryProvider = FutureProvider<List<MyBook>>((ref) async {
  final db = MyLibraryDb.instance;
  return await db.getAllBooks();
});

// ====================================================================
// BOOK INFO PROVIDERS
// ====================================================================

final showManualDownloadButtonProvider = StateProvider<bool>((ref) => false);
final donationKeyProvider = StateProvider<String>((ref) => '');
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  return DownloadManager();
});

final checkIdExists = FutureProvider.family<bool, String>((ref, md5) async {
  final db = MyLibraryDb.instance;
  return await db.checkIdExists(md5);
});

final bookInfoProvider = FutureProvider.family<BookInfoData?, String>((ref, url) async {
  final annasArchive = AnnasArchieve();
  final donationKey = ref.read(donationKeyProvider);
  return await annasArchive.bookInfo(url: url, donationKey: donationKey.isNotEmpty ? donationKey : null);
});

final getBookByIdProvider = FutureProvider.family<MyBook?, String>((ref, md5) async {
  final db = MyLibraryDb.instance;
  return await db.getId(md5);
});

// ====================================================================
// FILE PATH PROVIDER (Family)
// ====================================================================

final filePathProvider = FutureProvider.family<String, String>((ref, fileName) async {
  return await getFilePath(fileName);
});

// ====================================================================
// BOOK POSITION PROVIDER (Family)
// ====================================================================

final getBookPosition = FutureProvider.family<String?, String>((ref, fileName) async {
  try {
    final db = MyLibraryDb.instance;
    return await db.getBookState(fileName);
  } catch (e) {
    return null;
  }
});

// ====================================================================
// SAVE PDF STATE FUNCTION
// ====================================================================

Future<void> savePdfState(String fileName, WidgetRef ref) async {
  try {
    final db = MyLibraryDb.instance;
    final currentPage = ref.read(pdfCurrentPage);
    await db.saveBookState(fileName, currentPage.toString());
  } catch (e) {
    // Ignore save errors
  }
}

// ====================================================================
// EPUB EXTERNAL APP PROVIDER
// ====================================================================

final openEpubWithExternalAppProvider = StateProvider<bool>((ref) => false);

// ====================================================================
// SAVE EPUB STATE FUNCTION
// ====================================================================

Future<void> saveEpubState(String fileName, String? cfi, WidgetRef ref) async {
  try {
    final db = MyLibraryDb.instance;
    if (cfi != null && cfi.isNotEmpty) {
      await db.saveBookState(fileName, cfi);
    }
  } catch (e) {
    // Ignore save errors
  }
}

// ====================================================================
// DELETE FILE FROM MY LIBRARY PROVIDER
// ====================================================================

final deleteFileFromMyLib = FutureProvider.family<void, FileName>((ref, fileName) async {
  try {
    final db = MyLibraryDb.instance;
    // Delete book state
    await db.deleteBookState(fileName.fileName ?? '');
    // Delete book from library
    await db.delete(fileName.md5);
  } catch (e) {
    // Ignore delete errors
  }
});

// ====================================================================
// INSTANCE MANAGER PROVIDERS
// ====================================================================

/// Provider for the InstanceManager singleton
final instanceManagerProvider = Provider<InstanceManager>((ref) {
  return InstanceManager();
});

/// Provider for the list of archive instances
final archiveInstancesProvider = FutureProvider<List<ArchiveInstance>>((ref) async {
  final manager = ref.read(instanceManagerProvider);
  return await manager.getInstances();
});

/// Provider for the currently selected instance
final currentInstanceProvider = FutureProvider<ArchiveInstance?>((ref) async {
  final manager = ref.read(instanceManagerProvider);
  return await manager.getCurrentInstance();
});

/// Provider for auto-rank instances setting
final autoRankInstancesProvider = StateProvider<bool>((ref) => false);

// ====================================================================
// THEME & UI PROVIDERS
// ====================================================================

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Font size scale provider
final fontSizeScaleProvider = StateProvider<double>((ref) => 1.0);

/// Home page selected index provider
final homePageSelectedIndexProvider = StateProvider<int>((ref) => 0);

/// Selected index provider (for bottom navigation)
final selectedIndexProvider = StateProvider<int>((ref) => 0);

/// User agent provider
final userAgentProvider = StateProvider<String>((ref) =>
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');

/// Cookie provider
final cookieProvider = StateProvider<String>((ref) => '');

// ====================================================================
// BOOK DATA PROVIDERS
// ====================================================================

/// Provider for trending books
final getTrendingBooks = FutureProvider<List<dynamic>>((ref) async {
  // TODO: Implement trending books fetching
  return [];
});

/// Provider for search results
final searchProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  // TODO: Implement search
  return [];
});

/// Provider for subcategory type list
final getSubCategoryTypeList = FutureProvider<List<dynamic>>((ref) async {
  // TODO: Implement subcategory type list
  return [];
});

// ====================================================================
// DOWNLOAD PROVIDERS
// ====================================================================

/// Provider for active downloads (stream-based)
final activeDownloadsProvider = StreamProvider<List<DownloadTask>>((ref) {
  final downloadManager = ref.watch(downloadManagerProvider);
  return downloadManager.downloadsStream.map((map) => map.values.toList());
});
