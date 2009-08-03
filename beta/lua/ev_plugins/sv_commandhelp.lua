/*-------------------------------------------------------------------------------------------------------------------------
	View usage information for a given command
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = { }
PLUGIN.Title = "Command Help"
PLUGIN.Description = "View the usage of a command if available."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "help"
PLUGIN.Usage = "<command>"

function PLUGIN:Call( ply, args )
	for _, plugin in pairs( evolve.plugins ) do
		if ( plugin.ChatCommand and plugin.ChatCommand == string.lower( args[1] or "" ) ) then
			if ( plugin.Usage ) then
				evolve:notify( ply, evolve.colors.blue, plugin.Title, evolve.colors.white, " - " .. plugin.Description )
				evolve:notify( ply, evolve.colors.white, "Usage: !" .. plugin.ChatCommand .. " " .. plugin.Usage )
			else
				evolve:notify( ply, evolve.colors.red, "No help is available for that command." )
			end
			return 
		end
	end
	
	evolve:notify( ply, evolve.colors.red, "Unknown command '" .. ( args[1] or "" ) .. "'." )
end

evolve:registerPlugin( PLUGIN )