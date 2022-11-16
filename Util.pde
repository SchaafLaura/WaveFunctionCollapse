int PickRandomAccordingToOccurance(int[] occurances) {
  int[] cumulativeOccurances = new int[occurances.length];
  int n = 0;
  for (int i = 0; i < occurances.length; i++) {
    n += occurances[i];
    cumulativeOccurances[i] = n;
  }

  float random = random(0, n);
  for (int i = 0; i < occurances.length; i++)
    if (random < cumulativeOccurances[i])
      return i;
  return - 1; // something went horribly wrong :/
}

PImage IntsToImage(int[][] ints) {
  PImage ret = new PImage(ints[0].length, ints.length);
  ret.loadPixels();
  for (int i = 0; i < ret.height; i++) {
    for (int j = 0; j < ret.width; j++) {
      ret.pixels[j + i * ret.width] = ints[i][j];
    }
  }
  ret.updatePixels();
  return ret;
}

int[][] WrappingCut(int[][] input, int startY, int startX, int lengthY, int lengthX) {
  int[][] ret = new int[lengthY][lengthX];
  int w = input[0].length;
  int h = input.length;

  for (int i = startY; i < startY + lengthY; i++)
    for (int j = startX; j < startX + lengthX; j++)
      ret[i - startY][j - startX] = input[i % h][j % w];
  return ret;
}

public void PrettyPrintBooleanArray(Boolean[] arr) {
  for (int i = 0; i < arr.length; i++)
    print(arr[i] ? "1" : "0");
  println();
}

public void PrettyPrintBoolArray(boolean[] arr) {
  for (int i = 0; i < arr.length; i++)
    print(arr[i] ? "1" : "0");
  println();
}

class Point {
  int y;
  int x;
  public Point(int y, int x) {
    this.y = y;
    this.x = x;
  }
}
