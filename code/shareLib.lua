local ragdogLib = require "ragdogLib";
local twitterHelper = require "shareLib.twitterHelper";
local facebookHelper = require "shareLib.facebookHelper";

local shareLib = {};

local totalWidth = _G.totalWidth;
local totalHeight = totalHeight;

local canEmail = native.canShowPopup("mail");
local canSMS = native.canShowPopup("sms");
local facebookShare, twitterShare, emailShare, smsShare;

local shareFunctions = {
  ["facebook"] = facebookHelper.postOnUserWall,
  ["twitter"] = function(message)
    twitterHelper:tweet(message);
  end,
  ["sms"] = function(message)
    local options =
    {
       body = message
    }
    native.showPopup("sms", options)
  end,
  ["email"] = function(message)
    local options =
    {
       body = message
    }
    native.showPopup("mail", options)
  end
};

shareLib.shareMessage = function(shareType, message, replaceData)
  for k, v in pairs(replaceData) do
    local find = "%f[%a]"..k.."%f[%A]";
    message = message:gsub(find, v);
  end
  shareFunctions[shareType](message);
end

shareLib.init = function(message, replaceData)
  local group = display.newGroup();
  local touchBlocker = display.newRect(group, display.contentCenterX, display.contentCenterY, totalWidth, totalHeight);
  touchBlocker:setFillColor(0, 0, 0, .5);
  function touchBlocker:touch(event)
    return true;
  end
  touchBlocker:addEventListener("touch", touchBlocker);
  
  local buttonHolder = display.newGroup();
  group:insert(buttonHolder);
  
  local bg = display.newImageRect(buttonHolder, "IMG/shareIMG/sharepop.png", 156, 142);
  
  local facebookButton = ragdogLib.newSimpleButton(buttonHolder, "IMG/shareIMG/fb.png", 47, 48);
  facebookButton.x, facebookButton.y = bg.x-35, bg.y-35;
  function facebookButton:touchBegan()
    self.xScale, self.yScale = .9, .9;
    self:setFillColor(.7, .7, .7);
  end
  function facebookButton:touchEnded()
    self.xScale, self.yScale = 1, 1;
    self:setFillColor(1, 1, 1);
    local options = {
    service = "facebook",
    message = "Hi! I Check this Greate Game!",
    image = {
        { filename = "Icon-xxhdpi.png", baseDir = system.ResourceDirectory }
    },   -- listener = eventListener,
    url = "https://itunes.apple.com/us/app/tap-to-shoot/id981774771?ls=1&mt=8"
  }
  local isFacebookAvailable = native.canShowPopup( "social", "facebook" );
  if(isFacebookAvailable) then
    native.showPopup( "social", options );
  else
    native.showAlert( "isFacebookAvailable", "facebook is not Available" , { "OK" });
  end
    --shareLib.shareMessage("facebook", message, replaceData);
  end
  
  local twitterButton = ragdogLib.newSimpleButton(buttonHolder, "IMG/shareIMG/twit.png", 47, 48);
  twitterButton.x, twitterButton.y = bg.x+35, bg.y-35;
  function twitterButton:touchBegan()
    self.xScale, self.yScale = .9, .9;
    self:setFillColor(.7, .7, .7);
  end
  function twitterButton:touchEnded()
    self.xScale, self.yScale = 1, 1;
    self:setFillColor(1, 1, 1);
   -- shareLib.shareMessage("twitter", message, replaceData);
   local options = {
    service = "twitter",
    message = "Hi! I Check this Greate Game!",
    image = {
        { filename = "Icon-xxhdpi.png", baseDir = system.ResourceDirectory }
    },
   -- listener = eventListener,
    url = "https://itunes.apple.com/us/app/tap-to-shoot/id981774771?ls=1&mt=8"
  }
  local isFacebookAvailable = native.canShowPopup( "social", "twitter" );
  if(isFacebookAvailable) then
    native.showPopup( "social", options );
  else
    native.showAlert( "isFacebookAvailable", "twitter is not Available" , { "OK" });
  end
  end
  
  local emailButton = ragdogLib.newSimpleButton(buttonHolder, "IMG/shareIMG/email.png", 47, 48);
  emailButton.x, emailButton.y = bg.x-35, bg.y+35;
  if canEmail then
    function emailButton:touchBegan()
      self.xScale, self.yScale = .9, .9;
      self:setFillColor(.7, .7, .7);
    end
    function emailButton:touchEnded()
      self.xScale, self.yScale = 1, 1;
      self:setFillColor(1, 1, 1);
      shareLib.shareMessage("email", message, replaceData);
    end
  else
    emailButton:setFillColor(.7, .7, .7);
  end
  
  local smsButton = ragdogLib.newSimpleButton(buttonHolder, "IMG/shareIMG/sms.png", 47, 48);
  smsButton.x, smsButton.y = bg.x+35, bg.y+35;
  if canSMS then
    function smsButton:touchBegan()
      self.xScale, self.yScale = .9, .9;
      self:setFillColor(.7, .7, .7);
    end
    function smsButton:touchEnded()
      self.xScale, self.yScale = 1, 1;
      self:setFillColor(1, 1, 1);
      shareLib.shareMessage("sms", message, replaceData);
    end
  else
    smsButton:setFillColor(.7, .7, .7);
  end
  
  buttonHolder.x, buttonHolder.y = touchBlocker.x, touchBlocker.y-50;
  
  local backButton = ragdogLib.newSimpleButton(buttonHolder, "IMG/back.png", 67, 67);
  backButton.x, backButton.y = bg.x, bg.y+130;
  function backButton:touchBegan()
    self:setFillColor(.5, .5, .5);
    self.xScale, self.yScale = .9, .9;
  end
  function backButton:touchEnded()
    audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
    self:setFillColor(1, 1, 1);
    self.xScale, self.yScale = 1, 1;
    touchBlocker:removeEventListener("touch", touchBlocker);
    facebookButton:removeEventListener("touch", facebookButton);
    twitterButton:removeEventListener("touch", twitterButton);
    emailButton:removeEventListener("touch", emailButton);
    smsButton:removeEventListener("touch", smsButton);
    self:removeEventListener("touch", self);
    transition.to(group, {time = 200, alpha = 0, onComplete = group.removeSelf});
  end
  
  transition.from(touchBlocker, {time = 200, alpha = 0});
  transition.from(buttonHolder, {time = 200, xScale = 0.01, yScale = 0.01});
  return group;
end

return shareLib;