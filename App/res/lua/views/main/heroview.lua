local M = class("heroview", kvbaseview)

function M:ctor()
    self.packageItem = "abilityview"

    self.kvType = KVManager.Type_Hero
    self.topDataProvider = {
        {Desc[1000026], "Normal"},
        {Desc[1000029], "Fight"},
        {Desc[1000031], "Ability"},
        {Desc[1000032], "Show"},
        {Desc[1000030], "Unusual"},
    }
end

function M:initkvlist()
    self:super("kvbaseview", "initkvlist")
    
    local kvMap = KVManager.getUnitTemplateMap(self.kvType)
    self.kvlist:setDataUpdateFunc(function ()
        self.unitKvMap = {}

        for index = 1, #self.unitKv - 1, 2 do
            local vIndex = index + 1
            local k = self.unitKv[index]
            local v = self.unitKv[vIndex]
            self.unitKvMap[k] = vIndex
            if not kvMap[k] then
                printWarning(Desc.getText(1000010, k, "KVHero.lua"))
            end
        end

        for _, v in pairs(self.KVTemplate_Real) do
            if not self.unitKvMap[v[1]] then
                table.insert(self.unitKv, v[1])
                table.insert(self.unitKv, v[5] or "")
                self.unitKvMap[v[1]] = #self.unitKv
            end
        end

        return self.KVTemplate_Real
    end)
end

function M:onNewUnit()
    table.insert(self.allData, "npc_hero_new")
    local t = {}
    for _, v in ipairs(self.KVTemplate.Normal) do
        table.insert(t, v[1])
        table.insert(t, v[5])
    end
    table.insert(self.allData, t)
    local cnt = self:updateunitlist()
    self.unitlist:setSelectedIndex(cnt, true)
end

return M