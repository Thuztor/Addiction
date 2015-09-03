-------------------------------------------------------------------------
--                            ADDICTION MOD                            --
--                           CODE BY PEANUTS                           --
--                    	   TEXTURES BY THUZTOR		                   --
-------------------------------------------------------------------------
--                          OFFICIAL TOPIC                             --
--  NONE															   --
--                                                                     --
-------------------------------------------------------------------------

AddictionMod = {};
AddictionMod.debug = true;
AddictionMod.debugWindow = nil;
AddictionMod.oNicotine = nil;

AddictionMod.init = function()
	local player = getPlayer();
	local playerData = player:getModData();
	
	AddictionMod.oNicotine = Nicotine:new();
	
	playerData.addictionInit = playerData.addictionInit or 'false';
	if playerData.addictionInit == 'false' then 
		playerData.addictionInit = 'true';
		-- Init nicotine addiction system
		AddictionMod.oNicotine:initialise();
	end
end

AddictionMod.initConsoleDebug = function()
	if AddictionMod.debug then
		AddictionMod.debugWindow = DebugWindow:new('Addiction Mod Debug', 100, 100, 200, 200);
		AddictionMod.debugWindow:addToUIManager();
	end
end

AddictionMod.updateConsoleDebug = function()
	if AddictionMod.debugWindow ~= nil and not AddictionMod.debugWindow:getIsVisible() and isKeyDown(Keyboard.KEY_F2) then
		AddictionMod.debugWindow:setVisible(true);
	end
end

AddictionMod.itemUsed = function(character, item)
	if character:getObjectName() == 'Player' then
		itemType = item:getType();
		if itemType == 'Cigarettes' then
			AddictionMod.oNicotine:consume(itemType);
		end
	end
end

AddictionMod.tick = function()
	AddictionMod.oNicotine:updateAddictionDatas();
end

Events.OnPlayerUpdate.Add(AddictionMod.init);
Events.OnCreateUI.Add(AddictionMod.initConsoleDebug);
Events.OnPostUIDraw.Add(AddictionMod.updateConsoleDebug);
Events.OnUseItem.Add(AddictionMod.itemUsed);
Events.OnTick.Add(AddictionMod.tick);