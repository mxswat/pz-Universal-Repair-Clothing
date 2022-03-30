require "ISUI/ISInventoryPaneContextMenu"

local ripItemsCache = {}

local old_ISInventoryPaneContextMenu_createMenu = ISInventoryPaneContextMenu.createMenu
ISInventoryPaneContextMenu.createMenu = function(player, isInPlayerInventory, items, x, y, origin)
    local context = old_ISInventoryPaneContextMenu_createMenu(player, isInPlayerInventory, items, x, y, origin)
    local testItem = nil
    local clothing = nil
    for _, v in ipairs(items) do
        testItem = v;
        if not instanceof(v, "InventoryItem") then
            testItem = v.items[1];
        end
        if testItem:getCategory() == "Clothing" then
            clothing = testItem;
        end
    end

    local playerObj = getPlayer()
    if tostring(#items) == "1" and clothing then
        local scriptItem = clothing:getScriptItem()
        local fabricType = scriptItem:getFabricType()

        if scriptItem and fabricType == nil and clothing:getCoveredParts():size() > 0 then
            scriptItem:DoParam("FabricType = Leather")
            ripItemsCache[scriptItem:getFullName()] = true
        end

        if ripItemsCache[scriptItem:getFullName()] then
            local option = context:addOption(getRecipeDisplayName("Rip clothing"), playerObj, ISInventoryPaneContextMenu.mxOnRipClothing, items)
            -- Item is favourited, add tooltip
            if clothing:isFavorite() then
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = getText("ContextMenu_CantRipFavourite");
                option.toolTip = tooltip;
            end

            -- tools previously used `ClothingRecipesDefinitions["FabricType"][clothing:getFabricType()].tools;`
            -- I hard coded using scissors because I don't trust other modders to not fuck up the ClothingRecipesDefinitions
            local tools = "Base.Scissors"; 
            local playerInventory = playerObj:getInventory()
            if playerObj:isEquippedClothing(clothing) then
                option.notAvailable = true;
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = getText("ContextMenu_Require", "Unequip");
                option.toolTip = tooltip;
                -- If Tool is needed
            elseif playerInventory and not playerInventory:getItemFromType(tools, true, true) then
                option.notAvailable = true;
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                local toolItem = InventoryItemFactory.CreateItem(tools);
                tooltip.description = getText("ContextMenu_Require", toolItem:getDisplayName());
                option.toolTip = tooltip;
            end
        end
    end

    return context
end

-- Needed to fix a bug caused by an unknown mod that was fucking around wiht the ClothingRecipesDefinitions
ISInventoryPaneContextMenu.mxOnRipClothing = function(playerObj, items)
	items = ISInventoryPane.getActualItems(items)
	local items2 = {}
	for _,item in ipairs(items) do
		ISInventoryPaneContextMenu.transferIfNeeded(playerObj, item)
        table.insert(items2, item)
	end
	for _,item in ipairs(items2) do
        ISTimedActionQueue.add(ISRipClothing:new(playerObj, item))
	end
end