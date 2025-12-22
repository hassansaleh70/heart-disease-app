class HeartCase {
  final String id;
  final String name;
  final Map<String, dynamic> features;
  final int prediction;
  final double probability;
  final DateTime timestamp;

  HeartCase({
    required this.id,
    required this.name,
    required this.features,
    required this.prediction,
    required this.probability,
    required this.timestamp,
  });

  factory HeartCase.fromFirestore(String id, Map<String, dynamic> data) =>
      HeartCase(
        id: id,
        name: data['name'] ?? '',
        features: Map<String, dynamic>.from(data['features'] ?? {}),
        prediction: data['prediction'] ?? 0,
        probability: (data['probability'] ?? 0.0).toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
            data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'features': features,
    'prediction': prediction,
    'probability': probability,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}