import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/prayer_calculator.dart';

class CityPickerSheet extends StatefulWidget {
  final String currentCityId;
  final ValueChanged<String> onCitySelected;

  const CityPickerSheet({
    super.key,
    required this.currentCityId,
    required this.onCitySelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentCityId,
    required ValueChanged<String> onCitySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CityPickerSheet(
        currentCityId: currentCityId,
        onCitySelected: onCitySelected,
      ),
    );
  }

  @override
  State<CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<CityPickerSheet> {
  String _searchQuery = '';
  String _selectedRegion = 'Semua';

  static const List<String> regions = [
    'Semua',
    'Jawa & Banten',
    'Sumatera',
    'Kalimantan',
    'Sulawesi',
    'Bali & Nusa Tenggara',
    'Maluku & Papua',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final filteredCities = CityLocation.presets.where((c) {
      final matchesQuery =
          _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.province.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesRegion =
          _selectedRegion == 'Semua' || c.region == _selectedRegion;

      return matchesQuery && matchesRegion;
    }).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          height: MediaQuery.sizeOf(context).height * 0.82,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C241E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? const Color(0xFF1A453A) : const Color(0xFFE2EBE5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Gap(14),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const Gap(16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Wilayah / Kota Indonesia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          'Tersedia ${CityLocation.presets.length} kota di seluruh 38 provinsi Indonesia',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white54
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari kota atau provinsi (misal: Medan, Makassar, Balikpapan)...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF14362C)
                        : const Color(0xFFF1F5F3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const Gap(10),

              // Filter Pulau / Region Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: regions.map((region) {
                    final isSelected = _selectedRegion == region;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          region,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0F5A47),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRegion = region;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Gap(8),

              // Result Count Badge
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'Menampilkan ${filteredCities.length} kota',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // City List
              Expanded(
                child: filteredCities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: isDark
                                  ? Colors.white38
                                  : Colors.grey.shade400,
                            ),
                            const Gap(8),
                            Text(
                              'Kota tidak ditemukan',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        itemCount: filteredCities.length,
                        separatorBuilder: (ctx, i) => Divider(
                          height: 1,
                          color: isDark ? Colors.white10 : Colors.grey.shade100,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (ctx, i) {
                          final city = filteredCities[i];
                          final isSelected = city.id == widget.currentCityId;

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            tileColor: isSelected
                                ? (isDark
                                      ? const Color(0xFF1B4E3F)
                                      : const Color(0xFFE8F5EE))
                                : null,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF10B981)
                                    : (isDark
                                          ? Colors.white10
                                          : const Color(0xFFF1F5F3)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_city_rounded,
                                size: 20,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  city.name,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    fontSize: 14.5,
                                    color: isSelected
                                        ? const Color(0xFF10B981)
                                        : (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A)),
                                  ),
                                ),
                                const Gap(8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    city.timezone == 7.0
                                        ? 'WIB'
                                        : city.timezone == 8.0
                                        ? 'WITA'
                                        : 'WIT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${city.province} • ${city.region}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey.shade600,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF10B981),
                                  )
                                : null,
                            onTap: () {
                              widget.onCitySelected(city.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
