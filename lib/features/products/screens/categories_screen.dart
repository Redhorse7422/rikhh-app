import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:rikhh_app/features/products/models/product_model.dart';
import 'package:rikhh_app/shared/components/categories_slider.dart';
import 'package:rikhh_app/shared/components/category_card.dart';
import 'package:rikhh_app/shared/components/top_search_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/categories_bloc.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load categories using CategoriesBloc
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigationBar(),

            // Search Bar
            TopSearchBar(
              controller: _searchController,
              onChanged: (value) {
                // Handle search functionality
                setState(() {});
              },
              showBorder: true,
            ),

            // Category Filters
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  CategoriesSlider(
                    categories: _getCategoryries(),
                    onCategorySelected: (category) {
                      context.go('/main/search', extra: category.name);
                    },
                  ),
                ],
              ),
            ),

            // Category Count
            _buildCategoryCount(),

            // Categories Grid
            Expanded(child: _buildCategoriesGrid()),
          ],
        ),
      ),
    );
  }

  List<ProductCategory> _getCategoryries() {
    final state = context.read<CategoriesBloc>().state;
    if (state is CategoriesLoaded) {
      return state.categories;
    }
    return [];
  }

  Widget _buildTopNavigationBar() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Navigate to home tab using bottom navigation
              // Since this is a tab screen, we'll use a simple approach
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: const Icon(Feather.home, color: AppColors.heading, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.heading,
                ),
              ),
            ),
          ),
          // Empty container to balance the layout
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCategoryCount() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        int categoryCount = 0;
        if (state is CategoriesLoaded) {
          categoryCount = state.categories.length;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            '$categoryCount Categories',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.heading,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is CategoriesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Feather.alert_circle, size: 64, color: AppColors.body),
                const SizedBox(height: 16),
                Text(
                  'Error loading categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.heading,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: AppColors.body),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CategoriesBloc>().add(LoadCategories());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Feather.folder, size: 64, color: AppColors.body),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.heading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try refreshing the page',
                    style: TextStyle(color: AppColors.body),
                  ),
                ],
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 5,
              ),
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return CategoryCard(
                  name: category.name,
                  image: category.image ?? '',
                  onTap: () => {
                    context.go('/main/search', extra: category.name),
                  },
                );
              },
            ),
          );
        }

        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      },
    );
  }
}
