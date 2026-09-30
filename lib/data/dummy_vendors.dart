import '../models/vendor.dart';

/// Dummy vendor data for Oleena – Member 1 (Vendor Discovery).
/// All images use verified, stable Unsplash direct photo URLs.
final List<Vendor> dummyVendors = [
  Vendor(
    id: 'v001',
    name: 'Eternal Blooms Florist',
    category: 'Florist',
    categoryIcon: '💐',
    priceFrom: 45000,
    rating: 4.9,
    reviewCount: 127,
    // Fixed: reliable floral arrangement photo
    imageUrl:
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800&q=80',
    location: 'Colombo 3, Western Province',
    description:
        'Award-winning floral studio specialising in lush, romantic arrangements for weddings across Sri Lanka. '
        'Our master florists hand-craft each centrepiece, bridal bouquet, and venue decor using the freshest imported and local blooms. '
        'From intimate garden ceremonies to grand ballroom receptions, we bring every floral vision to life.',
    isFavorite: true,
  ),
  Vendor(
    id: 'v002',
    name: 'Luminara Photography',
    category: 'Photographer',
    categoryIcon: '📸',
    priceFrom: 120000,
    rating: 4.8,
    reviewCount: 214,
    imageUrl:
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
    location: 'Kandy, Central Province',
    description:
        'A duo of storytelling photographers with over a decade of experience capturing the magic of Sri Lankan weddings. '
        'Our cinematic approach blends candid emotion with artistic portraiture. '
        'Each package includes a pre-wedding shoot, full-day coverage, drone aerials, and a hand-crafted album.',
    isFavorite: false,
  ),
  Vendor(
    id: 'v003',
    name: 'The Grand Cinnamon Banquet',
    category: 'Venue',
    categoryIcon: '🏛️',
    priceFrom: 350000,
    rating: 4.7,
    reviewCount: 89,
    imageUrl:
        'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800&q=80',
    location: 'Galle Face, Colombo 1',
    description:
        'An exquisite oceanfront banquet hall accommodating up to 500 guests in unrivalled elegance. '
        'Our in-house event planning team, world-class catering, and dedicated coordinators ensure every detail is flawless. '
        'Breathtaking sea-view terraces make for unforgettable wedding portraits.',
    isFavorite: false,
  ),
  Vendor(
    id: 'v004',
    name: 'Harmony Strings Orchestra',
    category: 'Entertainment',
    categoryIcon: '🎻',
    priceFrom: 80000,
    rating: 4.6,
    reviewCount: 63,
    imageUrl:
        'https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=800&q=80',
    location: 'Nugegoda, Western Province',
    description:
        'A premier live music ensemble offering classical strings, jazz trios, and contemporary pop covers tailored for weddings. '
        'From the bride\'s walk down the aisle to the final dance, our musicians set the perfect emotional tone. '
        'Customisable playlists and ceremony consultation included.',
    isFavorite: true,
  ),
  Vendor(
    id: 'v005',
    name: 'Bridal Glow MUA Studio',
    category: 'Hair & Makeup',
    categoryIcon: '💄',
    priceFrom: 35000,
    rating: 4.9,
    reviewCount: 301,
    imageUrl:
        'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800&q=80',
    location: 'Rajagiriya, Western Province',
    description:
        'Colombo\'s most-loved bridal beauty studio, famous for flawless, long-lasting makeup that photographs beautifully. '
        'Specialising in both traditional Kandyan bridal looks and modern Western styles. '
        'Package includes trials, airbrush foundation, lash application, and on-site touch-up kits.',
    isFavorite: false,
  ),
  Vendor(
    id: 'v006',
    name: 'Dulce Ceylon Cakes',
    category: 'Wedding Cake',
    categoryIcon: '🎂',
    priceFrom: 28000,
    rating: 4.8,
    reviewCount: 156,
    imageUrl:
        'https://images.unsplash.com/photo-1535254973040-607b474cb50d?w=800&q=80',
    location: 'Battaramulla, Western Province',
    description:
        'Artisan wedding cakes designed and baked with love. Each cake is a bespoke masterpiece tailored to your wedding theme and palette. '
        'We offer multi-tiered fondant and buttercream creations, sugar flowers, and exotic flavour combinations. '
        'Tasting consultations available by appointment.',
    isFavorite: false,
  ),
];

/// All unique vendor categories.
final List<String> vendorCategories = [
  'All',
  ...{...dummyVendors.map((v) => v.category)},
];
