-- config.lua

application =
{	
    content =
    {
        fps = 60,
        width = 320,
        height = 480,
        scale = "letterbox",
        antialias = true,
        imageSuffix =
        {
          ["@4x"] = 4,
        	  ["@2x"] = 2
        },

    },
	notification =
	{
	    iphone =
	    {
	        types =
	        {
	           "badge", "sound", "alert"
	        }
	    },
	}
}