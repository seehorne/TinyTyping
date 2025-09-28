import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

import ketai.sensors.*;  // <<< Ketai library
//import processing.sound.*; //sound library
import android.media.SoundPool;
import android.media.AudioAttributes;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;

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
float scaleH = 0.9;
final float sizeOfInputArea = DPIofYourDeviceScreen*1;
PImage watch;
PFont font;

// ========== QWERTY-T9 groups ==========
String[][] t9Groups = {
  {"w ↑","e •","r ↓"}, {"t ↑","y •","u ↓"}, {"i ↑","o •","p ↓"},
  {"a ↑","s •","d ↓"}, {"f ↑","g •","h ↓"}, {"j ↑","k •","l ↓"},
  {"z ↑","x •","c ↓"}, {"v ↑","b •","n ↓"}, {"m ↑","q •","_ ↓"}
};

int[] groupIndices = new int[9];
int lastTapped = -1;

// ====== Ketai orientation sensor ======
KetaiSensor sensor;

float yaw = 0;   // azimuth (z-axis)
float pitch = 0; // x-axis
float roll = 0;  // y-axis

float[] g = new float[3];   // gravity (accelerometer)
float[] m = new float[3];   // geomagnetic (magnetometer)
boolean hasAccel = false;
boolean hasMag = false;

// --- yaw-based delete tracking ---
ArrayList<Float> yawHistory = new ArrayList<Float>();
ArrayList<Integer> timeHistory = new ArrayList<Integer>();
float yawThreshold = radians(8); // ~8 degrees
int windowMillis = 500; // lookback window (0.5s)
int lastDeleteTime = 0;       // time of last delete
int deleteBlockWindow = 1000; // ms block all checks after delete

// Delete feedback animation
int deleteFlashTime = 0;
int deleteFlashDuration = 300; // ms
float deleteFlashX = 0;
float deleteFlashY = 0;


// ========== audio ==========
SoundPool sp;
int aId = -1;
int bId = -1;
int cId = -1;
int dId = -1;
int eId = -1;
int fId = -1;
int gId = -1;
int hId = -1;
int iId = -1;
int jId = -1;
int kId = -1;
int lId = -1;
int mId = -1;
int nId = -1;
int oId = -1;
int pId = -1;
int qId = -1;
int rId = -1;
int sId = -1;
int tId = -1;
int uId = -1;
int vId = -1;
int wId = -1;
int xId = -1;
int yId = -1;
int zId = -1;
int spaceId = -1;
int deleteId = -1;

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

  // ========== audio ==========
  //ASound = new SoundFile(this, "a.wav");
// Old constructor works in Processing's Android mode
  sp = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);

  try {
    // getActivity() gives us the Android Context
    AssetFileDescriptor aafd = getActivity().getAssets().openFd("a.wav");
    aId = sp.load(aafd, 1);
    
    AssetFileDescriptor bafd = getActivity().getAssets().openFd("b.wav");
    bId = sp.load(bafd, 1);
    
    AssetFileDescriptor cafd = getActivity().getAssets().openFd("c.wav");
    cId = sp.load(cafd, 1);
    
    AssetFileDescriptor dafd = getActivity().getAssets().openFd("d.wav");
    dId = sp.load(dafd, 1);
    
    AssetFileDescriptor eafd = getActivity().getAssets().openFd("e.wav");
    eId = sp.load(eafd, 1);
    
    AssetFileDescriptor fafd = getActivity().getAssets().openFd("f.wav");
    fId = sp.load(fafd, 1);
    
    AssetFileDescriptor gafd = getActivity().getAssets().openFd("g.wav");
    gId = sp.load(gafd, 1);
    
    AssetFileDescriptor hafd = getActivity().getAssets().openFd("h.wav");
    hId = sp.load(hafd, 1);
    
    AssetFileDescriptor iafd = getActivity().getAssets().openFd("i.wav");
    iId = sp.load(iafd, 1);
    
    AssetFileDescriptor jafd = getActivity().getAssets().openFd("j.wav");
    jId = sp.load(jafd, 1);
    
    AssetFileDescriptor kafd = getActivity().getAssets().openFd("k.wav");
    kId = sp.load(kafd, 1);
    
    AssetFileDescriptor lafd = getActivity().getAssets().openFd("l.wav");
    lId = sp.load(lafd, 1);
    
    AssetFileDescriptor mafd = getActivity().getAssets().openFd("m.wav");
    mId = sp.load(mafd, 1);
    
    AssetFileDescriptor nafd = getActivity().getAssets().openFd("n.wav");
    nId = sp.load(nafd, 1);
    
    AssetFileDescriptor oafd = getActivity().getAssets().openFd("o.wav");
    oId = sp.load(oafd, 1);
    
    AssetFileDescriptor pafd = getActivity().getAssets().openFd("p.wav");
    pId = sp.load(pafd, 1);
    
    AssetFileDescriptor qafd = getActivity().getAssets().openFd("q.wav");
    qId = sp.load(qafd, 1);
    
    AssetFileDescriptor rafd = getActivity().getAssets().openFd("r.wav");
    rId = sp.load(rafd, 1);
    
    AssetFileDescriptor safd = getActivity().getAssets().openFd("s.wav");
    sId = sp.load(safd, 1);
    
    AssetFileDescriptor tafd = getActivity().getAssets().openFd("t.wav");
    tId = sp.load(tafd, 1);
    
    AssetFileDescriptor uafd = getActivity().getAssets().openFd("u.wav");
    uId = sp.load(uafd, 1);
    
    AssetFileDescriptor vafd = getActivity().getAssets().openFd("v.wav");
    vId = sp.load(vafd, 1);
    
    AssetFileDescriptor wafd = getActivity().getAssets().openFd("w.wav");
    wId = sp.load(wafd, 1);
    
    AssetFileDescriptor xafd = getActivity().getAssets().openFd("x.wav");
    xId = sp.load(xafd, 1);
    
    AssetFileDescriptor yafd = getActivity().getAssets().openFd("y.wav");
    yId = sp.load(yafd, 1);
    
    AssetFileDescriptor zafd = getActivity().getAssets().openFd("z.wav");
    zId = sp.load(zafd, 1);
    
    AssetFileDescriptor spaceafd = getActivity().getAssets().openFd("space.wav");
    spaceId = sp.load(spaceafd, 1);
    
    AssetFileDescriptor deleteafd = getActivity().getAssets().openFd("delete.wav");
    deleteId = sp.load(deleteafd, 1);
    
  } catch (Exception e) {
    e.printStackTrace();
  }

  // initialize Ketai
  sensor = new KetaiSensor(this);
  sensor.start();
}


void draw()
{
  background(255);

  // --- always print live orientation data to console ---
  println("Yaw:   " + degrees(yaw));
  println("Pitch: " + degrees(pitch));
  println("Roll:  " + degrees(roll));

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

    // typed string display
    textFont(font, 36);
    float maxW = sizeOfInputArea - 110;
    String displayStr = currentTyped;
    if (textWidth(displayStr) > maxW) {
      String ellipsis = "...";
      for (int i = 0; i < displayStr.length(); i++) {
        String candidate = ellipsis + displayStr.substring(i);
        if (textWidth(candidate) <= maxW) {
          displayStr = candidate;
          break;
        }
      }
    }

    fill(255);
    textAlign(LEFT, CENTER);
    text("Typed: " + displayStr, width/2 - sizeOfInputArea/2,
         height/2 - (2*scaleH-1)*sizeOfInputArea/2 - 28);
    textFont(font);

    // --- delete flash effect ---
    if (millis() - deleteFlashTime < deleteFlashDuration) {
      float alpha = map(millis() - deleteFlashTime, 0, deleteFlashDuration, 255, 0);
      fill(255, 0, 0, alpha);
      noStroke();
      ellipse(deleteFlashX + 10, deleteFlashY - 10, 30, 30); 
    }

    // draw T9 grid
    float cellW = sizeOfInputArea/3;
    float cellH = sizeOfInputArea/3 * scaleH;

    stroke(0);
    strokeWeight(3);

    for (int row=0; row<3; row++) {
      for (int col=0; col<3; col++) {
        int idx = row*3 + col;
        float x = width/2 - sizeOfInputArea/2 + col*cellW;
        float y = height/2 - (2*scaleH-1) * sizeOfInputArea/2 + row*cellH;

        fill(240);
        rect(x, y, cellW, cellH);

        fill(0);
        textAlign(CENTER, CENTER);
        for (int i=0; i<t9Groups[idx].length; i++) {
          float yOffset = y + (i+1) * (cellH / (t9Groups[idx].length+1));
          String label = t9Groups[idx][i];
          if (label.equals("_")) label = "␣";
          text(label, x + cellW/2, yOffset);
        }
      }
    }
    noStroke();
  }

  // --- check yaw for delete trigger ---
  checkYawDelete();
}


boolean didMouseClick(float x, float y, float w, float h)
{
  return (mouseX>x && mouseX<x+w && mouseY>y && mouseY<y+h);
}

// --- swipe tracking ---
float startX, startY;
int startCellIdx = -1; 

void mousePressed() {
  startX = mouseX;
  startY = mouseY;

  float cellW = sizeOfInputArea / 3;
  float cellH = sizeOfInputArea / 3;
  for (int row = 0; row < 3; row++) {
    for (int col = 0; col < 3; col++) {
      int idx = row * 3 + col;
      float x = width / 2 - sizeOfInputArea / 2 + col * cellW;
      float y = height / 2 - sizeOfInputArea / 2 + row * cellH;
      if (didMouseClick(x, y, cellW, cellH)) {
        startCellIdx = idx;
        return;
      }
    }
  }

  if (didMouseClick(width - 200, height - 200, 200, 200)) {
    startCellIdx = -2;
  }
}

void mouseReleased() {
  if (startCellIdx == -1) return;

  if (startCellIdx == -2) {
    nextTrial();
    startCellIdx = -1;
    return;
  }
  
  float dx = mouseX - startX;
  float dy = mouseY - startY;

  float threshold = 20;
  int direction;

  if (dy < -threshold) direction = 0;
  else if (dy > threshold) direction = 2;
  else direction = 1;

  if (direction < t9Groups[startCellIdx].length) {
    String chosen = t9Groups[startCellIdx][direction];
    if (chosen.equals("_ ↓")){
      chosen = " ";
      //parameter explanation:
      //first: int, soundID, which sound to play
      //second: int, left volume, volume from left speaker, 1 for max
      //third: int, right volume, volume from right speaker, 1 for max
      //fourth: int, priority, 1 to make it not get cut off
      //fifth: int, how many times to play, 1 to make it play once per key
      //rate: playback speed, 1= normal, 0.75 slightly slow, 1.25 slightly fast
      sp.play(spaceId, 1, 1, 1, 0, 1);
    } else {
      chosen = chosen.substring(0, 1); //so we dont get the arrow or dot
      if (chosen.equals("a")){
        sp.play(aId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("b")){
        sp.play(bId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("c")){
        sp.play(cId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("d")){
        sp.play(dId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("e")){
        sp.play(eId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("f")){
        sp.play(fId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("g")){
        sp.play(gId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("h")){
        sp.play(hId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("i")){
        sp.play(iId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("j")){
        sp.play(jId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("k")){
        sp.play(kId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("l")){
        sp.play(lId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("m")){
        sp.play(mId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("n")){
        sp.play(nId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("o")){
        sp.play(oId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("p")){
        sp.play(pId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("q")){
        sp.play(qId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("r")){
        sp.play(rId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("s")){
        sp.play(sId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("t")){
        sp.play(tId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("u")){
        sp.play(uId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("v")){
        sp.play(vId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("w")){
        sp.play(wId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("x")){
        sp.play(xId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("y")){
        sp.play(yId, 1, 1, 1, 0, 1);
      } else if (chosen.equals("z")){
        sp.play(zId, 1, 1, 1, 0, 1);
      }
    }
    currentTyped += chosen;
    lastTapped = startCellIdx;
  }

  startCellIdx = -1;
}


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

void onAccelerometerEvent(float x, float y, float z) {
  // Low-pass filter for smoother gravity
  final float alpha = 0.8;
  g[0] = alpha * g[0] + (1 - alpha) * x;
  g[1] = alpha * g[1] + (1 - alpha) * y;
  g[2] = alpha * g[2] + (1 - alpha) * z;
  hasAccel = true;
  computeOrientation();
}

void onMagneticFieldEvent(float x, float y, float z) {
  m[0] = x;
  m[1] = y;
  m[2] = z;
  hasMag = true;
  computeOrientation();
}

// ====== Ketai callback ======
void computeOrientation() {
  if (hasAccel && hasMag) {
    float[] R = new float[9];
    float[] I = new float[9];
    if (android.hardware.SensorManager.getRotationMatrix(R, I, g, m)) {
      float[] orientation = new float[3];
      android.hardware.SensorManager.getOrientation(R, orientation);
      yaw   = orientation[0];
      pitch = orientation[1];
      roll  = orientation[2];
    }
  }
}

// --- check for yaw-triggered delete ---
void checkYawDelete() {
  int now = millis();

  // Skip checking entirely if delete happened recently
  if (now - lastDeleteTime < deleteBlockWindow) {
    return;
  }

  yawHistory.add(yaw);
  timeHistory.add(now);

  // keep only last windowMillis worth of history
  while (timeHistory.size() > 0 && now - timeHistory.get(0) > windowMillis) {
    timeHistory.remove(0);
    yawHistory.remove(0);
  }

  if (yawHistory.size() > 1) {
    float oldestYaw = yawHistory.get(0);
    float diff = absAngleDiff(yaw, oldestYaw);
    if (diff > yawThreshold) {
      if (currentTyped.length() > 0) {
        currentTyped = currentTyped.substring(0, currentTyped.length()-1);
        println("[DELETE] Triggered. Δyaw=" + degrees(diff));
        //play delete sound
        sp.play(deleteId, 1, 1, 1, 0, 1);
        // Record flash position at end of typed text
        float maxW = sizeOfInputArea - 110;
        String displayStr = currentTyped;
        if (textWidth(displayStr) > maxW) {
          String ellipsis = "...";
          for (int i = 0; i < displayStr.length(); i++) {
            String candidate = ellipsis + displayStr.substring(i);
            if (textWidth(candidate) <= maxW) {
              displayStr = candidate;
              break;
            }
          }
        }
        deleteFlashX = width/2 - sizeOfInputArea/2 + textWidth("Typed: " + displayStr);
        deleteFlashY = height/2 - (2*scaleH-1)*sizeOfInputArea/2 - 28;
        deleteFlashTime = millis();
      }
      lastDeleteTime = now;   // mark time of delete
    }
  }
}

// --- angle difference helper ---
float absAngleDiff(float a, float b) {
  float d = a - b;
  while (d > PI) d -= TWO_PI;
  while (d < -PI) d += TWO_PI;
  return abs(d);
}
