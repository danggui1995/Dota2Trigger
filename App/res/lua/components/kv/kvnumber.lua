local M = class("kvnumber", kvbase)

function M:ctor(root)
    self.lerpValue = 1
    self.addBtn = fgui.GetComponent(root, "addBtn", Button)
    self.addBtn:onClick(function ()
        local newValue = tonumber(self.input:getText()) + self.lerpValue
        self.input:setText(newValue)
        self:saveKV(newValue)
    end)
    self.subBtn = fgui.GetComponent(root, "subBtn", Button)
    self.subBtn:onClick(function ()
        local newValue = tonumber(self.input:getText()) - self.lerpValue
        self.input:setText(newValue)
        self:saveKV(newValue)
    end)
    self.input = fgui.GetComponent(root, "input", InputComponent)
    self.input:onChanged(function ()
        self:saveKV(self.input:getText())
    end)
end

function M:setkv(config, kv, index, context)
    self.lerpValue = config[4]
    self:super("kvbase", "setkv", config, kv, index, context)
    
    if kv then
        self.input:setText(kv[self._valueIndex])
    else
        self.input:setText(config[5])
    end
end

kvnumber = M