class AppConstants {
  // Firebase collection names
  static const String usersCollection = 'users';
  static const String placesCollection = 'places';
  static const String wishlistsCollection = 'wishlists';
  static const String routePlansCollection = 'route_plans';
  static const String visitsCollection = 'visits';
  
  // Pakistan's popular tourist destinations
  static const List<String> popularDestinations = [
    'Hunza Valley',
    'Swat Valley',
    'Murree',
    'Naran Kaghan',
    'Skardu',
    'Lahore Fort',
    'Badshahi Mosque',
    'Faisal Mosque',
    'Mohenjo-daro',
    'Taxila',
    'Deosai Plains',
    'K2 Base Camp',
    'Fairy Meadows',
    'Kalash Valley',
    'Neelum Valley',
  ];
  
  // AI Model endpoints
  static const String llamaRoutePlanningModelEndpoint = 'https://api.llamalab.com/v1/models/meta-llama/llama-4-scout-17b-16e-instruct';
  static const String llamaChatModelEndpoint = 'https://api.llamalab.com/v1/chat';
  
  // App specific constants
  static const int maxWishlistItems = 20;
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // API Keys (These should be moved to environment variables in production)
  static const String mapsApiKey = 'API_KEY_FROM_ENV';
}
