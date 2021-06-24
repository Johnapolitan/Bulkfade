--[[
	/ Bulk Fade / 
	
	About: 
		This module was created to make bulk tweening much easier.
		Bulk tweening is when you tween all the elements together for a better transition.

	Version:
		- 1.1
		- 6/24/2021

	Author(s):
		kingerman88
]]

-- / Types / --

type ArrayList<T> = {[number]:T};
type IndexArray<I,V> = {[I]:V};

-- / Services / --

local TweenService = game:GetService("TweenService");

-- / Variables / --

local DefaultTweenConfiguration = TweenInfo.new(1, Enum.EasingStyle.Cubic)

-- Class Definitions
local ImageElements = {
	["ImageButton"] = true,
	["ImageLabel"] = true,
}
local TextElements = {
	["TextLabel"] = true,
	["TextButton"] = true,
	["TextBox"] = true,
}

-- / Functions / --

local function getAttributesAtValue(element, val)
	local temp = element:GetAttributes();
	for i in pairs(temp) do
		temp[i] = val
	end
	return temp;
end

local function addElement(self, element:Instance, tweenConfig:TweenInfo|nil)
	if not element:IsA("GuiObject") then return end;

	element:SetAttribute("BackgroundTransparency", element.BackgroundTransparency);
	if ImageElements[element.ClassName] then
		element:SetAttribute("ImageTransparency", element.ImageTransparency);
	elseif TextElements[element.ClassName] then
		element:SetAttribute("TextTransparency", element.TextTransparency);
	end
	table.insert(self.UiElements, element);
	self.AppearTweens[element] = TweenService:Create(element, tweenConfig or DefaultTweenConfiguration, element:GetAttributes());
	self.DisappearTweens[element] = TweenService:Create(element, tweenConfig or DefaultTweenConfiguration, getAttributesAtValue(element, 1));
end

local function removeElement(self, element)
	table.remove(self.UiElements, element);
	self.AppearTweens[element] = nil;
	self.DisappearTweens[element] = nil;
end

-- / BulkFade.lua / --

local BulkFade = {}
BulkFade.__index = BulkFade;

-- Creates a new tween group
-- @param elements:ArrayList<Instance> - An arraylist of instances (not nessesarily UI objects)
-- @param tweenConfig:TweenInfo:optional - a custom tweenInfo that will override the default tweenInfoConfig
-- @return BulkFadeGroup
function BulkFade.CreateGroup(elements:ArrayList<Instance>, tweenConfig:TweenInfo)
	local self = {};
	self.UiElements = {};
	self.AppearTweens = {};
	self.DisappearTweens = {};

	for _, element in ipairs(elements) do
		addElement(self, element, tweenConfig);
	end

	return setmetatable(self, BulkFade);
end

-- Calls all the tweens (in)
function BulkFade:TweenIn()
	for element, tween in pairs(self.AppearTweens) do
		tween:Play();
	end
end

-- Calls all the tweens (out)
function BulkFade:TweenOut()
	for element, tween in pairs(self.DisappearTweens) do
		tween:Play();
	end
end

-- Simply returns all the elements in the tweengroup
-- @return ArrayList<GuiObject> - A table of UI elements
function BulkFade:GetElements()
	return self.UiElements;
end

return BulkFade
