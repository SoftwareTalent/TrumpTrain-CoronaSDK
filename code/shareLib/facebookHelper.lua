local facebook = require "plugin.facebook.v4";
local json = require "json";
local facebookHelper = {};
local appID = _G.facebookAPPID;

facebookHelper.postOnUserWall = function(message)
  native.setActivityIndicator(true);
  local listener;
  listener = function(event)
    --CHECK THE DOCS TO SEE HOW TO AVOID THE NEED FOR PUBLISH_ACTIONS PERMISSION
	  if ( "session" == event.type ) then
		  if ( "login" == event.phase ) then
        local postMsg = {
          message = message,
          picture = "Link to your game icon",
          description = "Get Target The Dot game, the biggest hits currently on the stores!",
          link = "http://<your facebook page URL>",
          name = "Target The Dot Template",
          caption = "Target The Dot!"
        };
        facebook.request( "me/feed", "POST", postMsg )
        native.setActivityIndicator(true);
		  end
	  elseif ("request" == event.type) then	
			local respTab = json.decode(event.response);
      native.setActivityIndicator(false);
   		if respTab then
         native.showAlert("Success", "Message successfuly posted!", {"OK"});
			end
		end
    native.setActivityIndicator(nil);
	end
  facebook.login(appID, listener, {"publish_actions"});
end

return facebookHelper;