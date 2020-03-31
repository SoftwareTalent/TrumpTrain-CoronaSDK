----------------------------------------------------------------------------------
local composer = require( "composer" )

local scene = composer.newScene()

local ragdogLib = require "ragdogLib";
local networksLib = require "networksLib";
local shareLib = require "shareLib";
local adsLib = require "adsLib";
--For the second parameter, options must be a Lua table containing information to pre-populate the form, for example:
local options = {
    service = "facebook",
    message = "Check out this photo!",
    listener = eventListener,
    image = {
        { filename = "pic.jpg", baseDir = system.ResourceDirectory },
        { filename = "pic2.jpg", baseDir = system.ResourceDirectory }
    },
    url = "http://coronalabs.com"
}
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


-- "scene:create()"
function scene:create( event )
  -- adsLib.showAd("main_menu");
  local group = self.view;
  
  local bg = display.newImageRect(group, "IMG/bg.png", totalWidth, totalHeight);
  bg.x, bg.y = centerX, centerY;
  
  local box = display.newImageRect(group, "IMG/go.png", 233, 208);
  box.x, box.y = centerX, centerY-100;
  
  local bestScore = ragdogLib.getSaveValue("bestScore") or 0;
  
  if bestScore < _G.currentScore then
    bestScore = _G.currentScore;
    ragdogLib.setSaveValue("bestScore", bestScore, true);
    networksLib.addScoreToLeaderboard(bestScore);
  end
  
  local scoreText = display.newText(group, _G.currentScore, 0, 0, native.systemFont, 30);
  scoreText.x, scoreText.y = box.x, box.y+30;
  
  local bestScoreText = display.newText(group, bestScore, 0, 0, native.systemFont, 30);
  bestScoreText.x, bestScoreText.y = box.x, box.y+136;
  
  local backButton = ragdogLib.newSimpleButton(group, "IMG/back.png", 67, 67);
  backButton.x, backButton.y = centerX-90, centerY+120;
  function backButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function backButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    composer.gotoScene("menuScene", "fade");
  end
  
  local shareButton = ragdogLib.newSimpleButton(group, "IMG/share.png", 67, 67);
  shareButton.x, shareButton.y = centerX, centerY+120;
  function shareButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function shareButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    group:insert(shareLib.init(_G.socialShareMessage, {["totalPoints"] = (_G.currentScore or 0).."pts"}));
  end
  
  local retryButton = ragdogLib.newSimpleButton(group, "IMG/retry.png", 67, 67);
  retryButton.x, retryButton.y = centerX+90, centerY+120;
  function retryButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function retryButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    composer.gotoScene("gameScene", "fade");
    --adsLib.showAd("during_game");
  end
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