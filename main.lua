AntibirthRunes = RegisterMod("Antibirth Runes", 1)
Gebo = {}
local mod = AntibirthRunes

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

local EIDGeboRu = "Создает машину для пожертвований"
local EIDKenazRu = "Отравляет всех врагов в комнате"
local EIDFehuRu = "Применяет эффект Прикосновения Мидаса к половине монстров в комнате на 5 секунд"
local EIDOthalaRu = "Дает ещё одну копию случайного имеющегося артефакта"
local EIDSowiloRu = "Восстанавливает ранее убитых врагов в комнате#Позволяет повторно получить награду за зачистку комнаты#!!! Если использовать в борьбе с жадностью, можно превратить комнату в магазин"
local EIDIngwazRu = "Открывает все сундуки в комнате"

if EID then
	EID:addCard(GeboID, "Spawns a donation machine", "Gebo", "en_us")
	EID:addCard(KenazID, "Poisons all enemies in the room", "Kenaz", "en_us")
	EID:addCard(FehuID, "Applies the Midas Touch effect to half the monsters in a room for 5 seconds", "Fehu", "en_us")
	EID:addCard(OthalaID, "Gives another copy of a random item that you already have", "Othala", "en_us")
	EID:addCard(SowiloID, "Respawn all enemies of the room#Allows you to farm room clear rewards#!!! If used in a greed fight, it can reroll the room into a Shop", "Sowilo", "en_us")
	EID:addCard(IngwazID, "Unlocks every chest in the room", "Ingwaz", "en_us")
	EID:addCard(GeboID, "Aparece una máquina de donación", "Gebo", "spa")
	EID:addCard(KenazID, "Envenena a todos los enemigos en la sala", "Kenaz", "spa")
	EID:addCard(FehuID, "Aplica el efecto de Toque de Midas a la mitad de los monstruos en una habitación por 5 segundos", "Fehu", "spa")
	EID:addCard(OthalaID, "Te da una copia de un objeto ya existente en tu inventario", "Othala", "spa")
	EID:addCard(SowiloID, "Revive a los enemigos de una sala limpia#Permite conseguir más recompensas#!!! Si se usa en una pelea contra Greed, puede cambiar la sala a una tienda", "Sowilo", "spa")
	EID:addCard(IngwazID, "Abre todos los cofres de una sala", "Ingwaz", "spa")
	EID:addCard(GeboID, EIDGeboRu,"Гебо","ru")
	EID:addCard(KenazID, EIDKenazRu,"Кеназ","ru")
	EID:addCard(FehuID, EIDFehuRu,"Феху","ru")
	EID:addCard(OthalaID, EIDOthalaRu,"Отала","ru")
	EID:addCard(SowiloID, EIDSowiloRu,"Совило","ru")
	EID:addCard(IngwazID, EIDIngwazRu,"Ингваз","ru")
end

include("save_manager")

local useAPI = {
    [1] = "GiantBook API",
    [2] = "Screen API",
    [3] = "None",
}

local API = 1

AntibirthRunes.CallOnSave[#AntibirthRunes.CallOnSave + 1] = function()
	return "API", API, nil
end

AntibirthRunes.CallOnSettings[#AntibirthRunes.CallOnSettings + 1] = function(data)
    if data["API"] then
		API = data["API"]
	end
end

if ModConfigMenu then
    local RunesMCM = "Antibirth Runes"
	ModConfigMenu.UpdateCategory(RunesMCM, {
		Info = {"Configuration for API mod.",}
	})

    ModConfigMenu.AddSetting(RunesMCM, 
    {
        Type = ModConfigMenu.OptionType.NUMBER,
        CurrentSetting = function()
            return API
        end,
        Default = 1,
        Minimum = 1,
        Maximum = 3,
        Display = function()
            return 'Preffered API to use: '..useAPI[API]
        end,
        OnChange = function(currentNum)
            API = currentNum
        end,
        Info = "Preffered API for animations."
    })
end

function mod:GetRandomNumber(numMin, numMax, rng)
	if not numMax then
		numMax = numMin
		numMin = nil
	end
	
	rng = rng or RNG()

	if type(rng) == "number" then
		local seed = rng
		rng = RNG()
		rng:SetSeed(seed, 1)
	end
	
	if numMin and numMax then
		return rng:Next() % (numMax - numMin + 1) + numMin
	elseif numMax then
		return rng:Next() % numMax
	end
	return rng:Next()
end

local function magicchalk_3f(player)
  local magicchalk = Isaac.GetItemIdByName("Magic Chalk")
  return player:HasCollectible(magicchalk)
end

local function playGiantBook(gfx,sfx,p,card)
	local sound = nil
	if (Options.AnnouncerVoiceMode == 2 or Options.AnnouncerVoiceMode == 0 and p:GetCardRNG(card):RandomInt(4) == 0) then
		sound = sfx
	end
	if GiantBookAPI and API == 1 then
		GiantBookAPI.playGiantBook("Appear", gfx, Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0),sound)
	elseif (API ~= 1 or not GiantBookAPI) then
		if ScreenAPI and API == 2 then
			ScreenAPI.PlayGiantbook("gfx/ui/giantbook/"..gfx, "Appear", p, Isaac.GetItemConfig():GetCard(card))
		end
		if sound then
			SFXManager():Play(sound,1,0)
		end
	end
end

local GeboSlots = {
	
}

function Gebo.IsGeboSlot(_slot)
	for _,slot in ipairs(GeboSlots) do
		if slot.Type == _slot.Type and slot.Variant == _slot.Variant and (slot.SubType == _slot.SubType or slot.SubType == -1) then
			return true
		end
	end
	return false
end

function mod:PrintGeboList()
	for _,slot in ipairs(GeboSlots) do
		print(slot.Variant..":"..slot.SubType)
	end
end

function Gebo.GetGeboSlot(_slot)
	for _,slot in ipairs(GeboSlots) do
		if slot.Type == _slot.Type and slot.Variant == _slot.Variant and (slot.SubType == _slot.SubType or slot.SubType == -1) then
			return slot
		end
	end
end

function Gebo.AddMachineBeggar(variant, func, plays, _type, subtype)
	_type = _type or 6
	subtype = subtype or 0
	plays = plays or 5
	if func ~= nil and type(func) == "function" then
		table.insert(GeboSlots, {Type = _type, Variant = variant, SubType = subtype, Function = func, Plays = plays})
	end
end

function Gebo.UpdateMachineBeggar(variant, func, plays, _type, subtype)
	if type(variant) ~= "number" then return end
	_type = _type or 6
	subtype = subtype or 0
	plays = plays or 5
	
	for key,slot in ipairs(GeboSlots) do
		if slot.Type == _type and slot.Variant == variant and slot.SubType == subtype then
			GeboSlots[key].Type = _type
			GeboSlots[key].Variant = variant
			GeboSlots[key].SubType = subtype
			GeboSlots[key].Plays = plays
			if func ~= nil and type(func) == "function" then
				GeboSlots[key].Function = func
			end
		end
	end
end

include("save_manager")
include("gebo.crane")
include("gebo.fortune")
include("gebo.slot")
include("gebo.blood")
include("gebo.confessional")
include("gebo.restock")
include("gebo.beggar")
include("gebo.devil_beggar")
include("gebo.key_master")
include("gebo.bomb_bum")
include("gebo.battery_bum")
include("gebo.rotten_bum")
include("gebo.retribution.swine_beggar")
include("gebo.retribution.apon_machine")
include("gebo.fiendfolio.cosplay_beggar")
include("gebo.fiendfolio.evil_beggar")
include("gebo.fiendfolio.robot_fortune_teller")
include("gebo.fiendfolio.zodiac_beggar")
include("gebo.fiendfolio.golden_slot")
include("gebo.fiendfolio.vending")
include("gebo.fiendfolio.grid_restock")
include("gebo.andromeda.cosmic_beggar")

function mod:UseGebo(gebo, player, useflags)
	playGiantBook("Gebo.png", GeboSFX, player, GeboID)
	local slots = Isaac.GetRoomEntities()
	local rng = player:GetCardRNG(gebo)
	for _,slot in ipairs(slots) do
		if Gebo.IsGeboSlot(slot) and slot:GetSprite():GetAnimation() ~= "Broken" and slot:GetSprite():GetAnimation() ~= "Death" then
			if not mod:GetData(slot).Gebo then
				rng:SetSeed(slot.InitSeed + Random(), 35)
				mod:GetData(slot).Gebo = {Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player}
			else
				mod:GetData(slot).Gebo.Uses = mod:GetData(slot).Gebo.Uses + Gebo.GetGeboSlot(slot).Plays
			end
		end
	end
	if magicchalk_3f(player) and rng:RandomInt(2) == 0 and #slots > 0 then
		local slot = slots[rng:RandomInt(#slots) + 1]
		if Gebo.IsGeboSlot(slot) then
			local newslot = Isaac.Spawn(slot.Type, slot.Variant, slot.SubType, Game():GetRoom():FindFreeTilePosition(slot.Position, 9999), Vector.Zero, nil)
			rng:SetSeed(newslot.InitSeed + Random(), 35)
			mod:GetData(newslot).Gebo = {Uses = Gebo.GetGeboSlot(slot).Plays, rng = rng, Player = player}
			SFXManager():Play(SoundEffect.SOUND_SLOTSPAWN, 1, 0, false)
		end
	end
end

function mod:GeboEffect()
	for _,slot in ipairs(Isaac.GetRoomEntities()) do
		if Gebo.IsGeboSlot(slot) then
			local data = mod:GetData(slot)
			if data.Gebo ~= nil then
				if not data.PrevCollide then
					data.PrevCollide = slot.EntityCollisionClass
					slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
				end
				local slotData = Gebo.GetGeboSlot(slot)
				local dead = slotData.Function(slot, data.Gebo.Player, data.Gebo.Uses, data.Gebo.rng)
				
				if dead == nil or type(dead) == "boolean" and dead == true or type(dead) == "number" and dead <= 0 then
					data.Gebo = nil
				elseif type(dead) == "number" and dead > 0 then
					data.Gebo.Uses = dead
				end
			elseif data.PrevCollide then
				slot.EntityCollisionClass = data.PrevCollide
				data.PrevCollide = nil
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.GeboEffect)

--[[function mod:UseGebo(gebo, player, useflags)
	playGiantBook("Gebo.png", GeboSFX, player, GeboID)
	local donoState = Game():GetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BROKEN)
	Game():SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BROKEN, false)
	local slot = Isaac.Spawn(EntityType.ENTITY_SLOT, 8, -1, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
	Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, slot.Position, slot.Velocity, slot)
	Game():SetStateFlag(GameStateFlag.STATE_DONATION_SLOT_BROKEN, donoState)
	if magicchalk_3f(player) then
		local restock = Isaac.Spawn(EntityType.ENTITY_SLOT, 10, -1, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, restock.Position, restock.Velocity, restock)
	end
end]]
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseGebo, GeboID)

function mod:UseKenaz(kenaz, player, useflags)
	playGiantBook("Kenaz.png", KenazSFX, player, KenazID)
	player:AddCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK)
	player:RemoveCollectible(CollectibleType.COLLECTIBLE_TOXIC_SHOCK) --this method actually works lol
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_MEGA_BEAN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseKenaz, KenazID)

function mod:KenazPoison(entity)
	local player = Isaac.GetPlayer(0)
	if entity:GetData()["Poison"] then
		if entity:GetData()["Poison"] > 0 then
			local ranDamage = mod:GetRandomFloat(1.0, 3.5, player:GetCardRNG(KenazID))
			entity:AddPoison(EntityRef(player), 22, ranDamage)
			entity:GetData()["Poison"] = entity:GetData()["Poison"] - 1
			print("poison")
		else 
			entity:GetData()["Poison"] = nil
		end
	end
end
--mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, mod.KenazPoison)

function mod:UseFehu(fehu, player, useflags)
	playGiantBook("Fehu.png", FehuSFX, player, FehuID)
	--player:UseCard(Card.CARD_REVERSE_HERMIT, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	local entities = {}
	for _,e in pairs(Isaac.GetRoomEntities()) do
		if e:IsActiveEnemy(false) and e:IsEnemy() and e:IsVulnerableEnemy() and not EntityRef(e).IsCharmed and not EntityRef(e).IsFriendly then
			table.insert(entities,e)
		end
	end
	local div = magicchalk_3f(player) and 1 or 2
	entities = mod:Shuffle(entities)
	for i = 1,math.ceil(#entities/div) do
		entities[i]:AddMidasFreeze(EntityRef(player), 300 / div)
	end
	Game():GetRoom():TurnGold()
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseFehu, FehuID)

function mod:UseOthala(othala, player, useflags)
	playGiantBook("Othala.png", OthalaSFX, player, OthalaID)
	if player:GetCollectibleCount() > 0 then
		local playersItems = {}
		for item = 1, mod:GetMaxCollectibleID() do
			local itemConf = Isaac.GetItemConfig():GetCollectible(item)
			if player:HasCollectible(item) and itemConf.Type ~= ItemType.ITEM_ACTIVE 
			and (itemConf.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST)
			then
				for i = 1, player:GetCollectibleNum(item,true) do
					table.insert(playersItems,item)
				end
			end
		end
		playersItems = mod:Shuffle(playersItems)
		local data = mod:GetData(player)
		if #playersItems > 0 then
			local randomItem = player:GetCardRNG(OthalaID):RandomInt(#playersItems)+1
			--player:AddCollectible(playersItems[randomItem])
			data.OthalaClone = {}
			table.insert(data.OthalaClone,playersItems[randomItem])
		end
		if magicchalk_3f(player) then
			if #playersItems > 0 then
				local randomItem = player:GetCardRNG(OthalaID):RandomInt(#playersItems)+1
				--player:AddCollectible(playersItems[randomItem])
				table.insert(data.OthalaClone,playersItems[randomItem])
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseOthala, OthalaID)

local function PickingUp(player)
	local s = player:GetSprite()
	for _,im in ipairs({Up,Down,Left,Right}) do
		if s:GetAnimation() == "PickWalk"..im then
			return true
		end
	end
	return false
end

function mod:OthalaDuplicatePickup(player)
	local data = mod:GetData(player)
	if data.OthalaClone then
		if not PickingUp(player) and not player.QueuedItem.Item then
			player:AnimateCollectible(data.OthalaClone[1],"UseItem","PlayerPickup")
			player:QueueItem(Isaac.GetItemConfig():GetCollectible(data.OthalaClone[1]))
			table.remove(data.OthalaClone,1)
		end
		if #data.OthalaClone == 0 then
			data.OthalaClone = nil
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.OthalaDuplicatePickup)

function mod:UseSowilo(sowilo, player, useflags)
	playGiantBook("Sowilo.png", SowiloSFX, player, SowiloID)
	
	if magicchalk_3f(player) then
		player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	else
		player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseSowilo, SowiloID)

function mod:UseIngwaz(ingwaz, player, useflags)
	local entities = Isaac:GetRoomEntities()
	playGiantBook("Ingwaz.png", IngwazSFX, player, IngwazID)
	for i=1, #entities do
		if entities[i]:ToPickup() then
			if (entities[i].Variant >= 50 and 60 >= entities[i].Variant) or entities[i].Variant == PickupVariant.PICKUP_REDCHEST or entities[i].Variant == PickupVariant.PICKUP_MOMSCHEST then
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
mod:AddCallback(ModCallbacks.MC_USE_CARD, mod.UseIngwaz, IngwazID)

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

function mod:GetRandomFloat(numMin, numMax, rng)
    return numMin + rng:RandomFloat() * (numMax - numMin);
end

function mod:GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size -1
end

function mod:GetMaxTrinketID()
    return Isaac.GetItemConfig():GetTrinkets().Size -1
end

function mod:Shuffle(list)
	local size, shuffled  = #list, list
    for i = size, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
    return shuffled
end
