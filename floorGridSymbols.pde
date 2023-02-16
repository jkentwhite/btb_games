//FLOOR GRID
//floor grid is an interactive physical positioning game where players must match patterns of symbols
//by moving into a specific grid location that matches a position of that symbol on a projected 
//graphic on the wall

//this is the main code for analyzing the position of players and determining 
//if they are lined up with the patterns on the projected graphic

//create arrays for twenty patterns on floorgrid  
//where each number in the array is a rectangle in the 4x4 grid starting with 0 and ending with 15
//these number designations will determine where the symbols to be matched will be displayed
//and all other grid sections will be populated with random other symbols
int [] [] patternRects = {

  {0, 3, 12, 15}, 
  {1, 2, 13, 14}, 
  {5, 6, 9, 10}, 
  {12, 13, 14, 15}, 
  {5, 7, 8, 10}, 
  {3, 4, 11, 12}, 
  {0, 7, 8, 15}, 
  {4, 6, 9, 11}, 
  {0, 1, 2, 3}, 
  {4, 7, 8, 11}, 
  {3, 6, 9, 12}, 
  {0, 1, 10, 11}, 
  {2, 5, 10, 12}, 
  {7, 8, 13, 15}, 
  {0, 1, 4, 5}, 
  {3, 7, 9, 14}, 
  {1, 6, 11, 12}, 
  {3, 4, 8, 15}, 
  {2, 10, 12, 13}, 
  {1, 4, 7, 14}
};

void floorGridSymbols() {

  //load images from camera
  img.loadPixels();
  imgVideo = kinect.getVideoImage();

  //clear blobs arraylist
  blobs.clear();

  //get depth info from kinect
  int[] depth = kinect.getRawDepth();

  for (int x = 10; x < kinect.width-10; x++) {
    for (int y = 0; y < kinect.height; y++) {
      int offset = x + y * img.width;
      int d = depth[offset];

      //set the depth for the sensor to pick up players
      if (d > minTreshold && d < maxThreshold) {
        //see if the pixels in the range of the sensor are already part of a blob
        boolean found = false;
        for (Blob b : blobs) {
          //if the pixel is close enough it will become part of a previously defined blob
          if (b.isNear(x, y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }
        //if there are no blobs or the pixel is far enough away, start a new blob
        if (!found) {
          Blob b = new Blob(x, y);
          blobs.add(b);
          b.id= blobCounter;
        }
      }
    }
  }

  //update the image from camera
  img.updatePixels();
  imageMode(CENTER);
  tint(255, 128);
  image(img, width/2, height/2, displayWidth, displayHeight);

  //draw the grid
  for (int i = 0; i < 16; i++) {
    rectMode(CORNER);
    noFill();
    stroke(255, 255, 0);
    rect(gridSections[i][0], gridSections[i][1], gridX, gridY);
  }  



  //here we are setting up the pattern for display on the projection
  //by referencing the patternRects for each progression 
  //where the matching symbols will be displayed like this where matching symbols are x's and 
  //all other symbols are o's:
  // ie {0, 3, 12, 15}
  // x o o x 
  // o o o o
  // o o o o
  // x o o x

  if (patternCounter < patternRects.length) {
    patternNumber = patternCounter;
  } else {
    patternNumber = 0;
    patternCounter = 0;
  }

  //so, for the 16 possible grid sections, iterate through and set an array(gridSymbols)
  if (!patternSet) {
    for (int i = 0; i < 16; i++) {
      int symbol = int(random(2));
      if (patternRects[patternNumber][0] == i || patternRects[patternNumber][1] == i || patternRects[patternNumber][2] == i || patternRects[patternNumber][3] == i) {
        gridSymbol[i] = 3;
      } else {

      if (symbol == 0) {
        if (bombCounter < 4) {
          gridSymbol[i] = 0;
          bombCounter++;
        } else {
          symbol = int(random(1, 2));
        }
      }  
      if (symbol == 1) {
        if (skullCounter < 4) {
          gridSymbol[i] = 1;
          skullCounter++;
        } else {
          symbol = 2;
        }
      } 
      if (symbol == 2) {
        if (eagleCounter < 4) {
          gridSymbol[i] = 2;
          eagleCounter++;
        } else {
          symbol = int(random(0, 2));
        }
      }
     }
    }  
    //once the pattern is determined, set patternSet to true to
    //move on to actually displaying and reading the camera data 
    patternSet = true;
  }


  //build the pattern with symbols using the image files 
  for (int i = 0; i < 16; i++) {
    tint(255, 200);
    if (gridSymbol[i] == 3) {
      int rectX = gridSections[i][0];
      int rectY = gridSections[i][1];
      if(currentRectOccupied[i]){
        tint(255, 255);
      } 
      image(hawk, rectX + 128, rectY + 96);
    } 

    if (gridSymbol[i] == 0) {  
      int rectX = gridSections[i][0];
      int rectY = gridSections[i][1];
      image(bomb, rectX + 128, rectY + 96);
    }

    if (gridSymbol[i] == 1) {
      int rectX = gridSections[i][0];
      int rectY = gridSections[i][1];
      image(skull, rectX + 128, rectY + 96);
    }

    if (gridSymbol[i] == 2) {
      int rectX = gridSections[i][0];
      int rectY = gridSections[i][1];
      image(eagle, rectX + 128, rectY + 96);
    }
  }


  //for each blob that exists, let's check it against the grid   
  for (Blob b : blobs) {


    //loop through the grid spaces to determine if the blobs are in the grid sections
    //and set the relative boolean array to TRUE or FALSE accordingly
    for (int i  = 0; i < gridSections.length; i++) {
      if(b.id == 0){
        if (b.centerOfBlobX > gridSections[i][0] && b.centerOfBlobX < (gridSections[i][0] + gridX) && b.centerOfBlobY > gridSections[i][1] && b.centerOfBlobY < (gridSections[i][1] + gridY)) {
          gridRectOccupied[i][0] = true;
        } else {
          gridRectOccupied[i][0] = false;
        } 
      }
      if(b.id == 1){
        if (b.centerOfBlobX > gridSections[i][0] && b.centerOfBlobX < (gridSections[i][0] + gridX) && b.centerOfBlobY > gridSections[i][1] && b.centerOfBlobY < (gridSections[i][1] + gridY)) {
          gridRectOccupied[i][1] = true;
        } else {
          gridRectOccupied[i][1] = false;
        } 
      }
      if(b.id == 2){
        if (b.centerOfBlobX > gridSections[i][0] && b.centerOfBlobX < (gridSections[i][0] + gridX) && b.centerOfBlobY > gridSections[i][1] && b.centerOfBlobY < (gridSections[i][1] + gridY)) {
          gridRectOccupied[i][2] = true;
        } else {
          gridRectOccupied[i][2] = false;
        } 
      }
      if(b.id == 3){
        if (b.centerOfBlobX > gridSections[i][0] && b.centerOfBlobX < (gridSections[i][0] + gridX) && b.centerOfBlobY > gridSections[i][1] && b.centerOfBlobY < (gridSections[i][1] + gridY)) {
            gridRectOccupied[i][3] = true;
          } else {
            gridRectOccupied[i][3] = false;
        } 
      }
      
      for(int j = 0; j < gridRectOccupied[i].length; j++){
        if(gridRectOccupied[i][j]){
          currentRectOccupied[i] = true;
          j = gridRectOccupied[i].length;
        } 
      }       
    }
    
    for (int i  = 0; i < gridSections.length; i++) {
          for(int j = 0; j < gridRectOccupied[i].length; j++){
          if(currentRectOccupied[i]){
            rectOccupiedTimer[i]--;
          }
          if(rectOccupiedTimer[i] == 0){
              if(gridRectOccupied[i][j]){
                currentRectOccupied[i] = true;
              } else{
                 currentRectOccupied[i] = false;
              }
              rectOccupiedTimer[i] = 50;
            }
          }
        }

    //once the boolean are being triggered, this will look to see if the pattern from the patternNumber array is being matched 
    //and if so, begin a short timer to accentuate unlocking the pattern
    //here i am asking for the boolean that is assocaited with the designated grid sections according to the pattern number
    //and if that is true for all four sections of that pattern then begin to register the pattern with a short timer followed by 
    //completing the pattern

    if (currentRectOccupied[patternRects[patternNumber][0]] && 
        currentRectOccupied[patternRects[patternNumber][1]] && 
        currentRectOccupied[patternRects[patternNumber][2]] && 
        currentRectOccupied[patternRects[patternNumber][3]]) {
    // "Pattern Matched!"

    //use the arrays to set the designation for the pattern to be registered
    int rectOneX = gridSections[patternRects[patternNumber][0]][0];
    int rectOneY = gridSections[patternRects[patternNumber][0]][1];
    int rectTwoX = gridSections[patternRects[patternNumber][1]][0];
    int rectTwoY = gridSections[patternRects[patternNumber][1]][1];
    int rectThreeX = gridSections[patternRects[patternNumber][2]][0];
    int rectThreeY = gridSections[patternRects[patternNumber][2]][1];
    int rectFourX = gridSections[patternRects[patternNumber][3]][0];
    int rectFourY = gridSections[patternRects[patternNumber][3]][1];

    noStroke();

    //check if each of the blobs are in the designated rectangle and count to ten before registering TRUE
    if (currentRectOccupied[patternRects[patternNumber][0]]) {
      if (!rectOneGood) {
        rectMode(CORNER);  
        fill(54, 243, 179);
        rect(rectOneX, rectOneY, gridX, spaceCounterOne * 10);
      }
      spaceCounterOne++;
    } 
    if (spaceCounterOne >= 10) {
      rectOneGood = true;
      rectMode(CORNER);  
      fill(54, 243, 179);
      rect(rectOneX, rectOneY, gridX, gridY);
    }


    if (currentRectOccupied[patternRects[patternNumber][1]]) {
      if (!rectTwoGood) {
        rectMode(CORNER);  
        fill(54, 243, 179);
        rect(rectTwoX, rectTwoY, gridX, spaceCounterTwo * 10);
      }
      spaceCounterTwo++;
    } 
    if (spaceCounterTwo >= 10) {
      rectTwoGood = true;
      rectMode(CORNER);  
      fill(54, 243, 179);
      rect(rectTwoX, rectTwoY, gridX, gridY);
    }


    if (currentRectOccupied[patternRects[patternNumber][2]]) {
      if (!rectThreeGood) {
        rectMode(CORNER);  
        fill(54, 243, 179);
        rect(rectThreeX, rectThreeY, gridX, spaceCounterThree * 10);
      }
      spaceCounterThree++;
    } 
    if (spaceCounterThree >= 10) {
      rectThreeGood = true;
      rectMode(CORNER);  
      fill(54, 243, 179);
      rect(rectThreeX, rectThreeY, gridX, gridY);
    }


    if (currentRectOccupied[patternRects[patternNumber][3]]) {
      if (!rectFourGood) {
        rectMode(CORNER);  
        fill(54, 243, 179);
        rect(rectFourX, rectFourY, gridX, spaceCounterFour * 10);
      }
      spaceCounterFour++;
    }
    if (spaceCounterFour >= 10) {
      rectFourGood = true;
      rectMode(CORNER);  
      fill(54, 243, 179);
      rect(rectFourX, rectFourY, gridX, gridY);
    }
   }
  }

  //draw the blobs if they are bigger than 500
 blobCounter = 0;
  for(Blob b : blobs){
    if(b.size() > 500){
    b.show();
    blobCounter++;
    }
    //limit the number of blobs to 4
    if(blobCounter > 3){
      blobCounter = 3;
    }
    
  }

  //if the players are in the sections matching the symbols AND
  //they have been there for ten seconds,
  //trigger the success chime and move to the next pattern in the patternRects array
  if (rectOneGood && rectTwoGood && rectThreeGood && rectFourGood) {

    //play chime to siginify successful matching for that pattern
    chime.trigger();
    delay(200);

    //increment the score
    numberCorrect++;

    //increment the pattern in the array    
    patternCounter++;
    
    //reset the booleans for the matching sections
    rectOneGood = false;
    rectTwoGood = false;
    rectThreeGood = false;
    rectFourGood = false;

    //reset the level timer
    levelCountdownLevelOne = 70;

    //reset the ten second counter for when players are in the correct positions
    spaceCounterOne = 0;
    spaceCounterTwo = 0;
    spaceCounterThree = 0;
    spaceCounterFour = 0;

    //reset the patternSet so that the grid pattern gets calibrated 
    patternSet = false;
    
    //clear the grid of all symbols
    clearGridSymbolArray();
    
    //if the timer for the level expires trigger the failed buzzer sound 
    //and reset all the parameters the same as above 
  } else if(levelCountdownLevelOne == 0){
        buzzer.trigger();
        patternCounter++;
        levelCountdownLevelOne = 70;
        rectOneGood = false;
        rectTwoGood = false;
        rectThreeGood = false;
        rectFourGood = false;  

        spaceCounterOne = 0;
        spaceCounterTwo = 0;
        spaceCounterThree = 0;
        spaceCounterFour = 0;
        clearGridSymbolArray();
        

  }

  //for the prototype phase of development,
  //we can press 'Q' to reset all parameters and stop the game
  if (keyPressed) {
    if (key == 'q') {
      floorGridSymbolsLevelOne = false;
      levelOnePlayed = true;
      floorGridStartScreen = true;
      
      countdownFive = 50;
      numberCorrect = 0;
      clearGridSymbolArray();
      
      patternCounter++;

      rectOneGood = false;
      rectTwoGood = false;
      rectThreeGood = false;
      rectFourGood = false;

      spaceCounterOne = 0;
      spaceCounterTwo = 0;
      spaceCounterThree = 0;
      spaceCounterFour = 0;
      
      goodJobTeam.play();
    }
  }

  //console info for game runner
  println(patternNumber);
  println("FLOOR GRID LEVEL ONE");
  println("Press Q to move to LEVEL 2");
}