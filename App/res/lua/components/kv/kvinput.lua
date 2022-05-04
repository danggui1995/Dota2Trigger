local M = class("kvinput", kvbase)

function M:ctor(root)
    self.input = fgui.GetComponent(root, "input", InputComponent)
    self.input:onChanged(function ()
        self:saveKV(self.input:getText())
    end)
end

function M:setkv(config, kv, index, context)
    self:super("kvbase", "setkv", config, kv, index, context)

    if kv then
        self.input:setText(kv[self._valueIndex])
    else
        self.input:setText(config[5])
    end
end

kvinput = M