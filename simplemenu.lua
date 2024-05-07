if not SimpleMenu then 
	SimpleMenu = class()

	function SimpleMenu:init(m_id, title, message, options)		
		self.visible = false
		self.is_main = m_id == 99999
		self.dialog_data = { title = title, text = message, button_list = {}, id = "lootmenu#"..m_id }
		self.ids = {}
		for _,opt in ipairs(options) do
			if opt.data then self.ids[opt.text] = opt.data end
			local elem = {}
			elem.text = opt.text
			elem.callback_func = callback(self, self, "_do_callback", { data = opt.data, callback = opt.callback })
			elem.cancel_button = opt.is_cancel_button or false
			table.insert(self.dialog_data.button_list, elem)
		end
		return self
	end

	function SimpleMenu:_do_callback(info)
		if info.callback then info.callback(info.data) end
		self.visible = false
	end

	function SimpleMenu:show()
		if not self.visible then
			self.visible = true
			managers.system_menu:show(self.dialog_data)
		end
	end

	function SimpleMenu:hide()
		if self.visible then
			self.visible = false
			managers.system_menu:close(self.dialog_data.id)
		end
	end
end