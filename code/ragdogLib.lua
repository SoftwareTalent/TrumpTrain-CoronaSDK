------------------------------------------------------------------------
---This library contains a few functions that we're gonna use in several 
---parts of this template.
---We use various functions throughout our games and apps to speed up
---the most common practices. 
---Each template only contains a handful of these (the one useful to it)
---but we're planning on a release that will contain all our functions
---revised and polished up.
---Made by Ragdog Studios SRL in 2013 http://www.ragdogstudios.com
------------------------------------------------------------------------

local ragdogLib = {};

ragdogLib.newSlider = function(group, x, y, barImg, barWidth, barHeight, handleImg, handleWidth, handleHeight) 
  local bar = display.newImageRect(group or display.getCurrentStage(), barImg, barWidth*.9, barHeight);
  bar.x, bar.y = x, y;
  local redBarStart = display.newImageRect(group, "IMG/Misc/sliderFillStart.png", 10, 18);
  redBarStart.x, redBarStart.y = bar.x-bar.contentWidth*.5+2+redBarStart.contentWidth*.5, bar.y;
  local redBarCenter = display.newImageRect(group, "IMG/Misc/sliderFillCenter.png", 1, 18);
  redBarCenter.x, redBarCenter.y = x, y;
  local handle = display.newImageRect(group or display.getCurrentStage(), handleImg, handleWidth, handleHeight);
  handle.x, handle.y = x, y;
  handle.bar = bar;
  function handle:touch(event)
    if event.phase == "began" then
      display.getCurrentStage():setFocus(self);
      self.isFocus = true;
      self:setFillColor(0.5, 0.5, 0.5);
      self.xStart = event.x-self.x;
      if self.touchBegan then
        self:touchBegan();
      end
    elseif event.phase == "moved" and self.isFocus then
      self.x = event.x-self.xStart;
      if self.x < self.bar.x-self.bar.contentWidth*.5 then
        self.x = self.bar.x-self.bar.contentWidth*.5;
      elseif self.x > self.bar.x+self.bar.contentWidth*.5 then
        self.x = self.bar.x+self.bar.contentWidth*.5;
      end
      if self.touchMoved then
        self:touchMoved()
      end
      redBarCenter.xScale = handle.x-redBarStart.x+redBarStart.contentWidth*.5;
      redBarCenter.x = redBarStart.x+redBarStart.contentWidth*.5+(handle.x-redBarStart.x+redBarStart.contentWidth*.5)*.5;
    elseif event.phase == "ended" and self.isFocus then
      self:setFillColor(1, 1, 1);
      self.isFocus = false;
      display.getCurrentStage():setFocus(nil);
      if self.touchEnded then
        self:touchEnded()
      end
    end
    return true;
  end
  handle:addEventListener("touch", handle);
  
  --we calculate the max value at 100, and min value at 0, where 100 is the right of the bar, and 0 the left one
  function handle:getValue()
    return ((handle.x-bar.x-bar.contentWidth*.5)*100/bar.contentWidth)+100;
  end
  function handle:setValue(value)
    handle.x = bar.x-bar.contentWidth*.5+(value*(bar.contentWidth)/100);
    redBarCenter.xScale = handle.x-redBarStart.x+redBarStart.contentWidth*.5;
    redBarCenter.x = redBarStart.x+redBarStart.contentWidth*.5+(handle.x-redBarStart.x+redBarStart.contentWidth*.5)*.5;
  end
  
  return handle;
end

local poolRemoveSelf = function(self)
  for i = #self, 1, -1 do
    self[i].pool = nil;
    self[i]:removeSelf();
    self[i] = nil;
  end
  self = nil;
end
 
local poolGetObject = function(self)
  local object = self[#self];
  self[#self] = nil;
  return object;
end
 
local poolSetObject = function(self, object)
  self[#self+1] = object;
  return true;
end
 
ragdogLib.initObjectPool = function(numOfObj, data)
  local pool = {};
 
  data.preparedFunctions = {};
  for k,v in pairs(data) do
    if k ~= "create" then
      data.preparedFunctions[#data.preparedFunctions+1] = k;
    end
  end
 
  pool.getObject = poolGetObject;
  pool.setObject = poolSetObject;
  pool.removeSelf = poolRemoveSelf;
 
  for i = 1, numOfObj do
    local object = data.create();
    for a = 1, #data.preparedFunctions do
      object[data.preparedFunctions[a]] = data[data.preparedFunctions[a]];
    end
    object.pool = pool;
    object:deactivate();
  end
 
  return pool;
end

ragdogLib.newComplexButton = function(group, img1, width1, height1, img2, width2, height2, offsetX, offsetY)
  local button = display.newGroup();
  group:insert(button);
  local button1 = display.newImageRect(button, img1, width1, height1);
  local button2 = display.newImageRect(button, img2, width2, height2);
  button2.x, button2.y = offsetX or 0, offsetY or 0;
  button2.isVisible = false;
  function button:touch(event)
    if event.phase == "began" then
      audio.play(_G.buttonSFX, {channel = audio.findFreeChannel()});
      display.getCurrentStage():setFocus(self);
      self.isFocus = true;
      if self.touchBegan then
        self:touchBegan();
      end
      return true;
    elseif event.phase == "moved" and self.isFocus then
      local bounds = self.contentBounds;
      if event.x > bounds.xMax or event.x < bounds.xMin or event.y > bounds.yMax or event.y < bounds.yMin then
        self.isFocus = false;
        display.getCurrentStage():setFocus(nil);
        if self.touchEnded then
          self:touchEnded();
        end
      end
      return true;
    elseif event.phase == "ended" and self.isFocus then
      self.isFocus = false;
      display.getCurrentStage():setFocus(nil);
      if self.touchEnded then
        self:touchEnded();
      end
      return true;
    end
  end
  button:addEventListener("touch", button);
  
  return button;
end


ragdogLib.getSaveValue = function(key)
  if not ragdogLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      ragdogLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  ragdogLib.saveTable = ragdogLib.saveTable or {};
  return ragdogLib.saveTable[key];
end

ragdogLib.setSaveValue = function(key, value, operateSave)
  if not ragdogLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      ragdogLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  ragdogLib.saveTable = ragdogLib.saveTable or {};
  ragdogLib.saveTable[key] = value;
  if operateSave then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "w+");
    local json = require "json";
    file:write(json.encode(ragdogLib.saveTable));
    io.close(file);
  end
  return ragdogLib.saveTable[key];
end

ragdogLib.newSimpleButton = function(group, img, width, height)
  local button = display.newImageRect(group or display.getCurrentStage(), img, width, height);
  function button:touch(event)
    if event.phase == "began" then
      display.getCurrentStage():setFocus(self);
      self.isFocus = true;
      if self.touchBegan then
        self:touchBegan();
      end
      return true;
    elseif event.phase == "moved" and self.isFocus then
      local bounds = self.contentBounds;
      if event.x > bounds.xMax or event.x < bounds.xMin or event.y > bounds.yMax or event.y < bounds.yMin then
        self.isFocus = false;
        display.getCurrentStage():setFocus(nil);
        if self.touchEnded then
          self:touchEnded();
        end
      else
        if self.touchMoved then
          self:touchMoved(event);
        end
      end
      return true;
    elseif event.phase == "ended" and self.isFocus then
      self.isFocus = false;
      display.getCurrentStage():setFocus(nil);
      if self.touchEnded then
        self:touchEnded();
      end
      return true;
    end
  end
  button:addEventListener("touch", button);
  
  return button;
end

ragdogLib.convertRGB = function(r, g, b)
   return {r/255, g/255, b/255};
end

return ragdogLib;
