import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailorapp/core/constants/countries_data.dart';
import 'package:tailorapp/core/models/country_model.dart';

class CountryPickerWidget extends StatefulWidget {
  final CountryModel selectedCountry;
  final Function(CountryModel) onCountrySelected;
  final String? title;
  final String? searchHint;
  final bool showSearchBar;
  final bool showPopularCountries;
  final List<CountryModel>? popularCountries;

  const CountryPickerWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
    this.title,
    this.searchHint,
    this.showSearchBar = true,
    this.showPopularCountries = true,
    this.popularCountries,
  });

  @override
  State<CountryPickerWidget> createState() => _CountryPickerWidgetState();

  static Future<CountryModel?> show({
    required BuildContext context,
    CountryModel? selectedCountry,
    String? title,
    String? searchHint,
    bool showSearchBar = true,
    bool showPopularCountries = true,
    List<CountryModel>? popularCountries,
  }) {
    return showModalBottomSheet<CountryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerWidget(
        selectedCountry: selectedCountry ?? CountriesData.defaultCountry,
        onCountrySelected: (country) => Navigator.of(context).pop(country),
        title: title,
        searchHint: searchHint,
        showSearchBar: showSearchBar,
        showPopularCountries: showPopularCountries,
        popularCountries: popularCountries,
      ),
    );
  }
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CountryModel> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountriesData.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      _searchQuery = query;
      _filteredCountries = CountriesData.searchCountries(query);
    });
  }

  void _selectCountry(CountryModel country) {
    HapticFeedback.selectionClick();
    widget.onCountrySelected(country);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(theme, isDark),

          // Search bar
          if (widget.showSearchBar) _buildSearchBar(theme, isDark),

          // Popular countries section
          if (widget.showPopularCountries && _searchQuery.isEmpty)
            _buildPopularCountries(theme, isDark),

          // Country list
          Expanded(child: _buildCountryList(theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.close,
                size: 20,
                color: theme.iconTheme.color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.title ?? 'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
          ),
          // Show selected country info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedCountry.flag,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.selectedCountry.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.searchHint ?? 'Search countries...',
          hintStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.primaryColor,
            size: 18,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _filterCountries('');
                  },
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 15,
        ),
        onChanged: _filterCountries,
      ),
    );
  }

  Widget _buildPopularCountries(ThemeData theme, bool isDark) {
    final popularCountries =
        widget.popularCountries ?? CountriesData.popularCountries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'Popular Countries',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: popularCountries.length,
            itemBuilder: (context, index) {
              final country = popularCountries[index];
              final isSelected = country.code == widget.selectedCountry.code;

              return GestureDetector(
                onTap: () => _selectCountry(country),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.15)
                        : (isDark ? Colors.grey[800] : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor.withValues(alpha: 0.3)
                          : theme.dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.flag,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        country.code,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? theme.primaryColor
                              : theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCountryList(ThemeData theme, bool isDark) {
    if (_filteredCountries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: theme.iconTheme.color?.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredCountries.length,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder: (context, index) {
        final country = _filteredCountries[index];
        final isSelected = country.code == widget.selectedCountry.code;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color:
                isSelected ? theme.primaryColor.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Text(
              country.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.titleMedium?.color,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    country.code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
            onTap: () => _selectCountry(country),
          ),
        );
      },
    );
  }
}
