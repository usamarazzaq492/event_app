import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../app/config/app_colors.dart';
import '../app/config/app_text_style.dart';
import '../utils/haptic_utils.dart';

class SearchFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  const SearchFiltersWidget({
    Key? key,
    required this.onFiltersChanged,
    this.initialFilters = const {},
  }) : super(key: key);

  @override
  State<SearchFiltersWidget> createState() => _SearchFiltersWidgetState();
}

class _SearchFiltersWidgetState extends State<SearchFiltersWidget> {
  late Map<String, dynamic> _filters;
  late TextEditingController _searchController;
  late TextEditingController _locationController;
  late RangeValues _priceRange;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _selectedCategory;
  late String _selectedSortBy;

  final List<String> _categories = [
    'All',
    'Music',
    'Sports',
    'Technology',
    'Business',
    'Education',
    'Health',
    'Food',
    'Art',
    'Entertainment',
  ];

  final List<String> _sortOptions = [
    'Date',
    'Price',
    'Distance',
    'Popularity',
    'Rating',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    _filters = Map.from(widget.initialFilters);
    _searchController = TextEditingController(text: _filters['search'] ?? '');
    _locationController =
        TextEditingController(text: _filters['location'] ?? '');
    _priceRange = RangeValues(
      _filters['minPrice']?.toDouble() ?? 0.0,
      _filters['maxPrice']?.toDouble() ?? 1000.0,
    );
    _startDate = _filters['startDate'] ?? DateTime.now();
    _endDate = _filters['endDate'] ?? DateTime.now().add(Duration(days: 30));
    _selectedCategory = _filters['category'] ?? 'All';
    _selectedSortBy = _filters['sortBy'] ?? 'Date';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    HapticUtils.light();
    setState(() {
      _filters = {
        'search': _searchController.text,
        'location': _locationController.text,
        'minPrice': _priceRange.start,
        'maxPrice': _priceRange.end,
        'startDate': _startDate,
        'endDate': _endDate,
        'category': _selectedCategory,
        'sortBy': _selectedSortBy,
      };
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearFilters() {
    HapticUtils.light();
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _priceRange = RangeValues(0.0, 1000.0);
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(Duration(days: 30));
      _selectedCategory = 'All';
      _selectedSortBy = 'Date';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: AppColors.signinoptioncolor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(3.h)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search Filters',
                style: TextStyles.homeheadingtext.copyWith(fontSize: 18.sp),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear',
                      style: TextStyles.regulartext.copyWith(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Search and Location
          _buildSearchSection(),
          SizedBox(height: 3.h),

          // Category Filter
          _buildCategorySection(),
          SizedBox(height: 3.h),

          // Price Range
          _buildPriceSection(),
          SizedBox(height: 3.h),

          // Date Range
          _buildDateSection(),
          SizedBox(height: 3.h),

          // Sort By
          _buildSortSection(),
          SizedBox(height: 3.h),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search & Location',
          style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search events...',
            prefixIcon: Icon(Icons.search, color: AppColors.blueColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.h),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
        ),
        SizedBox(height: 2.h),
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Location (city, state)',
            prefixIcon: Icon(Icons.location_on, color: AppColors.blueColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.h),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                HapticUtils.selection();
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.blueColor
                      : AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(2.h),
                  border: Border.all(
                    color: isSelected ? AppColors.blueColor : Colors.grey,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyles.regulartext.copyWith(
                    color: isSelected ? Colors.white : AppColors.whiteColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 2.h),
        RangeSlider(
          values: _priceRange,
          min: 0.0,
          max: 1000.0,
          divisions: 20,
          activeColor: AppColors.blueColor,
          inactiveColor: Colors.grey,
          onChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${_priceRange.start.round()}',
              style: TextStyles.regulartext.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${_priceRange.end.round()}',
              style: TextStyles.regulartext.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyles.regulartext.copyWith(fontSize: 10.sp),
                      ),
                      Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        style: TextStyles.regulartext,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(2.h),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: TextStyles.regulartext.copyWith(fontSize: 10.sp),
                      ),
                      Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        style: TextStyles.regulartext,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyles.homeheadingtext.copyWith(fontSize: 14.sp),
        ),
        SizedBox(height: 2.h),
        DropdownButtonFormField<String>(
          value: _selectedSortBy,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.h),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.backgroundColor,
          ),
          dropdownColor: AppColors.signinoptioncolor,
          style: TextStyles.regulartext.copyWith(color: AppColors.whiteColor),
          items: _sortOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: TextStyles.regulartext
                    .copyWith(color: AppColors.whiteColor),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSortBy = value!;
            });
          },
        ),
      ],
    );
  }
}
