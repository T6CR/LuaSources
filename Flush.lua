local captured = {
	actors = {},
	luaSources = {}
}

local function flush()
	warn("Flushing "..#captured.actors+#captured.luaSources.." logged assets.")
	for i,actor in pairs(captured.actors) do
		task.spawn(function()
			actor:Destroy()
		end)
	end
	for i,luaSource in pairs(captured.luaSources) do
		task.spawn(function()
			luaSource:Destroy()
		end)
	end
	captured = {
		actors = {},
		luaSources = {}
	}
end

local function addTo(instance)
	if instance:IsA("LuaSourceContainer") and instance ~= script then
		local hasActor = instance:GetActor() or nil
		if hasActor then
			if not table.find(captured.actors,hasActor) then
				warn("Actor has been added to logs.")
				table.insert(captured.actors,hasActor)
			end
		end
		if not table.find(captured.luaSources,instance) then
			warn("Script has been added to logs.")
			table.insert(captured.luaSources,instance)
		end
	end
end

game:GetService("ScriptContext").Error:Connect(function(message,stackTrace,scriptInstance)
	addTo(scriptInstance)
end)

game.DescendantAdded:Connect(function(instance)
	addTo(instance)
end)

game.ItemChanged:Connect(function(instance)
	addTo(instance)
end)

for i,instance in game:GetDescendants() do
	addTo(instance)
end

flush()
