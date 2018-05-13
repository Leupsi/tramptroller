boolean ADJUST_BASELINE_AUTOMATICALLY = true;
float DIFFERENCE_TRESHOLD = 5.0f;

int START_OBSTACLE_SPEED = 8;
int OBST_WIDTH = 20;

int SCORE_THRESHOLD = 5;

float JUMP_HEIGHT_FACTOR_KINECT = 2.5;
float JUMP_HEIGHT_FACTOR_KEYBOARD = 1;

GameMode gameMode  = GameMode.START;

Button startGameButton;
Button restartGameButton;

Player player;
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();

int obstacleSpeed = START_OBSTACLE_SPEED;

float lastObstacleTime = 0;
int obstacleInterval = 0;
int minObstacleGap = 1500;
int maxObstacleGap = 4000;
int minObstHeight = 20;
int maxObstHeight = 50;

float jumpHeightFactor;

int score = 0;

float[] differences = new float[20];
float[] stdDevDiff = new float[20];
int diffInd = 0;



void setupGame() {
  frameRate(60);

  cp5 = new ControlP5(this);

  startGameButton = cp5.addButton("startGameButton")
    .setPosition(100, 100)
      .setSize(200, 300);

  restartGameButton = cp5.addButton("restartGameButton")
    .setPosition(100, 200)
      .setSize(200, 200);
  restartGameButton.hide();

  player = new Player(100, 0, 20, 20);

  if(inputMode == InputMode.KINECT) {
    jumpHeightFactor = JUMP_HEIGHT_FACTOR_KINECT;
  } else {
    jumpHeightFactor = JUMP_HEIGHT_FACTOR_KEYBOARD;
    KEY_PRESS_COUNTER_FACTOR *= 2.5;
    KEY_PRESS_COUNTER_GRAVITY *= 2.5;
  }
}

void drawGame() {
  background(255);

  context.update();

  switch(gameMode) {
  case START:
    initScreen();
    break;
  case GAME:
    gameScreen();
    break;
  case OVER:
    gameOverScreen();
    break;
  }
}

class Obstacle { 
  float x; 
  float y;
  float h; 
  float w;
  boolean wasCleared;

  Obstacle(float obHeight, float obWidth) { 
    h = obHeight;
    w = obWidth;
    y = height - h;
    x = width + 10;
  }

  Obstacle(float obHeight, float obWidth, float obYOffset) { 
    h = obHeight;
    w = obWidth;
    x = width + 10; 
    y = height - h + obYOffset; // offset from bottom of window
  }

  void decreaseX(int val) {
    this.x -= val;
  }

  boolean isVisible() {
    return this.x + this.w > 0;
  }

  void render() { 
    rectMode(CORNER);
    fill(0);
    if (player.isColliding(this)) {
      fill(#FF0000);
    }
    rect(x, y, w, h);
  }
}

class Player {
  float x;  
  float y;
  float w;
  float h;
  float baseY;

  Player(float x, float yBaseline, float w, float h) {
    this.x = x;
    this.w = w;
    this.h = h;
    this.baseY = height - h / 2 - yBaseline;
    this.y = this.baseY;
  }

  void setYDifference(float difference) {
    if (difference > 0) {
      y = baseY - difference * jumpHeightFactor;
    } else {
      y = baseY;
    }
  }

  void render() { 
    rectMode(CENTER);
    fill(0);
    rect(x, y, w, h);
  }

  boolean isColliding(Obstacle ob) {
    return x - w / 2 + w > ob.x && 
      x - w / 2 < ob.x + ob.w && 
      y - h / 2 + h > ob.y &&
      y - h / 2 < ob.y + ob.h;
  }
}

/********* SCREEN CONTENTS *********/

void initScreen() {
  background(0);
  textAlign(CENTER);
  text("Click to start", height/2, width/2);
}

void gameScreen() {
  if (userTorsoPosSet() || inputMode == InputMode.KEYBOARD) {
    addObstacle();
    handleObstacles();

    float difference;
    if(inputMode == InputMode.KINECT) {
      difference = getDifference();
      println(difference);
    } else {
      difference = keyPressCounter;
    }

    player.setYDifference(difference);
    player.render();

    checkCollisionAndScore();
    renderScore();
  } else {
    if(getTrackedSkeletonId(context) == -1) {
      renderNoUserText();
    } else {
      renderNotCalibratedText();
    }
  }
}

float getDifference() {
  float difference = getTorsoYDifference(context, projUserTorsoPos);

  if (ADJUST_BASELINE_AUTOMATICALLY) {
    differences[diffInd] = difference;
    stdDevDiff[diffInd] = getStdDev(differences);
    println(stdDevDiff[diffInd] + "; " + getMean(differences));
    if (stdDevDiff[diffInd] > 0.5 && stdDevDiff[diffInd] < 3 && getMean(differences) > 5) {
      println("ADJUST");
      setUserTorsoPos(context, getTrackedSkeletonId(context));
      difference = getTorsoYDifference(context, projUserTorsoPos);
    }
    diffInd = (diffInd + 1) % differences.length;
  }

  if (difference < DIFFERENCE_TRESHOLD) {
    difference = 0;
  }

  return difference;
}

void addObstacle() {
  if (millis() - lastObstacleTime > obstacleInterval) {
    obstacleInterval = int(random(minObstacleGap, maxObstacleGap));
    float obstHeight = random(minObstHeight, maxObstHeight);
    obstacles.add(new Obstacle(obstHeight, OBST_WIDTH));
    lastObstacleTime = millis();
  }
}

void handleObstacles() {
  ArrayList<Obstacle> toRemove = new ArrayList<Obstacle>();
  for (int i = 0; i < obstacles.size (); i++) {
    obstacles.get(i).decreaseX(obstacleSpeed);
    if (obstacles.get(i).isVisible()) {
      obstacles.get(i).render();
    } else {
      toRemove.add(obstacles.get(i));
    }
  }
  for (int i = 0; i < toRemove.size (); i++) {
    obstacles.remove(toRemove.get(i));
  }
}

void checkCollisionAndScore() {
  for (int i = 0; i < obstacles.size (); i++) {
    Obstacle ob = obstacles.get(i);
    if (player.isColliding(ob)) {
      gameMode = GameMode.OVER;
    } else if (!ob.wasCleared && player.x - player.w > ob.x) {
      ob.wasCleared = true;
      score++;
      if(score > 0 && score % SCORE_THRESHOLD == 0) {
        obstacleSpeed += 2;
        if(maxObstHeight < 100) {
          maxObstHeight += 10;
        }
      }
    }
  }
}

void renderScore() {
  textSize(22);
  textAlign(CENTER);
  fill(0);
  text("YOUR SCORE: " + score, width/2, 50);
}

void renderNoUserText() {
  textSize(22);
  textAlign(CENTER);
  fill(0);
  text("No User detected. Please move around a bit.", width/2, 150);
}

void renderNotCalibratedText() {
  textSize(22);
  textAlign(CENTER);
  fill(0);
  text("Raise a hand to start the game.", width/2, 150);
}

void gameOverScreen() {
  restartGameButton.show();
  renderGameOverText();
  renderGameOverScore();
}

void renderGameOverText() {
  textSize(22);
  textAlign(CENTER);
  fill(0);
  text("GAME OVER", width/4*3, 50);
}

void renderGameOverScore() {
  textSize(22);
  textAlign(CENTER);
  fill(0);
  text("YOUR SCORE: " + score, width/4*3, 100);
}


//Buttons
public void startGameButton(int value) {
  gameMode = GameMode.GAME;
  startGameButton.hide();
}

public void restartGameButton(int value) {
  restartGameButton.hide();
  gameMode = GameMode.GAME;
  resetGame();
}

void resetGame() {
  score = 0;
  lastObstacleTime = 0;
  obstacleSpeed = START_OBSTACLE_SPEED;
  obstacles.clear();
  userTorsoPos = new PVector(0, 0, 0);
  projUserTorsoPos = new PVector(0, 0, 0);
}

/***** Maths *****/
float getMean(float[] data)
{
  float sum = 0.0;
  for (float a : data) {
    sum += a;
  }
  return sum/data.length;
}

float getVariance(float[] data)
{
  float mean = getMean(data);
  float temp = 0;
  for (float a : data) {
    temp += (a-mean)*(a-mean);
  }
  return temp/(data.length-1);
}

float getStdDev(float[] data)
{
  return (float) Math.sqrt(getVariance(data));
}

