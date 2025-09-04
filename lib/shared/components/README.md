# Shared Components

This directory contains reusable UI components that can be used across the entire application.

## Components

### SkewedBadge

A skewed badge component with a unique geometric design that can be used for product badges, status indicators, or promotional labels.

#### Usage

```dart
import 'package:rikhh_app/shared/components/skewed_badge.dart';

SkewedBadge(
  text: 'Popular',
  color: Colors.orange,
)
```

#### Properties

- `text` (String, required): The text to display in the badge
- `color` (Color, required): The background color of the badge

#### Features

- **Skewed Design**: Unique geometric shape with inward cut on top-right and outward extension on bottom-right
- **Responsive**: Automatically adjusts to text content
- **Customizable**: Easy to change colors and text
- **Reusable**: Can be used anywhere in the app for consistent badge styling

#### Design Details

The badge uses a custom `ClipPath` with the following geometry:
- Top-left: Normal corner
- Top-right: 10px inward cut for skewed effect
- Bottom-right: Extended outward for dynamic look
- Bottom-left: Normal corner

This creates a modern, eye-catching design that stands out from traditional rectangular badges.

### ProductCard

A comprehensive product display card component that can be used throughout the app for consistent product presentation.

#### Usage

```dart
import 'package:rikhh_app/shared/components/product_card.dart';

ProductCard(
  image: 'assets/images/product.jpg',
  rating: 4.5,
  sold: '2.3k+',
  name: 'Product Name',
  currentPrice: '₹999',
  originalPrice: '₹1499',
  badge: 'Popular',
  badgeColor: Colors.orange,
  onTap: () {
    // Handle product tap
  },
)
```

#### Properties

- `image` (String, required): Path to the product image
- `rating` (double, required): Product rating (e.g., 4.5)
- `sold` (String, required): Number of units sold (e.g., '2.3k+')
- `name` (String, required): Product name/title
- `currentPrice` (String, required): Current selling price
- `originalPrice` (String, required): Original/listed price
- `badge` (String?, optional): Badge text to display (e.g., 'Popular', 'Sale')
- `badgeColor` (Color?, optional): Color for the badge
- `onTap` (VoidCallback?, optional): Callback function when card is tapped

#### Features

- **Professional Design**: Clean, modern card layout with shadows and borders
- **Badge Support**: Optional skewed badge for promotions or status
- **Rating Display**: Star rating with sold count
- **Price Comparison**: Shows current and original prices with strikethrough
- **Responsive Layout**: Automatically adjusts to content and screen size
- **Touch Interaction**: Built-in tap handling for navigation
- **Consistent Styling**: Uses app theme colors and design system

#### Design Details

- **Card Dimensions**: Optimized for GridView with 0.7 aspect ratio
- **Image Container**: 140px height with rounded top corners
- **Content Spacing**: 6px spacing between elements for compact layout
- **Typography**: Hierarchical text sizing for better readability
- **Shadows**: Subtle shadow for depth and modern appearance
