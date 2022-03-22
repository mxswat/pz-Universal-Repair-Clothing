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

    local playerObj = getSpecificPlayer(player)
    if tostring(#items) == "1" and clothing then
        local scriptItem = clothing:getScriptItem()
        local fabricType = scriptItem:getFabricType()

        if scriptItem and fabricType == nil and clothing:getCoveredParts():size() > 0 then
            scriptItem:DoParam("FabricType = Leather")
            ripItemsCache[scriptItem:getFullName()] = true
        end

        if ripItemsCache[scriptItem:getFullName()] then
            local option = context:addOption(getRecipeDisplayName("Rip clothing"), playerObj, ISInventoryPaneContextMenu.onRipClothing, items)
            -- Item is favourited, add tooltip
            if clothing:isFavorite() then
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = getText("ContextMenu_CantRipFavourite");
                option.toolTip = tooltip;
            end
            
            local tools = ClothingRecipesDefinitions["FabricType"][clothing:getFabricType()].tools;
            if playerObj:isEquippedClothing(clothing) then
                option.notAvailable = true;
                local tooltip = ISInventoryPaneContextMenu.addToolTip();
                tooltip.description = getText("ContextMenu_Require", "Unequip");
                option.toolTip = tooltip;
                -- If Tool is needed
            elseif tools and not playerObj:getInventory():getItemFromType(tools, true, true) then
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
