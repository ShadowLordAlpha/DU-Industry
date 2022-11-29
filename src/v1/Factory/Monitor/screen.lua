if not init then
    init = true
    Test = ''
    inputstring = ""
    input = nil
    IndustryHubName = "HUB 1"
    IndustryIsSelected = false
    SelectedIndustryNumber = nil

    Industry = {}

    -- Functions
    function Ternary(condition,x,y) if condition then return x else return y end end
    function ToVec4(a,b,c,d) return {x = a, y = b, z = c, r = d} end
    function ToColor(w,x,y,z) return {r = w, g = x, b = y, o = z} end

    function Split(s, delimiter)
        result = {};
        for match in (s..delimiter):gmatch("(.-)"..delimiter) do
            table.insert(result, match);
        end
        return result;
    end

    function DisplayText(layer, fnt, text, x, y, alignH, alignV, color)
        setNextFillColor(layer, color.r, color.g, color.b, color.o)
        setNextTextAlign(layer, alignH, alignV)
        addText(layer, fnt, text, x, y)
    end

    function DisplayBox(layer, x, y, w, h, fill, shadow, blur, round, stroke, strokeWidth)
        if stroke ~= nil then setNextStrokeColor(layer, stroke.r, stroke.g, stroke.b, stroke.o) end
        if strokeWidth ~= nil then setNextStrokeWidth(layer, strokeWidth) end
        if shadow ~= nil then setNextShadow(layer, blur, shadow.r, shadow.g, shadow.b, shadow.o) end
        if fill ~= nil then setNextFillColor(layer, fill.r, fill.g, fill.b, fill.o) end
        if round ~= nil then addBoxRounded(layer, x, y, w, h, round) else addBox(layer, x, y, w, h) end
    end

    function GetMouse()
        local mx, my = getCursor()
        Mouse = {x = mx, y = my, Down = getCursorDown(), Release = getCursorReleased()}
    end

    function GetState(n)
        local s = ""
        if n == 1 then
            s = "STOPPED"
        elseif n == 2 then
            s = "RUNNING"
        elseif n == 3 then
            s = "MISSING INGREDIENT"
        elseif n == 4 then
            s = "OUTPUT FULL"
        elseif n == 5 then
            s = "NO OUTPUT CONTAINER"
        elseif n == 6 then
            s = "PENDING"
        elseif n == 7 then
            s = "MISSING SCHEMATIC"
        elseif n == 8 then
            s = "STOPPING"
        end
        return s
    end

    function GetStateColor(n)
        local c = {}
        n = tonumber(n)
        if n == 1 or n == 6 then
            c = ToColor(1,1,.2,1)
        elseif n == 2 then
            c = ToColor(.2,1,.2,1)
        else
            c = ToColor(1,.2,.2,1)
        end
        return c
    end

    function CreateHubRow(obj,layer,font,font2,font3,n,x)
        local c = GetStateColor(tonumber(obj.Status))
        local sx = x - 220
        local psx = math.floor(x/3)

        if IndustryIsSelected then
            if obj.Selected then
                setNextFillColor(layer, .9, .9, .2, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, Ternary(obj.Item ~= nil,obj.Item, ""), 230, 100)

                setNextFillColor(layer, .7, .7, .7, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font2, Ternary(obj.Description ~= nil, obj.Description, "") .. "", 230, 120)

                setNextFillColor(layer, c.r, c.g, c.b, c.o)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, Ternary(obj.Status ~= nil, GetState(tonumber(obj.Status)), ""), 230, 150)

                setNextFillColor(layer, .7, .7, .7, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font2, "Eff", 230, 200)

                setNextFillColor(layer, .7, .7, .7, 1)
                setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
                addText(layer, font2, "Completed", x - (sx - (math.floor(sx/2))), 200)

                setNextFillColor(layer, .7, .7, .7, 1)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font2, "Up Time", x, 200)

                setNextFillColor(layer, .2, .9, .2, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, Ternary(obj.Eff ~= nil,obj.Eff, "") .. "%", 230, 220)

                setNextFillColor(layer, .2, .9, .2, 1)
                setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
                addText(layer, font, Ternary(obj.CyclesCompleted ~= nil,obj.CyclesCompleted, ""), x - (sx - (math.floor(sx/2))), 220)

                setNextFillColor(layer, .2, .9, .2, 1)
                setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
                addText(layer, font, Ternary(obj.UpTime ~= nil,obj.UpTime, ""), x, 220)

                setNextFillColor(layer, .8, .8, .2, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, "INPUTS", 250, 300)

                for k,v in ipairs(obj.Input) do
                    setNextFillColor(layer, .8, .8, .8, 1)
                    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                    addText(layer, font2, obj.Input[k], 265, 300+(k*18))
                end

                setNextFillColor(layer, .8, .8, .2, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, "OUTPUTS", x - 550, 300)

                for k,v in ipairs(obj.Output) do
                    setNextFillColor(layer, .8, .8, .8, 1)
                    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                    addText(layer, font2, obj.Output[k], x - 535, 300 +(k*18))
                end

                setNextFillColor(layer, .8, .8, .2, 1)
                setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                addText(layer, font, "BANK", x - 300, 300)

                for k,v in ipairs(obj.Bank) do
                    local tt = Split(obj.Bank[k],'@')
                    setNextFillColor(layer, .8, .8, .8, 1)
                    setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
                    if tt[2] ~= nil then
                        addText(layer, font2, math.floor(tt[2])..' | '..tt[1] , x - 285, 300 +(k*18))
                    end
                end
            end
        else
            setNextFillColor(layer, .9, .9, .2, 1)
            setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
            addText(layer, font, Ternary(obj.Item ~= nil,obj.Item, ""), 220+10, 50+(50*n))

            local tempInputList = ''
            for k,v in ipairs(obj.Input) do
                tempInputList = tempInputList .. Ternary(k == 1, "", " | ") .. obj.Input[k]
            end

            setNextFillColor(layer, .8, .8, .8, 1)
            setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
            addText(layer, font2, tempInputList, 230, 65+(50*n))

            if c == nil then c = ToColor(.9,.9,.9,1) end

            setNextFillColor(layer, c.r, c.g, c.b, c.o)
            setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
            addText(layer, font, Ternary(obj.Status ~= nil, GetState(tonumber(obj.Status)), ""), x - 210, 50+(50*n))

            setNextFillColor(layer, .2, .9, .2, 1)
            setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
            addText(layer, font, Ternary(obj.Eff ~= nil,obj.Eff, "") .. "%", x - 50, 50+(50*n))

            setNextFillColor(layer, .7, .7, .7, 1)
            setNextTextAlign(layer, AlignH_Left, AlignV_Middle)
            addText(layer, font2, Ternary(inputList ~= nil,inputList, "") .. "", 220+10, 68+(50*n))
        end
        setNextStrokeWidth(layer,2)
        setNextFillColor(layer, 0, 0, 0, 1)
        if obj.Selected then
            setNextStrokeColor(layer, .2,.2,.2,1)
        else
            setNextStrokeColor(layer, 0,0,0,1)
        end
        addCircle(layer, 18, 48+(50*n), 8)

        --setNextShadow(layer, 25, 0, 0, 0, 1)
        if obj.Selected then
            setNextShadow(layer,6, 9, 9, 0.2, 1)
            setNextFillColor(layer, 10, 10, 0.2, 1)
            addCircle(layer, 18, 48+(50*n), 2)
            setNextFillColor(layer, 0, 0, 0, 1)
            setNextStrokeColor(layer, 1, 1, .2, 1)
        else
            setNextFillColor(layer, 0.1, 0.1, 0.1, 1)
            setNextStrokeColor(layer, 0, 0, 0, 1)
        end

        setNextStrokeWidth(layer,2)
        addBox(layer, 0, 26+(50*n), 220, 46)

        setNextFillColor(layer, .9, .9, .9, 1)
        setNextTextAlign(layer, AlignH_Right, AlignV_Middle)
        addText(layer, font, Ternary(obj.Name ~= nil,obj.Name, "") .. "", 215, 54+(50*n))
    end

    function SetSelected(n)
        for k,v in ipairs(Industry) do
            Industry[k].Selected = (n == k)
            if Industry[k].Selected then
                setOutput('INDUSTRY'..n)
                IndustryIsSelected = true
                SelectedIndustryNumber = n
            end
        end
    end

    function CreateItem(input)
        local t = {}

        if Industry[tonumber(input[2])] ~= nil then
            t.Selected = Industry[tonumber(input[2])].Selected
        else
            t.Selected = false
        end

        t.Item = input[6]
        t.Status = input[5]
        t.Eff = input[4]
        t.CyclesCompleted = input[8]
        t.UpTime = input[9]
        t.Input = Split(input[10], "~")
        t.Output = Split(input[11], "~")
        t.Name = input[3]
        t.Description = input[7]
        t.Maintain = input[13]
        t.Batch = input[14]

        logMessage(input[12].."string")

        if input[12] ~= "taco" then
            t.Bank = Split(input[12], "~")
        else
            t.Bank = input[12]
        end
        return t
    end

    function CreateButton(layer, font, name, x, tx, y, mx, my, r)
        local click = false
        if r and mx > x and mx < x + tx and my > y and my < y + 50 then click = true end

        setNextFillColor(layer, 0.9, 0.9, 0.2, 1)
        setNextStrokeColor(layer, 0, 0, 0, 1)
        setNextStrokeWidth(layer,2)
        addBox(layer, x, y, tx, 50)

        setNextFillColor(layer, .2, .2, .2, 1)
        setNextTextAlign(layer, AlignH_Center, AlignV_Middle)
        addText(layer, font, name, (x + (math.floor(tx/2))), y + 25)
        return click
    end

    function SendMessage()

    end
end

-- Layers
local rx, ry = getResolution()
local hx = rx/2 + 100
local hy = ry/2 + 0
local tx = math.floor((rx - 230)/3)
local gridlayer = createLayer()
local infolayer = createLayer()
local headerlayer = createLayer()
local timefont = loadFont("RefrigeratorDeluxe", 30)
local font = loadFont("FiraMono-Bold", 25)
local orefont = loadFont("FiraMono-Bold", 12)
local sufont = loadFont("FiraMono-Bold", 10)
local mx, my = getCursor()
local hoverindex = 0
local header = ''

-- Player Actions
down = getCursorDown()
release = getCursorReleased()
mx = math.floor(mx)
my = math.floor(my)
inputstring = getInput()

if inputstring ~= "" then input = Split(inputstring, "#") end

if input ~= nil then
    if input[1] == "I" then Industry[tonumber(input[2])] = CreateItem(input) end
end

local total = 0
for k,v in ipairs(Industry) do
    if Industry[k] ~= nil then
        total = k
        if release and mx > 0 and mx < 220 and my > (22+(50*k)) and my < (72+(50*k)) then SetSelected(k) end
        CreateHubRow(Industry[k],gridlayer,font,orefont,planetfont,k,rx,selected)
    end
end

if IndustryIsSelected then
    if release and mx > 0 and mx < 220 and my > (22+(50*(total+1))) and my < (72+(50*(total+1))) then IndustryIsSelected = false end

    setNextFillColor(infolayer, 0.1, 0.1, 0.1, 1)
    setNextStrokeColor(infolayer, 0, 0, 0, 1)
    setNextStrokeWidth(infolayer,2)
    addBox(infolayer, 0, 26+(50*(total+1)), 220, 46)
    setNextFillColor(infolayer, .9, .9, .9, 1)
    setNextTextAlign(infolayer, AlignH_Center, AlignV_Middle)
    addText(infolayer, font, "BACK", 110, 54+(50*(total+1)))
end

if IndustryIsSelected then
    if CreateButton(infolayer, font, "START", 230, tx, 510, mx, my, release) then setOutput('START'..SelectedIndustryNumber) end
    if CreateButton(infolayer, font, "MAINTAIN "..Industry[SelectedIndustryNumber].Maintain, 230 + tx, tx, 510, mx, my, release) then setOutput('MAINTAIN'..SelectedIndustryNumber) end
    if CreateButton(infolayer, font, "BATCH "..Industry[SelectedIndustryNumber].Batch, 230 + (tx*2), tx, 510, mx, my, release) then setOutput('BATCH'..SelectedIndustryNumber) end
    if CreateButton(infolayer, font, "UPDATE BANK", 230, tx, 565, mx, my, release) then setOutput('UPDATEBANK'..SelectedIndustryNumber) end
    if CreateButton(infolayer, font, "SOFT STOP", 230 + tx, tx, 565, mx, my, release) then setOutput('SOFTSTOP'..SelectedIndustryNumber) end
    if CreateButton(infolayer, font, "HARD STOP", 230 + (tx*2), tx, 565, mx, my, release) then setOutput('HARDSTOP'..SelectedIndustryNumber) end
end

-- Info
setNextShadow(infolayer, 15, 0, 0, 0, 1)
setNextFillColor(infolayer, 1, 1, 1, .2)
addBox(infolayer, 0, 0, 220, ry)

-- Header
if input ~= nil then headertext = "INDUSTRY HUB" end
setNextShadow(headerlayer, 25, 0, 0, 0, 1)
setNextFillColor(headerlayer, 1, 1, 0.2, 1)
addBox(headerlayer, 0, 0, 1050, 52)
setNextFillColor(headerlayer, .1, .1, .1, 1)
setNextTextAlign(headerlayer, AlignH_Center, AlignV_Middle)
addText(headerlayer, font, headertext, rx/2, 30)

setBackgroundColor(.1, .1, .1)
requestAnimationFrame(2)