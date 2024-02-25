--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 1080,
		height = 2400, 
		scale = "letterbox",
		fps = 60,
		
		imageSuffix =
		{
			["@2x"] = 2,
			["@4x"] = 4,
		},
	},

	-- Area Plugins
	plugins = {
		accelerometer = true
	}
}
