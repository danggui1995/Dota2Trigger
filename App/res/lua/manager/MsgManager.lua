local M = {}

function M.showMsg(text, ...)
    local str
    if type(text) == 'string' then
        str = string.format(text, ...)
    else
        str = Desc.getText(text, ...)
    end
    -- print("showMsg : ", str)
    Dispatcher.dispatchEvent(EventType.Msg_Show, str)
end

function M.copyToClipBorad(str)
    if str then
        CS.UnityEngine.GUIUtility.systemCopyBuffer = str
        MsgManager.showMsg(1000043, str)
    end
end

MsgManager = M