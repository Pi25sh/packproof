/// Extracted commodity and packaging attributes parsed by OCR and inspection logic.
class ProductDetails {
  final String brandName;
  final String declaredNetQuantity;
  final String declaredMrp;
  final String unitSalePrice;
  final String batchMfgDate;
  final String manufacturerAddress;
  final String consumerCareDetails;
  final String countryOfOrigin;

  const ProductDetails({
    required this.brandName,
    required this.declaredNetQuantity,
    required this.declaredMrp,
    required this.unitSalePrice,
    required this.batchMfgDate,
    required this.manufacturerAddress,
    required this.consumerCareDetails,
    this.countryOfOrigin = 'India',
  });

  Map<String, dynamic> toJson() => {
    'brandName': brandName,
    'declaredNetQuantity': declaredNetQuantity,
    'declaredMrp': declaredMrp,
    'unitSalePrice': unitSalePrice,
    'batchMfgDate': batchMfgDate,
    'manufacturerAddress': manufacturerAddress,
    'consumerCareDetails': consumerCareDetails,
    'countryOfOrigin': countryOfOrigin,
  };

  factory ProductDetails.fromJson(Map<String, dynamic> json) {
    return ProductDetails(
      brandName: json['brandName'] as String,
      declaredNetQuantity: json['declaredNetQuantity'] as String,
      declaredMrp: json['declaredMrp'] as String,
      unitSalePrice: json['unitSalePrice'] as String,
      batchMfgDate: json['batchMfgDate'] as String,
      manufacturerAddress: json['manufacturerAddress'] as String? ?? 'N/A',
      consumerCareDetails: json['consumerCareDetails'] as String? ?? 'N/A',
      countryOfOrigin: json['countryOfOrigin'] as String? ?? 'India',
    );
  }
}
