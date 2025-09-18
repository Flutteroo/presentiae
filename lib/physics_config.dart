class PhysicsConfig {
  double friction;
  double wallBounciness;
  double bouncinessFalloff;
  double maxSpeed; // Maximum pixel speed for normalizing LED indicator
  double bounceAngleVariation; // Random angle variation in degrees (±)

  PhysicsConfig({
    required this.friction,
    required this.wallBounciness,
    required this.bouncinessFalloff,
    required this.maxSpeed,
    required this.bounceAngleVariation,
  });

  // Creates a default configuration, e.g., "space-like" physics
  factory PhysicsConfig.defaultConfig() {
    return PhysicsConfig(
      friction: 0.990, // Very low friction for a "space" feel
      wallBounciness: 3.2, // Bounces back with more energy
      bouncinessFalloff: 0.17, // Gradual reduction in bounciness at high speeds
      maxSpeed: 200.0, // Maximum pixel speed for LED indicator normalization
      bounceAngleVariation: 10.0, // ±10° random angle variation on bounces
    );
  }

  // Deserialization: Create a PhysicsConfig object from a map
  factory PhysicsConfig.fromJson(Map<String, dynamic> json) {
    return PhysicsConfig(
      friction: json['friction'] as double,
      wallBounciness: json['wallBounciness'] as double,
      bouncinessFalloff: json['bouncinessFalloff'] as double,
      maxSpeed: json['maxSpeed'] as double? ?? 200.0, // Default if not present
      bounceAngleVariation: json['bounceAngleVariation'] as double? ??
          5.0, // Default if not present
    );
  }

  // Serialization: Convert the PhysicsConfig object to a map
  Map<String, dynamic> toJson() {
    return {
      'friction': friction,
      'wallBounciness': wallBounciness,
      'bouncinessFalloff': bouncinessFalloff,
      'maxSpeed': maxSpeed,
      'bounceAngleVariation': bounceAngleVariation,
    };
  }
}
