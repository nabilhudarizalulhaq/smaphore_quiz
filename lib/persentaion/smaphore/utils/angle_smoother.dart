class AngleSmoother {
  /// Jumlah frame untuk smoothing (semakin besar semakin stabil tapi lambat)
  final int windowSize;

  /// Penyimpanan nilai sudut sebelumnya
  final List<double> _values = [];

  AngleSmoother({this.windowSize = 5});

  /// Menghaluskan sudut dengan moving average
  double smooth(double newValue) {
    _values.add(newValue);

    if (_values.length > windowSize) {
      _values.removeAt(0);
    }

    final sum = _values.reduce((a, b) => a + b);
    return sum / _values.length;
  }

  /// Reset (opsional)
  void reset() {
    _values.clear();
  }
}
