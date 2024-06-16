local ml = managers.localization

session = managers.network:session()
nr_player = nr_player or session:amount_of_players()

function ps_name_spoof(name)
	local s = managers.network:session()
	if not s then
		return
	end
	
	local my_peer = s:local_peer()
	my_peer:set_name( name )
	
	for _, peer in pairs( s._peers ) do
		peer:send( "request_player_name_reply", name )
	end
end

tele = tele or function(info)
	function Use_Peer(id)
		for _, u_data in pairs(managers.groupai:state():all_player_criminals()) do
			local player = u_data.unit
			local player_id = player:network():peer():id()
			if id == player_id or id == -1 then
				player:network():send("sync_player_movement_state", "dead", 1, player:id())
				player:network():send_to_unit({"spawn_dropin_penalty", true, nil, 1, nil, nil})
				managers.groupai:state():on_player_criminal_death(player:network():peer():id())
				DelayedCalls:Add( "teleport_all", 2, function()
				    IngameWaitingForRespawnState.request_player_spawn(id)
				end)
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_tele_to_me_state'), ml:text('plst_tele_to_me_desc'), menu_options)
		menu:Show()
	end
end

custody_me = custody_me or function(info)
	local player = managers.player:local_player()
	if player then 
	    managers.player:force_drop_carry()
	    managers.statistics:downed( { death = true } )
	    IngameFatalState.on_local_player_dead()
	    game_state_machine:change_state_by_name( "ingame_waiting_for_respawn" )
	    player:character_damage():set_invulnerable( true )
	    player:character_damage():set_health( 0 )
	    player:base():_unregister()
	    player:base():set_slot( player, 0 )
	end
end

un_custody_all = un_custody_all or function(info)
	if BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()] then
		for id = 1, 4, 1 do
			if managers.network:session():peer(id) and not alive(managers.network:session():peer(id):unit()) then
				IngameWaitingForRespawnState.request_player_spawn(id)
			end
		end
	end
end

teleporting = teleporting or function(info)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		if peer then
			local pos
			for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
				if pl_record.status ~= "dead" then
					local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
					if unit:network():peer():id() == id then
						pos = unit:position()
					end
				end
			end
			if pos then
				managers.player:warp_to(pos, managers.player:player_unit():rotation())
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_tele_to_state'), ml:text('plst_tele_to_desc'), menu_options)
		menu:Show()
	end
end

local slow_mo = function(name)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
		    peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0.05, 1, 3600, 1)
			
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0.05, 1, 3600, 1)
		end
	end
	function Use_Peers_2(id)
	    ps_name_spoof(name)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("stop_timespeed_effect", "pause", 1)
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_slow_mo_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = ml:text('plst_slow_mo_all_restore'), callback = Use_Peers_2}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_slow_mo'), menu_options)
		menu:Show()
	end
end

local stop = function(name)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0, 1, 3600, 1)
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0, 1, 3600, 1)
		end
	end
	function Use_Peers_2(id)
	    ps_name_spoof(name)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("stop_timespeed_effect", "pause", 1)
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_stop_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = ml:text('plst_stop_all_restore'), callback = Use_Peers_2}
		menu_options[#menu_options+1] = {text = " ", callback = Use_Peers_2}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_stop'), menu_options)
		menu:Show()
	end
end

local arrested = function(name)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
			for pl_key, pl_record in pairs(managers.groupai:state():all_player_criminals()) do
				if pl_record.status ~= "arrested" then
					local unit = managers.groupai:state():all_player_criminals()[pl_key].unit
					if unit:network():peer():id() == id then
						unit:network():send_to_unit({"sync_player_movement_state", unit, "arrested", 2, unit:id()})
					end 
				end	
			end	
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "arrested" then
				local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
				unit:network():send_to_unit( { "sync_player_movement_state", unit, "arrested", 0, unit:id() } )
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_cuff_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_cuff'), menu_options)
		menu:Show()
	end
end

local tased = function(name)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
			for pl_key, pl_record in pairs(managers.groupai:state():all_player_criminals()) do
				if pl_record.status ~= "tased" then
					local unit = managers.groupai:state():all_player_criminals()[pl_key].unit
					if unit:network():peer():id() == id then
						unit:network():send_to_unit({"sync_player_movement_state", unit, "tased", 2, unit:id()})
					end
				end
			end
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "tased" then
				local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
				unit:network():send_to_unit( { "sync_player_movement_state", unit, "tased", 0, unit:id() } )
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_tase_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_tase'), menu_options)
		menu:Show()
	end
end

local downed = function(name)
    function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
			for pl_key, pl_record in pairs(managers.groupai:state():all_player_criminals()) do
				if pl_record.status ~= "incapacitated" then
					local unit = managers.groupai:state():all_player_criminals()[pl_key].unit
					if unit:network():peer():id() == id then
						unit:network():send_to_unit({"sync_player_movement_state", unit, "incapacitated", 2, unit:id()})
					end 
				end	
			end	
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "incapacitated" then
				local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
				unit:network():send_to_unit( { "sync_player_movement_state", unit, "incapacitated", 0, unit:id() } )
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_incapacitated_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_incapacitated'), menu_options)
		menu:Show()
	end
end

local bleedout = function(name)
    function Use_Peer(id)
	    ps_name_spoof(name)
		local peer = managers.network._session:peer(id)
		if peer then
			for pl_key, pl_record in pairs(managers.groupai:state():all_player_criminals()) do
				if pl_record.status ~= "bleed_out" then
					local unit = managers.groupai:state():all_player_criminals()[pl_key].unit
					if unit:network():peer():id() == id then
						unit:network():send_to_unit({"sync_player_movement_state", unit, "bleed_out", 2, unit:id()})
					end 
				end	
			end	
		end
	end
	function Use_Peers(id)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "bleed_out" then
				local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
				unit:network():send_to_unit( { "sync_player_movement_state", unit, "bleed_out", 0, unit:id() } )
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_bleedout_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_bleedout'), menu_options)
		menu:Show()
	end
end

local kill = function(name)
    function Use_Peer(id)
	    local session = managers.network._session
	    if ( session ) then
		    local peer = session:peer( id )
		    if ( peer ) then
			    --ps_name_spoof(name)
			    if not peer:unit() then
                   return
                end
				ps_name_spoof(name)
				peer:send("sync_friendly_fire_damage", peer:id(), peer:unit(), 900000, "fire")
                --peer:send("sync_trip_mine_set_armed", peer:unit(), "explosive", 1)
                --peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 16384, peer:id())
                --peer:send("sync_flame_bullet", peer:unit():position(), math.UP, 1638400, peer:id())					
			end
	    end
    end

    function Use_Peers(id)
	    ps_name_spoof(name)
	    for peer_id, peer in pairs(managers.network._session._peers) do
			if not peer:unit() then
                return
            end
            peer:send("sync_friendly_fire_damage", peer:id(), peer:unit(), 900000, "fire")
			--peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 16384, peer:id())
		end
    end

    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = ml:text('plst_kill_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_cant_spoof') .. "\n"  .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_kill'), menu_options)
	    menu:Show()
    end
end

local conkill = function(name) 
    function PlayerState_con_kill(id, interval)
        DelayedCalls:Add("PlayerState_con_kill", interval, function()
		    local session = managers.network._session
	        if ( session ) then
		        local peer = session:peer( id )
		        if ( peer ) and peer:unit() then
			        ps_name_spoof(name)
                    peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 16384, peer:id())
                    peer:send("sync_flame_bullet", peer:unit():position(), math.UP, 16384, peer:id())
				    if ( peer ) and peer:unit() then
                        PlayerState_con_kill(id, 2) 
		            end
		        end
				PlayerState_con_kill(id, 2) --uncustody & rejoin detect
	        end		
	    end)
    end

    function Use_Peer(id)
	    local session = managers.network._session
	    if ( session ) then
		    local peer = session:peer( id )
		    if ( peer ) then
			    if not peer:unit() then
                   return
                end
                PlayerState_con_kill(id, 0.1)
		    end
	    end
    end


    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_conkill'), menu_options)
	    menu:Show()
    end
end

local reviev = function(name)
    function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		ps_name_spoof(name)
		if peer then
			for pl_key, pl_record in pairs(managers.groupai:state():all_player_criminals()) do
				if pl_record.status ~= "standard" then
					local unit = managers.groupai:state():all_player_criminals()[pl_key].unit
					if unit:network():peer():id() == id then
						unit:network():send_to_unit({"sync_player_movement_state", unit, "standard", 2, unit:id()})
					end 
				end	
			end	
		end
	end
	function Use_Peers(id)
	    ps_name_spoof(name)
		for pl_key, pl_record in pairs( managers.groupai:state():all_player_criminals() ) do
			if pl_record.status ~= "standard" then
				local unit = managers.groupai:state():all_player_criminals()[ pl_key ].unit
				unit:network():send_to_unit( { "sync_player_movement_state", unit, "standard", 0, unit:id() } )
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_standard_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_standard'), menu_options)
		menu:Show()
	end
end

local custody = function(name)
	function Use_Peer(id)
	    ps_name_spoof(name)
		for _, u_data in pairs(managers.groupai:state():all_player_criminals()) do
			local player = u_data.unit
			local player_id = player:network():peer():id()
			if id == player_id or id == -1 then
				player:network():send("sync_player_movement_state", "dead", 1, player:id())
				player:network():send_to_unit({"spawn_dropin_penalty", true, nil, 1, nil, nil})
				managers.groupai:state():on_player_criminal_death(player:network():peer():id())
			end
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_custody'), menu_options)
		menu:Show()
	end
end

local un_custody = function(name)
	function Use_Peer(id)
	    ps_name_spoof(name)
		local peer = managers.network:session():peer(id)
		if peer and peer:id() ~= managers.network:session():local_peer():id() then
			if Network:is_client() then
				managers.network:session():server_peer():send("request_spawn_member")
			else	
				IngameWaitingForRespawnState.request_player_spawn(id)
			end	
		end
	end
	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_un_custody'), menu_options)
		menu:Show()
	end
end

local crash = function(name)
	function Remove_Peer(id)
	    ps_name_spoof(name)
	    local session = managers.network._session
	    if ( session ) then
	        local peer = session:peer( id )
		    if ( peer ) then
		        if not peer:unit() then
			        peer:send("sync_carry", painting, 1, true, false, 1)
			        peer:send("sync_teammate_progress", 1, false, free, 0, false)
			        peer:send("sync_deployable_equipment", ecm_jammer, 1)
                else
			        peer:send("suppression", peer:unit(), 100)
					peer:send("damage_tase", peer:unit(), nil, 16384, 1, true)
		            peer:send("set_pose", peer:unit(), 1)
			        peer:send("action_change_speed", peer:unit(), 0.05)
					peer:send("sync_trip_mine_set_armed", peer:unit(), "explosive", 1)	
			        peer:send("action_change_pose", peer:unit(), 1, peer:unit():position())
                    peer:send("action_jump_middle", peer:unit(), peer:unit():position())
			        peer:send("action_land", peer:unit(), peer:unit():position())
			        peer:send("sync_carry", painting, 1, true, false, 1)
			        peer:send("sync_deployable_equipment", ecm_jammer, 1)
			        peer:send("sync_teammate_progress", 1, false, free, 0, false)
			        peer:send("sync_fall_position", peer:unit(), peer:unit():position(), peer:unit():rotation())
			        peer:send("set_stance", peer:unit(), 1, false, false)
			    end
			end
	    end
    end
    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Remove_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Remove_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_crash'), menu_options)
	    menu:Show()
    end
end

local concrash = function(name)
	function plst_con_crash(id, interval)
        DelayedCalls:Add("plst_con_crash", interval, function()
		    local session = managers.network._session
	        if ( session ) then
		        local peer = session:peer( id )
				ps_name_spoof(name)
		        if ( peer ) then
			        if not peer:unit() then
			            peer:send("sync_carry", painting, 1, true, false, 1)
			            peer:send("sync_teammate_progress", 1, false, free, 0, false)
			            peer:send("sync_deployable_equipment", ecm_jammer, 1)
				    else
				        peer:send("suppression", peer:unit(), 100)
						peer:send("damage_tase", peer:unit(), nil, 16384, 1, true)
		                peer:send("set_pose", peer:unit(), 1)
						peer:send("sync_trip_mine_set_armed", peer:unit(), "explosive", 1)	
			            peer:send("action_change_speed", peer:unit(), 0.05)
			            peer:send("action_change_pose", peer:unit(), 1, peer:unit():position())
                        peer:send("action_jump_middle", peer:unit(), peer:unit():position())
			            peer:send("action_land", peer:unit(), peer:unit():position())
			            peer:send("sync_carry", painting, 1, true, false, 1)
			            peer:send("sync_deployable_equipment", ecm_jammer, 1)
			            peer:send("sync_teammate_progress", 1, false, free, 0, false)
			            peer:send("sync_fall_position", peer:unit(), peer:unit():position(), peer:unit():rotation())
			            --peer:send("set_stance", peer:unit(), 1, false, false)
				    end 
					plst_con_crash(id, 0.1)
			    end
				plst_con_crash(id, 0.1) --rejoin detect
	        end		
	    end)
    end
	function Use_Peer(id)
	    local session = managers.network._session
	    if ( session ) then
	        local peer = session:peer( id )
	        if ( peer ) then
		        if not peer:unit() then
			        plst_con_crash(id, 0.1)
			    else
			        plst_con_crash(id, 0.1)
			    end
		    end 
	    end
    end
    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_con_crash'), menu_options)
	    menu:Show()
    end
end

local shake = function(name) 
    function PlayerState_shake_thread1(id, interval)
        DelayedCalls:Add("PlayerState_shake", interval, function()
		    local session = managers.network._session
	        if ( session ) then
		        local peer = session:peer( id )
		        if ( peer ) and peer:unit() then
			        ps_name_spoof(name)
                    peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 0, peer:id())
                    peer:send("sync_flame_bullet", peer:unit():position(), math.UP, 0, peer:id())
				    if ( peer ) and peer:unit() then
                        PlayerState_shake_thread2(id, 0.1)
						PlayerState_shake_thread1(id, 0.1) 
		            end
		        end
				PlayerState_shake_thread2(id, 0.1)
				PlayerState_shake_thread1(id, 0.1) --uncustody & rejoin detect
	        end		
	    end)
    end
	
	function PlayerState_shake_thread2(id, interval)
        DelayedCalls:Add("PlayerState_shake", interval, function()
		    local session = managers.network._session
	        if ( session ) then
		        local peer = session:peer( id )
		        if ( peer ) and peer:unit() then
			        ps_name_spoof(name)
                    peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 0, peer:id())
                    peer:send("sync_flame_bullet", peer:unit():position(), math.UP, 0, peer:id())
				    if ( peer ) and peer:unit() then
                        PlayerState_shake_thread2(id, 0.1)
						PlayerState_shake_thread1(id, 0.1)
		            end
		        end
				PlayerState_shake_thread2(id, 0.1)
                PlayerState_shake_thread1(id, 0.1)--uncustody & rejoin detect
	        end		
	    end)
    end

    function Use_Peer(id)
	    local session = managers.network._session
	    if ( session ) then
		    local peer = session:peer( id )
		    if ( peer ) then
			    if not peer:unit() then
                   return
                end
                PlayerState_shake_thread1(id, 0.1)
				PlayerState_shake_thread2(id, 0.2)
		    end
	    end
    end


    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_shake'), menu_options)
	    menu:Show()
    end
end

local explode = function(name) 
    function Remove_Peer(id)
	    ps_name_spoof(name)
	    local session = managers.network._session
	    if ( session ) then
	        local peer = session:peer( id )
		    if ( peer ) then
		        if not peer:unit() then
                   return
                end
                peer:send("sync_explode_bullet", peer:unit():position(), math.UP, 16384, peer:id())
                peer:send("sync_flame_bullet", peer:unit():position(), math.UP, 16384, peer:id())			
			end
	    end
    end
    if managers.network._session then
	    local menu_options = {}
	    for _, peer in pairs(managers.network:session():peers()) do
		    if peer:rank() and peer:level() then
			    menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Remove_Peer}
		    else
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Remove_Peer}
		    end
	    end
	    menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
	    menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
	    local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_your_spoof_name').. name .. "\n" .. ml:text('plst_your_spoof_name_2') .. ml:text('plst_explode'), menu_options)
	    menu:Show()
    end
end

cheater_tag = cheater_tag or function(info)
	function Use_Peer(id)
		local peer = managers.network:session():peer(id)
	    if peer then
		    peer:mark_cheater(VoteManager.REASON[table.random_key(VoteManager.REASON)])
	    end
	end
	
	function Use_Peers()
		for peer_id, peer in pairs(managers.network:session():peers()) do
		    peer:mark_cheater(VoteManager.REASON[table.random_key(VoteManager.REASON)])
		end
	end

	if managers.network._session then
		local menu_options = {}
		for _, peer in pairs(managers.network:session():peers()) do
			if peer:rank() and peer:level() then
				menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Use_Peer}
			else
				menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Use_Peer}
			end
		end
		menu_options[#menu_options+1] = {text = ml:text('plst_cheater_tag_all'), callback = Use_Peers}
		menu_options[#menu_options+1] = {text = " ", is_cancel_button = true}
		menu_options[#menu_options+1] = {text = ml:text('dialog_cancel'), is_cancel_button = true}
		local menu = QuickMenu:new(ml:text('plst_send_to_who'), ml:text('plst_cheater_tag'), menu_options)
		menu:Show()
	end
end

ps_menu_main_host = function()
	local dialog_data = {    
		title = ml:text('plst_host_main_title'),
		text = ml:text('plst_host_main_desc'),
		button_list = {}
	}
 
	local main_menu_table = {
		["input"] = {
			{ text = ml:text('plst_slow_mo'), callback_func = function() name_spoof_host(slow_mo) end },
			{ text = ml:text('plst_stop'), callback_func = function() name_spoof_host(stop) end },
			{ text = ml:text('plst_cuff'), callback_func = function() name_spoof_host(arrested) end },
			{ text = ml:text('plst_tase'), callback_func = function() name_spoof_host(tased) end },
			{ text = ml:text('plst_incapacitated'), callback_func = function() name_spoof_host(downed) end },
			{ text = ml:text('plst_bleedout'), callback_func = function() name_spoof_host(bleedout) end },
			{ text = ml:text('plst_kill'), callback_func = function() kill(managers.network:session():local_peer():name()) end },
			{ text = ml:text('plst_explode'), callback_func = function() name_spoof_host(explode) end },
			{ text = ml:text('plst_conkill'), callback_func = function() name_spoof_host(conkill) end },
			{ text = ml:text('plst_shake'), callback_func = function() name_spoof_host(shake) end },
			{ text = ml:text('plst_standard'), callback_func = function() name_spoof_host(reviev) end },
			{ text = ml:text('plst_custody'), callback_func = function() custody(managers.network:session():local_peer():name()) end },
			{ text = ml:text('plst_un_custody'), callback_func = function() un_custody(managers.network:session():local_peer():name()) end },
			{ text = ml:text('plst_un_custody_all'), callback_func = function() un_custody_all() end },
			{ text = ml:text('plst_custody_self'), callback_func = function() custody_me() end },
			{ text = ml:text('plst_tele_to'), callback_func = function() teleporting() end },
			{ text = ml:text('plst_tele_to_me'), callback_func = function() tele() end },
			{ text = ml:text('plst_cheater_tag'), callback_func = function() cheater_tag() end },
			{ text = ml:text('plst_crash'), callback_func = function() name_spoof_host(crash) end },
			{ text = ml:text('plst_con_crash'), callback_func = function() name_spoof_host(concrash) end }
		}
	}
 
	local main_menu_array = "input"
	if main_menu_table[main_menu_array] then
		for _, dostuff in pairs(main_menu_table[main_menu_array]) do
			if main_menu_table[main_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}      
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

ps_menu_main_client = function()
	local dialog_data = {    
		title = ml:text('plst_client_main_desc'),
		text = ml:text('plst_host_main_desc'),
		button_list = {}
	}
 
	local main_menu_table = {
		["input"] = {
			{ text = ml:text('plst_slow_mo'), callback_func = function() name_spoof_client(slow_mo) end },
			{ text = ml:text('plst_stop'), callback_func = function() name_spoof_client(stop) end },
			{ text = ml:text('plst_kill'), callback_func = function() kill(managers.network:session():local_peer():name()) end },
			{ text = ml:text('plst_explode'), callback_func = function() name_spoof_host(explode) end },
			{ text = ml:text('plst_conkill'), callback_func = function() name_spoof_client(conkill) end },
			{ text = ml:text('plst_shake'), callback_func = function() name_spoof_host(shake) end },
			{ text = ml:text('plst_un_custody_me'), callback_func = function() un_custody_all() end },
			{ text = ml:text('plst_custody_self'), callback_func = function() custody_me() end },
			{ text = ml:text('plst_tele_to'), callback_func = function() teleporting() end },
			{ text = ml:text('plst_cheater_tag'), callback_func = function() cheater_tag() end },
			{ text = ml:text('plst_crash'), callback_func = function() name_spoof_client(crash) end },
			{ text = ml:text('plst_con_crash'), callback_func = function() name_spoof_client(concrash) end }
		}
	}
 
	local main_menu_array = "input"
	if main_menu_table[main_menu_array] then
		for _, dostuff in pairs(main_menu_table[main_menu_array]) do
			if main_menu_table[main_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end
	
	table.insert(dialog_data.button_list, {})
	local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}      
	table.insert(dialog_data.button_list, no_button) 
	managers.system_menu:show_buttons(dialog_data)
end

name_spoof_host = function(state)
    if not PlayerState.settings.anonymous_enabled then
	    state(managers.network:session():local_peer():name())
	else
	    local dialog_data = {    
		    title = ml:text('plst_spoof_title'),
		    text = ml:text('plst_spoof_desc'),
		    button_list = {}
	    }
	    local count_data = #dialog_data.button_list
	    local lpeer_id = managers.network._session._local_peer._id
	    table.insert(dialog_data.button_list, {
			text = ml:text('plst_spoof_anonymous').._G.PlayerState.settings.plst_anonymous,
			callback_func = function() state(_G.PlayerState.settings.plst_anonymous) end,     
		})
	    table.insert(dialog_data.button_list, {
			text = ml:text('plst_spoof_not_anonymous')..managers.network:session():local_peer():name(),
			callback_func = function() state(managers.network:session():local_peer():name()) end,     
		})
	    table.insert(dialog_data.button_list, {})
	    for _, peer in pairs( managers.network._session._peers ) do
		    local peer_id = peer._id
		    if peer_id ~= lpeer_id then
			    local peer_name = peer._name
			    table.insert(dialog_data.button_list, {
				    text = peer_name,
				    callback_func = function() state(peer_name) end,    
			    })
		    end
	    end
	
	    table.insert(dialog_data.button_list, {})
	    table.insert(dialog_data.button_list, {text = ml:text('plst_return'), callback_func = function() ps_menu_main_host() end,})
	    local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}      
	    table.insert(dialog_data.button_list, no_button) 
	    managers.system_menu:show_buttons(dialog_data)
	end
end

name_spoof_client = function(state)
	if not PlayerState.settings.anonymous_enabled then
	    state(managers.network:session():local_peer():name())
	else
	    local dialog_data = {    
		    title = ml:text('plst_spoof_title'),
		    text = ml:text('plst_spoof_desc'),
		    button_list = {}
	    }
	    local count_data = #dialog_data.button_list
	    local lpeer_id = managers.network._session._local_peer._id
	    table.insert(dialog_data.button_list, {
			text = ml:text('plst_spoof_anonymous').._G.PlayerState.settings.plst_anonymous,
			callback_func = function() state(_G.PlayerState.settings.plst_anonymous) end,     
		})
	    table.insert(dialog_data.button_list, {
			text = ml:text('plst_spoof_not_anonymous')..managers.network:session():local_peer():name(),
			callback_func = function() state(managers.network:session():local_peer():name()) end,     
		})
	    table.insert(dialog_data.button_list, {})
	    for _, peer in pairs( managers.network._session._peers ) do
		    local peer_id = peer._id
		    if peer_id ~= lpeer_id then
			    local peer_name = peer._name
			    table.insert(dialog_data.button_list, {
				    text = peer_name,
				    callback_func = function() state(peer_name) end,    
			    })
		    end
	    end
	
	    table.insert(dialog_data.button_list, {})
	    table.insert(dialog_data.button_list, {text = ml:text('plst_return'), callback_func = function() ps_menu_main_client() end,})
	    local no_button = {text = managers.localization:text("dialog_cancel"), cancel_button = true}      
	    table.insert(dialog_data.button_list, no_button) 
	    managers.system_menu:show_buttons(dialog_data)
	end
end

if Network:is_server() then
    ps_menu_main_host()
else
    ps_menu_main_client()
end

