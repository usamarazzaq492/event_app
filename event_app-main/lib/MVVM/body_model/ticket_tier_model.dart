/// Model representing a single ticket tier for an event.
/// [selectedQuantity] is mutable local UI state, starts at 0.
class TicketTier {
  final int tierId;
  final String tierName;
  final double price;
  final int? quantityCap;
  final int quantitySold;
  final int? available;
  final bool isSoldOut;
  final String? description;
  int selectedQuantity;

  TicketTier({
    required this.tierId,
    required this.tierName,
    required this.price,
    this.quantityCap,
    required this.quantitySold,
    this.available,
    required this.isSoldOut,
    this.description,
    this.selectedQuantity = 0,
  });

  factory TicketTier.fromJson(Map<String, dynamic> json) {
    return TicketTier(
      tierId:           json['tierId'] as int,
      tierName:         json['tierName'] as String,
      price:            (json['price'] as num).toDouble(),
      quantityCap:      json['quantityCap'] as int?,
      quantitySold:     (json['quantitySold'] as num?)?.toInt() ?? 0,
      available:        json['available'] as int?,
      isSoldOut:        json['isSoldOut'] as bool? ?? false,
      description:      json['description'] as String?,
      selectedQuantity: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'tierId':       tierId,
    'tierName':     tierName,
    'price':        price,
    'quantityCap':  quantityCap,
    'quantitySold': quantitySold,
    'available':    available,
    'isSoldOut':    isSoldOut,
    'description':  description,
  };

  /// Returns the booking API payload item: { tier_id, quantity }
  Map<String, dynamic> toBookingPayload() => {
    'tier_id':  tierId,
    'quantity': selectedQuantity,
  };

  /// Emoji icon based on common tier names
  String get tierEmoji {
    final name = tierName.toLowerCase();
    if (name.contains('vip'))    return '⭐';
    if (name.contains('child'))  return '👶';
    if (name.contains('senior')) return '🏅';
    if (name.contains('adult'))  return '🎫';
    if (name.contains('early'))  return '🐦';
    if (name.contains('general'))return '🎟️';
    return '🎫';
  }
}
