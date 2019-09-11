--[[
Copyright 2009-2019 João Cardoso
Levelland is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of Levelland.

Levelland is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Levelland is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Levelland. If not, see <http://www.gnu.org/licenses/>.
--]]

local function GetQuestLinkLevel(link)
	return link and strmatch(link, 'quest:%d+:(%d+)')
end

local function GetQuestLevel(id)
	return id and GetQuestLinkLevel(GetQuestLink(id))
end

local function GetQuestLogLevel(index)
	return index and GetQuestLevel(select(8, GetQuestLogTitle(index)))
end


--[[ Quest Tracker ]]--

hooksecurefunc(QUEST_TRACKER_MODULE, 'SetBlockHeader', function(self, block, title, index, isComplete)
	local level = GetQuestLevel(block.id)
	if level then
		local level = ' (' .. level .. ')'
		local height = self:SetStringText(block.HeaderText, title .. level, true, OBJECTIVE_TRACKER_COLOR['Header'])

		if height > OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT then
			local after = '...' .. level

			while height > OBJECTIVE_TRACKER_DOUBLE_LINE_HEIGHT do
				title = title:sub(0, -2)
				height = self:SetStringText(block.HeaderText, title .. after, true, OBJECTIVE_TRACKER_COLOR['Header'])
			end
		end
	end
end)


--[[ Quest Map ]]--

hooksecurefunc('QuestLogQuests_Update', function()
	for i, button in pairs{QuestMapFrame.QuestsFrame.Contents:GetChildren()} do
		if button.Check then
			local level = GetQuestLevel(button.questID)
			if level then
				local height = button.Text:GetHeight()

				button.Text:SetFormattedText('%s (%d)', button.Text:GetText(), level)
				button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth() + 2, 0)
				button:SetHeight(button:GetHeight() - height + button.Text:GetHeight())
			end
		end
	end
end)

hooksecurefunc('QuestInfo_Display', function(template, parentFrame)
	local questFrame = parentFrame:GetParent():GetParent()
	local id = template.questLog and questFrame.questID or GetQuestID()
	local level = GetQuestLevel(id)
	if level then
		QuestInfoTitleHeader:SetFormattedText('%s (%d)', QuestInfoTitleHeader:GetText(), level)
	end
end)

hooksecurefunc('QuestMapLogTitleButton_OnEnter', function(button)
	local level = GetQuestLevel(button.questID)
	if level then
		GameTooltipTextLeft1:SetFormattedText('%s (%d)', GameTooltipTextLeft1:GetText(), level)
		GameTooltip:Show()
	end
end)


--[[ Quest Greeting ]]--

QuestFrameGreetingPanel:HookScript('OnShow', function()
	local numActiveQuests = GetNumActiveQuests()

	for i= 1, numActiveQuests + GetNumAvailableQuests() do
		local level = i > numActiveQuests and GetAvailableLevel(i) or GetActiveLevel(i)
		local line = _G['QuestTitleButton'..i]

		line:SetFormattedText('%s (%d)', line:GetText(), level)
	end
end)


--[[ Gossip Frame ]]--

local function HookGossipLines(func, n)
	hooksecurefunc(func, function(...)
		local start = GossipFrame.buttonIndex - select('#', ...) / n - 1

		for i = start, GossipFrame.buttonIndex - 2 do
			local level = select((i - start) * n + 2, ...)

			if type(level) == 'number' and level > -1 then
				local line = _G['GossipTitleButton'..i]
				line:SetFormattedText('%s (%d)', line:GetText(), level)
			end
		end
	end)
end

TRIVIAL_QUEST_DISPLAY = NORMAL_QUEST_DISPLAY
HookGossipLines('GossipFrameAvailableQuestsUpdate', 6)
HookGossipLines('GossipFrameActiveQuestsUpdate', 5)


--[[ Tooltips ]]--

local TooltipMeta = getmetatable(CreateFrame('GameTooltip')).__index
hooksecurefunc(TooltipMeta, 'SetHyperlink', function(tooltip, link)
	local level = GetQuestLinkLevel(link)
	if level then
		local line = _G[tooltip:GetName()..'TextLeft1']
		line:SetFormattedText('%s (%d)', line:GetText() or '', level)
		tooltip:Show()
	end
end)
