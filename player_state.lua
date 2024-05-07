--my code is bad
session = managers.network:session()
nr_player = nr_player or session:amount_of_players()


if not SimpleMenu then
	managers.chat:_receive_message(1, "SimpleMenu", "not created", Color.red)
	return
end


cuffed = cuffed or function()
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
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
		menu_options[#menu_options+1] = {text = "全体被拷", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("被拷", "选择让谁被拷", menu_options)
		menu:Show()
	end
end

tased = tased or function(info)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
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
		menu_options[#menu_options+1] = {text = "全体被电", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("被电", "选择让谁被电", menu_options)
		menu:Show()
	end
end



downed = downed or function(info)
    function Use_Peer(id)
		local peer = managers.network._session:peer(id)
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
		menu_options[#menu_options+1] = {text = "全体被踹", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("被剑圣踹", "选择谁被剑圣踹", menu_options)
		menu:Show()
	end
end

bleedout = bleedout or function(info)
    function Use_Peer(id)
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
		menu_options[#menu_options+1] = {text = "全体倒下", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("倒下", "选择让谁倒下(如果你选择让客机倒下,再手动救起此客机会使其闪退)", menu_options)
		menu:Show()
	end
end

reviev = reviev or function(info)
    function Use_Peer(id)
		local peer = managers.network._session:peer(id)
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
		menu_options[#menu_options+1] = {text = "全体被救起", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("救起", "选择救起谁", menu_options)
		menu:Show()
	end
end

custody = custody or function(info)
	function Use_Peer(id)
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
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("进局", "选择让谁进局", menu_options)
		menu:Show()
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
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("传送", "选择让谁传送", menu_options)
		menu:Show()
	end
end

un_custody = un_custody or function(info)
	function Use_Peer(id)
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
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("出局", "选择让谁出局", menu_options)
		menu:Show()
	end
end

custody_me = custody_me or function(info)
	local player = managers.player:local_player()
	managers.player:force_drop_carry()
	managers.statistics:downed( { death = true } )
	IngameFatalState.on_local_player_dead()
	game_state_machine:change_state_by_name( "ingame_waiting_for_respawn" )
	player:character_damage():set_invulnerable( true )
	player:character_damage():set_health( 0 )
	player:base():_unregister()
	player:base():set_slot( player, 0 )
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
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("传送", "传送到谁附近", menu_options)
		menu:Show()
	end
end


stop = stop or function(info)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		if peer then
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0, 1, 3600, 1)
		end
	end
	function Use_Peers(id)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0, 1, 3600, 1)
		end
	end
	function Use_Peers_2(id)
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
		menu_options[#menu_options+1] = {text = "全体罚站", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "解除全体罚站", callback = Use_Peers_2}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("罚站", "选择谁被罚站,同时请确定其没有安装AStc等反慢模组", menu_options)
		menu:Show()
	end
end

slow_mo = slow_mo or function(info)
	function Use_Peer(id)
		local peer = managers.network._session:peer(id)
		if peer then
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0.05, 1, 3600, 1)
		end
	end
	function Use_Peers(id)
		for peer_id, peer in pairs(managers.network._session._peers) do
			peer:send("start_timespeed_effect", "pause", "pausable", "player;game;game_animation", 0.05, 1, 3600, 1)
		end
	end
	function Use_Peers_2(id)
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
		menu_options[#menu_options+1] = {text = "全体慢动作", callback = Use_Peers}
		menu_options[#menu_options+1] = {text = "解除全体慢动作", callback = Use_Peers_2}
		menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
		local menu = QuickMenu:new("慢动作", "选择让谁被慢动作,同时请确定其没有安装AStc等反慢模组", menu_options)
		menu:Show()
	end
end





kill = kill or function(info)
function errmsg(msg) managers.chat:_receive_message(1, "No unit", msg, Color(0.8,0,0), false) end	
function Remove_Peer(id)
	local session = managers.network._session
	if ( session ) then
		local peer = session:peer( id )
		if ( peer ) then
			if not peer:unit() then
               errmsg("你必须与" .. peer:name() .. "建立连接,同时" .. peer:name() .."不可以在大厅/准备界面/监狱里.")
               return
            end
            peer:send("sync_friendly_fire_damage", peer:id(), peer:unit(), 900000, "fire")
		end
	end
end

function Remove_Peers(id)
	for peer_id, peer in pairs(managers.network._session._peers) do
			if not peer:unit() then
               errmsg("你必须与" .. peer:name() .. "建立连接,同时" .. peer:name() .."不可以在大厅/准备界面/监狱里.")
               return
            end
            peer:send("sync_friendly_fire_damage", peer:id(), peer:unit(), 900000, "fire")
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
	menu_options[#menu_options+1] = {text = "全体倒地", callback = Remove_Peers}
	menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
	local menu = QuickMenu:new("倒地", "选择让谁倒地", menu_options)
	menu:Show()
end
end


conkill = conkill or function(info)
function errmsg(msg) managers.chat:_receive_message(1, "No unit", msg, Color(0.8,0,0), false) end	

function PlayerState_con_kill(id, interval)
    DelayedCalls:Add("PlayerState_con_kill", interval, function()
		local session = managers.network._session
	    if ( session ) then
		    local peer = session:peer( id )
		    if ( peer ) and peer:unit() then
			    --update_name_spoof_hint(peer:name()) --test function!!!!!!!! also try to use on exploit!
                peer:send("sync_friendly_fire_damage", peer:id(), peer:unit(), 900000, "fire")
				if ( peer ) and peer:unit() then
                   PlayerState_con_kill(id, 2) 
		        end
		    end
	    end		
	end)
end

function Remove_Peer(id)
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
			menu_options[#menu_options+1] ={text = "(" .. peer:rank() .. "-" .. peer:level() .. ") " .. peer:name(), data = peer:id(), callback = Remove_Peer}
		else
			menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Remove_Peer}
		end
	end
	--menu_options[#menu_options+1] = {text = "全体倒地", callback = Remove_Peers}
	menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
	local menu = QuickMenu:new("倒地", "选择让谁倒地", menu_options)
	menu:Show()
end
end




set_pose1 = set_pose1 or function(info)
function errmsg(msg) managers.chat:_receive_message(1, "No unit", msg, Color(0.8,0,0), false) end
function acmsg(msg) managers.chat:_receive_message(1, "WTF", msg, Color(0.8,0,0), false) end	
function Remove_Peer(id)
	local session = managers.network._session
	if ( session ) then
		local peer = session:peer( id )
		if ( peer ) then
		    if not peer:unit() then
               errmsg("你必须与" .. peer:name() .. "建立连接,同时" .. peer:name() .."不可以在大厅/准备界面/监狱里.")
               return
            end
            peer:send("set_pose", peer:unit(), 1)
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
	menu_options[#menu_options+1] = {text = "取消", is_cancel_button = true}
	local menu = QuickMenu:new("闪退", "选择让谁闪退", menu_options)
	menu:Show()
end
end



if not ps_menu or nr_player ~= session:amount_of_players() then
    if Network:is_server() then
	   nr_player = session:amount_of_players()
	   ps_menu = nil
	   local opts = {}
       table.insert(opts, { text = "慢动作", callback = slow_mo })
	   table.insert(opts, { text = "原地罚站", callback = stop })
       table.insert(opts, { text = "被拷", callback = cuffed })
	   table.insert(opts, { text = "被电", callback = tased })
	   table.insert(opts, { text = "被踹", callback = downed })
	   table.insert(opts, { text = "倒地(state)", callback = bleedout })
	   table.insert(opts, { text = "倒地", callback = kill })
       table.insert(opts, { text = "连续倒地", callback = conkill })	   
	   table.insert(opts, { text = "被救起", callback = reviev })
	   table.insert(opts, { text = "进局", callback = custody })
	   table.insert(opts, { text = "出局", callback = un_custody })
	   table.insert(opts, { text = "全部出局", callback = un_custody_all }) 
	   table.insert(opts, { text = "让我进局", callback = custody_me	})
	   table.insert(opts, { text = "让我传送到一名玩家附近", callback = teleporting })
	   table.insert(opts, { text = "让一名玩家传送到我附近", callback = tele })
	   table.insert(opts, { text = "闪退", callback = set_pose1	})
	   table.insert(opts, { text = " "	})
	   table.insert(opts, { text = "取消", is_cancel_button = true })
	   ps_menu = SimpleMenu:new(99999, "当前状态:主机", "改变一名玩家的状态", opts)
	else
	   nr_player = session:amount_of_players()
	   ps_menu = nil
	   local opts = {}
	   table.insert(opts, { text = "倒地", callback = kill }) 
	   table.insert(opts, { text = "连续倒地", callback = conkill })
       table.insert(opts, { text = "慢动作", callback = slow_mo })
	   table.insert(opts, { text = "原地罚站", callback = stop }) 
	   table.insert(opts, { text = "让我传送到一名玩家附近", callback = teleporting })
	   table.insert(opts, { text = "让我进局", callback = custody_me	})
	   table.insert(opts, { text = "让我出局", callback = un_custody_all }) 
	   table.insert(opts, { text = "闪退", callback = set_pose1	})
	   table.insert(opts, { text = " "	})
	   table.insert(opts, { text = "取消", is_cancel_button = true })
	   ps_menu = SimpleMenu:new(99999, "当前状态:客机", "改变一名玩家的状态", opts)
	end   
end
ps_menu:show()
