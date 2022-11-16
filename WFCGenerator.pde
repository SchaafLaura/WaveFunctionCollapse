class WFCGenerator {
  int dimX;
  int dimY;
  int N;
  int[][] input;
  int[][] output;
  int inputW;
  int inputH;

  int runningPatternId = 0;
  HashMap<Integer, Pattern> patterns; // keys are the Ids of Patterns
  HashMap<Integer, Integer> patternOccurances; // keys are the Ids of Patterns here too
  HashMap<Integer, Adjacency> adjacencies; // you guessed it: here too

  Boolean[][][] wave;
  int[][] entropy;

  Point lastCollapsed;
  int lastCollapsedId;

  public WFCGenerator() {
    patterns = new HashMap<Integer, Pattern>();
    patternOccurances = new HashMap<Integer, Integer>();
    adjacencies = new HashMap<Integer, Adjacency>();
    SetDefaults();
  }

  public void Propagate() {
    UpdatePoint(lastCollapsed);
    for (int i = 0; i < dimY; i++)
      for (int j = 0; j < dimX; j++)
        UpdatePoint(new Point(i, j));
  }

  public void Collapse() {
    Point toCollapse = FindPointWithLowestEntropy();
    int[] validPatternIdsAtPointToCollapse = GetValidPatternIdsAtPoint(toCollapse);
    int[] correspondingOccurances = GetOccurencesOfIds(validPatternIdsAtPointToCollapse);
    int occuranceIndex = PickRandomAccordingToOccurance(correspondingOccurances);
    int idToCollapseTo = validPatternIdsAtPointToCollapse[occuranceIndex];
    CollapsePoint(toCollapse, idToCollapseTo);
    WritePatternToOutput(toCollapse, idToCollapseTo);
    UpdatePoint(toCollapse);
    lastCollapsed = toCollapse;
    //lastCollapsedId = idToCollapseTo;
  }


  private void UpdatePoint(Point point) {
    int numberOfPatterns = patterns.size();
    Boolean[] oldPossibilities = wave[point.y][point.x];

    int currentNumberOfPossibilities = 0;
    for (int i = 0; i < numberOfPatterns; i++)
      currentNumberOfPossibilities += oldPossibilities[i] ? 1 : 0;
    if (currentNumberOfPossibilities == 1) {
      /*
      if (point.x > 0)
       UpdatePoint(new Point(point.y, point.x - 1));
       if (point.x < dimX - 1)
       UpdatePoint(new Point(point.y, point.x + 1));
       if (point.y > 0)
       UpdatePoint(new Point(point.y - 1, point.x));
       if (point.y < dimY - 1)
       UpdatePoint(new Point(point.y + 1, point.x));
       */
      return;
    }

    Boolean[] newPossibilities = new Boolean[numberOfPatterns];

    boolean[] possibilitiesFromLeft = new boolean[numberOfPatterns];
    boolean[] possibilitiesFromRight = new boolean[numberOfPatterns];
    boolean[] possibilitiesFromBottom = new boolean[numberOfPatterns];
    boolean[] possibilitiesFromTop = new boolean[numberOfPatterns];

    for (int i = 0; i < numberOfPatterns; i++) {
      possibilitiesFromLeft[i] = true;
      possibilitiesFromRight[i] = true;
      possibilitiesFromBottom[i] = true;
      possibilitiesFromTop[i] = true;
    }

    if (point.x > 0)
      possibilitiesFromLeft = GetValidRightNeighborsAtPoint(new Point(point.y, point.x - 1));
    if (point.x < dimX - 1)
      possibilitiesFromRight = GetValidLeftNeighborsAtPoint(new Point(point.y, point.x + 1));
    if (point.y > 0)
      possibilitiesFromTop = GetValidBottomNeighborsAtPoint(new Point(point.y - 1, point.x));
    if (point.y < dimY - 1)
      possibilitiesFromBottom = GetValidTopNeighborsAtPoint(new Point(point.y + 1, point.x));

    boolean somethingChanged = false;
    for (int i = 0; i < numberOfPatterns; i++) {
      newPossibilities[i] = (possibilitiesFromLeft[i] && possibilitiesFromRight[i] && possibilitiesFromTop[i] && possibilitiesFromBottom[i]);
      if (newPossibilities[i] != oldPossibilities[i])
        somethingChanged = true;
    }

    if (somethingChanged) {
      for (int i = 0; i < numberOfPatterns; i++) {
        wave[point.y][point.x][i] = newPossibilities[i];
      }

      if (point.x > 0)
        UpdatePoint(new Point(point.y, point.x - 1));
      if (point.x < dimX - 1)
        UpdatePoint(new Point(point.y, point.x + 1));
      if (point.y > 0)
        UpdatePoint(new Point(point.y - 1, point.x));
      if (point.y < dimY - 1)
        UpdatePoint(new Point(point.y + 1, point.x));
    }
  }

  private boolean[] GetValidBottomNeighborsAtPoint(Point point) {
    int[] possibilities = GetValidPatternIdsAtPoint(point);
    boolean[] cumulativePossibilities = new boolean[patterns.size()];
    for (int id : possibilities) {
      ArrayList<Integer> r = adjacencies.get(id).bottom;
      for (int k : r) {
        cumulativePossibilities[k] = true;
      }
    }
    return cumulativePossibilities;
  }

  private boolean[] GetValidTopNeighborsAtPoint(Point point) {
    int[] possibilities = GetValidPatternIdsAtPoint(point);
    boolean[] cumulativePossibilities = new boolean[patterns.size()];
    for (int id : possibilities) {
      ArrayList<Integer> r = adjacencies.get(id).top;
      for (int k : r) {
        cumulativePossibilities[k] = true;
      }
    }
    return cumulativePossibilities;
  }

  private boolean[] GetValidLeftNeighborsAtPoint(Point point) {
    int[] possibilities = GetValidPatternIdsAtPoint(point);
    boolean[] cumulativePossibilities = new boolean[patterns.size()];
    for (int id : possibilities) {
      ArrayList<Integer> r = adjacencies.get(id).left;
      for (int k : r) {
        cumulativePossibilities[k] = true;
      }
    }
    return cumulativePossibilities;
  }

  private boolean[] GetValidRightNeighborsAtPoint(Point point) {
    int[] possibilities = GetValidPatternIdsAtPoint(point);
    boolean[] cumulativePossibilities = new boolean[patterns.size()];
    for (int id : possibilities) {
      ArrayList<Integer> r = adjacencies.get(id).right;
      for (int k : r) {
        cumulativePossibilities[k] = true;
      }
    }
    return cumulativePossibilities;
  }


  private void WritePatternToOutput(Point point, int id) {
    Pattern P = patterns.get(id);
    byte b = P.pattern[0][0];
    int c = PatternFactory.GetColorFromId(b);
    output[point.y][point.x] = c;
  }

  private void CollapsePoint(Point toCollapse, int idToCollapseTo) {
    for (int k = 0; k < wave[toCollapse.y][toCollapse.x].length; k++)
      wave[toCollapse.y][toCollapse.x][k] = k == idToCollapseTo;
  }

  private int[] GetOccurencesOfIds(int[] ids) {
    int[] occurances = new int[ids.length];
    for (int i = 0; i < ids.length; i++)
      occurances[i] = patternOccurances.get(i);
    return occurances;
  }

  private int[] GetValidPatternIdsAtPoint(Point point) {
    Boolean[] waveStateAtPoint = wave[point.y][point.x];
    int n = 0;
    for (int i = 0; i < waveStateAtPoint.length; i++)
      n += waveStateAtPoint[i] ? 1 : 0;
    int[] validPatternIds = new int[n];
    n = 0;
    for (int i = 0; i < waveStateAtPoint.length; i++)
      if (waveStateAtPoint[i])
        validPatternIds[n++] = i;
    return validPatternIds;
  }

  private Point FindPointWithLowestEntropy() {
    int record = patterns.size();
    ArrayList<Point> recordPoints = new ArrayList<Point>();
    for (int i = 0; i < dimY; i++) {
      for (int j = 0; j < dimX; j++) {
        if (entropy[i][j] < record && entropy[i][j] > 1) {
          record = entropy[i][j];
          recordPoints = new ArrayList<Point>();
          recordPoints.add(new Point(i, j));
        } else if (entropy[i][j] == record) {
          recordPoints.add(new Point(i, j));
        }
      }
    }
    return recordPoints.get((int) random(0, recordPoints.size()));
  }

  public void ComputeEntropy() {
    entropy = new int[dimY][dimX];
    for (int i = 0; i < dimY; i++) {
      for (int j = 0; j < dimX; j++) {
        int e = 0;
        for (int k = 0; k < wave[i][j].length; k++)
          e += wave[i][j][k] ? 1 : 0;
        entropy[i][j] = e;
      }
    }
  }

  public void InitWave() {
    wave = new Boolean[dimY][dimX][patterns.values().size()];
    for (int i = 0; i < dimY; i++)
      for (int j = 0; j < dimX; j++)
        for (int k = 0; k < patterns.values().size(); k++)
          wave[i][j][k] = true;
  }

  public void ComputeAdjacencies() {
    for (int patternId : patterns.keySet()) {
      Pattern currentPattern = patterns.get(patternId);
      Adjacency A = new Adjacency();
      for (int otherPatternId : patterns.keySet()) {
        Pattern otherPattern = patterns.get(otherPatternId);

        if (currentPattern.CanHaveNeighborTop(otherPattern))
          A.top.add(otherPatternId);
        if (currentPattern.CanHaveNeighborRight(otherPattern))
          A.right.add(otherPatternId);
        if (currentPattern.CanHaveNeighborBottom(otherPattern))
          A.bottom.add(otherPatternId);
        if (currentPattern.CanHaveNeighborLeft(otherPattern))
          A.left.add(otherPatternId);
      }
      adjacencies.put(patternId, A);
    }
  }

  public void ReadInput(Boolean yWrapping, Boolean xWrapping) {
    int yMax = yWrapping ? inputH : inputH - N + 1;
    int xMax = xWrapping ? inputW : inputW - N + 1;
    for (int i = 0; i < yMax; i++) {
      for (int j = 0; j < xMax; j++) {
        Pattern P = PatternFactory.MakePattern(WrappingCut(input, i, j, N, N));
        int k = GetPatternId(P); // gets Id if it exists, otherwise creates entries in patterns and occurances and then gets id
        patternOccurances.put(k, patternOccurances.get(k) + 1);
      }
    }
  }

  public void SetInput(PImage img) {
    inputH = img.height;
    inputW = img.width;
    input = new int[inputH][inputW];
    img.loadPixels();
    for (int i = 0; i < inputH; i++)
      for (int j = 0; j < inputW; j++)
        input[i][j] = img.pixels[j + i * inputW];
  }

  public void SetPatternSize(int patternSize) {
    N = patternSize;
  }

  public void SetOutputSize(int dimY, int dimX) {
    this.dimX = dimX;
    this.dimY = dimY;
    output = new int[dimY][dimX];
    for (int i = 0; i < dimY; i++)
      for (int j = 0; j < dimX; j++)
        output[i][j] = -1;
  }

  private void SetDefaults() {
    SetOutputSize(32, 32);
    N = 3;
  }

  private int GetPatternId(Pattern P) {
    for (int k : patterns.keySet())
      if (P.equals(patterns.get(k)))
        return k;

    patterns.put(runningPatternId, P);
    patternOccurances.put(runningPatternId, 0);
    return runningPatternId++;
  }
}
