require "ISUI/ISInventoryPaneContextMenu"

local old_onInspectClothing = ISInventoryPaneContextMenu.onInspectClothing
ISInventoryPaneContextMenu.onInspectClothing = function(playerObj, clothing)
    local scriptItem = clothing:getScriptItem()
    local fabricType = scriptItem:getFabricType()

    if scriptItem and fabricType == nil and clothing:getCoveredParts():size() > 0 then
        scriptItem:DoParam("FabricType = Leather")
    end

	old_onInspectClothing(playerObj, clothing)
end