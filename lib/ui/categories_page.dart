// Flutter imports:
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openlib/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:openlib/ui/components/page_title_widget.dart';
import 'package:openlib/ui/extensions.dart';
import 'package:openlib/ui/results_page.dart';

class CategoryBook {
  final String title;
  final String thumbnail;
  final String tag;
  final String info;
  CategoryBook(
      {required this.title,
      required this.thumbnail,
      required this.tag,
      required this.info});
}

List<CategoryBook> getLocalizedCategories(AppLocalizations l10n) {
  return [
    CategoryBook(
        info: l10n.classicsInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/1%20classic.jpeg",
        title: l10n.classics,
        tag: "list/tag/classics"),
    CategoryBook(
        info: l10n.romanceInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/2%20romance.jpeg",
        title: l10n.romance,
        tag: "list/tag/romance"),
    CategoryBook(
        info: l10n.fictionInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/3%20fiction.jpeg",
        title: l10n.fiction,
        tag: "list/tag/fiction"),
    CategoryBook(
        info: l10n.youngAdultInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/4%20young%20adult.jpeg",
        title: l10n.youngAdult,
        tag: "list/tag/young-adult"),
    CategoryBook(
        info: l10n.fantasyInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/5%20fantasy.jpeg",
        title: l10n.fantasy,
        tag: "list/tag/fantasy"),
    CategoryBook(
        info: l10n.scienceFictionInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/6%20science%20fiction.jpeg",
        title: l10n.scienceFiction,
        tag: "list/tag/science-fiction"),
    CategoryBook(
        info: l10n.nonfictionInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/7%20nonfiction.jpeg",
        title: l10n.nonfiction,
        tag: "list/tag/nonfiction"),
    CategoryBook(
        info: l10n.childrenInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/8%20children.jpeg",
        title: l10n.children,
        tag: "list/tag/children"),
    CategoryBook(
        info: l10n.historyInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/9%20history.jpeg",
        title: l10n.history,
        tag: "list/tag/history"),
    CategoryBook(
        info: l10n.mysteryInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/10%20mystery.jpeg",
        title: l10n.mystery,
        tag: "list/tag/mystery"),
    CategoryBook(
        info: l10n.coversInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/11%20covers.jpeg",
        title: l10n.covers,
        tag: "list/tag/covers"),
    CategoryBook(
        info: l10n.horrorInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/12%20horror.jpeg",
        title: l10n.horror,
        tag: "list/tag/horror"),
    CategoryBook(
        info: l10n.historicalFictionInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/13%20historical%20fiction.jpeg",
        title: l10n.historicalFiction,
        tag: "list/tag/historical-fiction"),
    CategoryBook(
        info: l10n.bestInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/14%20best.jpeg",
        title: l10n.best,
        tag: "list/best"),
    CategoryBook(
        info: l10n.titlesInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/15%20titles.jpeg",
        title: l10n.titles,
        tag: "list/title"),
    CategoryBook(
        info: l10n.middleGradeInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/16%20middle%20grade.jpeg",
        title: l10n.middleGrade,
        tag: "list/tag/middle-grade"),
    CategoryBook(
        info: l10n.paranormalInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/17%20paranormal.jpeg",
        title: l10n.paranormal,
        tag: "list/tag/paranormal"),
    CategoryBook(
        info: l10n.loveInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/18%20love.jpeg",
        title: l10n.love,
        tag: "list/tag/love"),
    CategoryBook(
        info: l10n.queerInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/19%20queer.jpeg",
        title: l10n.queer,
        tag: "list/tag/queer"),
    CategoryBook(
        info: l10n.nonfictionInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/20%20nonfiction.jpeg",
        title: l10n.nonfiction,
        tag: "list/nonfiction"),
    CategoryBook(
        info: l10n.historicalRomanceInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/21%20historical%20romance.jpeg",
        title: l10n.historicalRomance,
        tag: "list/tag/historical-romance"),
    CategoryBook(
        info: l10n.contemporaryInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/22%20contemporary.jpeg",
        title: l10n.contemporary,
        tag: "list/tag/contemporary"),
    CategoryBook(
        info: l10n.thrillerInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/23%20thriller.jpeg",
        title: l10n.thriller,
        tag: "list/tag/thriller"),
    CategoryBook(
        info: l10n.womenInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/24%20women.jpeg",
        title: l10n.women,
        tag: "list/tag/women"),
    CategoryBook(
        info: l10n.biographyInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/25%20biography.jpeg",
        title: l10n.biography,
        tag: "list/tag/biography"),
    CategoryBook(
        info: l10n.lgbtqInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/26%20lgbtq.jpeg",
        title: l10n.lgbtq,
        tag: "list/tag/lgbtq"),
    CategoryBook(
        info: l10n.seriesInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/27%20series.jpeg",
        title: l10n.series,
        tag: "list/series"),
    CategoryBook(
        info: l10n.titleChallengeInfo,
        thumbnail: "https://raw.githubusercontent.com/Nav-jangra/images/refs/heads/main/28%20title%20challenge.jpeg",
        title: l10n.titleChallenge,
        tag: "list/tag/title-challenge"),
  ];
}

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesTypeValues = getLocalizedCategories(AppLocalizations.of(context)!);
    return Column(
      children: [
        TitleText("Categories"),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 4
                      : 2,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(
                                title: categoriesTypeValues[index].title,
                                tag: categoriesTypeValues[index].tag,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: CachedNetworkImage(
                                imageUrl: categoriesTypeValues[index].thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                ),
                                errorWidget: (context, url, error) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                child: Text(
                                  categoriesTypeValues[index].title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: categoriesTypeValues.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
