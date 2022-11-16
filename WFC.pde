// These should really come from user input somehow...
int outputDimX = 16;
int outputDimY = 16;
int patternSize = 3;
Boolean xWrapping = true;
Boolean yWrapping = false;

// Global stuff, that everything has access to
PImage input;
WFCGenerator generator;

// "Entry point"
void setup() {
  smooth(0);
  size(800, 800);
  // setup WFC
  input = loadImage("input.png");
  generator = new WFCGenerator();
  setupWFC();
  // --> draw()
}

void draw() {

  generator.Collapse();
  for(int i = 0; i < outputDimX * outputDimY; i++){
    generator.Propagate();
  }
  generator.ComputeEntropy();

  PImage ent = new PImage(generator.entropy[0].length, generator.entropy.length);
  ent.loadPixels();
  for (int i = 0; i < ent.height; i++) {
    for (int j = 0; j < ent.width; j++) {
      ent.pixels[j + i * ent.width] =color((int) map(generator.entropy[i][j], 0, generator.patterns.size(), 0, 255));
    }
  }
  ent.updatePixels();
  noTint();
  image(ent, 0, 0, width, height);
  tint(255, 128);
  image(IntsToImage(generator.output), 0, 0, width, height);
}

void setupWFC() {
  println("Setting input to a " + input.width + "x" + input.height + " image");
  generator.SetInput(input);

  println("Setting output size to " + outputDimX + "x" + outputDimY);
  generator.SetOutputSize(outputDimX, outputDimY);

  println("Setting pattern size to " + patternSize);
  generator.SetPatternSize(patternSize);

  print("Generating pattern tables" + (yWrapping ? " wrapping y" : "") + (xWrapping ? ", wrapping x" : "") + " ... ");
  generator.ReadInput(yWrapping, xWrapping);
  println("found " + generator.patterns.size());

  println("Generating adjacency relations");
  generator.ComputeAdjacencies();

  println("Initializing the 'wave'");
  generator.InitWave();

  println("Initializing entropy");
  generator.ComputeEntropy();

  println("Setup Complete");
  println("----------------------------------------------------");
}
