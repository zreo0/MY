--
-- �ƾ�����
-- by ���� @ ˫���� @ ݶ����
-- Build 20140730
--
-- ��Ҫ����: �ƾ�����
-- 
local _L = MY.LoadLangPack(MY.GetAddonInfo().szRoot.."ImRobot/lang/")
local _Cache = {
    szQueryUrl = "http://www.zhaiyiming.com/Software/robot/api/?format=json&encoding=gbk&msg=",
    szHead = _L['(auto mode)'],
    tQueue = {},
}
MY_ImRobot = {}
MY_ImRobot.bEnable = false
-- RegisterCustomData('MY_ImRobot.bEnable')

-- ��ȡ��Ŀ�ʹ�
MY_ImRobot.OnWhisper = function(szName, szMsg)
    if szName == GetClientPlayer().szName then
        return
    end
    
    local szUrl = _Cache.szQueryUrl .. MY.String.UrlEncode(szMsg)
    MY.RemoteRequest(szUrl, function(szTitle, szContent)Output(szContent)
        local data = MY.Json.Decode(szContent)
        if not data then
            return nil
        end
        
        table.insert(_Cache.tQueue, { szName = szName, szText = _Cache.szHead .. data.text })
    end, function()
        Output('Query Talk Failed.', szName, szMsg)
    end, 10000)
end

_Cache.OnMsgArrive = function(szMsg, nFont, bRich, r, g, b)
    if not MY_ImRobot.bEnable then
        return
    end
    -- �ݴ�
    if not bRich then
        return
    end
    -- ��ʽ����Ϣ
    local tMsgContent = MY.Chat.FormatContent(szMsg)
    -- �����Ϣ�Ƿ��Ǳ����������
    if tMsgContent[1].type ~= "name" then
        return
    end
    -- ��ȡ��������˵�����
    local szName = tMsgContent[1].name
    -- �Ƴ���Ϣͷ����β������
    table.remove(tMsgContent, 1)
    table.remove(tMsgContent, 1)
    table.remove(tMsgContent)
    
    local szText = ''
    for _, msg in ipairs(tMsgContent) do
        if msg.text then
            szText = szText .. msg.text
        end
    end
    
    MY_ImRobot.OnWhisper(szName, szText)Output(szName, szText)
end

MY_ImRobot.Reply = function()
    if #_Cache.tQueue == 0 then
        return
    end
    
    local rec = table.remove(_Cache.tQueue, 1)Output(rec)
    MY.Talk(rec.szName, rec.szText)
end

_Cache.OnPanelActive = function(wnd)
    local ui = MY.UI(wnd)
    local w, h = ui:size()
    
    ui:append("WndCheckBox_EnableRobot", "WndCheckBox"):children("#WndCheckBox_EnableRobot"):pos(20,20)
      :text(_L['enable im robot']):check(MY_ImRobot.bEnable or false)
      :check(function(bCheck)
        MY_ImRobot.bEnable = bCheck
        if MY_ImRobot.bEnable then
            RegisterMsgMonitor(_Cache.OnMsgArrive, { 'MSG_WHISPER' })
        else
            UnRegisterMsgMonitor(_Cache.OnMsgArrive)
        end
    end)
end

MY.RegisterPanel( "ImRobot", _L["im robot"], _L['General'], "ui/Image/UICommon/PlugIn.UITex|6", {255,127,0,200}, {
    OnPanelActive = _Cache.OnPanelActive, OnPanelDeactive = nil
})
MY.Game.AddHotKey("MY_ImRobot_Reply", _L["ImRobot Reply"], function() MY_ImRobot.Reply() end, nil)