class Coupon {
  final String id;
  final String code;
  final String type; // 'percent' or 'fixed'
  final double value;
  final double minSpend;

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minSpend,
  });

  String get displayValue => type == 'percent'
      ? '${value.toStringAsFixed(0)}% OFF'
      : 'AED ${value.toStringAsFixed(0)} OFF';

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minSpend: (json['min_spend'] as num?)?.toDouble() ?? 0,
    );
  }
}
