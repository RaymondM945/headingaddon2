local f = CreateFrame("Frame")

local box = CreateFrame("Frame", "MyCenterBox", UIParent)
box:SetSize(25, 25) -- width, height
box:SetPoint("CENTER") -- position at center of screen
box.texture = box:CreateTexture(nil, "BACKGROUND")
box.texture:SetAllPoints()
box.texture:SetColorTexture(0, 0, 0, 1)

local colorMap = {
	player = { 1, 0, 0 },
	party1 = { 0, 1, 0 },
	party2 = { 0, 0, 1 },
	party3 = { 1, 1, 1 },
	party4 = { 0.5, 0.5, 0.5 },
	partypet1 = { 1, 0.5, 0.5 },
	partypet2 = { 0.5, 0.5, 1 },
	partypet3 = { 0.5, 1, 0.5 },
	partypet4 = { 1, 1, 0.5 },
	attack = { 0.5, 0, 0 },
	follow = { 0.5, 0.5, 0 },
	switch = { 1, 0, 0.5 },
}

local colorMap2 = {
	player = { 0.5, 1, 1 },
	party1 = { 0, 0.5, 1 },
	party2 = { 1, 0.5, 0 },
	party3 = { 0, 1, 0.5 },
	party4 = { 0.5, 0, 1 },
	partypet1 = { 1, 1, 0 },
	partypet2 = { 1, 0, 1 },
	partypet3 = { 0.5, 0, 0.5 },
	partypet4 = { 0, 1, 1 },
	attack = { 0.5, 0, 0 },
	follow = { 0.5, 0.5, 0 },
	switch = { 1, 0, 0.5 },
}

local Healingpercentage = { 90, 80, 70, 60, 50 }
local selectedpercentage = Healingpercentage[1]

local checkforheal = false
local testheal = "Test Main"
local followtarget = nil
f:SetScript("OnUpdate", function(self, elapsed)
	if IsInGroup() then
		if not checkforheal then
			box.texture:SetColorTexture(0, 0, 0, 1)
			if UnitExists("party1") and UnitAffectingCombat("party1") then
				box.texture:SetColorTexture(1, 0.5, 1, 1)
				if not followtarget then
					box.texture:SetColorTexture(0.5, 0.5, 0, 1)
				elseif not UnitIsUnit("target", "party1target") then
					box.texture:SetColorTexture(1, 0, 0.5, 1)
				elseif UnitExists("target") then
					local health = UnitHealth("target")
					local maxHealth = UnitHealthMax("target")
					local hpPercent = (health / maxHealth) * 100
					if hpPercent < 70 then
						if not IsCurrentSpell("Attack") then
							box.texture:SetColorTexture(0.5, 0, 0, 1)
						end
					end
				end
			end

			local groupPets = {}
			for i = 0, 4 do
				local petUnit = (i == 0) and "playerpet" or "partypet" .. i

				if UnitExists(petUnit) then
					table.insert(groupPets, petUnit)
				end
			end

			local lowesthp = 100
			local lowestunitname = "player"
			for i = 0, 4 do
				local unit = (i == 0) and "player" or "party" .. i

				if UnitExists(unit) then
					local name = UnitName(unit)
					local health = UnitHealth(unit)
					local maxHealth = UnitHealthMax(unit)
					local hpPercent = (maxHealth > 0) and (health / maxHealth) * 100 or 0

					print(name .. " - " .. hpPercent)

					if hpPercent < lowesthp then
						lowesthp = hpPercent
						lowestunitname = unit
					end
				end
			end

			for _, petUnit in ipairs(groupPets) do
				local petName = UnitName(petUnit)
				local currentHP = UnitHealth(petUnit)
				local maxHP = UnitHealthMax(petUnit)
				local petPercent = (maxHP > 0) and (currentHP / maxHP) * 100 or 0
				print(petName .. " - " .. petPercent)

				if petPercent < lowesthp then
					lowesthp = petPercent
					lowestunitname = petUnit
				end
			end

			print("lowest Hp in the group is " .. lowestunitname .. " With hp: " .. lowesthp)
			local mana = UnitPower("player", 0)

			if mana >= 0 and lowesthp < 100 then
				local spellName = UnitCastingInfo("player")
				local usable, nomana = IsUsableSpell("Holy Light")
				if lowesthp <= selectedpercentage then
					local r, g, b = unpack(colorMap[lowestunitname] or { 0, 0, 0, 1 })
					if spellName ~= "Holy Light" and usable then
						box.texture:SetColorTexture(r, g, b, 1)
					else
						box.texture:SetColorTexture(0, 0, 0, 1)
					end
				else
					local flashName = GetSpellInfo("Flash of Light")
					if flashName then
						local usable2, nomana2 = IsUsableSpell("Flash of Light")
						local r, g, b = unpack(colorMap2[lowestunitname] or { 0, 0, 0, 1 })
						if spellName ~= flashName and usable2 then
							box.texture:SetColorTexture(r, g, b, 1)
						else
							box.texture:SetColorTexture(0, 0, 0, 1)
						end
					end
				end
			else
			end
		end
	end
end)

local colorMapOrder = {
	"player",
	"party1",
	"party2",
	"party3",
	"party4",
	"partypet1",
	"partypet2",
	"partypet3",
	"partypet4",
	"none",
	"attack",
	"follow",
	"switch",
}

local dropdown = CreateFrame("Frame", "MyColorDropdown", UIParent, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOP", UIParent, "TOP", 0, -20)

local dropdownLabel = dropdown:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dropdownLabel:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 0)
dropdownLabel:SetText("Test Main Heal color")

local selectedValue = "none"

UIDropDownMenu_Initialize(dropdown, function(self, level)
	for _, key in ipairs(colorMapOrder) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = key
		info.value = key
		info.func = function()
			selectedValue = key
			UIDropDownMenu_SetSelectedValue(dropdown, key)
			print("Selected:", key)

			if checkforheal then
				if testheal == "Test Main" then
					local color = colorMap[key]
					if color then
						local r, g, b = unpack(color)
						box.texture:SetColorTexture(r, g, b, 1)
					else
						box.texture:SetColorTexture(0, 0, 0, 1)
					end
				else
					local color = colorMap2[key]
					if color then
						local r, g, b = unpack(color)
						box.texture:SetColorTexture(r, g, b, 1)
					else
						box.texture:SetColorTexture(0, 0, 0, 1)
					end
				end
			end
		end
		UIDropDownMenu_AddButton(info, level)
	end
end)

UIDropDownMenu_SetWidth(dropdown, 150)
UIDropDownMenu_SetButtonWidth(dropdown, 150)
UIDropDownMenu_SetSelectedValue(dropdown, selectedValue)
UIDropDownMenu_JustifyText(dropdown, "LEFT")

-- Create a checkbox below the dropdown
local myCheckbox = CreateFrame("CheckButton", "MyCheckbox", UIParent, "UICheckButtonTemplate")
myCheckbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 10, -0) -- offset for padding
myCheckbox.text:SetText("Check Heal")

-- Default state
myCheckbox:SetChecked(checkforheal)

-- Handle checkbox clicks
myCheckbox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		print("Checkbox enabled")
		checkforheal = true

		if testheal == "Test Main" then
			local color = colorMap[selectedValue]
			if color then
				local r, g, b = unpack(color)
				box.texture:SetColorTexture(r, g, b, 1)
			else
				box.texture:SetColorTexture(0, 0, 0, 1)
			end
		else
			local color = colorMap2[selectedValue]
			if color then
				local r, g, b = unpack(color)
				box.texture:SetColorTexture(r, g, b, 1)
			else
				box.texture:SetColorTexture(0, 0, 0, 1)
			end
		end
	else
		print("Checkbox disabled")
		checkforheal = false
		box.texture:SetColorTexture(0, 0, 0, 1)
	end
end)

local dropdown2 = CreateFrame("Frame", "MySecondDropdown", UIParent, "UIDropDownMenuTemplate")
dropdown2:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -30)

UIDropDownMenu_Initialize(dropdown2, function(self, level)
	for _, option in ipairs(Healingpercentage) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = option
		info.value = option
		info.func = function()
			selectedpercentage = option
			UIDropDownMenu_SetSelectedValue(dropdown2, option)
			print("Second dropdown selected:", option)
		end
		UIDropDownMenu_AddButton(info, level)
	end
end)

UIDropDownMenu_SetWidth(dropdown2, 150)
UIDropDownMenu_SetButtonWidth(dropdown2, 150)
UIDropDownMenu_SetSelectedValue(dropdown2, selectedpercentage)
UIDropDownMenu_JustifyText(dropdown2, "LEFT")

local dropdown3 = CreateFrame("Frame", "MyThirdDropdown", UIParent, "UIDropDownMenuTemplate")
dropdown3:SetPoint("TOPLEFT", dropdown2, "BOTTOMLEFT", 0, -30)

-- Label for the third dropdown
local dropdown3Label = dropdown3:CreateFontString(nil, "ARTWORK", "GameFontNormal")
dropdown3Label:SetPoint("BOTTOMLEFT", dropdown3, "TOPLEFT", 20, 0)
dropdown3Label:SetText("Which Heal to Test")

-- Dropdown options
local testOptions = { "Test Main", "Test Secondary" }
testheal = testOptions[1]
UIDropDownMenu_Initialize(dropdown3, function(self, level)
	for _, option in ipairs(testOptions) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = option
		info.value = option
		info.func = function()
			testheal = option
			UIDropDownMenu_SetSelectedValue(dropdown3, option)
			print("Color Test Mode selected:", option)
			if checkforheal then
				if option == "Test Main" then
					local color = colorMap[selectedValue]
					if color then
						local r, g, b = unpack(color)
						box.texture:SetColorTexture(r, g, b, 1)
					else
						box.texture:SetColorTexture(0, 0, 0, 1)
					end
				else
					local color = colorMap2[selectedValue]
					if color then
						local r, g, b = unpack(color)
						box.texture:SetColorTexture(r, g, b, 1)
					else
						box.texture:SetColorTexture(0, 0, 0, 1)
					end
				end
			end
		end
		UIDropDownMenu_AddButton(info, level)
	end
end)
UIDropDownMenu_SetWidth(dropdown3, 150)
UIDropDownMenu_SetButtonWidth(dropdown3, 150)
UIDropDownMenu_SetSelectedValue(dropdown3, testheal)
UIDropDownMenu_JustifyText(dropdown3, "LEFT")

local frame = CreateFrame("Frame")
frame:RegisterEvent("AUTOFOLLOW_BEGIN")
frame:RegisterEvent("AUTOFOLLOW_END")
frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "AUTOFOLLOW_BEGIN" then
		print("Started following:", arg1)
		followtarget = arg1
	elseif event == "AUTOFOLLOW_END" then
		print("Stopped following")
		followtarget = nil
	end
end)
