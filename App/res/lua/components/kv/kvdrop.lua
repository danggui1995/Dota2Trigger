local M = class("kvdrop", kvbase)

function M:ctor(root)
    self._isModifier = false
    self.drop = fgui.GetComponent(root, "drop", DropDown)
    self.drop:onChanged(function ()
        local value = self.drop:getSelectedData()
        self:saveKV(value)
    end)
end

function M:setkv(config, kv, index, context)
    self:super("kvbase", "setkv", config, kv, index, context)

    local modulekey = config[4]
    if modulekey then
        local items = KVModule.getItems(modulekey, context)
        if items then
            self.drop:setList(items)
            self.drop:setDataProvider(items)
            local curvalue
            if kv then
                curvalue = kv[self._valueIndex]
            else
                curvalue = config[5]
            end
            for key, value in pairs(items) do
                if value == curvalue then
                    self.drop:setSelectedIndex(key)
                    break
                end
            end
        else
            self.drop:setText("Modulekey not found : " .. modulekey)
        end
    end
end

kvdrop = M