local adsLib = {};

local revmob, chartboost, ads, tapfortap, playhaven, adbuddiz;

--Functions localizations and random seed set
local ragdogLib = require "ragdogLib";
local mRandom = math.random;
local Alreadyinitialize = 0;
local adsShowFunctions, adsApiKeys, adsListenerFunctions, adsInitFunctions, adsRemoveBannerFunctions, activeBanners;
math.randomseed(os.time());

adsApiKeys = {
  --VUNGLE ADS http://www.vungle.com
  --ON ANDROID, VUNGLE ADS REQUIRES THE GOOGLE PLAY SERVICES PLUGIN IF YOUR CORONA VERSION IS 2014.2264 OR GREATER
  --MORE INFO HERE http://docs.coronalabs.com/plugin/vungle/index.html
  --VUNGLE SUPPORTS A FUNCTION CALLBACK THAT NOTIFIES YOU IF THE USER HAS WATCHED THE ENTIRE VIDEO, SO THAT YOU CAN REWARD HIM.
  --THE CALLBACK IS _G.VungleCallbackForCompletedVideo, AND RETURNS TRUE IF THE USER HAS WATCHED IT, FALSE IF NOT.
  --AN EXAMPLE OF THE CALLBACK CAN BE
  --_G.VungleCallbackForCompletedVideo = function(result)
  --   if result then
  --     increaseUserCoins();
  --   end
  --end
  --THE CALLBACK CAN BE PLACED ANYWHERE, ANY FILE.
  ["vungle"] = {
    ["Android"] = {
      appId = "Your App ID from Vungle for Android"
    },
    ["iPhone"] = {
      appId = "Your App ID from Vungle for iOS"
    }
  },
  --INNER-ACTIVE ADS http://inner-active.com
  ["inneractive"] = {
    ["Android"] = {
      appId = "Your App ID from Inner-Active for Android"
    },
    ["iPhone"] = {
      appId = "Your App ID from Inner-Active for iOS"
    }
  },
  --INMOBI ADS http://www.inmobi.com  
  ["inmobi"] = {
    ["Android"] = {
      appId = "Your App ID from inMobi for Android"
    },
    ["iPhone"] = {
      appId = "Your App ID from inMobi for iOS"
    }
  },
  --ADBUDDIZ ADS http://www.adbuddiz.com
  ["adbuddiz"] = {
    ["Android"] = {
      publisherKey = "Your App ID from adbuddiz for Android"
    },
    ["iPhone"] = {
      publisherKey = "Your App ID from adbuddiz for iOS"
    }
  },
  --CHARTBOOST ADS http://www.chartboost.com
  --******VERY IMPORTANT******
  --IF YOU'RE USING A CORONA SDK VERSION EQUAL OR MORE RECENT THAN 2014.2169, YOU WILL NEED TO GET THE CHARTBOOST PLUGIN 
  --http://docs.coronalabs.com/plugin/chartboost/index.html
  --THE ABOVE IS TRUE ONLY FOR IOS. ANDROID WORKS WITHOUT ISSUES OR THE NEED OF THE PLUGIN.
  --
  ["chartboostplugin"] = {  
    ["Android"] = {
      appId = "Your app id from chartboost",
      appSignature = "Your app signature from chartboost",
      appVersion = "1.0"
    },
    ["iPhone"] = {
      appId = "5754f57a04b0164118d1fa9e",
      appSignature = "2502f4d8bec6d7dfe5465c579bd982382e68a519",
      appVersion = "1.0"
    }
  },
  ["chartboost"] = {  
    ["Android"] = {
      appId = "Your app id from chartboost",
      appSignature = "Your app signature from chartboost",
      appVersion = "1.0"
    },
    ["iPhone"] = {
      appId = "5754f57a04b0164118d1fa9e",
      appSignature = "2502f4d8bec6d7dfe5465c579bd982382e68a519",
      appVersion = "1.0"
    }
  },
  --REVMOB ADS https://www.revmobmobileadnetwork.com
  ["revmob"] = {
    ["Android"] = {
      appId = "Your app id from revmob"
    },
    ["iPhone"] = {
      appId = "54373b008efc888507c36cd7"
    }
  },
  --TAPFORTAP ADS https://tapfortap.com
  ["tapfortap"] = {
    ["Android"] = {
      appId = "Your app id from tapfortap"
    },
    ["iPhone"] = {
      appId = "Your app id from tapfortap"
    }
  },
  --ADMOB ADS https://www.admob.com
  ["admob"] = {
    ["Android"] = {
      pluginVersion = 2, --SPECIFY IF YOU'RE USING VERSION 1 (OLD) OF THE PLUGIN, OR VERSION 2 (NEW). DIFFERENCIES CAN BE FOUND HERE: http://coronalabs.com/blog/2014/07/15/tutorial-implementing-admob-v2/
      bannerId = "ca-app-pub-4461949699343736/2360475409",
      interstitialId = "ca-app-pub-4461949699343736/3837208603"
    },
    ["iPhone"] = {
      pluginVersion = 2, --SPECIFY IF YOU'RE USING VERSION 1 (OLD) OF THE PLUGIN, OR VERSION 2 (NEW). DIFFERENCIES CAN BE FOUND HERE: http://coronalabs.com/blog/2014/07/15/tutorial-implementing-admob-v2/
      bannerId = "ca-app-pub-4461949699343736/6790675003",
      interstitialId = "ca-app-pub-4461949699343736/8267408209"
    }
  },
  --IADS ADS http://advertising.apple.com
  ["iads"] = {
    ["iPhone"] = {
      appId = "Your app id from iads"
    }
  },
  --PLAYHAVEN ADS http://upsight.com
  ["playhaven"] = {
    ["Android"] = {
      appToken = "Your app token from playhaven",
      appSecret = "Your app secret from playhaven",
      placementId = "Your placement id from playhaven connected to an interstitial ad"
    },
    ["iPhone"] = {
      appToken = "Your app token from playhaven",
      appSecret = "Your app secret from playhaven",
      placementId = "Your placement id from playhaven connected to an interstitial ad"
    }
  }
};

local currentSystem = system.getInfo("platformName");
if currentSystem ~= "Android" then
  currentSystem = "iPhone";
end

adsListenerFunctions = {
  ["vungle"] = function(event)
    if event.isError then
      if ads.ragdogAdsLib and ads.ragdogAdsLib.vungle then
        local adData, providerData = ads.ragdogAdsLib.vungle.adData, ads.ragdogAdsLib.vungle.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    elseif event.type == "adView" then
      if event.isCompletedView then
        if _G.VungleCallbackForCompletedVideo then
          _G.VungleCallbackForCompletedVideo(true);
        end
      else
        if _G.VungleCallbackForCompletedVideo then
          _G.VungleCallbackForCompletedVideo(false);
        end
      end
    end
  end,
  ["inneractive"] = function(event)
    if event.isError then
      if ads.ragdogAdsLib and ads.ragdogAdsLib.inneractive then
        local adData, providerData = ads.ragdogAdsLib.inneractive.adData, ads.ragdogAdsLib.inneractive.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["inmobi"] = function(event)
    if event.isError then
      if ads.ragdogAdsLib and ads.ragdogAdsLib.inmobi then
        local adData, providerData = ads.ragdogAdsLib.inmobi.adData, ads.ragdogAdsLib.inmobi.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["adbuddiz"] = function(event)
    if event.value == "didFailToShowAd" then
      if adbuddiz.ragdogAdsLib then
        local adData, providerData = adbuddiz.ragdogAdsLib.adData, adbuddiz.ragdogAdsLib.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["chartboostplugin"] = function(event)
    if event.type == "interstitial" then
      if event.respone == "failed" then
        if chartboost.ragdogAdsLib then
          local adData, providerData = chartboost.ragdogAdsLib.adData, chartboost.ragdogAdsLib.providerData;
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
        end
      end
    end
  end,
  ["chartboost"] = {
    didFailToLoadInterstitial = function(event)
      if chartboost.ragdogAdsLib then
        local adData, providerData = chartboost.ragdogAdsLib.adData, chartboost.ragdogAdsLib.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  },
  ["revmob"] = function(event)
    if event.type == "adNotReceived" then
      if revmob.ragdogAdsLib then
        local adData, providerData = revmob.ragdogAdsLib.adData, revmob.ragdogAdsLib.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["tapfortap"] = function(event)
    if event.event == "onFailToReceiveAd" then
      if tapfortap.ragdogAdsLib then
        local adData, providerData = tapfortap.ragdogAdsLib.adData, tapfortap.ragdogAdsLib.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["admob"] = function(event)
    if event.isError then
      if ads.ragdogAdsLib and ads.ragdogAdsLib.admob then
        local adData, providerData = ads.ragdogAdsLib.admob.adData, ads.ragdogAdsLib.admob.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["iads"] = function(event)
    if event.isError then
      if ads.ragdogAdsLib and ads.ragdogAdsLib.iads then
        local adData, providerData = ads.ragdogAdsLib.iads.adData, ads.ragdogAdsLib.iads.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end,
  ["playhaven"] = function(event)
    if event.status == "didFail" or event.status == "requestFailed" then
      if playhaven.ragdogAdsLib then
        local adData, providerData = playhaven.ragdogAdsLib.adData, playhaven.ragdogAdsLib.providerData;
        adData.fallbackCount = adData.fallbackCount or 0;
        adData.fallbackCount = adData.fallbackCount+1;
        if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
          adsShowFunctions[adData.providers[providerData.providerFallback].providerName][adData.adType](adData.providers[providerData.providerFallback], adData);
        else
          adData.fallbackCount = 0;
        end
      end
    end
  end
};

adsInitFunctions = {
  ["vungle"] = function()
    ads = require "ads";
    ads.init("vungle", adsApiKeys.vungle[currentSystem].appId, adsListenerFunctions.vungle);
  end,
  ["inneractive"] = function()
    ads = require "ads";
    ads.init("inneractive", adsApiKeys.inneractive[currentSystem].appId, adsListenerFunctions.inneractive);
  end,
  ["inmobi"] = function()
    ads = require "ads";
    ads.init("inmobi", adsApiKeys.inmobi[currentSystem].appId, adsListenerFunctions.inmobi);
  end,
  ["adbuddiz"] = function()
    adbuddiz = require("plugin.adbuddiz");
    if currentSystem == "Android" then
      adbuddiz.setAndroidPublisherKey(adsApiKeys.adbuddiz[currentSystem].publisherKey);
    else
      adbuddiz.setIOSPublisherKey(adsApiKeys.adbuddiz[currentSystem].publisherKey);
    end
    adbuddiz.cacheAds();
    Runtime:addEventListener("AdBuddizEvent", adsListenerFunctions.adbuddiz);
  end,
  ["chartboostplugin"] = function()
    chartboost = require( "plugin.chartboost" );
    chartboost.init(
    {
      appID = adsApiKeys.chartboostplugin[currentSystem].appId,
      appSignature = adsApiKeys.chartboostplugin[currentSystem].appSignature,  
      listener = adsListenerFunctions.chartboostplugin
    })
    local function systemEvent( event )
      local phase = event.phase;
      if event.type == 'applicationResume' then
        chartboost.startSession( adsApiKeys.chartboostplugin[currentSystem].appId, adsApiKeys.chartboostplugin[currentSystem].appSignature );
      end
      return true
    end
    Runtime:addEventListener('system', systemEvent);
    chartboost.startSession(adsApiKeys.chartboostplugin[currentSystem].appId, adsApiKeys.chartboostplugin[currentSystem].appSignature);
    chartboost.cache("cachedInterstitial");
   -- Alreadyinitialize = 1;
  -- native.showAlert( "No ad available", "Please cache an ad."..Alreadyinitialize, { "OK" });
  end,
  ["chartboost"] = function()
    chartboost = require "adsLib.chartboost.chartboost";
    chartboost.create{
      appId = adsApiKeys.chartboost[currentSystem].appId,
      appSignature = adsApiKeys.chartboost[currentSystem].appSignature,
      appVersion = adsApiKeys.chartboost[currentSystem].appVersion,
      delegate = adsListenerFunctions.chartboost;
    };
    chartboost.startSession();
    chartboost.cacheInterstitial();
  end,
  ["revmob"] = function()
    revmob = require "adsLib.revmob.revmob";
    revmob.startSession({["Android"] = adsApiKeys.revmob["Android"].appId, ["iPhone OS"] = adsApiKeys.revmob["iPhone"].appId });
  end,
  ["tapfortap"] = function()
    tapfortap = require "plugin.tapfortap";
    tapfortap.initialize(adsApiKeys.tapfortap[currentSystem].appId);
    tapfortap.setInterstitialListener(adsListenerFunctions.tapfortap);
    tapfortap.setAdViewListener(adsListenerFunctions.tapfortap);
    tapfortap.prepareInterstitial();
  end,
  ["admob"] = function()
    ads = require "ads";
    local adMobAppId = adsApiKeys.admob[currentSystem].bannerId;
    if adMobAppId == "Your app id from admob for a banner ad" then
      adMobAppId = adsApiKeys.admob[currentSystem].interstitialId;
    end
    ads.init("admob", adMobAppId, adsListenerFunctions.admob);
    if ads:getCurrentProvider() ~= "admob" then
      ads:setCurrentProvider("admob");
    end
    if adsApiKeys.admob[currentSystem].interstitialId ~= "Your app id from admob for an interstitial ad" then
      ads.load("interstitial", {appId = adsApiKeys.admob[currentSystem].interstitialId, testMode = false});
    end
  end,
  ["iads"] = function()
    ads = require "ads";
    ads.init("iads", adsApiKeys.iads["iPhone"].appId, adsListenerFunctions.iads);
  end,
  ["playhaven"] = function()
    playhaven = require "plugin.playhaven";
    playhaven.init(adsListenerFunctions.playhaven, {
        token = adsApiKeys.playhaven[currentSystem].appToken,
        secret = adsApiKeys.playhaven[currentSystem].appSecret,
        closeButton = system.pathForFile("adsLib/playhaven/closeButton.png", system.ResourceDirectory),
        closeButtonTouched = system.pathForFile("adsLib/playhaven/closeButtonTouched.png", system.ResourceDirectory)
    });
  end
};

adsShowFunctions = {
  ["vungle"] = {
    ["interstitial"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "vungle" then
        ads:setCurrentProvider("vungle");
      end
      
      if providerData.mustBeCached then
        if not ads.isAdAvailable() then
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        end
      end
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.vungle = ads.ragdogAdsLib.vungle or {};
      ads.ragdogAdsLib.vungle.adData = adData;
      ads.ragdogAdsLib.vungle.providerData = providerData;
      
      ads.show("interstitial");
    end
  },
  ["inneractive"] = {
    ["interstitial"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "inneractive" then
        ads:setCurrentProvider("inneractive");
      end

      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.inneractive = ads.ragdogAdsLib.inneractive or {};
      ads.ragdogAdsLib.inneractive.adData = adData;
      ads.ragdogAdsLib.inneractive.providerData = providerData;
      
      ads.show("fullscreen");
    end,
    ["banner"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "inneractive" then
        ads:setCurrentProvider("inneractive");
      end
      
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.inneractive = ads.ragdogAdsLib.inneractive or {};
      ads.ragdogAdsLib.inneractive.adData = adData;
      ads.ragdogAdsLib.inneractive.providerData = providerData;
      
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = display.screenOriginX, display.screenOriginY;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = display.screenOriginX, 10000;
      end
      
      ads.show("banner", { x= xPos, y= yPos});
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "inneractive";
    end
  },
  ["inmobi"] = {
    ["interstitial"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "inmobi" then
        ads:setCurrentProvider("inmobi");
      end

      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.inmobi = ads.ragdogAdsLib.inmobi or {};
      ads.ragdogAdsLib.inmobi.adData = adData;
      ads.ragdogAdsLib.inmobi.providerData = providerData;
      
      ads.show("interstitial");
    end,
    ["banner"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "inmobi" then
        ads:setCurrentProvider("inmobi");
      end
      
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.inmobi = ads.ragdogAdsLib.inmobi or {};
      ads.ragdogAdsLib.inmobi.adData = adData;
      ads.ragdogAdsLib.inmobi.providerData = providerData;
      
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = display.screenOriginX, display.screenOriginY;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = display.screenOriginX, 10000;
      end
      
      ads.show("banner320x50", { x= xPos, y= yPos});
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "inmobi";
    end
  },
  ["adbuddiz"] = {
    ["interstitial"] = function(providerData, adData)
      if providerData.mustBeCached then
        if not adbuddiz.isReadyToShowAd() then
          adbuddiz.cacheAds();
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        end
      end
      adbuddiz.ragdogAdsLib = adbuddiz.ragdogAdsLib or {};
      adbuddiz.ragdogAdsLib.adData = adData;
      adbuddiz.ragdogAdsLib.providerData = providerData;
      
      adbuddiz.showAd();
    end
  },
  ["chartboostplugin"] = {
    ["interstitial"] = function(providerData, adData)
      if providerData.mustBeCached then
        if not chartboost.hasCachedInterstitial("cachedInterstitial") then
          chartboost.cache("cachedInterstitial");
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        else
          chartboost.show( 'interstitial', "cachedInterstitial");
        end
      else
        chartboost.show('interstitial');
      end
      chartboost.ragdogAdsLib = chartboost.ragdogAdsLib or {};
      chartboost.ragdogAdsLib.adData = adData;
      chartboost.ragdogAdsLib.providerData = providerData;
     -- native.showAlert( "No ad available", "In show.", { "OK" });
    end
  },
  ["chartboost"] = {
    ["interstitial"] = function(providerData, adData)
      if providerData.mustBeCached then
        if not chartboost.hasCachedInterstitial() then
         chartboost.cacheInterstitial();
        --  chartboost.cache( "interstitial" );
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        end
      end
      chartboost.ragdogAdsLib = chartboost.ragdogAdsLib or {};
      chartboost.ragdogAdsLib.adData = adData;
      chartboost.ragdogAdsLib.providerData = providerData;
      
      chartboost.showInterstitial();
      --chartboost.show( "interstitial" );
    end
  },
  ["revmob"] = {
    ["interstitial"] = function(providerData, adData)
      revmob.ragdogAdsLib = revmob.ragdogAdsLib or {};
      revmob.ragdogAdsLib.adData = adData;
      revmob.ragdogAdsLib.providerData = providerData;
      
      revmob.showFullscreen(adsListenerFunctions.revmob);
    end,
    ["banner"] = function(providerData, adData)
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = display.contentCenterX, display.screenOriginY+20;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = display.contentCenterX, display.contentHeight-display.screenOriginY-20;
      end
      
      revmob.ragdogAdsLib = revmob.ragdogAdsLib or {};
      revmob.ragdogAdsLib.adData = adData;
      revmob.ragdogAdsLib.providerData = providerData;
      
      revmob.ragdogAdsLib.currentBanner = revmob.createBanner({x = xPos, y = yPos, width = display.contentWidth-(display.screenOriginX*2), height = 40, listener = adsListenerFunctions.revmob});
      
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "revmob";
    end
  },
  ["tapfortap"] = {
    ["interstitial"] = function(providerData, adData)
      if providerData.mustBeCached then
        if not tapfortap.interstitialIsReady() then
          tapfortap.prepareInterstitial();
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        end
      end
      tapfortap.ragdogAdsLib = tapfortap.ragdogAdsLib or {};
      tapfortap.ragdogAdsLib.adData = adData;
      tapfortap.ragdogAdsLib.providerData = providerData;
 
      tapfortap.showInterstitial();
    end,
    ["banner"] = function(providerData, adData)
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = 1, 2;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = 3, 2;
      end   
      tapfortap.ragdogAdsLib = tapfortap.ragdogAdsLib or {};
      tapfortap.ragdogAdsLib.adData = adData;
      tapfortap.ragdogAdsLib.providerData = providerData;
      
      tapfortap.createAdView(xPos, yPos);
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "tapfortap";
    end
  },
  ["admob"] = {
    ["interstitial"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "admob" then
        ads:setCurrentProvider("admob");
      end
      
      if providerData.mustBeCached then
        if not ads.isLoaded() then
          ads.load("interstitial", {appId = adsApiKeys.admob[currentSystem].interstitialId, testMode = false});
          adData.fallbackCount = adData.fallbackCount or 0;
          adData.fallbackCount = adData.fallbackCount+1;
          if providerData.providerFallback and adData.fallbackCount <= #adData.providers then
            adsShowFunctions[adData.providers[providerData.providerFallback].providerName]["interstitial"](adData.providers[providerData.providerFallback], adData);
          else
            adData.fallbackCount = 0;
          end
          return;
        end
      end
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.admob = ads.ragdogAdsLib.admob or {};
      ads.ragdogAdsLib.admob.adData = adData;
      ads.ragdogAdsLib.admob.providerData = providerData;
      
      ads.show("interstitial", {appId = adsApiKeys.admob[currentSystem].interstitialId});
    end,
    ["banner"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "admob" then
        ads:setCurrentProvider("admob");
      end
      
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.admob = ads.ragdogAdsLib.admob or {};
      ads.ragdogAdsLib.admob.adData = adData;
      ads.ragdogAdsLib.admob.providerData = providerData;
      
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = display.screenOriginX, display.screenOriginY;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = display.screenOriginX, 10000;
      end
      
      ads.show("banner", { x= xPos, y= yPos, appId = adsApiKeys.admob[currentSystem].bannerId});
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "admob";
    end
  },
  ["iads"] = {
    ["banner"] = function(providerData, adData)
      if ads:getCurrentProvider() ~= "iads" then
        ads:setCurrentProvider("iads");
      end
      
      ads.ragdogAdsLib = ads.ragdogAdsLib or {};
      ads.ragdogAdsLib.iads = ads.ragdogAdsLib.iads or {};
      ads.ragdogAdsLib.iads.adData = adData;
      ads.ragdogAdsLib.iads.providerData = providerData;
      
      local xPos, yPos;
      adData.adPosition = adData.adPosition or "top";
      if adData.adPosition == "top" then
        xPos, yPos = display.screenOriginX, display.screenOriginY;
      elseif adData.adPosition == "bottom" then
        xPos, yPos = display.screenOriginX, 10000;
      end
      
      ads.show("banner", { x= xPos, y= yPos, appId = adsApiKeys.admob[currentSystem].bannerId});
      activeBanners = activeBanners or {};
      activeBanners[adData.innerId] = "iads";
    end
  },
  ["playhaven"] = {
    ["interstitial"] = function(providerData, adData)
      playhaven.ragdogAdsLib = playhaven.ragdogAdsLib or {};
      playhaven.ragdogAdsLib.adData = adData;
      playhaven.ragdogAdsLib.providerData = providerData;
      
      playhaven.contentRequest(adsApiKeys.playhaven[currentSystem].placementId, true);
    end
  }
};

adsRemoveBannerFunctions = {
  ["revmob"] = function()
    if revmob.ragdogAdsLib and revmob.ragdogAdsLib.currentBanner then
      revmob.ragdogAdsLib.currentBanner:release();
      revmob.ragdogAdsLib.currentBanner = nil;
    end
  end,
  ["tapfortap"] = function()
    tapfortap.removeAdView();
  end,
  ["admob"] = function()
    if ads:getCurrentProvider() ~= "admob" then
      ads:setCurrentProvider("admob");
    end
    ads:hide();
  end,
  ["iads"] = function()
    if ads:getCurrentProvider() ~= "iads" then
      ads:setCurrentProvider("iads");
    end
    ads:hide();
  end,
  ["inmobi"] = function()
    if ads:getCurrentProvider() ~= "inmobi" then
      ads:setCurrentProvider("inmobi");
    end
    ads:hide();
  end,
  ["inneractive"] = function()
    if ads:getCurrentProvider() ~= "inneractive" then
      ads:setCurrentProvider("inneractive");
    end
    ads:hide();
  end
};

adsLib.init = function(activeAds, adsSettings)
  if _G.activeRemoveAdsButton then
    if ragdogLib.getSaveValue("isAdsRemoved") then
      return;
    end
  end
  adsLib.adsSettings = adsSettings;
  activeAds = activeAds[currentSystem];
  for i = 1, #activeAds do
    adsInitFunctions[activeAds[i]]();
  end
end

adsLib.showAd = function(adId)
  if _G.activeRemoveAdsButton then
    if ragdogLib.getSaveValue("isAdsRemoved") then
      return;
    end
  end
  local selectedAd = adsLib.adsSettings[currentSystem][adId];
  if not selectedAd then
    return;
  end
  selectedAd.innerId = adId;
  if selectedAd.frequency > 1 then
    selectedAd.currentFrequencyCount = selectedAd.currentFrequencyCount or 0;
    selectedAd.currentFrequencyCount = selectedAd.currentFrequencyCount+1;
    if selectedAd.currentFrequencyCount >= selectedAd.frequency then
      selectedAd.currentFrequencyCount = 0;
    else
      return;
    end
  end
  
  local chosenProvider;
  if selectedAd.mediationType == "order" then
    if selectedAd.keepOrderDuringSession then
      selectedAd.currentOrderCount = ragdogLib.getSaveValue(adId.."order") or 0;
    end
    selectedAd.currentOrderCount = selectedAd.currentOrderCount or 0;
    selectedAd.currentOrderCount = selectedAd.currentOrderCount+1;
    if selectedAd.currentOrderCount > #selectedAd.providers then
      selectedAd.currentOrderCount = 1;
    end
    if selectedAd.keepOrderDuringSession then
      ragdogLib.setSaveValue(adId.."order", selectedAd.currentOrderCount, true);
    end
    chosenProvider = selectedAd.providers[selectedAd.currentOrderCount];
  elseif selectedAd.mediationType == "percentage" then
    local chance = mRandom(1, 100);
    local currentWeight = 0;
    for i = 1, #selectedAd.providers do
      currentWeight = currentWeight+selectedAd.providers[i].weight;
      if chance <= currentWeight then
        chosenProvider = selectedAd.providers[i];
        break;
      end
    end
  end
 --native.showAlert( "No ad available", "Please cache an ad." , { "OK" });
  adsShowFunctions[chosenProvider.providerName][selectedAd.adType](chosenProvider, selectedAd);
end

adsLib.removeAd = function(adId)
  if activeBanners and activeBanners[adId] then
    adsRemoveBannerFunctions[activeBanners[adId]]();
  end
end

return adsLib;