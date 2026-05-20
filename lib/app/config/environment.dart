enum Environment {
  dev,
  prod;

  bool get isDev => this == Environment.dev;
  bool get isProd => this == Environment.prod;

  String get name => switch (this) {
        Environment.dev => 'Development',
        Environment.prod => 'Production',
      };
}
