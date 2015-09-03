require "ISBaseObject";
require "datetime";

Substance = ISBaseObject:derive("Substance");
Substance.chanceOfGainAL = 0;
Substance.maxALGainedPerDay = 3;


--************************************************************************--
--** Substance:giveStuff
--**
--************************************************************************--
function Substance:giveStuff(player)
	
end

--************************************************************************--
--** Substance:consume
--**
--************************************************************************--
function Substance:consume(itemType)
	
end

--************************************************************************--
--** Substance:increaseLC
--**
--************************************************************************--
function Substance:increaseLC(levelCounter)
	
end

--************************************************************************--
--** Substance:decreaseLC
--**
--************************************************************************--
function Substance:decreaseLC()
	
end

--************************************************************************--
--** Substance:increaseIC
--**
--************************************************************************--
function Substance:increaseIC()
	
end

--************************************************************************--
--** Nicotine:updateAvgIC
--**
--************************************************************************--
function Substance:updateAvgIC()

end

--************************************************************************--
--** Substance:updateAddictionDatas
--**
--************************************************************************--
function Substance:updateAddictionDatas()

end

--************************************************************************--
--** Substance:increaseAL()
--**
--************************************************************************--
function Substance:increaseAL()

end

--************************************************************************--
--** Substance:setChanceOfGainAL()
--**
--************************************************************************--
function Substance:setChanceOfGainAL()
	local playerData = getPlayer():getModData();
	self.chanceOfGainAL = playerData.NLC * playerData.avgNIC;
end

--************************************************************************--
--** Substance:setAddictionStartDate
--**
--************************************************************************--
function Substance:addictionStartDate()
	local gameTime = GameTime:getInstance();
	local currentTime = DateTime:new(gameTime:getDay() + 1, gameTime:getMonth() + 1, gameTime:getYear(), 0);
	return currentTime:getTimestamp();
end

--************************************************************************--
--** Substance:startTimer
--**
--************************************************************************--
function Substance:startTimer()
	gameTime = GameTime:getInstance();
	currentTime = DateTime:new(gameTime:getDay() + 1, gameTime:getMonth() + 1, gameTime:getYear(), gameTime:getTimeOfDay());
	return currentTime;
end

--************************************************************************--
--** Substance:startTimer
--**
--************************************************************************--
function Substance:getTimerMinutes(LCStartTimer)
	local gameTime = GameTime:getInstance();
	local currentTime = DateTime:new(gameTime:getDay() + 1, gameTime:getMonth() + 1, gameTime:getYear(), gameTime:getTimeOfDay());
	local diffTime = currentTime:diff(LCStartTimer);
	return(diffTime:getTimestamp() / 60);
end

--************************************************************************--
--** Substance:getDaysSinceStart
--**
--************************************************************************--
function Substance:getDaysSinceAddictionStart(startAddictionTimestamp)
	local gameTime = GameTime:getInstance();
	local playerData = getPlayer():getModData();
	
	local currentTime = DateTime:new(gameTime:getDay() + 1, gameTime:getMonth() + 1, gameTime:getYear(), gameTime:getTimeOfDay());
	
	local  startTime = nil;
	if startAddictionTimestamp ~= nil and startAddictionTimestamp > 0 then
		startTime = DateTime:new(nil, nil, nil, nil);
		startTime:setTimestamp(startAddictionTimestamp);
	else
		startTime = DateTime:new(gameTime:getStartDay() + 1, gameTime:getStartMonth() + 1, gameTime:getStartYear(), 0);
	end
	
	local diffTime = currentTime:diff(startTime);
	local daysSinceStart = diffTime:getTimestamp() / 86400;
	return(math.ceil(daysSinceStart));
end

--************************************************************************--
--** Substance:isNewDay
--**
--************************************************************************--
function Substance:isNewDay()
	local playerData = getPlayer():getModData();
	local gameTime = GameTime:getInstance();
	local currentTime = DateTime:new(gameTime:getDay() + 1, gameTime:getMonth() + 1, gameTime:getYear(), 0);
	
	playerData.lastAddictionDateCheck = playerData.lastAddictionDateCheck or currentTime:getTimestamp();
	
	if playerData.lastAddictionDateCheck < currentTime:getTimestamp() then
		playerData.lastAddictionDateCheck = currentTime:getTimestamp();
		return true;
	end
	
	return false;
end

--************************************************************************--
--** Substance:new
--**
--************************************************************************--
function Substance:new()
    o = {};  
	o.data = {};
    setmetatable(o, self);
    self.__index = self;
	return o;
end
