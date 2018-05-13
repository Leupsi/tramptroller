import SimpleOpenNI.*;
import controlP5.*;

float KEY_PRESS_COUNTER_FACTOR = 7f;
float KEY_PRESS_COUNTER_GRAVITY = 9f;
int MAX_KEY_PRESS_COUNTER = 150;

ControlP5 cp5;
SimpleOpenNI  context;

Mode mode;
InputMode inputMode = InputMode.KEYBOARD;

Button fitnessButton;
Button gameButton;

// user skeleton related variables
boolean allowGestures = true;
PVector userTorsoPos = new PVector();
PVector projUserTorsoPos = new PVector();

int keyPressCounter = 0;
boolean mayPressKey = true;

/*
* SETUP
 */
void setup () {
  mode = Mode.MENU;
  //size(400, 400);

  context = new SimpleOpenNI(this);

  context.enableDepth(); // Tiefenbild ein
  context.enableUser(); // Skeletterkennung ein
  context.setMirror(true); // funktioniert derzeit nicht
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);

  size(context.depthWidth(), context.depthHeight());

  noStroke();

  setupMenu();
}

void setupMenu() {
  cp5 = new ControlP5(this);

  // create a new button with name 'buttonA'
  fitnessButton = cp5.addButton("fitness")
    .setPosition(100, 100)
      .setSize(200, 300);

  // and add another 2 buttons
  gameButton = cp5.addButton("game")
    .setPosition(310, 100)
      .setSize(200, 300);
}

/*
* DRAW
 */
void draw() {
  if(inputMode == InputMode.KEYBOARD) {
    checkKeyPressed();
  }
  switch(mode) {
  case MENU: 
    drawMenu();
    break;
  case FITNESS:
    drawFitness();
    break;
  case GAME:
    drawGame();
    break;
  }
}

void drawMenu() {
}

boolean userTorsoPosSet() {
  return userTorsoPos.x != 0 && userTorsoPos.y != 0 && userTorsoPos.z != 0;
}


/****** SimpleOpenNI ******/

float getTorsoYDifference(SimpleOpenNI context, PVector otherTorso) {
  PVector realTorso = new PVector();
  PVector projTorso = new PVector();
  context.getJointPositionSkeleton(getTrackedSkeletonId(context), SimpleOpenNI.SKEL_TORSO, realTorso);
  context.convertRealWorldToProjective(realTorso, projTorso);

  return otherTorso.y - projTorso.y;
}


void highlightJoint(int userId, int limbID, color col, float size)
{
  // get 3D position of a joint
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId, limbID, jointPos);

  // convert real world point to projective space
  PVector jointPos_Proj = new PVector();
  context.convertRealWorldToProjective(jointPos, jointPos_Proj);

  // create a distance scalar related to the depth (z dimension)
  float distanceScalar = (500 / jointPos_Proj.z);

  // set the fill colour
  fill(0, 0, 255);

  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(jointPos_Proj.x, jointPos_Proj.y+120, distanceScalar*size, distanceScalar*size);
}

int getTrackedSkeletonId(SimpleOpenNI context) {
  for (int i=1; i<=10; i++)
  {
    if (context.isTrackingSkeleton(i))
    { 
      return i;
    }
  }
  return -1;
}

String pVectorToString(PVector vector) {
  return"(" + vector.x + ", " + vector.y + ", " + vector.z + ")";
}

// Event-based Methods

// when a person ('user') enters the field of view
void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("New User Detected - userId: " + userId);

  context.startTrackingSkeleton(userId);
}

// when a person ('user') leaves the field of view
void onLostUser(int userId)
{
  println("User Lost - userId: " + userId);
}

void onCompletedGesture(SimpleOpenNI curContext, int gestureType, PVector pos)
{
  // println("onCompletedGesture - gestureType: " + gestureType + ", pos: " + pos);

  if (gestureType == SimpleOpenNI.GESTURE_HAND_RAISE && allowGestures) {
    int userId = getTrackedSkeletonId(curContext);

    if (belongsToUser(pos, userId, curContext)) {
      println("calibration gesture");
      setUserTorsoPos(curContext, userId);
      println("new userTorsoPos: " + pVectorToString(userTorsoPos) + "; projective: " + pVectorToString(projUserTorsoPos));
    }
  }
}

void setUserTorsoPos(SimpleOpenNI context, int userId) {
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_TORSO, userTorsoPos);
  context.convertRealWorldToProjective(userTorsoPos, projUserTorsoPos);
}

boolean belongsToUser(PVector gesturePos, int userId, SimpleOpenNI context) {
  PVector rightHand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);

  PVector leftHand = new PVector();
  context.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);


  // println("Dist Left Hand: " + gesturePos.dist(leftHand) + "; Dist Right Hand: " + gesturePos.dist(rightHand));

  return gesturePos.dist(rightHand) > 80 || gesturePos.dist(leftHand) > 80;
}

// when button fitness gets clicked
public void fitness(int value) {
  mode = Mode.FITNESS;
  hideButtons();
  setupFitness();
}

// when button game gets clicked
public void game(int value) {
  mode = Mode.GAME;
  hideButtons();
  setupGame();
}

void hideButtons() {
  fitnessButton.hide();
  gameButton.hide();
}

// -----------------------------------------------------------------
// Keyboard event
void keyPressed()
{
  // switch(key)
  // {
    // case ' ':
    //   onBlankKeyPress();
    //   // switch(mode) {
    //   //   case FITNESS:
    //   //     onFitnessKeyPressed();
    //   //     break;
    //   //   case GAME:
    //   //     onGameKeyPressed();
    //   //     break;
    //   // }
    //   break;
  // }
}

void checkKeyPressed() {
  if(keyPressed) {
    if(key == ' ') {
      onBlankKeyPressed();
    } 
  } else {
    onBlankKeyNotPressed();
  }
}

void onBlankKeyPressed() {
  if(mayPressKey) {
    if(keyPressCounter < MAX_KEY_PRESS_COUNTER) {
      keyPressCounter += KEY_PRESS_COUNTER_FACTOR;
    } else {
      mayPressKey = false;
    }
  } else {
    onBlankKeyNotPressed();
  }
}

void onBlankKeyNotPressed() {
  if(keyPressCounter > 0) {
    keyPressCounter -= KEY_PRESS_COUNTER_GRAVITY;
    if(keyPressCounter <= 0) {
      mayPressKey = true;
      keyPressCounter = 0;
    }
  }
}

