----------------------------------------------------------------------------------
local composer = require( "composer" )

local scene = composer.newScene()

local ragdogLib = require "ragdogLib";
local networksLib = require "networksLib";
local adsLib = require "adsLib";
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- local forward references should go here

--let's localize these values for faster reading
local totalWidth = _G.totalWidth;
local totalHeight = _G.totalHeight;
local leftSide = _G.leftSide;
local rightSide = _G.rightSide;
local topSide = _G.topSide;
local bottomSide = _G.bottomSide;
local centerX = display.contentCenterX;
local centerY = display.contentCenterY;

local buttonSFX = _G.buttonSFX;

-- -------------------------------------------------------------------------------
local circleScale = .8;
local arrowSpeed = 10;
local circleInitialSpeed = 1;
local speedIncreaseAtEveryPoint = .5;
local maxCircleSpeed = 20;
local circleSpeed;
local currentScore;

local minAngleToMakePoint = 330;
local maxAngleToMakePoint = 32;
local minRedAngleToMakePoint = 355;
local maxRedAngleToMakePoint = 4;

local pointsForHittingRed = 2;

local gameOverSFX, scorePointSFX, hittingRedSFX, shootSFX;

-- "scene:create()"
function scene:create( event )
  --adsLib.showAd("main_menu");
  circleSpeed = 0;
  currentScore = 0;
  
  gameOverSFX = audio.loadSound("SFX/gameOverSFX.mp3");
  scorePointSFX = audio.loadSound("SFX/scorePointSFX.mp3");
  hittingRedSFX = audio.loadSound("SFX/hittingRedSFX.mp3");
  shootSFX = audio.loadSound("SFX/shootSFX.mp3");
  
  local group = self.view;
  
  local bg = display.newImageRect(group, "IMG/bg.png", totalWidth, totalHeight);
  bg.x, bg.y = centerX, centerY;
  
  local circle = display.newImageRect(group, "IMG/circle.png", 164*circleScale, 164*circleScale);
  circle.x, circle.y = centerX, centerY-140;
  function circle:enterFrame()
    self.rotation = self.rotation+circleSpeed;
    if self.rotation > 360 then
      self.rotation = self.rotation-360;
    end
  end
  Runtime:addEventListener("enterFrame", circle);
  
  local shadow = display.newImageRect(group, "IMG/shadow.png", 301*circleScale, 358*circleScale);
  shadow.x, shadow.y = circle.x-circle.contentWidth*.5+shadow.contentWidth*.5+10, circle.y-circle.contentHeight*.5+shadow.contentHeight*.5+10;
  
  circle:toFront();
  
  local line = display.newImageRect(group, "IMG/line.png", 441, 3);
  line.x, line.y = centerX, centerY+180;
  
  local arrow = display.newImageRect(group, "IMG/triangle.png", 18, 31);
  arrow.x, arrow.y = centerX, line.y-line.contentHeight*.5-arrow.contentHeight*.5-5;
  arrow.xStart, arrow.yStart = arrow.x, arrow.y;
  arrow.state = 0;
  function arrow:enterFrame()
    if self.state == 1 then
      if self.y-self.contentHeight*.5 <= circle.y+circle.height*.5 then
        if circle.rotation >= minAngleToMakePoint or circle.rotation <= maxAngleToMakePoint then
          if circleSpeed == 0 then
            circleSpeed = circleInitialSpeed;
          else
            circleSpeed = circleSpeed+speedIncreaseAtEveryPoint;
            if circleSpeed > maxCircleSpeed then
              circleSpeed = maxCircleSpeed;
            end
          end
          currentScore = currentScore+1;
          if circle.rotation >= minRedAngleToMakePoint or circle.rotation <= maxRedAngleToMakePoint then
            currentScore = currentScore+pointsForHittingRed;
            audio.play(hittingRedSFX, {channel = audio.findFreeChannel()});
          else
            audio.play(scorePointSFX, {channel = audio.findFreeChannel()});
          end
          transition.to(circle, {time = 100, xScale = 1.1, yScale = 1.1});
          transition.to(circle, {delay = 100, time = 50, xScale = 1, yScale = 1});
          self.state = 0;
          self.x, self.y = arrow.xStart, arrow.yStart;
        else
          self.isVisible = false;
          self.state = 2;
          self.time = 0;
          audio.play(gameOverSFX, {channel = audio.findFreeChannel()});
          for i = 1, 20 do
            local particle = display.newRect(group, 0, 0, 5, 5);
            particle.xSpeed = math.random(-30, 30)*.1;
            particle.ySpeed = math.random(20, 40)*.1;
            particle.x, particle.y = self.x, self.y-self.contentHeight*.5;
            function particle:enterFrame()
              self.x, self.y = self.x+self.xSpeed, self.y+self.ySpeed;
              self.alpha = self.alpha-0.01;
              if self.alpha <= 0 then
                Runtime:removeEventListener("enterFrame", self);
                self:removeSelf();
              end
            end
            Runtime:addEventListener("enterFrame", particle);
            circleSpeed = 0;
          end
        end
      end
      self.y = self.y-arrowSpeed;
    elseif self.state == 2 then
      self.time = self.time+1;
      if self.time >= 90 then
        Runtime:removeEventListener("enterFrame", self);
        _G.currentScore = currentScore;
        composer.gotoScene("gameOverScene", "fade");
      end
    end
  end
  Runtime:addEventListener("enterFrame", arrow);
  
  local tapToStart = display.newText(group, "Tap to Start", 0, 0, native.systemFont, 25);
  tapToStart.x, tapToStart.y = centerX, centerY;
  
  function bg:touch(event)
    if event.phase == "began" then
      if arrow.state == 0 then
        arrow.state = 1;
        audio.play(shootSFX, {channel = audio.findFreeChannel()});
        if tapToStart then
          transition.to(tapToStart, {time = 200, alpha = 0, onComplete = tapToStart.removeSelf});
          tapToStart = nil;
        end
      end
    end
  end
  bg:addEventListener("touch", bg);
  
  local scoreText = display.newText(group, currentScore, 0, 0, native.systemFont, 30);
  scoreText.x, scoreText.y = rightSide-10-scoreText.contentWidth*.5, topSide+10+scoreText.contentHeight*.5;
  
  function scoreText:enterFrame()
    self.text = currentScore;
    self.x, self.y = rightSide-10-self.contentWidth*.5, topSide+10+self.contentHeight*.5;
  end
  Runtime:addEventListener("enterFrame", scoreText);
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      
      audio.dispose(gameOverSFX);
      gameOverSFX = nil;
      audio.dispose(scorePointSFX);
      scorePointSFX = nil;
      audio.dispose(hittingRedSFX);
      hittingRedSFX = nil;
      audio.dispose(shootSFX);
      shootSFX = nil;

      local removeAll;
	
      removeAll = function(group)
        if group.enterFrame then
          Runtime:removeEventListener("enterFrame", group);
        end
        if group.touch then
          group:removeEventListener("touch", group);
          Runtime:removeEventListener("touch", group);
        end		
        for i = group.numChildren, 1, -1 do
          if group[i].numChildren then
            removeAll(group[i]);
          else
            if group[i].enterFrame then
              Runtime:removeEventListener("enterFrame", group[i]);
            end
            if group[i].touch then
              group[i]:removeEventListener("touch", group[i]);
              Runtime:removeEventListener("touch", group[i]);
            end
          end
        end
      end

      removeAll(self.view);
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view

    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene