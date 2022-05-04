local M = class("kvbase", BaseComponent)

function M:ctor(root)
    self._parentKV = false
    self._valueIndex = false
    self._context = false
    self._config = false

    self.title = fgui.GetComponent(root, "title", Label)
end

function M:setkv(config, kv, index, context)
    self._config = config
    self._parentKV = kv
    self._valueIndex = index
    self._context = context
    self.title:setText(config[2])
end

function M:saveKV(value)
    if self._parentKV and self._valueIndex then
        self._parentKV[self._valueIndex] = tostring(value)
    end
    Dispatcher.dispatchEvent(EventType.OnSavePressed)
end

kvbase = M