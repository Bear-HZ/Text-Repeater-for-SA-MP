script_name("Text Repeater")
script_author("Bear")
script_version("0.1.0")


local loops = {}

local isStopMessageNeeded = false


function main()	
	while not isSampAvailable() do wait(50) end
	sampAddChatMessage("{AAAAFF}Text Repeater {FFFFFF}| Start: {AAAAFF}/repeat (# of times) (frequency in seconds) (text) {FFFFFF}| Stop: {AAAAFF}/stoprepeat", -1)
	
	sampRegisterChatCommand("repeat", function(args)
		if #args == 0 or not args:find("[^%s]") then
			sampAddChatMessage(" ", -1)
			sampAddChatMessage("{AAAAFF}Usage: {FFFFFF}/repeat (# of times) (frequency in seconds) (text)", -1)
			sampAddChatMessage(" ", -1)
		elseif args:find("^%d+%s%d+%s.") then
			local _, _, repCount, frequency, textToRepeat = args:find("^(%d+)%s(%d+)%s(.+)")
			
			if tonumber(repCount) < 1 then
				sampAddChatMessage(" ", -1)
				sampAddChatMessage("--- {FF6666}Invalid Entry {FFFFFF}| Repetition count must be 1 or greater", -1)
				sampAddChatMessage("{AAAAFF}Usage: {FFFFFF}/repeat (# of times) (frequency in seconds) (text)", -1)
				sampAddChatMessage(" ", -1)
			else
				sampAddChatMessage(" ", -1)
				sampAddChatMessage("{AAAAFF}Repeating: {FFFFFF}" .. textToRepeat, -1)
				sampAddChatMessage(repCount .. " times, once every " .. frequency .. " seconds", -1)
				sampAddChatMessage("Use {AAAAFF}/stoprepeat {FFFFFF}to end cycle", -1)
				sampAddChatMessage(" ", -1)
				
				table.insert(loops, {isStartAwaited = true, t_repCount = tonumber(repCount), t_frequency = tonumber(frequency), t_textToRepeat = textToRepeat})
			end
		else
			sampAddChatMessage(" ", -1)
			sampAddChatMessage("--- {FF6666}Invalid Entry", -1)
			sampAddChatMessage("{AAAAFF}Usage: {FFFFFF}/repeat (# of times) (frequency in seconds) (text)", -1)
			sampAddChatMessage(" ", -1)
		end
	end)
	
	sampRegisterChatCommand("stoprepeat", function()
		for _, selectedLoop in pairs(loops) do
			selectedLoop.isStartAwaited = nil
		end
		
		isStopMessageNeeded = true
	end)
	
	lua_thread.create(function()
		repeat
			if isStopMessageNeeded then
				wait(955)
				
				sampAddChatMessage(" ", -1)
				sampAddChatMessage("{AAAAFF}Text Repeater: {FFFFFF}All loops {FF8888}stopped", -1)
				sampAddChatMessage(" ", -1)
				
				isStopMessageNeeded = false
			end
			
			wait(100)
		until false
	end)
	
	repeat
		for _, selectedLoop in pairs(loops) do
			if selectedLoop and selectedLoop.isStartAwaited then
				lua_thread.create(function()
					sampSendChat(selectedLoop.t_textToRepeat)
					
					for i = 1, selectedLoop.t_repCount - 1 do
						wait(selectedLoop.t_frequency * 1000)
						
						if selectedLoop.isStartAwaited == nil then
							break
						else
							sampSendChat(selectedLoop.t_textToRepeat)
						end
					end
					
					if selectedLoop.isStartAwaited ~= nil then
						wait(1000)
						
						sampAddChatMessage(" ", -1)
						sampAddChatMessage("{AAAAFF}Repetition {88FF88}complete: {FFFFFF}" .. selectedLoop.t_textToRepeat, -1)
						sampAddChatMessage(selectedLoop.t_repCount .. " times, once every " .. selectedLoop.t_frequency .. " seconds", -1)
						sampAddChatMessage(" ", -1)
					end
				end)
				
				selectedLoop.isStartAwaited = false
			end
			
			wait(100)
		end
		
		wait(100)
	until false
end