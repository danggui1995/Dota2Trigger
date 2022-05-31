local M = class("kvlink", kvbase)
--[[

格式为
"1"
{
    "ItemDef"   "1000"
}
]]
function M:ctor(root)
    self.title = fgui.GetComponent(root, "title", Label)
    self.value = fgui.GetComponent(root, "value", Label)
    root.onClick:Set(function ()
        local cinfo = KVComplex[self._config[1]]
        if cinfo and cinfo[2] and type(cinfo[2]) == 'function' then
            self._context.data = self.value:getData()
            cinfo[2](self._context, function (data)
                if self.isArray then
                    if self._parentKV[self._valueIndex] then
                        self._parentKV[self._valueIndex][2] = data
                        self:setLinkData(data)
                        Dispatcher.dispatchEvent(EventType.OnSavePressed)
                    else
                        Dispatcher.dispatchEvent(EventType.KVUpdate_Inform_View)
                    end
                else
                    self._parentKV[self._valueIndex] = data
                    self:setLinkData(data)
                    Dispatcher.dispatchEvent(EventType.OnSavePressed)
                end
            end)
        else
            printWarning("kvlink 缺少第二个参数，参数类型为function , key = ", self._config[1])
        end
    end)
end

function M:setLinkData(v)
    local showValue = v
    if showValue == "" then
        showValue = "NONE"
    end
    self.value:setText(showValue)
    self.value:setData(v)

    local keyStr
    if self.isArray then
        keyStr = self._parentKV[self._valueIndex][1]
    else
        keyStr = fgui.GetKeyLang(self._config[1])
    end
    self.title:setText(keyStr)
end

function M:setkv(config, kv, index, context, isArray)
    self:super("kvbase", "setkv", config, kv, index, context)
    self.isArray = isArray

    if kv then
        if self.isArray then
            self:setLinkData(self._parentKV[self._valueIndex][2])
        else
            self:setLinkData(self._parentKV[self._valueIndex])
        end
    else
        self.title:setText("0")
    end
end

kvlink = M