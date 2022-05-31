local M = class("kvflag", kvbase)

function M:ctor(root)
    self._isModifier = false
    self.drop = fgui.GetComponent(root, "drop", DropDown)
    self.drop:onChanged(function (context)
        local itemObj = context.data
        if itemObj then
            local dataProvider = self.drop:getDataProvider()
            local index = itemObj.data + 1
            dataProvider[index][2] = itemObj.selected
            
            self:saveKV(self:updateDropTitle(dataProvider))
        end
    end)
    self.drop:keepVisibleAfterClick(true)
    self.drop:onItemRendered(function (data, index, item)
        item.selected = data[2]
    end)
end

function M:updateDropTitle(dataProvider)
    local t = {}
    for _, v in ipairs(dataProvider) do
        if v[2] then
            table.insert(t, v[1])
        end
    end
    local str = table.concat(t, ' | ')
    self.drop:setText(str)
    return str
end

function M:setkv(config, kv, index, context)
    self:super("kvbase", "setkv", config, kv, index, context)

    local modulekey = config[4]
    if modulekey then
        local items = KVModule.getItems(modulekey, context)
        if items then
            local curvalue
            if kv then
                curvalue = kv[self._valueIndex]
            else
                curvalue = config[5]
            end

            local listData = {}
            local allFlagValue = string.split(curvalue, "|", true)
            for _, v in ipairs(items) do
                local selected = allFlagValue[v] and true or false
                table.insert(listData, {v, selected} )
            end
            self.drop:setList(items)
            self.drop:setDataProvider(listData)
            self:updateDropTitle(listData)

            for key, value in pairs(items) do
                if value == curvalue then
                    self.drop:setSelectedIndex(key, true)
                    break
                end
            end
        else
            self.drop:setText("Modulekey not found : " .. modulekey)
        end
    end
end

kvflag = M