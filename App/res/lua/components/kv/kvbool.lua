local M = class("kvbool", kvbase)

function M:ctor(root)
    self.checkBtn = fgui.GetComponent(root, "check", Button)
    self.checkBtn:onChanged(function ()
        self:saveKV(self.checkBtn:isSelected() and "1" or "0")
    end)
end

function M:setkv(config, kv, index, context)
    self:super("kvbase", "setkv", config, kv, index, context)

    if kv then
        self.checkBtn:setSelected(kv[self._valueIndex] == "1")
    else
        self.checkBtn:setSelected(config[5] == 1)
    end
end

kvbool = M