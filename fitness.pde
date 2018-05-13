
/*https://color.adobe.com/de/Colors-color-theme-10336674/edit/?copy=true*/

// Einbeziehen des minim-Audio-Toolkits
import ddf.minim.*;
// Instanz der minim Bibliothek
Minim minim;
// Instanz die das geladene Audiodokument repraesentiert
AudioPlayer coinSound;

Circle myCircleBody = new Circle(200, 200, 11);

int activator = 0;
int counter = 0;
int textCounter = 0;

private static final byte countdown = 60;
private static int seconds, startTime;

int collissionCircle;
color c1, c2, c3, c4, c5;

final int NWAVES=1;              //Number of full waves (1 wave=1 cycle=360 deg) to display across the width
final float FREQ=4.0;            //Frequency in Hz
float DELTA=radians(10);         //Delta angle (in radians) for phase shifting (Wave speed)
final float AMPLITUDE=50;

final int BASE_RAD=20;
final int INN_RAD=15;

float xpos;
float ang=0;
float BodyX;
float BodyY;
float text1=0;
float text2=0;
float text3=0;

void setupFitness() {
  xpos=width/2;  
  frameRate(60);
  startTime = millis()/1000 + countdown + 33;

  c1 = color(41, 44, 68);
  c2 = color(79, 128, 225);
  c3 = color(255, 83, 73);
  c4 = color(240, 240, 241);
  c5 = color(240, 240, 241, 75);

  // Audiotoolkit erstellen
  minim = new Minim (this);
  // Audiodatei aus dem data-Ordner laden
  coinSound = minim.loadFile ("coin.wav");
}

void drawFitness() {
  context.update();
  if (userTorsoPosSet() || inputMode == InputMode.KEYBOARD) {
    setGradient(0, 0, width, height, c1, c2, 1);

    myCircleBody.x = BodyX; 
    myCircleBody.y = BodyY; 

    noStroke();
    fill(24, 205, 202);
    drawSine();

    drawCircles();

    if (activator<0) {
      counter++;
    } else if (activator>0) {
      counter=0;
    }

    if (counter>0 & counter<2 & seconds>0) {
      textCounter = textCounter+1;
      coinSound.play();
    }

    // println(textCounter); 
    renderFitnessScore();

    stroke(255); 
    line(0, 390, width, 390); 
    ang=ang-DELTA;   
    xpos=xpos-getSinusLambda()*DELTA/TWO_PI;  

    

    drawUserPosition(color(#FFBE43), 250);

    speedUp();

    seconds = startTime - millis()/1000;
    fill(255);

    checkEndOfFitness();
  } else {
    background(255);
    if(getTrackedSkeletonId(context) == -1) {
      renderNoUserText();
    } else {
      renderNotCalibratedText();
    }
  }
}

void drawSine() {
  for (float x = - BASE_RAD; x < width+BASE_RAD; x+=0.5) {
    float y = getCoinY(mapToSinus(x), -ang) ;  
    ellipse(x, y, BASE_RAD, BASE_RAD);
  } 
}

void drawCircles() {
  for (int i = 0; i < millis ()+1; i = i+160) {
    /* Kreise Mitte Rechts */
    Circle myCircle2 = new Circle(xpos+i, getCoinY(mapToSinus(xpos), -ang), INN_RAD/2);
    if (dist(myCircleBody.x, myCircleBody.y, myCircle2.x, myCircle2.y) < myCircleBody.r + myCircle2.r) { 
      fill(c5);
      /*activator = -4000;*/
    } else if (dist(myCircleBody.x, myCircleBody.y, myCircle2.x, myCircle2.y) > myCircleBody.r + myCircle2.r) { 
      fill(c5);
      /*activator++;*/
    } 
    myCircle2.render();   

    /* Kreise Unten */
    Circle myCircle3 = new Circle(xpos+i+40, getCoinY(mapToSinus(xpos), -ang)+AMPLITUDE, INN_RAD/2);
    if (dist(myCircleBody.x, myCircleBody.y, myCircle3.x, myCircle3.y) < myCircleBody.r + myCircle3.r) { 
      fill(c3);
      activator = -4000;
    } else if (dist(myCircleBody.x, myCircleBody.y, myCircle3.x, myCircle3.y) > myCircleBody.r + myCircle3.r) { 
      fill(c4);
      activator++;
    } 
    myCircle3.render();

    /* Kreise Oben */
    Circle myCircle4 = new Circle(xpos+i-40, getCoinY(mapToSinus(xpos), -ang)-AMPLITUDE, INN_RAD/2);
    if (dist(myCircleBody.x, myCircleBody.y, myCircle4.x, myCircle4.y) < myCircleBody.r + myCircle4.r) { 
      fill(c3); 
      activator = -4000;
    } else if (dist(myCircleBody.x, myCircleBody.y, myCircle4.x, myCircle4.y) > myCircleBody.r + myCircle4.r) { 
      fill(c4); 
      activator++;
    } 
    myCircle4.render();

    /* Kreise Mitte Links */
    Circle myCircle5 = new Circle(xpos+i-80, getCoinY(mapToSinus(xpos), -ang), INN_RAD/2);
    if (dist(myCircleBody.x, myCircleBody.y, myCircle5.x, myCircle5.y) < myCircleBody.r + myCircle5.r) { 
      fill(c5);
      /*activator = -4000;*/
    } else if (dist(myCircleBody.x, myCircleBody.y, myCircle5.x, myCircle5.y) > myCircleBody.r + myCircle5.r) { 
      fill(c5);
      /*activator++;*/
    } 
    myCircle5.render();
  }
}

void speedUp() {
  if (textCounter>20) {
    DELTA = radians(12);
    text1++;

    textAlign(CENTER, CENTER);
    textSize(40);

    if ( text1 < 255 ) {
      fill (255, 255-(text1*4));
    } else { 
      fill (255, 0);
    }
    text("SPEED UP 1", width/2, height/2);
  }

  if (textCounter>60) {
    DELTA = radians(14); 
    text2++;

    textAlign(CENTER, CENTER);
    textSize(40);

    if ( text2 < 255 ) {
      fill (255, 255-(text2*4));
    } else { 
      fill (255, 0);
    }
    text("SPEED UP 2", width/2, height/2);
  }

  if (textCounter>100) {
    DELTA = radians(16);
    text3++;

    textAlign(CENTER, CENTER);
    textSize(40);

    if ( text3 < 255 ) {
      fill (255, 255-(text3*4));
    } else { 
      fill (255, 0);
    }
    text("SPEED UP 3", width/2, height/2);
  }
}

void renderFitnessScore() {
  textSize(22);
  textAlign(CENTER);
  fill(255);
  text("YOUR SCORE: " + textCounter, width/2, 50);
  textSize(12);
  text("Speed varies at 20, 60 and 100 points.", width/2, height-60);
}

void checkEndOfFitness() {
  if (seconds < 0) {
    setGradient(0, 0, width, height, c1, c2, 1); 
    noStroke();
    fill(255);
    myCircleBody.render();    

    textSize(32);
    text("YOUR NEW SCORE: " + textCounter, width/2, height/2-20); 
    textSize(14);
    text("Knee down to restart", width/2, height-45);

    /*Restart Button */
    stroke(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text("Restart", width/2, (height/2)+33);
    fill(255, 20);

    if (mouseX>(width/2)-50 && mouseX <(width/2)+50 && mouseY>(height/2)+10 && mouseY <(height/2)+60) {
      fill(255, 80);
      if (mousePressed) {
        resetFitness();
      }
    }
    rect((width/2)-50, (height/2)+10, 100, 50);
    line(0, 390, width, 390);
    myCircleBody.render();
  } else { 
    textSize(12);      
    text("Remaining time: " + seconds, width/2, height-45);
  }

  if (BodyY > 400) {
    /*println("RESTART ACTIVATED");*/
    resetFitness();
  } else {
    /*println("NO RESTART GESTURE");*/
    /*println(BodyY);*/
  }
}

void resetFitness() {
  startTime = millis()/1000 + countdown;
  activator = 0;
  counter = 0;
  textCounter = 0;
  DELTA = radians(10);
  text1 = 0;
  text2 = 0;
  text3 = 0;
}

void drawUserPosition(color col, float size)
{
  if(inputMode == InputMode.KINECT) {
    // get 3D position of a joint
    PVector jointPos = new PVector();
    context.getJointPositionSkeleton(getTrackedSkeletonId(context), SimpleOpenNI.SKEL_TORSO, jointPos);

    // convert real world point to projective space
    PVector jointPos_Proj = new PVector();
    context.convertRealWorldToProjective(jointPos, jointPos_Proj);

    BodyX = jointPos_Proj.x;
    BodyY = height / 2 + (jointPos_Proj.y-projUserTorsoPos.y);
  } else {
    BodyX = width / 2;
    BodyY = height / 2 + AMPLITUDE - keyPressCounter;
  }


  // draw the circle at the position of the joint

  fill(c4, 255-(counter*30));
  Circle myCircleExplosion = new Circle(BodyX, BodyY, counter*3);
  myCircleExplosion.render();  

  // set the fill colour
  if (activator<=0) {
    fill(c3);
  } else if (activator>=0) {
    fill(c4);
  }

  Circle myCircleBody = new Circle(BodyX, BodyY, 11);
  myCircleBody.render();
}


// Event-based Methods
class Circle { 
  float x; 
  float y; 
  // the Circle radius
  float r; 

  Circle(float xpos, float ypos, float radius) { 
    x = xpos; 
    y = ypos; 
    r = radius;
  }

  void render() { 
    ellipse(x, y, r*2, r*2);
  }
}


void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}  

float getCoinY(float xin, float sig) {
  return height/2+AMPLITUDE*sin(xin*FREQ+sig);
}

float mapToSinus(float ix) {
  return (map(ix, 0, width, 0, NWAVES*TWO_PI));
}

float getSinusLambda() {
  return width/(NWAVES*FREQ);
}