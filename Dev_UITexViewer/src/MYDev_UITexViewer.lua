--
-- �����߹���
-- by ���� @ ˫���� @ ݶ����
-- Build 20140730
-- 
local _L = MY.LoadLangPack(MY.GetAddonInfo().szRoot.."Dev_UITexViewer/lang/")
local _Cache = {}
MYDev_UITexViewer = {}
MYDev_UITexViewer.szUITexPath = ''
RegisterCustomData('MYDev_UITexViewer.szUITexPath')

_Cache.OnPanelActive = function(wnd)
    local ui = MY.UI(wnd)
    local w, h = ui:size()
    local x, y = 20, 20
    
    
    local uiBoard = ui:append('WndScrollBox_ImageList','WndScrollBox')
      :children('#WndScrollBox_ImageList')
      :handleStyle(3):pos(x, y+25):size(w-21, h - 70)
    
    local uiEdit = ui:append('WndEdit_Copy', 'WndEditBox'):children('#WndEdit_Copy')
      :pos(x, h-30):size(w-20, 25):multiLine(true)
    
    ui:append('WndAutoComplete_UITexPath','WndAutoComplete'):children('#WndAutoComplete_UITexPath')
      :pos(x, y):size(w-20, 25):text(MYDev_UITexViewer.szUITexPath)
      :change(function(szText)
        local tInfo = KG_Table.Load(szText .. '.txt', {
        -- ͼƬ�ļ�֡��Ϣ���ı�ͷ����
            {f = "i", t = "nFrame" },             -- ͼƬ֡ ID
            {f = "i", t = "nLeft"  },             -- ֡λ��: �����������(Xλ��)
            {f = "i", t = "nTop"   },             -- ֡λ��: ���붥������(Yλ��)
            {f = "i", t = "nWidth" },             -- ֡����
            {f = "i", t = "nHeight"},             -- ֡�߶�
            {f = "s", t = "szFile" },             -- ֡��Դ�ļ�(������)
        }, FILE_OPEN_MODE.NORMAL)
        if not tInfo then
            return
        end
        
        MYDev_UITexViewer.szUITexPath = szText
        uiBoard:clear()
        for i = 0, 256 do
            local tLine = tInfo:Search(i)
            if not tLine then
                break
            end
            
            if tLine.nWidth ~= 0 and tLine.nHeight ~= 0 then
                uiBoard:append("<image>eventid=277 name=\"Image_"..i.."\"</image>"):item('#Image_' .. i)
                  :image(szText .. '.UITex', tLine.nFrame)
                  :size(tLine.nWidth, tLine.nHeight)
                  :alpha(220)
                  :hover(function(bIn) MY.UI(this):alpha((bIn and 255) or 220) end)
                  :tip(szText .. '.UITex#' .. i .. '\n' .. _L['(left click to generate xml)'], MY.Const.UI.Tip.POS_TOP)
                  :click(function() uiEdit:text('<image>width='..tLine.nWidth..' height='..tLine.nHeight..' path="' .. szText .. '.UITex" frame=' .. i ..'</image>') end)
            end
        end
      end)
      :click(function(nButton, raw)
        if IsPopupMenuOpened() then
            MY.UI(raw):autocomplete('close')
        else
            MY.UI(raw):autocomplete('search', '')
        end
      end)
      :autocomplete('option', 'maxOption', 20)
      :autocomplete('option', 'source', LoadLUAData(MY.GetAddonInfo().szRoot .. 'Dev_UITexViewer/data/data') or {})
      :change()
end

MY.RegisterPanel( "Dev_UITexViewer", _L["UITexViewer"], _L['Development'], "ui/Image/UICommon/BattleFiled.UITex|7", {255,127,0,200}, {
    OnPanelActive = _Cache.OnPanelActive, OnPanelDeactive = nil
})