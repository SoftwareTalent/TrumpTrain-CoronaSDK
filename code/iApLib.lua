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

local store = require "store";

local iApLib = {};
local resultFun;

local function iApListener(event)
  local transaction = event.transaction;
  if ( transaction.state == "purchased" ) then
    native.setActivityIndicator(false);
    if type(resultFun) == "table" then
      if resultFun[transaction.productIdentifier] then
        resultFun[transaction.productIdentifier]();
      end
    else
      if resultFun then
        resultFun(true);
      end
    end
  elseif (transaction.state == "restored") then
    if resultFun[transaction.productIdentifier] then
      resultFun[transaction.productIdentifier]();
    end
  elseif ( transaction.state == "cancelled" ) then
    native.setActivityIndicator(false);
    native.showAlert("Error", "The purchase was cancelled", {"Ok"});
  elseif ( transaction.state == "failed" ) then
    native.setActivityIndicator(false);
    native.showAlert("Error", "The purchase has failed", {"Ok"});
  end
  store.finishTransaction( event.transaction )
end

iApLib.restoreItems = function(items)
  if store.canMakePurchases then
    resultFun = {};
    for i = 1, #items do
      resultFun[items[i].id] = items[i].callback;
    end
    store.restore();
  else
    native.showAlert("Error", "Purchases are not supported on this device.", {"Ok"});
  end
end

iApLib.purchaseItem = function(item, callback)
  resultFun = callback;
  if store.canMakePurchases then
    native.setActivityIndicator(true);
    store.purchase(item);
  else
    native.showAlert("Error", "Purchases are not supported on this device.", {"Ok"});
  end
end

if system.getInfo("platformName") == "Android" then
  store.init("google", iApListener);
else
  store.init("apple", iApListener);
end

return iApLib;
