_G.PlayerState = PlayerState or {}
PlayerState.path = ModPath
PlayerState.save_path = SavePath .. "plst.txt"
PlayerState.settings = {
	plst_lang_value = 1,
	plst_anonymous = ""}
	
function PlayerState:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function PlayerState:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

Hooks:Add("MenuManagerInitialize", "PlayerState_MenuManagerInitialize", function(menu_manager)
	MenuCallbackHandler.plst_lang_callback = function(self,item)
		local value = tonumber(item:value())
		PlayerState.settings.plst_lang_value = value
		PlayerState:Save()
	end
	
	MenuCallbackHandler.plst_anonymous_callback = function(self,item)
		PlayerState.settings.plst_anonymous = item:value()
		PlayerState:Save()
	end
	
	MenuCallbackHandler.plst_closed = function(self)
		PlayerState:Save()
	end
	
	PlayerState:Load()
	MenuHelper:LoadFromJsonFile(PlayerState.path .. "menu/options.txt", PlayerState, PlayerState.settings)
end)

Hooks:Add("LocalizationManagerPostInit", "PlayerState_LocalizationManagerPostInit", function(loc)
	PlayerState:Load()
	local t = PlayerState.path .. "loc/"
	if PlayerState.settings.plst_lang_value == 1 then
	    for _, filename in pairs(file.GetFiles(t)) do
		    local str = filename:match('^(.*).txt$')
		    if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			    loc:load_localization_file(t .. filename)
			    return
		    end
	    end
	    loc:load_localization_file(t .. "english.txt")
	elseif PlayerState.settings.plst_lang_value == 2 then
		loc:load_localization_file(t .. "english.txt")
	elseif PlayerState.settings.plst_lang_value == 3 then
	    loc:load_localization_file(t .. "schinese.txt")
	end
end)