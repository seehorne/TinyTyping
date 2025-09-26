import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases;
int totalTrialNum = 2;
int currTrialNum = 0;
float startTime = 0;
float finishTime = 0;
float lastTime = 0;
float lettersEnteredTotal = 0;
float lettersExpectedTotal = 0;
float errorsTotal = 0;
String currentPhrase = "";
String currentTyped = "";
final int DPIofYourDeviceScreen = 455;
float scaleH = 0.9; // Scale down the height input area to display typed string properly
final float sizeOfInputArea = DPIofYourDeviceScreen*1;
PImage watch;
PFont font;

// ========== QWERTY-T9 groups ==========
String[][] t9Groups = {
  {"w","e","r"},     // top left
  {"t","y","u"},     // top middle
  {"i","o","p"},     // top right
  {"a","s","d"},     // middle left
  {"f","g","h"},     // middle middle
  {"j","k","l"},     // middle right
  {"z","x","c"},     // bottom left
  {"v","b","n"},     // bottom middle
  {"m","q","_"}      // bottom right (_ for space)
};

// state
int[] groupIndices = new int[9];
int lastTapped = -1;


void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt");
  Collections.shuffle(Arrays.asList(phrases), new Random());

  orientation(LANDSCAPE);
  size(1920, 822);
  font = createFont("NotoSans-Regular.ttf", 14 * displayDensity);
  textFont(font);
  noStroke();
}


void draw()
{
  background(255);

  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!", 400, 200);
    text("Total time taken: " + (finishTime - startTime)/1000 + "s", 400, 230);
    text("Total letters entered: " + lettersEnteredTotal, 400, 260);
    text("Total letters expected: " + lettersExpectedTotal, 400, 290);
    text("Total errors entered: " + errorsTotal, 400, 320);
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f);
    text("Raw WPM: " + wpm, 400, 350);
    float freebieErrors = lettersExpectedTotal*.05;
    text("Freebie errors: " + nf(freebieErrors, 1, 3), 400, 380);
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty, 400, 410);
    text("WPM w/ penalty: " + (wpm-penalty), 400, 440);
    return;
  }

  drawWatch();

  // big 1" square area background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea);

  if (startTime==0 && !mousePressed)
  {
    fill(0);
    textAlign(CENTER);
    text("Click to start time!", 280, 150);
  }

  if (startTime==0 && mousePressed)
  {
    nextTrial();
  }

  if (startTime!=0)
  {
    textAlign(LEFT);
    fill(0);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50);
    text("Target:   " + currentPhrase, 70, 100);

    // NEXT button
    fill(255, 0, 0);
    rect(width-200, height-200, 200, 200);
    fill(255);
    text("NEXT > ", width-150, height-150);

    // ========== typed string display ==========
    textFont(font, 36);
    float maxW = sizeOfInputArea - 110; // limit to width of the input square, minus the length of "typed: "
    String displayStr = currentTyped;
    
    // If too wide, crop from the left and prepend "..."
    if (textWidth(displayStr) > maxW) {
      String ellipsis = "...";
      // Walk backwards until the substring (with "...") fits
      for (int i = 0; i < displayStr.length(); i++) {
        String candidate = ellipsis + displayStr.substring(i);
        if (textWidth(candidate) <= maxW) {
          displayStr = candidate;
          break;
        }
      }
    }

    
    // Draw text aligned to left of the square
    fill(255);
    textAlign(LEFT, CENTER);
    text("Typed: " + displayStr, width/2 - sizeOfInputArea/2, height/2 - (2*scaleH-1)*sizeOfInputArea/2 - 28);
    //text("Typed: " + currentTyped, width/2, height/2 - (2*scaleH-1)*sizeOfInputArea/2 - 28);

    //if (lastTapped >= 0) {
    //  String preview = t9Groups[lastTapped][ groupIndices[lastTapped] ];
    //  if (preview.equals("_")) preview = "␣"; // show space symbol
    //  fill(150, 0, 0);
    //  text("Current: " + preview, width/2, height/2 - (2*scaleH-1)*sizeOfInputArea/2 - 20);
    //}
    textFont(font);

    // ========== draw 3x3 T9 grid ==========
    float cellW = sizeOfInputArea/3;
    float cellH = sizeOfInputArea/3 * scaleH;

    stroke(0);
    strokeWeight(3);

    for (int row=0; row<3; row++) {
      for (int col=0; col<3; col++) {
        int idx = row*3 + col;
        float x = width/2 - sizeOfInputArea/2 + col*cellW;
        float y = height/2 - (2*scaleH-1) * sizeOfInputArea/2 + row*cellH; // shifted down for proper text display

        fill(240);
        rect(x, y, cellW, cellH);

        // vertical letters
        fill(0);
        textAlign(CENTER, CENTER);
        for (int i=0; i<t9Groups[idx].length; i++) {
          float yOffset = y + (i+1) * (cellH / (t9Groups[idx].length+1));
          String label = t9Groups[idx][i];
          if (label.equals("_")) label = "␣"; // draw space symbol
          text(label, x + cellW/2, yOffset);
        }
      }
    }

    noStroke();
  }
}


boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h);
}


//void mousePressed()
//{
//  float cellW = sizeOfInputArea/3;
//  float cellH = sizeOfInputArea/3;

//  // check T9 buttons
//  for (int row=0; row<3; row++) {
//    for (int col=0; col<3; col++) {
//      int idx = row*3 + col;
//      float x = width/2 - sizeOfInputArea/2 + col*cellW;
//      float y = height/2 - sizeOfInputArea/2 + row*cellH;

//      if (didMouseClick(x, y, cellW, cellH)) {
//        // cycle inside group and immediately append
//        groupIndices[idx] = (groupIndices[idx] + 1) % t9Groups[idx].length;
//        String chosen = t9Groups[idx][ groupIndices[idx] ];
//        if (chosen.equals("_")) {
//          currentTyped += " ";   // treat "_" as space
//        } else {
//          currentTyped += chosen;
//        }
//        lastTapped = idx;
//        return;
//      }
//    }
//  }

//  // NEXT button
//  if (didMouseClick(width-200, height-200, 200, 200)) {
//    nextTrial();
//  }
//}

// Track start position of the swipe
float startX, startY;

// track which cell started
int startCellIdx = -1; 

void mousePressed() {
  startX = mouseX;
  startY = mouseY;

  // Figure out which button the press started in
  float cellW = sizeOfInputArea / 3;
  float cellH = sizeOfInputArea / 3;
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      int idx = row * 3 + col;
      float x = width / 2 - sizeOfInputArea / 2 + col * cellW;
      float y = height / 2 - sizeOfInputArea / 2 + row * cellH;
      if (didMouseClick(x, y, cellW, cellH)) {
        startCellIdx = idx; // store the starting button
        return;
      }
    }
  }

  // NEXT button
  if (didMouseClick(width - 200, height - 200, 200, 200)) {
    startCellIdx = -2; // special value for NEXT
  }
}

void mouseReleased() {
  if (startCellIdx == -1) return; // no button pressed

  if (startCellIdx == -2) { // NEXT button
    nextTrial();
    startCellIdx = -1;
    return;
  }
  
  float dx = mouseX - startX;
  float dy = mouseY - startY;

  // Threshold to differentiate a swipe from a tap
  float threshold = 20; // pixels
  int direction; // 0 = up, 1 = tap/middle, 2 = down

  if (dy < -threshold) direction = 0;
  else if (dy > threshold) direction = 2;
  else direction = 1;

  // Use startCellIdx for the correct button
  if (direction < t9Groups[startCellIdx].length) {
    String chosen = t9Groups[startCellIdx][direction];
    if (chosen.equals("_")) chosen = " ";
    currentTyped += chosen;
    lastTapped = startCellIdx;
  }

  startCellIdx = -1; // reset cell selection
}

//this was to figure out direction which we don't need in the same way anymore
//void handleT9Input(int direction) {
//  float cellW = sizeOfInputArea / 3;
//  float cellH = sizeOfInputArea / 3;

//  // Check T9 buttons
//  for (int row = 0; row < 3; row++) {
//    for (int col = 0; col < 3; col++) {
//      int idx = row * 3 + col;
//      float x = width / 2 - sizeOfInputArea / 2 + col * cellW;
//      float y = height / 2 - sizeOfInputArea / 2 + row * cellH;

//      if (didMouseClick(x, y, cellW, cellH)) {
//        // Map swipe direction to letter
//        if (direction < t9Groups[idx].length) {
//          String chosen = t9Groups[idx][direction];
//          if (chosen.equals("_")) chosen = " "; // treat "_" as space
//          currentTyped += chosen;
//          lastTapped = idx;
//        }
//        return;
//      }
//    }
//  }

//  // Check NEXT button
//  if (didMouseClick(width - 200, height - 200, 200, 200)) {
//    nextTrial();
//  }
//}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) return;

  if (startTime!=0 && finishTime==0)
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum);
    System.out.println("Target phrase: " + currentPhrase);
    System.out.println("Phrase length: " + currentPhrase.length());
    System.out.println("User typed: " + currentTyped);
    System.out.println("User typed length: " + currentTyped.length());
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim()));
    System.out.println("Time taken on this trial: " + (millis()-lastTime));
    System.out.println("Time taken since beginning: " + (millis()-startTime));
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1)
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!");
    System.out.println("Total time taken: " + (finishTime - startTime)/1000 + "s");
    System.out.println("Total letters entered: " + lettersEnteredTotal);
    System.out.println("Total letters expected: " + lettersExpectedTotal);
    System.out.println("Total errors entered: " + errorsTotal);

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f);
    float freebieErrors = lettersExpectedTotal*.05;
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;

    System.out.println("Raw WPM: " + wpm);
    System.out.println("Freebie errors: " + freebieErrors);
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty));
    System.out.println("==================");

    currTrialNum++;
    return;
  }

  if (startTime==0)
  {
    System.out.println("Trials beginning! Starting timer...");
    startTime = millis();
  } else currTrialNum++;

  lastTime = millis();
  currentTyped = "";
  currentPhrase = phrases[currTrialNum];
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}


int computeLevenshteinDistance(String phrase1, String phrase2)
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];
  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(
        min(distance[i - 1][j] + 1, distance[i][j - 1] + 1),
        distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1)
      );

  return distance[phrase1.length()][phrase2.length()];
}
