final static class PatternFactory {
  static HashMap<Integer, Byte> map = new HashMap<Integer, Byte>();
  static byte id = 0;

  static Pattern MakePattern(int[][] in) {
    byte[][] pattern = new byte[in.length][in[0].length];
    for (int i = 0; i < pattern.length; i++) {
      for (int j = 0; j < pattern[0].length; j++) {
        if (map.containsKey(in[i][j])) {
          pattern[i][j] = map.get(in[i][j]);
        } else {
          map.put(in[i][j], id++);
          pattern[i][j] = (byte)(id - 1);
        }
      }
    }
    return new Pattern(pattern);
  }


  public static int GetColorFromId(byte b) {
    for (int k : map.keySet())
      if (map.get(k) == b)
        return k;
    return -1; // something went wrong I guess?
  }
}

static class Pattern {
  byte[][] pattern;

  public Pattern(byte[][] pattern) {
    this.pattern = pattern;
  }

  @Override
    public boolean equals(Object o) {
    if (o == this)
      return true;
    if (!(o instanceof Pattern))
      return false;
    Pattern other = (Pattern) o;
    for (int i = 0; i < pattern.length; i++)
      for (int j = 0; j < pattern[0].length; j++)
        if (pattern[i][j] != other.pattern[i][j])
          return false;
    return true;
  }
  public boolean CanHaveNeighborTop(Pattern other) {
    for (int i = 0; i < pattern.length - 1; i++)
      for (int j = 0; j < pattern[0].length; j++)
        if (!(pattern[i][j] == other.pattern[i + 1][j]))
          return false;
    return true;
  }
  public boolean CanHaveNeighborRight(Pattern other) {
    for (int i = 0; i < pattern.length; i++)
      for (int j = 1; j < pattern[0].length; j++)
        if (!(pattern[i][j] == other.pattern[i][j-1]))
          return false;
    return true;
  }
  public boolean CanHaveNeighborBottom(Pattern other) {
    for (int i = 1; i < pattern.length; i++)
      for (int j = 0; j < pattern[0].length; j++)
        if (!(pattern[i][j] == other.pattern[i - 1][j]))
          return false;
    return true;
  }
  public boolean CanHaveNeighborLeft(Pattern other) {
    for (int i = 0; i < pattern.length; i++)
      for (int j = 0; j < pattern[0].length - 1; j++)
        if (!(pattern[i][j] == other.pattern[i][j+1]))
          return false;
    return true;
  }
}

class Adjacency {
  ArrayList<Integer> top = new ArrayList<Integer>();
  ArrayList<Integer> right = new ArrayList<Integer>();
  ArrayList<Integer> bottom = new ArrayList<Integer>();
  ArrayList<Integer> left = new ArrayList<Integer>();
}
