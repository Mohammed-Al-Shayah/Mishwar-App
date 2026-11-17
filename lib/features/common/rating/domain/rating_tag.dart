enum RatingSide { rider, driver }

enum RatingTag {
  safeDriving('safe_driving'),
  cleanCar('clean_car'),
  friendly('friendly'),
  knowsRoute('knows_route'),
  late('late'),
  fastDriving('fast_driving'),
  dirtyCar('dirty_car'),
  longerRoute('longer_route'),
  onTime('on_time'),
  respectful('respectful'),
  rude('rude');

  const RatingTag(this.value);
  final String value;
}
