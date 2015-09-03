-------------------------------------------------------------------------
-- Nicotine addiction datas :										   --
-- NAL : Nicotine Addiction Level									   --
-- NLC : Nicotine Level Counter										   --
-- NAT : Nicotine Addiction Timer									   --
-- NIC : Nicotine Item Counter										   --
-------------------------------------------------------------------------
require("addiction/substance");

Nicotine = Substance:derive("Nicotine");
Nicotine.items = {};
Nicotine.items.Cigarettes = {};
Nicotine.items.Cigarettes.NicotineLevel = 7;

Nicotine.NALGainedDivisor = {};
Nicotine.NALGainedDivisor[0] = 3;
Nicotine.NALGainedDivisor[1] = 4;
Nicotine.NALGainedDivisor[2] = 5;
Nicotine.NALGainedDivisor[3] = 6;
Nicotine.NALGainedDivisor[4] = 8;

--************************************************************************--
--** Nicotine:initialise
--**
--************************************************************************--
function Nicotine:initialise()
	Substance.initialise(self);
	local player = getPlayer();
	local playerData = player:getModData();
	
	playerData.NLC = playerData.NLC or 0;
	playerData.NIC = playerData.NIC or 0;
	playerData.avgNIC = playerData.avgNIC or 0;
	
	if player:HasTrait('SmokerLvl1') then
		playerData.NAL = 1;
	elseif player:HasTrait('SmokerLvl2') then
		playerData.NAL = 2;
	elseif player:HasTrait('SmokerLvl3') then
		playerData.NAL = 3;
	elseif player:HasTrait('SmokerLvl4') then
		playerData.NAL = 4;
	elseif player:HasTrait('SmokerLvl5') then
		playerData.NAL= 5;
	else
		playerData.NAL = 0;
	end
	
	self:giveStuff(player);
	if playerData.NAL > 0 then
		--self:giveStuff(player);
		playerData.startSmokingDate = self:addictionStartDate();
	end
end

--************************************************************************--
--** Nicotine:giveStuff
--**
--************************************************************************--
function Nicotine:giveStuff(player)
	local playerInventory = player:getInventory();
	playerInventory:AddItem("Base.Cigarettes");
	playerInventory:AddItem("Base.Lighter");
end

--************************************************************************--
--** Nicotine:consume
--**
--************************************************************************--
function Nicotine:consume(itemType)
	self:increaseLC(self.items[itemType].NicotineLevel);
	self:increaseIC();
	self:updateAvgIC();
	self:increaseAL();
end

--************************************************************************--
--** Nicotine:increaseLC
--**
--************************************************************************--
function Nicotine:increaseLC(levelCounter)
	local playerData = getPlayer():getModData();
	playerData.NLC = playerData.NLC + levelCounter;
end

--************************************************************************--
--** Nicotine:decreaseLC
--**
--************************************************************************--
function Nicotine:decreaseLC()
	local playerData = getPlayer():getModData();
	if(playerData.NLC > 0) then
		playerData.NLCStartTimer = playerData.NLCStartTimer or self:startTimer();
		local minutesSinceTimerStart = self:getTimerMinutes(playerData.NLCStartTimer);
		if playerData.NLC <= 11 then
			if minutesSinceTimerStart > 50 then
				playerData.NLC = playerData.NLC - 0.5;
				playerData.NLCStartTimer = self:startTimer();
			end
		elseif playerData.NLC > 11 and playerData.NLC <= 23 then
			if minutesSinceTimerStart > 30 then
				playerData.NLC = playerData.NLC - 0.5;
				playerData.NLCStartTimer = self:startTimer();
			end
		elseif playerData.NLC > 23 and playerData.NLC <= 36 then
			if minutesSinceTimerStart > 20 then
				playerData.NLC = playerData.NLC - 0.5;
				playerData.NLCStartTimer = self:startTimer();
			end
		elseif playerData.NLC > 36 and playerData.NLC <= 50 then
			if minutesSinceTimerStart > 20 then
				playerData.NLC = playerData.NLC - 0.62;
				playerData.NLCStartTimer = self:startTimer();
			end
		elseif playerData.NLC > 50 and playerData.NLC <= 65 then
			if minutesSinceTimerStart > 10 then
				playerData.NLC = playerData.NLC - 0.5;
				playerData.NLCStartTimer = self:startTimer();
			end
		elseif playerData.NLC > 65 then
			if minutesSinceTimerStart > 10 then
				playerData.NLC = playerData.NLC - 1.25;
				playerData.NLCStartTimer = self:startTimer();
			end
		end
	end
end

--************************************************************************--
--** Nicotine:increaseIC
--**
--************************************************************************--
function Nicotine:increaseIC()
	local playerData = getPlayer():getModData();
	
	if playerData.NIC == 0 then
		-- This is the first nicotine item we consume
		-- So we set the date of the first of all of nicotine consumption
		playerData.startSmokingDate = self:addictionStartDate();
	end
	
	playerData.NIC = playerData.NIC + 1;
end

--************************************************************************--
--** Nicotine:updateAvgIC
--**
--************************************************************************--
function Nicotine:updateAvgIC()
	local playerData = getPlayer():getModData();
	if playerData.NIC > 0 then
		playerData.avgNIC = playerData.NIC / self:getDaysSinceAddictionStart(playerData.startSmokingDate);
	end
end

--************************************************************************--
--** Nicotine:updateAddictionDatas
--**
--************************************************************************--
function Nicotine:updateAddictionDatas()
	local playerData = getPlayer():getModData();
	self:decreaseLC();
	self:setChanceOfGainAL();
	
	-- Reset of the addiction level gained in a day if this is a new day
	if self:isNewDay() then
		playerData.NALGainedToday = 0;
	end
	
	if AddictionMod.debug then
		playerData.chanceOfGainNAL = self.chanceOfGainAL;
	end
end

--************************************************************************--
--** Nicotine:increaseAL()
--**
--************************************************************************--
function Nicotine:increaseAL()
	local playerData = getPlayer():getModData();
	
	self:setChanceOfGainAL();
	
	playerData.NALGainedToday = playerData.NALGainedToday or 0;
	
	if playerData.NAL < 5 then
		local draw = ZombRandBetween(0, 101);
		
		if AddictionMod.debug then
			playerData.NALDraw = draw;
		end
		
		if draw <= self.chanceOfGainAL then
			local NALGained = math.ceil(playerData.NIC / self.NALGainedDivisor[playerData.NAL]);
			if AddictionMod.debug then
				playerData.NALGainedComputeResult = string.format('%0.2f', playerData.NIC / self.NALGainedDivisor[playerData.NAL]) .. ' => ' .. tostring(NALGained);
			end
			if NALGained + playerData.NALGainedToday > self.maxALGainedPerDay then
				playerData.NALGainedToday = self.maxALGainedPerDay;
			else
				playerData.NAL = playerData.NAL + NALGained;
				playerData.NALGainedToday = playerData.NALGainedToday + NALGained;
			end
		end
	end
end

--************************************************************************--
--** Nicotine:doSmokerTraits
--**
--************************************************************************--
function Nicotine:doSmokerTraits()
	TraitFactory.addTrait("SmokerLvl1", "Addiction, social smoker", -2, "o   No unhappiness by smoking a cigarette.<br>o   Poorer condition.<br>o   Starts with smoking tools.", false);
	TraitFactory.addTrait("SmokerLvl2", "Addiction, lighter smoker", -3, "o   No unhappiness by smoking a cigarette.<br>o   Poorer condition.<br>o   Starts with smoking tools.", false);
	TraitFactory.addTrait("SmokerLvl3", "Addiction, smoker", -4, "o   No unhappiness by smoking a cigarette.<br>o   Poorer condition.<br>o   Starts with smoking tools.", false);
	TraitFactory.addTrait("SmokerLvl4", "Addiction, heavy smoker", -5, "o   No unhappiness by smoking a cigarette.<br>o   Poorer condition.<br>o   Starts with smoking tools.", false);
	TraitFactory.addTrait("SmokerLvl5", "Addiction, chain smoker", -6, "o   No unhappiness by smoking a cigarette.<br>o   Poorer condition.<br>o   Starts with smoking tools.", false);
	
	TraitFactory.setMutualExclusive('SmokerLvl1', 'SmokerLvl2');
	TraitFactory.setMutualExclusive('SmokerLvl1', 'SmokerLvl3');
	TraitFactory.setMutualExclusive('SmokerLvl1', 'SmokerLvl4');
	TraitFactory.setMutualExclusive('SmokerLvl1', 'SmokerLvl5');
	TraitFactory.setMutualExclusive('SmokerLvl2', 'SmokerLvl3');
	TraitFactory.setMutualExclusive('SmokerLvl2', 'SmokerLvl4');
	TraitFactory.setMutualExclusive('SmokerLvl2', 'SmokerLvl5');
	TraitFactory.setMutualExclusive('SmokerLvl3', 'SmokerLvl4');
	TraitFactory.setMutualExclusive('SmokerLvl3', 'SmokerLvl5');
	TraitFactory.setMutualExclusive('SmokerLvl4', 'SmokerLvl5');
end

Events.OnGameBoot.Add(Nicotine.doSmokerTraits);