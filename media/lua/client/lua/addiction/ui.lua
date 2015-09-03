require "ISUI/ISWindow";

DebugWindow = ISWindow:derive("DebugWindow");

function DebugWindow:render()
	local playerData = getPlayer():getModData();
	local smokeSince = '';
	if playerData.startSmokingDate ~= nil then
		local startSmokingDateTime = DateTime:new(nil, nil, nil, nil);
		startSmokingDateTime:setTimestamp(playerData.startSmokingDate);
		smokeSince = startSmokingDateTime:formatDate('$j/$n/$y $h:$i');
	end
	self:drawText('Smoke since:' .. smokeSince, 10, 25, 1, 1, 1, 1, UIFont.Small);
	self:drawText('NAL:' .. tostring(playerData.NAL), 10, 45, 1, 1, 1, 1, UIFont.Small);
	self:drawText('NLC:' .. string.format('%0.2f', playerData.NLC), 10, 65, 1, 1, 1, 1, UIFont.Small);
	self:drawText('NIC:' .. tostring(playerData.NIC) .. ' (avg:' .. string.format('%0.2f', playerData.avgNIC) .. ')', 10, 85, 1, 1, 1, 1, UIFont.Small);
	self:drawText('Gained NAL today: ' .. tostring(playerData.NALGainedToday), 10, 105, 1, 1, 1, 1, UIFont.Small);
	playerData.chanceOfGainNAL = playerData.chanceOfGainNAL or 0;
	self:drawText('Gain NAL prob.: ' .. string.format('%0.2f', playerData.chanceOfGainNAL) .. ' %', 10, 125, 1, 1, 1, 1, UIFont.Small);
	playerData.NALDraw = playerData.NALDraw or 0;
	self:drawText('Last NAL draw: ' .. string.format('%0.2f', playerData.NALDraw), 10, 145, 1, 1, 1, 1, UIFont.Small);
	self:drawText('NAL Gain result : ' .. tostring(playerData.NALGainedComputeResult), 10, 165, 1, 1, 1, 1, UIFont.Small);
end