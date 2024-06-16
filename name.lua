local Steam = Steam
local steam_uid = Steam.userid
local name = managers.network.account:username() -- Spoof name here if you want, just change "managers.network.account:username()" to "your spoof name"
function update_name()
	if not userid or userid == steam_uid(Steam) then
		return name
	else
		return name
	end
end
 
function update_name_spoof()
	local s = managers.network:session()
	if not s then
		return
	end
	
	local my_peer = s:local_peer()
	my_peer:set_name( name )
	
	for _, peer in pairs( s._peers ) do
		if not peer:loaded() or not my_peer:loaded() then
			peer:send( "request_player_name_reply", name )
		end
		peer:send( "request_player_name_reply", name )
	end
end

update_name()
update_name_spoof()
