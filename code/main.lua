_G.totalWidth = display.contentWidth-(display.screenOriginX*2);
_G.totalHeight = display.contentHeight-(display.screenOriginY*2);
_G.leftSide = display.screenOriginX;
_G.rightSide = display.contentWidth-display.screenOriginX;
_G.topSide = display.screenOriginY;
_G.bottomSide = display.contentHeight-display.screenOriginY;

local ragdogLib = require "ragdogLib";
local setupFile = require "setupFile";
local composer = require "composer";
local adsLib = require "adsLib";

display.setStatusBar(display.HiddenStatusBar);
 
adsLib.showAd("main_menu");


composer.recycleOnSceneChange = true;

_G.buttonSFX = audio.loadSound("SFX/Button_Select.mp3");

composer.gotoScene("menuScene", "fade");

local screenShotNumber = 1;

function keyIsPressed(event)
  if event.keyName == "a" and event.phase == "down" then
    display.save(composer.stage, "screen"..screenShotNumber..".png", system.DocumentsDirectory, true);
    screenShotNumber = screenShotNumber+1;
  end
end
--Runtime:addEventListener("key", keyIsPressed);