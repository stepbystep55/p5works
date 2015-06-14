import de.voidplus.soundcloud.*;
import ddf.minim.*;
import ddf.minim.analysis.*;

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

public class NoiseArray {
  int[] arr = null;
  int curIdx = 0;
  public NoiseArray (int[] arr) {
    this.arr = arr;
    this.curIdx = (int)random(this.arr.length - 1);
  }
  public int pop () {
    this.curIdx = this.curIdx + ((0 < random(-1, 1)) ? 1 : -1);
    if (this.arr.length <= this.curIdx) this.curIdx = this.arr.length - 2;
    if (this.curIdx < 0) this.curIdx = 1;
    return this.arr[curIdx];
  }
}

public class Spherable {
  ArrayList<PVector> coords = new ArrayList<PVector>();
  ArrayList<PVector> coords4base = new ArrayList<PVector>();

  float radius = 256;
  public Spherable() {
    float angleUnit = TWO_PI / 15;

    for(int i = 0; i < PI / angleUnit; i++) {
      for(int k = 0; k < TWO_PI / angleUnit; k++) {
        float ang1 = (angleUnit * i) + (k * pow(angleUnit, 2) / TWO_PI);
        float ang2 = angleUnit * k;
        PVector vector = new PVector(
          radius * sin(ang1) * cos(ang2)
          , radius * sin(ang1) * sin(ang2)
          , radius * cos(ang1)
        );
        coords.add(vector);
      }
    }
    float angleUnit4base = TWO_PI / 12;
    for(int i = 0; i < PI / angleUnit4base; i++) {
      for(int k = 0; k < TWO_PI / angleUnit4base; k++) {
        float ang1 = (angleUnit4base * i) + (k * pow(angleUnit4base, 2) / TWO_PI);
        float ang2 = angleUnit4base * k;
        PVector vector = new PVector(
          radius * sin(ang1) * cos(ang2)
          , radius * sin(ang1) * sin(ang2)
          , radius * cos(ang1)
        );
        coords4base.add(vector);
      }
    }
  }

  PVector vector4rotate = new PVector(random(0, TWO_PI), random(0, TWO_PI), random(0, TWO_PI));
  PVector velocity4rotate = new PVector(0.001, 0.001, 0.001);
  PVector acceleration4rotate = new PVector(0, 0, 0);
  PVector stopper4rotate = new PVector(0.004, 0.004, 0.004);
  int blowCount = 0;
  float blowMagnitude = 0;
  NoiseArray blowGaps = new NoiseArray(new int[]{8, 10, 12, 20, 24});
  int blowGap = 24;
  int snareCount = 0;
  int kickCount = 0;
  public void update(boolean isKick, boolean isSnare, boolean isHat) {
    --blowCount;
    //if (isKick) {
    if (isKick) {
    //if (isSnare) {
      //if (++snareCount % 4 == 0) {
      if (++kickCount % 4 == 0) {
        acceleration4rotate.x = random(0.056, 0.128);
        acceleration4rotate.y = random(0.056, 0.128);
        acceleration4rotate.z = random(0.056, 0.128);
      }
    }
    if (isSnare) {
    //if (isHat) {
      if (blowCount <= 0) {
        blowCount = 56;
        blowMagnitude = random(1, 8);
        blowGap = blowGaps.pop();
      }
    }
    vector4rotate.add(PVector.add(velocity4rotate, acceleration4rotate));
    if (0 < acceleration4rotate.mag()) {
      //acceleration4rotate.sub(stopper4rotate);
      acceleration4rotate.mult(0.96);
    }
    if (acceleration4rotate.mag() <= 0) {
      acceleration4rotate.x = 0;
      acceleration4rotate.y = 0;
      acceleration4rotate.z = 0;
    }
  }

  float baseMagnitude = 8;
  public void render() {
    rotateX(vector4rotate.x);
    rotateY(vector4rotate.y);
    rotateZ(vector4rotate.z);

    if (blowCount > 0) {
      strokeWeight(3);
      stroke(color(3, 100, 70));
      fill(color(3, 100, 100));
      for(int i = 1; i < coords.size() - 1; i++) {
        if (i % blowGap == 0) {
          beginShape();
          vertex(coords.get(i - 1).x , coords.get(i - 1).y, coords.get(i - 1).z);
          vertex(coords.get(i + 1).x , coords.get(i + 1).y, coords.get(i + 1).z);
          vertex(coords.get(i).x * blowMagnitude, coords.get(i).y * blowMagnitude, coords.get(i).z * blowMagnitude);
          endShape(CLOSE);
        }
      }
    }

    strokeWeight(3);
    stroke(color(12, 100, 0));
    fill(color(12, 100, 20));
    for(int i = 1; i < coords4base.size(); i++) {
      if (i % 18 == 0) {
        beginShape();
        vertex(coords4base.get(i - 1).x * baseMagnitude, coords4base.get(i - 1).y * baseMagnitude, coords4base.get(i - 1).z * baseMagnitude);
        vertex(coords4base.get(i + 1).x * baseMagnitude, coords4base.get(i + 1).y * baseMagnitude, coords4base.get(i + 1).z * baseMagnitude);
        vertex(0, 0, 0);
        endShape(CLOSE);
      }
    }

  }
}

AudioPlayer audioPlayer;
BeatDetect beatDetect;
BeatDetect energyDetect;
BeatListener beatListener;
String SC_CLIENT_ID = "3c0b5ed40e9c5fc004af19c6a02d251b";
String SC_CLIENT_SECRET = "a5d4f66abe65aad74fa0990b75ee1fc3";
//int detectMode = BeatDetect.SOUND_ENERGY;
//int detectMode = BeatDetect.FREQ_ENERGY;

void setupAudio() {
  Track track = new SoundCloud(SC_CLIENT_ID, SC_CLIENT_SECRET).getTrack(203092203);
  //Track track = new SoundCloud(SC_CLIENT_ID, SC_CLIENT_SECRET).getTrack(206961360);
  //Track track = new SoundCloud(SC_CLIENT_ID, SC_CLIENT_SECRET).getTrack(203092366);
  //Track track = new SoundCloud(SC_CLIENT_ID, SC_CLIENT_SECRET).getTrack(200491875);

  audioPlayer = new Minim(this).loadFile(track.getStreamUrl(), 2048);

  //if (detectMode == BeatDetect.FREQ_ENERGY) {
    beatDetect = new BeatDetect(audioPlayer.bufferSize(), audioPlayer.sampleRate());
    beatListener = new BeatListener(beatDetect, audioPlayer);
  //} else {
    energyDetect = new BeatDetect();
  //}
  //beatDetect.setSensitivity(50);
}


public class RandomTranslator {
  int changingTranslaionCount = 0;
  float translationX, translationY, translationZ;
  float nextTranslationX, nextTranslationY, nextTranslationZ;
  float easing = 0.1;
  float sketchWidth, sketchHeight;

  public RandomTranslator(float sketchWidth, float sketchHeight) {
    this.sketchWidth = sketchWidth;
    this.sketchHeight = sketchHeight;
    changingTranslaionCount = (int)random(128, 512);
    translationX = sketchWidth / 2;
    translationY = sketchHeight / 2;
    translationZ = 0;
    nextTranslationX = translationX;
    nextTranslationY = translationY;
    nextTranslationZ = translationZ;
  }
  public void doit(int drawCount) {
    if (drawCount == changingTranslaionCount) {
      changingTranslaionCount += (int)random(128, 256);
      nextTranslationX = sketchWidth / 2 + random(-sketchWidth / 4, sketchWidth / 4);
      nextTranslationY = sketchHeight / 2 + random(-sketchHeight / 4, sketchHeight / 4);
      //nextTranslationZ = random(-sketchWidth / 4, sketchWidth / 4);
      nextTranslationZ = random(0, sketchWidth / 4);
      //nextTranslationZ = random(0, sketchWidth / 4);
    }
    float distanceX = nextTranslationX - translationX;
    if (abs(distanceX) > 0) translationX += distanceX * easing;
    float distanceY = nextTranslationY - translationY;
    if (abs(distanceY) > 0) translationY += distanceY * easing;
    float distanceZ = nextTranslationZ - translationZ;
    if (abs(distanceZ) > 0) translationZ += distanceZ * easing;

    translate(translationX, translationY, translationZ);
  }
}

RandomTranslator translator;
Spherable tama = new Spherable();
void setup() {
  colorMode(HSB, 100);
  size(1024, 768, P3D);
  //background(24);
  background(color(12, 100, 100));
  setupAudio();
  translator = new RandomTranslator(1024, 768);
}

int drawCount = 0;
void draw() {
  ++drawCount;
  //background(16);
  background(color(12, 100, 100));
  translator.doit(drawCount);
  tama.update(
    beatDetect.isKick(),
    beatDetect.isSnare(),
    beatDetect.isHat()
  );
  tama.render();
}

void keyPressed() {
  if (keyCode == ENTER) {
    if (audioPlayer.isPlaying()) {
      audioPlayer.pause();
      noLoop();
    } else { // isMuted()
      audioPlayer.play();
      loop();
    }
  }
}
