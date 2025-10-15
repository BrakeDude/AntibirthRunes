AntibirthRunes = RegisterMod("Antibirth Runes", 1)
local mod = AntibirthRunes
local json = require("json")
local Runes = {}

include("libs.gebo.main")

local GeboID = Isaac.GetCardIdByName("Gebo")
local KenazID = Isaac.GetCardIdByName("Kenaz")
local FehuID = Isaac.GetCardIdByName("Fehu")
local OthalaID = Isaac.GetCardIdByName("Othala")
local SowiloID = Isaac.GetCardIdByName("Sowilo")
local IngwazID = Isaac.GetCardIdByName("Ingwaz")

local GeboSFX = Isaac.GetSoundIdByName("Gebo")
local KenazSFX = Isaac.GetSoundIdByName("Kenaz")
local FehuSFX = Isaac.GetSoundIdByName("Fehu")
local OthalaSFX = Isaac.GetSoundIdByName("Othala")
local SowiloSFX = Isaac.GetSoundIdByName("Sowilo")
local IngwazSFX = Isaac.GetSoundIdByName("Ingwaz")

if EID then
	EID:addCard(
		GeboID,
		"Interacts with any machine or beggar in the room. Plays beggars 6 times, plays blood machines 4 times, plays other machines 5 times. Machines and beggars have an increased chance to pay out or explode, even paying out at only one play.",
		"Gebo",
		"en_us"
	)
	EID:addCard(KenazID, "Poisons all enemies in the room", "Kenaz", "en_us")
	EID:addCard(FehuID, "Applies the Midas Touch effect to half the monsters in a room for 5 seconds", "Fehu", "en_us")
	EID:addCard(OthalaID, "Gives another copy of a random item that you already have", "Othala", "en_us")
	EID:addCard(
		SowiloID,
		"Respawn all enemies of the room#Allows you to farm room clear rewards#!!! If used in a greed fight, it can reroll the room into a Shop",
		"Sowilo",
		"en_us"
	)
	EID:addCard(IngwazID, "Unlocks every chest in the room", "Ingwaz", "en_us")
	EID:addCard(
		GeboID,
		"Interactúa con cualquier máquina o mendigo en la habitación. Usa mendigos 6 veces, usa donadores de sangre 4 veces, usa otras máquinas 5 veces. Las máquinas y los mendigos tienen una mayor probabilidad de pagar o explotar, incluso pagando en una sola jugada.",
		"Gebo",
		"spa"
	)
	EID:addCard(KenazID, "Envenena a todos los enemigos en la sala", "Kenaz", "spa")
	EID:addCard(
		FehuID,
		"Aplica el efecto de Toque de Midas a la mitad de los monstruos en una habitación por 5 segundos",
		"Fehu",
		"spa"
	)
	EID:addCard(OthalaID, "Te da una copia de un objeto ya existente en tu inventario", "Othala", "spa")
	EID:addCard(
		SowiloID,
		"Revive a los enemigos de una sala limpia#Permite conseguir más recompensas#!!! Si se usa en una pelea contra Greed, puede cambiar la sala a una tienda",
		"Sowilo",
		"spa"
	)
	EID:addCard(IngwazID, "Abre todos los cofres de una sala", "Ingwaz", "spa")
	EID:addCard(
		GeboID,
		"Взаимодействует с любыми машиной или попрошайкой в ​​комнате. Попрошайки - 6 раз, донорские машины - 4 раза, остальные - 5 раз. Машины и попрошайки имеют повышенный шанс на награды или взорваться, даже если заплатят только за одну игру.",
		"Гебо",
		"ru"
	)
	EID:addCard(KenazID, "Отравляет всех врагов в комнате", "Кеназ", "ru")
	EID:addCard(
		FehuID,
		"Применяет эффект Прикосновения Мидаса к половине монстров в комнате на 5 секунд",
		"Феху",
		"ru"
	)
	EID:addCard(
		OthalaID,
		"Дает ещё одну копию случайного имеющегося артефакта",
		"Отала",
		"ru"
	)
	EID:addCard(
		SowiloID,
		"Восстанавливает ранее убитых врагов в комнате#Позволяет повторно получить награду за зачистку комнаты#!!! Если использовать в борьбе с жадностью, можно превратить комнату в магазин",
		"Совило",
		"ru"
	)
	EID:addCard(IngwazID, "Открывает все сундуки в комнате", "Ингваз", "ru")
end

local useAPI = {
	[1] = "GiantBook API",
	[2] = "Screen API",
	[3] = "None",
}

local GiantBookColors = {
	["poof2"] = Color(0, 0, 0, 0.8, 0, 0, 0),
	["poof"] = Color(0.2, 0.1, 0.3, 1, 0, 0, 0),
	["bg"] = Color(0.117, 0.0117, 0.2, 1, 0, 0, 0),
}

local function CheckAvailableAPI(api, prevAPI, forward)
	if not GiantBookAPI and not ScreenAPI then
		return 3
	end
	if not prevAPI then
		prevAPI = api
	end	
	if api < prevAPI then
		if api == 2 and not ScreenAPI then
			api = 1
		end
		if api == 1 and not GiantBookAPI then
			api = 3
		end
	else
		if api == 1 and not GiantBookAPI then
			api = 2
		end
		if api == 2 and not ScreenAPI then
			api = 3
		end
	end
	return api
end

local function RefreshSaveData()
	if mod:HasData() then
		mod.SavedData = json.decode(mod:LoadData())
		if not mod.SavedData or type(mod.SavedData.BookAPI) ~= "number" or type(mod.SavedData.GeboData) ~= "table" then
			mod.SavedData = {
				BookAPI = 3,
				GeboData = {},
			}

			mod:SaveData(json.encode(mod.SavedData))
		end
		local prevAPI = mod.SavedData.BookAPI
		mod.SavedData.BookAPI = CheckAvailableAPI(prevAPI)
		if prevAPI ~= mod.SavedData.BookAPI then
			mod:SaveData(json.encode(mod.SavedData))
		end
	else
		mod.SavedData = {
			BookAPI = 3,
			GeboData = {},
		}

		mod:SaveData(json.encode(mod.SavedData))
	end
end

RefreshSaveData()

if ModConfigMenu and not REPENTOGON then
	local RunesMCM = "Antibirth Runes"
	ModConfigMenu.UpdateCategory(RunesMCM, {
		Info = { "Configuration for API mod." },
	})

	ModConfigMenu.AddSetting(RunesMCM, {
		Type = ModConfigMenu.OptionType.NUMBER,
		CurrentSetting = function()
			return mod.SavedData.BookAPI
		end,
		Default = 1,
		Minimum = 1,
		Maximum = 3,
		Display = function()
			return "Preffered API to use: " .. useAPI[mod.SavedData.BookAPI]
		end,
		OnChange = function(currentNum)
			mod.SavedData.BookAPI = CheckAvailableAPI(currentNum, mod.SavedData.BookAPI)
			mod:SaveData(json.encode(mod.SavedData))
		end,
		Info = "Preffered API for animations.",
	})
end

if not REPENTOGON then
	function Runes:SaveData(isSaving)
		if isSaving then
			mod.SavedData.GeboData = Gebo.GetSaveData()
			mod:SaveData(json.encode(mod.SavedData))
		end
	end
	mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Runes.SaveData)
	mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
		Runes:SaveData(true)
	end)

	function Runes:LoadData(isLoading)
		if isLoading then
			RefreshSaveData()
			Gebo.LoadSaveData(mod.SavedData.GeboData)
		else
			mod.SavedData.GeboData = {}
		end
	end
	mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Runes.LoadData)
end

local function magicchalk_3f(player)
	local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
	return magicchalk > 0 and player:HasCollectible(magicchalk)
end

local function PlaySND(sound, rng)
	if not rng then
		rng = RNG()
		rng:SetSeed(math.max(1, Isaac.GetFrameCount()), 35)
	end
	if Options.AnnouncerVoiceMode == 2 or Options.AnnouncerVoiceMode == 0 and rng:RandomInt(4) == 0 then
		SFXManager():Play(sound, 1, 0)
	end
end

local function playGiantBook(gfx, sfx, p, rng)
	if REPENTOGON then
		ItemOverlay.Show(Isaac.GetGiantBookIdByName(gfx), 0, p)
		PlaySND(sfx, rng)
	else
		local sound = nil
		if Options.AnnouncerVoiceMode == 2 or Options.AnnouncerVoiceMode == 0 and rng:RandomInt(4) == 0 then
			sound = sfx
		end
		local bookAPI = mod.SavedData.BookAPI
		if GiantBookAPI and bookAPI == 1 then
			GiantBookAPI.playGiantBook(
				"Appear",
				gfx .. ".png",
				GiantBookColors["poof"],
				GiantBookColors["bg"],
				GiantBookColors["poof2"],
				sound
			)
		elseif bookAPI ~= 1 or not GiantBookAPI then
			if ScreenAPI and bookAPI == 2 then
				ScreenAPI.PlayGiantbook("gfx/ui/giantbook/" .. gfx .. ".png", "Appear", p, Isaac.GetItemConfig():GetCard(Isaac.GetCardIdByName(gfx)), GiantBookColors)
			end
			if sound then
				SFXManager():Play(sound, 1, 0)
			end
		end
	end
end

function Runes:UseGebo(gebo, player, useflags)
	local rng = player:GetCardRNG(gebo)
	playGiantBook("Gebo", GeboSFX, player, rng)
	local slots = {}
	for _, slot in ripairs(Isaac.GetRoomEntities()) do
		if Gebo.IsGeboSlot(slot) then
			table.insert(slots, slot)
		end
	end
	for _, slot in ipairs(slots) do
		if slot:GetSprite():GetAnimation() ~= "Broken" and slot:GetSprite():GetAnimation() ~= "Death" then
			if Gebo.GetGeboSlot(slot).REPENTOGON then
				if not Gebo.GetData(slot).GeboUses then
					Gebo.GetData(slot).GeboUses = 0
				end
				Gebo.GetData(slot).GeboUses = Gebo.GetData(slot).GeboUses + Gebo.GetGeboSlot(slot).Plays
			else
				if not Gebo.GetData(slot).Gebo then
					local rng = slot:GetDropRNG()
					Gebo.GetData(slot).Gebo = { Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
				else
					Gebo.GetData(slot).Gebo.Uses = Gebo.GetData(slot).Gebo.Uses + Gebo.GetGeboSlot(slot).Plays
				end
			end
		end
	end
	if magicchalk_3f(player) and rng:RandomInt(2) == 0 and #slots > 0 then
		local slot = slots[rng:RandomInt(#slots) + 1]
		if Gebo.IsGeboSlot(slot) then
			local rng = slot:GetDropRNG()
			local newslot = Isaac.Spawn(
				slot.Type,
				slot.Variant,
				slot.SubType,
				Game():GetRoom():FindFreeTilePosition(slot.Position, 9999),
				Vector.Zero,
				nil
			)
			if Gebo.GetGeboSlot(slot).REPENTOGON then
				Gebo.GetData(newslot).GeboUses = Gebo.GetGeboSlot(slot).Plays
			else
				Gebo.GetData(newslot).Gebo = { Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player }
			end
			SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseGebo, GeboID)

function Runes:UseKenaz(kenaz, player, useflags)
	local rng = player:GetCardRNG(kenaz)
	playGiantBook("Kenaz", KenazSFX, player, rng)
	player:AddCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK, 0, false, 0, 0)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK, true, 0, true)
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEGA_BEAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseKenaz, KenazID)

function Runes:UseFehu(fehu, player, useflags)
	local rng = player:GetCardRNG(fehu)
	playGiantBook("Fehu", FehuSFX, player, rng)
	local entities = {}
	for _, e in pairs(Isaac.GetRoomEntities()) do
		if
			e:IsActiveEnemy(false)
			and e:IsEnemy()
			and e:IsVulnerableEnemy()
			and not EntityRef(e).IsCharmed
			and not EntityRef(e).IsFriendly
		then
			table.insert(entities, e)
		end
	end
	local div = magicchalk_3f(player) and 1 or 2
	entities = mod:Shuffle(entities)
	for i = 1, math.ceil(#entities / div) do
		entities[i]:AddMidasFreeze(EntityRef(player), 300 / div)
	end
	Game():GetRoom():TurnGold()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseFehu, FehuID)

function Runes:UseOthala(othala, player, useflags)
	local data = mod:GetData(player)
	local rng = player:GetCardRNG(othala)
	playGiantBook("Othala", OthalaSFX, player, rng)
	if REPENTOGON then
		local itemConfig = Isaac.GetItemConfig()
		local history = player:GetHistory()
		---@type table
		local collectHistory = history:GetCollectiblesHistory()

		local itemsTable = collectHistory
		local index, item, collectConfig
		local itemsToGet = magicchalk_3f(player) and 2 or 1
		for _ = 1, itemsToGet do
			repeat
				index = rng:RandomInt(rng:RandomInt(#itemsTable)) + 1
				item = itemsTable[index]:GetItemID()
				collectConfig = itemConfig:GetCollectible(item)
				if
					collectConfig.Hidden
					or collectConfig.Type == ItemType.ITEM_ACTIVE
					or collectConfig:HasTags(ItemConfig.TAG_QUEST)
				then
					table.remove(itemsTable, index)
					index = nil
				end
			until index or #itemsTable == 0
			if index then
				if not data.OthalaClone then
					data.OthalaClone = {}
				end
				table.insert(data.OthalaClone, item)
			end
			index = nil
		end
	else
		if player:GetCollectibleCount() > 0 then
			local playersItems = {}
			for item = 1, mod.GetMaxCollectibleID() do
				local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
				if
					player:HasCollectible(item)
					and itemConfig.Type ~= ItemType.ITEM_ACTIVE
					and itemConfig.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST
					and not itemConfig.Hidden
				then
					for _ = 1, player:GetCollectibleNum(item, true) do
						table.insert(playersItems, item)
					end
				end
			end
			playersItems = mod:Shuffle(playersItems)
			if #playersItems > 0 then
				local randomItem = player:GetCardRNG(othala):RandomInt(#playersItems) + 1
				--player:AddCollectible(playersItems[randomItem])
				data.OthalaClone = {}
				table.insert(data.OthalaClone, playersItems[randomItem])
			end
			if magicchalk_3f(player) then
				if #playersItems > 0 then
					local randomItem = player:GetCardRNG(othala):RandomInt(#playersItems) + 1
					table.insert(data.OthalaClone, playersItems[randomItem])
				end
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseOthala, OthalaID)

local function PickingUp(player)
	local s = player:GetSprite()
	if s:GetAnimation():sub(1, 8) == "PickWalk" then
		return true
	end
	return false
end

function Runes:OthalaDuplicatePickup(player)
	local data = mod:GetData(player)
	if data.OthalaClone then
		if not PickingUp(player) and not player.QueuedItem.Item then
			player:AnimateCollectible(data.OthalaClone[1], "UseItem", "PlayerPickup")
			SFXManager():Play(SoundEffect.SOUND_POWERUP1, 1, 0)
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(data.OthalaClone[1]))
			table.remove(data.OthalaClone, 1)
		end
		if #data.OthalaClone == 0 then
			data.OthalaClone = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, Runes.OthalaDuplicatePickup)

function Runes:UseSowilo(sowilo, player, useflags)
	local rng = player:GetCardRNG(sowilo)
	playGiantBook("Sowilo", SowiloSFX, player, rng)

	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseSowilo, SowiloID)

function Runes:UseIngwaz(ingwaz, player, useflags)
	local entities = Isaac:GetRoomEntities()
	local rng = player:GetCardRNG(ingwaz)
	playGiantBook("Ingwaz", IngwazSFX, player, rng)
	for i = 1, #entities do
		if entities[i]:ToPickup() then
			if
				(entities[i].Variant >= 50 and 60 >= entities[i].Variant)
				or entities[i].Variant == PickupVariant.PICKUP_REDCHEST
				or entities[i].Variant == PickupVariant.PICKUP_MOMSCHEST
			then
				entities[i]:ToPickup():TryOpenChest(player)
			end
			if RepentancePlusMod then
				if entities[i].Variant == RepentancePlusMod.CustomPickups.FLESH_CHEST then
					RepentancePlusMod.openFleshChest(entities[i])
				elseif entities[i].Variant == RepentancePlusMod.CustomPickups.SCARLET_CHEST then
					RepentancePlusMod.openScarletChest(entities[i])
				elseif entities[i].Variant == RepentancePlusMod.CustomPickups.BLACK_CHEST then
					RepentancePlusMod.openBlackChest(entities[i])
				end
			end
		end
	end

	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, Runes.UseIngwaz, IngwazID)

function mod:GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.AB_Runes then
			data.AB_Runes = {}
		end
		return data.AB_Runes
	end
	return nil
end

function mod.GetMaxCollectibleID()
	return Isaac.GetItemConfig():GetCollectibles().Size - 1
end

function mod.GetMaxTrinketID()
	return Isaac.GetItemConfig():GetTrinkets().Size - 1
end

function mod:Shuffle(list)
	local size, shuffled = #list, list
	for i = size, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
	return shuffled
end

--ripairs stuff from revel
function ripairs_it(t, i)
	i = i - 1
	local v = t[i]
	if v == nil then
		return v
	end
	return i, v
end
function ripairs(t)
	return ripairs_it, t, #t + 1
end
