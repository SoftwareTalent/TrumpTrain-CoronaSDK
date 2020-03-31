local networksLib = {};

local gameNetwork = require "gameNetwork";

local currentSystem = system.getInfo("platformName");
if currentSystem ~= "Android" and currentSystem ~= "iPhone OS" then
  currentSystem = "Android";
end

local activeNetworksProviders;
local currentNetwork;

local leaderBoards, achievements = {}, {}
  leaderBoards.Easy = "com.appledts.EasyTapList"
  leaderBoards.Hard = "com.appledts.HardTapList"
  leaderBoards.Awesome = "com.appledts.AwesomeTapList"
  achievements.OneTap = "com.appletest.one_tap"
  achievements.TwentyTaps = "com.appledts.twenty_taps"
  achievements.OneHundredTaps = "com.appledts.one_hundred_taps"
local currentBoard = "Easy"


local function offlineAlert() 
  native.showAlert( "GameCenter Offline", "Please check your internet connection.", { "OK" } )
end
local function onlineAlert() 
  native.showAlert( "GameCenter online", "connected to gamecenter.", { "OK" } )
end

local initializeFunctions = {
  ["google"] = function()
    gameNetwork.init("google", function(event) 
       gameNetwork.request("login", { userInitiated=true, listener=function()  print("User logged in google game services"); end });
    end);
  end,
  ["gamecenter"] = function()
    gameNetwork.init( "gamecenter", { listener=initCallback } )
  end
};

networksLib.init = function(activeNetworks)
  activeNetworksProviders = activeNetworks;
  currentNetwork = activeNetworks[currentSystem][1];
  if initializeFunctions[currentNetwork] then
    initializeFunctions[currentNetwork]();
  end
end

local function initCallback( event )
offlineAlert();

  -- "showSignIn" is only available on iOS 6+
  if event.type == "showSignIn" then
    -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
    -- For the iOS 6.0 landscape orientation bug, this is an opportunity to remove native objects so they won't rotate.
  -- This is type "init" for all versions of Game Center.
  elseif event.data then
    loggedIntoGC = true
    onlineAlert();
  end

end
networksLib.showLeaderboard = function()
  if currentNetwork == "google" then
    gameNetwork.show("leaderboards");
  elseif currentNetwork == "gamecenter" then
    gameNetwork.show("leaderboards", { leaderboard = {timeScope="AllTime"}});
  end
end

networksLib.addScoreToLeaderboard = function(score)
  if currentNetwork == "google" then
    gameNetwork.request( "setHighScore",
    {
      localPlayerScore = { category= activeNetworksProviders[currentSystem][2], value=tonumber(score) }, 
      listener = function() print("Score was posted"); end
    });
  elseif currentNetwork == "gamecenter" then
    gameNetwork.request( "setHighScore",
    {
        localPlayerScore = { category=activeNetworksProviders[currentSystem][2], value=tonumber(score) },
        listener= function() print("Score was posted"); end
    })

  end
     --gameNetwork.request( "setHighScore", { localPlayerScore={ category=leaderBoards[currentBoard], value=userScore }, listener=requestCallback } ); else offlineAlert();

end

return networksLib;