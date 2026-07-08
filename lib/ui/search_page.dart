// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // For Timer/Debounce

// Project imports:
import 'package:openlib/services/database.dart';
import 'package:openlib/ui/components/active_downloads_widget.dart';
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/results_page.dart';
import 'components/snack_bar_widget.dart';
// Import the new API Service (adjust path as necessary)
import 'package:openlib/services/google_suggest_api.dart';

import 'package:openlib/state/state.dart'
    show
        searchQueryProvider,
        selectedTypeState,
        selectedSortState,
        selectedFileTypeState,
        selectedLanguageState,
        selectedYearState,
        getTypeValues,
        getFileType,
        getSortValues,
        getLanguageValues,
        getYearValues,
        enableFiltersState;

// ====================================================================
// Suggestion Providers (New)
// ====================================================================

// Provider to hold the list of suggestions
final searchSuggestionProvider = StateProvider<List<String>>((ref) => []);
// Provider to show/hide the loading indicator
final suggestionsLoadingProvider = StateProvider<bool>((ref) => false);

// ====================================================================
// SearchPage Implementation (Stateful Conversion for API & Debounce)
// ====================================================================

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  Timer? _debounce;
  late final TextEditingController _searchController;
  final GoogleSuggestApi _apiService =
      GoogleSuggestApi(); // Instantiate API service

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state value
    _searchController =
        TextEditingController(text: ref.read(searchQueryProvider));

    // Listener to update the TextField when state changes (e.g., when a suggestion is tapped)
    ref.listenManual(searchQueryProvider, (previous, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
        // Move cursor to the end
        _searchController.selection =
            TextSelection.fromPosition(TextPosition(offset: next.length));
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // *** API LOGIC ***
  Future<void> _fetchSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      ref.read(searchSuggestionProvider.notifier).state = [];
      return;
    }

    ref.read(suggestionsLoadingProvider.notifier).state = true;

    // Call the Google Suggest API function
    final realSuggestions = await _apiService.fetchSuggestions(cleanQuery);

    ref.read(searchSuggestionProvider.notifier).state = realSuggestions;
    ref.read(suggestionsLoadingProvider.notifier).state = false;
  }
  // *****************

  void _onSearchQueryChanged(String value) {
    // 1. Update the Riverpod state immediately
    ref.read(searchQueryProvider.notifier).state = value;

    // 2. Debounce the API call to limit requests while the user is typing
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(value);
    });
  }

  void onSubmit(BuildContext context) {
    final searchQuery = ref.read(searchQueryProvider);
    if (searchQuery.isNotEmpty) {
      // Clear suggestions list before navigating
      ref.read(searchSuggestionProvider.notifier).state = [];
      ref.read(enableFiltersState.notifier).state = true;
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return ResultPage(searchQuery: searchQuery);
      }));
    } else {
            showSnackBar(context: context, message: AppLocalizations.of(context)!.searchFieldEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    // WidgetRef is available via ConsumerState
    final dropdownTypeValue = ref.watch(selectedTypeState);
    final dropdownSortValue = ref.watch(selectedSortState);
    final dropDownFileTypeValue = ref.watch(selectedFileTypeState);
    final dropdownLanguageValue = ref.watch(selectedLanguageState);
    final dropdownYearValue = ref.watch(selectedYearState);

    // Watch suggestion states
    final suggestions =
        ref.watch(searchSuggestionProvider); // The list of titles
    final isLoadingSuggestions =
        ref.watch(suggestionsLoadingProvider); // Loading state

    // Get localized filter values
    final l10n = AppLocalizations.of(context)!;
    final typeValues = getTypeValues(l10n);
    final sortValues = getSortValues(l10n);
    final fileType = getFileType(l10n);
    final languageValues = getLanguageValues(l10n);
    final yearValues = getYearValues(l10n);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const ActiveDownloadsWidget(),
                        TitleText(l10n.search),
            // Search Input Field
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7, top: 10),
              child: TextField(
                controller: _searchController, // <--- Added controller
                showCursor: true,
                cursorColor: Theme.of(context).colorScheme.secondary,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 5),
                    color: Theme.of(context).colorScheme.secondary,
                    icon:
                        isLoadingSuggestions // Show loading spinner if fetching suggestions
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              )
                            : const Icon(
                                Icons.search,
                                size: 23,
                              ),
                    onPressed: () => onSubmit(context), // <--- Simplified call
                  ),
                  filled: true,
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                                    hintText: l10n.search,
                  // Remove explicit fillColor to use the theme default (Dark Grey in Dark Mode)
                ),
                onSubmitted: (String value) => onSubmit(context),
                style: TextStyle(
                  color: Theme.of(context).col
