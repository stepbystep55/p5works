import de.voidplus.soundcloud.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;

AudioPlayer audioPlayer;
BeatDetect beatDetect;
BeatListener beatListener;
String SC_CLIENT_ID = "3c0b5ed40e9c5fc004af19c6a02d251b";
String SC_CLIENT_SECRET = "a5d4f66abe65aad74fa0990b75ee1fc3";

public class BeatListener implements AudioListener {
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source) {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps) {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR) {
    beat.detect(source.mix);
  }
}

//int detectMode = BeatDetect.SOUND_ENERGY;
int detectMode = BeatDetect.FREQ_ENERGY;

void setupAudio() {
  Track track = new SoundCloud(SC_CLIENT_ID, SC_CLIENT_SECRET).getTrack(183320737);

  audioPlayer = new Minim(this).loadFile(track.getStreamUrl(), 1024);

  if (detectMode == BeatDetect.FREQ_ENERGY) {
    beatDetect = new BeatDetect(audioPlayer.bufferSize(), audioPlayer.sampleRate());
    beatListener = new BeatListener(beatDetect, audioPlayer);
  } else {
    beatDetect = new BeatDetect();
  }
  //beatDetect.setSensitivity(50);
}

public class Linear {
  boolean alive = true;
  float weight = 1;
  boolean isVertical = true;
  float alpha = 255;
  PVector startLocation, endLocation;
  static final int GROWING = 0;
  static final int MATURING = 1;
  static final int ENDING = 2;
  int mode = GROWING;
  float length = 0;
  static final float SPEED = 96;
  public static final int ENDING_PATTERN_FADING = 0;
  public static final int ENDING_PATTERN_SHRINKING = 1;
  int endingPattern = ENDING_PATTERN_FADING;
  int direction = 1;
  float rgbR = 0;
  float rgbG = 0;
  float rgbB = 0;
  float quadrant = 0;

  public Linear(float startPosition, float quadrant, float weight, int endingPattern, int direction, boolean colored) {
    this.quadrant =quadrant;
    this.weight = weight;
    this.isVertical = isVertical;
    this.direction = direction;
    if (colored) {
      this.rgbR = random(255);
      this.rgbG = random(255);
      this.rgbB = random(255);
    }
    this.endingPattern = endingPattern;

    if (quadrant == 0) {
      float y = (0 < direction) ? 0 : height;
      this.startLocation = new PVector(startPosition, y);
      this.endLocation = new PVector(startPosition, y);
    } else if (quadrant == 1) {
      float x = (0 < direction) ? 0 : width;
      this.startLocation = new PVector(x, startPosition + height / 2);
      this.endLocation = new PVector(x, startPosition + height / 2);
    } else if (quadrant == 2) {
      float y = (0 < direction) ? 0 : height;
      this.startLocation = new PVector(startPosition + width / 2, y);
      this.endLocation = new PVector(startPosition + width / 2, y);
    } else {
      float x = (0 < direction) ? 0 : width;
      this.startLocation = new PVector(x, startPosition);
      this.endLocation = new PVector(x, startPosition);
    }
  }

  int maturedCount = 64;
  public boolean update() {
    if (!alive) return alive;

    if (mode == GROWING) {
      length += SPEED;
      if (quadrant % 2 == 0) {
        this.endLocation.y = (0 < direction) ? length : height - length;
        if (height < length) mode = MATURING;
      } else {
        this.endLocation.x = (0 < direction) ? length : width - length;
        if (width < length) mode = MATURING;
      }
    } else if (mode == MATURING) {
      if (maturedCount-- < 0) mode = ENDING;
    } else {
      if (endingPattern == ENDING_PATTERN_FADING) {
        alpha -= 24;
        if (alpha < 0) alive = false;
      } else {
        length -= SPEED;
        if (quadrant % 2 == 0) {
          this.endLocation.y = (0 < direction) ? length : height - length;
        } else {
          this.endLocation.x = (0 < direction) ? length : width - length;
        }
        if (length < 0) alive = false;
      }
    }
    return alive;
  }
  public void draw() {
    strokeWeight(weight);
    strokeCap(SQUARE);
    stroke(rgbR, rgbG, rgbB, alpha);
    line(startLocation.x, startLocation.y, endLocation.x, endLocation.y);
  }
}

public class Lines {
  static final int MAX_LINES_LENGTH = 4;
  Linear[] lines = new Linear[(int)random(1, MAX_LINES_LENGTH)];

  public Lines(int quadrant) {

    float maxWidth = quadrant % 2 == 0 ? width / 2 : height / 2;
    float maxLineWeight = maxWidth / MAX_LINES_LENGTH + 6;
    float distanceBetweenLines = random(2, maxLineWeight / 6);
    float[] weightArr = new float[lines.length];
    float totallength = 0;
    for (int i = 0; i < weightArr.length; i++) {
      weightArr[i] = random(1, maxLineWeight);
      totallength += weightArr[i];
    }
    totallength += distanceBetweenLines * (weightArr.length - 1);

    int coloredIndex = (5 < random(6)) ? (int)random(lines.length - 1) : -1;
    int endingPattern = (0 < random(-1, 1)) ? Linear.ENDING_PATTERN_FADING : Linear.ENDING_PATTERN_SHRINKING;
    int direction = (0 < random(-1, 1)) ? 1 : -1;
    boolean isVertical = quadrant % 2 == 0 ? true : false;

    float previousWeight = 0;
    float startPosition = random(weightArr[0] / 2, maxWidth - (totallength - weightArr[0] / 2));
    float previousStartPosition = startPosition;
    for (int i = 0; i < weightArr.length; i++) {
      if (i != 0) startPosition = previousStartPosition + previousWeight / 2 + distanceBetweenLines + weightArr[i] / 2;
      lines[i] = new Linear(startPosition, quadrant, weightArr[i], endingPattern, direction, coloredIndex == i);
      previousWeight = weightArr[i];
      previousStartPosition = startPosition;
    }
  }
  boolean alive = true;
  public boolean update() {
    if (!alive) return alive;

    boolean anyAlive = false;
    for (int i = 0; i < lines.length; i++) {
      boolean lineAlive = lines[i].update();
      if (lineAlive) anyAlive = true;
    }
    if (!anyAlive) alive = false;
    return alive;
  }

  public void draw() {
    for (int i = 0; i < lines.length; i++) lines[i].draw();
  }
}

public class RandomLoop {
  ArrayList<Integer> queue = new ArrayList<Integer>(0);
  public RandomLoop(int queueWidth) {
    for (int i = 0; i < queueWidth; i++) queue.add(i);
  }
  public int next() {
    int ret = queue.remove(0);
    queue.add(ret);
    return ret;
  }
}
ArrayList<Lines> linesList = new ArrayList<Lines>();
RandomLoop randomLoop = new RandomLoop(4);
void setup() {
  size(1024, 768);
  background(255);
  setupAudio();
  //audioPlayer.play();
}

int beatCount = 0;
int tippingCount = 1;

void draw() {
  background(255);

  boolean onBeat = false;
  if (detectMode == BeatDetect.FREQ_ENERGY) {
    if (beatDetect.isKick()) onBeat = true;
  } else {
    beatDetect.detect(audioPlayer.mix);
    if (beatDetect.isOnset()) onBeat = true;
  }

  beatDetect.detect(audioPlayer.mix);
  if (onBeat) {
    ++beatCount;
    if (beatCount == tippingCount) {
      linesList.add(new Lines(randomLoop.next()));
      tippingCount += 8;//(int)random(8, 16);
    }
  }
  for (Iterator<Lines> itr = linesList.iterator(); itr.hasNext(); ) {
    Lines lines = itr.next();
    if (!lines.update()) itr.remove();
    lines.draw();
  }
}

void mouseClicked() {
  if (audioPlayer.isPlaying()) {
    audioPlayer.pause();
    noLoop();
  } else { // isMuted()
    audioPlayer.play();
    loop();
  }
}