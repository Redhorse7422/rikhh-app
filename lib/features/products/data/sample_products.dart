import 'package:rikhh_app/features/products/models/media_file_model.dart';

import '../models/product_model.dart';

class SampleProducts {
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'Round Neck, Cotton White T-Shirt, Women',
        description:
            'Premium quality cotton t-shirt with a comfortable round neck design. Perfect for everyday wear, this white t-shirt features a soft, breathable fabric that keeps you cool and comfortable throughout the day. The classic fit and versatile design make it easy to pair with any outfit.',
        price: 2345.0,
        originalPrice: 4489.0,
        rating: 4.6,
        reviewCount: 23450,
        // thumbnailImage: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        // images: [
        //   'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop',
        //   'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=800&h=600&fit=crop',
        //   'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop',
        // ],
        category: 'Clothing',
        tags: ['Women', 'T-Shirt', 'Cotton', 'White', 'Casual'],
        inStock: true,
        stockQuantity: 150,
        specifications: {
          'Material': '100% Cotton',
          'Fit': 'Regular Fit',
          'Neck': 'Round Neck',
          'Sleeve': 'Short Sleeve',
          'Care': 'Machine Washable',
          'Origin': 'India',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
      Product(
        id: '2',
        name: 'HRX Shoes by Hrithik Roshan',
        description:
            'Premium athletic shoes designed for maximum comfort and performance. Features advanced cushioning technology and breathable mesh upper for optimal ventilation during workouts.',
        price: 2345.0,
        originalPrice: 4489.0,
        rating: 4.6,
        reviewCount: 2300,
        // thumbnailImage: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
        // images: [
        //   'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=600&fit=crop',
        //   'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=800&h=600&fit=crop',
        // ],
        category: 'Shoes',
        tags: ['Sports', 'Athletic', 'Running', 'Comfortable'],
        inStock: true,
        stockQuantity: 75,
        specifications: {
          'Material': 'Mesh & Synthetic',
          'Sole': 'Rubber',
          'Closure': 'Lace-up',
          'Type': 'Athletic',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
      Product(
        id: '3',
        name: 'Titan Watch Black Edition',
        description:
            'Elegant black watch with premium build quality and precise timekeeping. Features a classic design that complements both casual and formal attire.',
        price: 1450.0,
        originalPrice: 2489.0,
        rating: 4.9,
        reviewCount: 14300,
        // thumbnailImage: 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400&h=400&fit=crop',
        // images: ['https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800&h=600&fit=crop'],
        category: 'Accessories',
        tags: ['Watch', 'Black', 'Classic', 'Elegant'],
        inStock: true,
        stockQuantity: 200,
        specifications: {
          'Movement': 'Quartz',
          'Case Material': 'Stainless Steel',
          'Band Material': 'Leather',
          'Water Resistance': '30m',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
      Product(
        id: '4',
        name: 'Nike Air Max Running Shoes',
        description:
            'Professional running shoes with Air Max technology for superior cushioning and support. Perfect for long-distance running and daily training.',
        price: 3899.0,
        originalPrice: 5999.0,
        rating: 4.7,
        reviewCount: 8900,
        // thumbnailImage: 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=400&h=400&fit=crop',
        // images: [
        //   'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop',
        //   'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=800&h=600&fit=crop',
        // ],
        category: 'Shoes',
        tags: ['Nike', 'Running', 'Air Max', 'Professional'],
        inStock: true,
        stockQuantity: 120,
        specifications: {
          'Brand': 'Nike',
          'Technology': 'Air Max',
          'Type': 'Running',
          'Weight': '280g',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
      Product(
        id: '5',
        name: 'Samsung Galaxy Smart Watch',
        description:
            'Advanced smartwatch with health monitoring, fitness tracking, and smartphone connectivity. Features a vibrant display and long battery life.',
        price: 12999.0,
        originalPrice: 15999.0,
        rating: 4.8,
        reviewCount: 5200,
        // thumbnailImage: 'https://images.unsplash.com/photo-1544117519-31a4b719223d?w=400&h=400&fit=crop',
        // images: ['https://images.unsplash.com/photo-1544117519-31a4b719223d?w=800&h=600&fit=crop'],
        category: 'Electronics',
        tags: ['Smartwatch', 'Samsung', 'Health', 'Fitness'],
        inStock: true,
        stockQuantity: 85,
        specifications: {
          'Display': 'AMOLED',
          'Battery': 'Up to 5 days',
          'Water Resistance': '5ATM',
          'Compatibility': 'Android & iOS',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
      Product(
        id: '6',
        name: 'Cherry Blossom Extract Perfume',
        description:
            'Delicate fragrance with notes of cherry blossom, creating a fresh and feminine scent. Perfect for daily wear and special occasions.',
        price: 2345.0,
        originalPrice: 2999.0,
        rating: 4.6,
        reviewCount: 14300,
        // thumbnailImage: 'https://images.unsplash.com/photo-1541643600914-78b0847b36cc?w=400&h=400&fit=crop',
        // images: ['https://images.unsplash.com/photo-1541643600914-78b0847b36cc?w=800&h=600&fit=crop'],
        category: 'Beauty',
        tags: ['Perfume', 'Cherry Blossom', 'Fragrance', 'Women'],
        inStock: true,
        stockQuantity: 300,
        specifications: {
          'Volume': '50ml',
          'Type': 'Eau de Parfum',
          'Longevity': '6-8 hours',
          'Sillage': 'Moderate',
        },
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now(),
        thumbnailImg: MediaFile(
          id: '1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          scope: 'scope',
          uri: 'uri',
          url:
              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          fileName: 'fileName',
          mimetype: 'mimetype',
          size: 120,
        ),
        photos: [
          MediaFile(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            scope: 'scope',
            uri: 'uri',
            url:
                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
            fileName: 'fileName',
            mimetype: 'mimetype',
            size: 120,
          ),
        ],
      ),
    ];
  }

  static Product getProductById(String id) {
    return getProducts().firstWhere((product) => product.id == id);
  }

  static List<Product> getProductsByCategory(String category) {
    return getProducts()
        .where((product) => product.category == category)
        .toList();
  }
}
