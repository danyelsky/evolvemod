/*-------------------------------------------------------------------------------------------------------------------------
	Ban a player
-------------------------------------------------------------------------------------------------------------------------*/

local PLUGIN = {}
PLUGIN.Title = "Ban"
PLUGIN.Description = "Ban a player."
PLUGIN.Author = "Overv"
PLUGIN.ChatCommand = "ban"
PLUGIN.Usage = "<player> [time=5] [reason]"
PLUGIN.Privileges = { "Ban", "Permaban" }

function PLUGIN:Call( ply, args )
	local time = math.Clamp( tonumber( args[2] ) or 5, 0, 10080 )
	
	if ( ( time > 0 and ply:EV_HasPrivilege( "Ban" ) ) or ( time == 0 and ply:EV_HasPrivilege( "Permaban" ) ) ) then
		local pl = evolve:FindPlayer( args[1] )
		
		if ( #pl > 1 ) then
			evolve:Notify( ply, evolve.colors.white, "Did you mean ", evolve.colors.red, evolve:CreatePlayerList( pl, true ), evolve.colors.white, "?" )
		elseif ( #pl == 0 ) then
			evolve:Notify( ply, evolve.colors.red, "No matching players found." )
		else
			for _, v in ipairs( ents.GetAll() ) do
				if ( v:EV_GetOwner() == pl[1]:UniqueID() ) then v:Remove() end
			end
			
			local time = math.Clamp( tonumber( args[2] ) or 5, 0, 10080 )
			local reason = table.concat( args, " ", 3 )
			if ( #reason == 0 ) then reason = "No reason specified" end
			
			if ( time > 0 ) then pl[1]:SetProperty( "BanEnd", os.time() + time * 60 ) else pl[1]:SetProperty( "BanEnd", 0 ) end
			pl[1]:SetProperty( "BanReason", reason )
			pl[1]:SetProperty( "BanAdmin", ply:UniqueID() )
			evolve:CommitProperties()
			
			if ( time == 0 ) then
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " banned ", evolve.colors.red, pl[1]:Nick(), evolve.colors.white, " permanently (" .. reason .. ")." )
				
				if ( gatekeeper ) then
					gatekeeper.Drop( pl[1]:UserID(), "Permanently banned (" .. reason .. ")" )
				else
					pl[1]:Kick( "Permanently banned (" .. reason .. ")" )
				end
			else
				evolve:Notify( evolve.colors.blue, ply:Nick(), evolve.colors.white, " banned ", evolve.colors.red, pl[1]:Nick(), evolve.colors.white, " for " .. time .. " minutes (" .. reason .. ")." )
				
				if ( gatekeeper ) then
					gatekeeper.Drop( pl[1]:UserID(), "Banned for " .. time .. " minutes (" .. reason .. ")" )
				else
					pl[1]:Kick( "Banned for " .. time .. " minutes (" .. reason .. ")" )
				end
			end
		end
	else
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
end

function PLUGIN:PlayerAuthed( ply, steamid, uniqueid )
	if ( ply:GetProperty( "BanEnd", false ) ) then
		if ( ply:GetProperty( "BanEnd" ) > os.time() or tonumber( ply:GetProperty( "BanEnd" )  ) == 0 ) then
			ply:Kick( "Banned." )
		else
			ply:SetProperty( "BanEnd", nil )
			evolve:CommitProperties()
		end
	end
end

function PLUGIN:Menu( arg, players )
	if ( arg ) then
		RunConsoleCommand( "ev", "ban", players[1], arg )
	else
		return "Ban", evolve.category.administration, {
			{ "5 minutes", "5" },
			{ "10 minutes", "10" },
			{ "15 minutes", "15" },
			{ "30 minutes", "30" },
			{ "1 hour", "60" },
			{ "2 hours", "120" },
			{ "4 hours", "240" },
			{ "12 hours", "720" },
			{ "One day", "1440" },
			{ "Two days", "2880" },
			{ "One week", "10080" },
			{ "Two weeks", "20160" },
			{ "One month", "43200" },
			{ "One year", "525600" },
			{ "Permanently", "0" }
		}, "Time"
	end
end

evolve:RegisterPlugin( PLUGIN )