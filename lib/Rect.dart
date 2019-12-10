class Rect {
  int bottom;
  int left;
  int top;
  int right;
  Rect(this.bottom, this.left, this.top, this.right);
  Rect.empty() { bottom = 0; left = 0; top = 0; right = 0; }

  int width() { return right - left; }
  int height() { return top - bottom; }

  @override String toString() {return 'Rect{($left, $bottom), ($right, $top)}';}

  void grow(int i) {
    bottom -= i;
    left -= i;
    top += i;
    right += i;
  }
}
