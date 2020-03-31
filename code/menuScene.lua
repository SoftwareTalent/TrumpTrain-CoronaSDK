----------------------------------------------------------------------------------
local composer = require( "composer" )

local scene = composer.newScene()

local ragdogLib = require "ragdogLib";
local networksLib = require "networksLib";
local adsLib = require "adsLib";

local iApLib;
if _G.activeRemoveAdsButton then
  iApLib = require "iApLib";
end

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
  adsLib.showAd("main_menu");
  local group = self.view;
  
  local bg = display.newImageRect(group, "IMG/bg.png", totalWidth, totalHeight);
  bg.x, bg.y = centerX, centerY;
  
  local logo = display.newImageRect(group, "IMG/logo.png", 177, 124);
  logo.x, logo.y = centerX, topSide+30+logo.contentHeight*.5;
  
  local playButton = ragdogLib.newSimpleButton(group, "IMG/play.png", 104, 104);
  playButton.x, playButton.y = centerX, centerY;
  function playButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function playButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    composer.gotoScene("gameScene", "fade");
  end
  
  local leaderButton = ragdogLib.newSimpleButton(group, "IMG/leader.png", 67, 67);
  leaderButton.x, leaderButton.y = centerX-90, centerY+120;
  function leaderButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function leaderButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    networksLib.showLeaderboard();
  end
  
  local rateButton = ragdogLib.newSimpleButton(group, "IMG/rate.png", 67, 67);
  rateButton.x, rateButton.y = centerX, centerY+120;
  function rateButton:touchBegan()
    self:setFillColor(.7, .7, .7);
    self.xScale, self.yScale = .9, .9;
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function rateButton:touchEnded()
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    local options =
    {
       iOSAppId = _G.iOSappIDforRate, --your ios app id
       supportedAndroidStores = {"google", "samsung", "amazon", "nook"}, --the store you support on android
    }
    native.showPopup("appStore", options);
  end
  
  local soundButton = ragdogLib.newComplexButton(group, "IMG/soundon.png", 67, 67, "IMG/sounoff.png", 67, 67);
  soundButton.x, soundButton.y = centerX+90, centerY+120;
  if audio.getVolume() < 1 then
    soundButton[1].isVisible = false;
    soundButton[2].isVisible = true;
  end
  function soundButton:touchBegan()
    if self[1].isVisible then
      self[1]:setFillColor(.7, .7, .7);
      self[1].xScale, self[1].yScale = .9, .9;
    elseif self[2].isVisible then
      self[2]:setFillColor(.7, .7, .7);
      self[2].xScale, self[1].yScale = .9, .9;
    end
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
  end
  function soundButton:touchEnded()
    if self[1].isVisible then
      self[1]:setFillColor(1, 1, 1);
      self[1].xScale, self[1].yScale = 1, 1;
      self[1].isVisible = false;
      self[2].isVisible = true;
      audio.setVolume(0);
    elseif self[2].isVisible then
      self[2]:setFillColor(1, 1, 1);
      self[2].xScale, self[1].yScale = 1, 1;
      self[2].isVisible = false;
      self[1].isVisible = true;
      audio.setVolume(1);
    end
  end
  
  if _G.activeRemoveAdsButton and not ragdogLib.getSaveValue("removeAds") then
    local removeAdsButton = ragdogLib.newSimpleButton(group, "IMG/noads.png", 37, 37);
    removeAdsButton.x, removeAdsButton.y = rightSide-5-removeAdsButton.contentWidth*.5, topSide+5+removeAdsButton.contentHeight*.5;
    function removeAdsButton:touchBegan()
      self:setFillColor(.5, .5, .5);
      self.xScale, self.yScale = .9, .9;
    end
    function removeAdsButton:touchEnded()
      audio.play(buttonSFX, {channel = audio.findFreeChannel()});
      self:setFillColor(1, 1, 1);
      self.xScale, self.yScale = 1, 1;
      iApLib.purchaseItem(_G.iApItems["removeAds"], function(result)
      if result then
        ragdogLib.setSaveValue("isAdsRemoved", "true", true);
      end
    end);
    end
    local restoreAdsButton = ragdogLib.newSimpleButton(group, "IMG/iap.png", 37, 37);
    restoreAdsButton.x, restoreAdsButton.y = removeAdsButton.x, removeAdsButton.contentBounds.yMax+5+restoreAdsButton.contentHeight*.5;
    function restoreAdsButton:touchBegan()
      self:setFillColor(.5, .5, .5);
      self.xScale, self.yScale = .9, .9;
    end
    function restoreAdsButton:touchEnded()
      audio.play(buttonSFX, {channel = audio.findFreeChannel()});
      self:setFillColor(1, 1, 1);
      self.xScale, self.yScale = 1, 1;
      iApLib.restoreItems({{id = _G.iApItems["removeAds"][1], callback = function()
        ragdogLib.setSaveValue("isAdsRemoved", "true", true);
        native.showAlert("Success", "Previous Purchase found! Ads Removed.", {"Ok"});
      end}});
    end
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