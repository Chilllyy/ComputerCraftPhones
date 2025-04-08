function setPos(...) return term.setCursorPos(...) end
function clear(...) return term.clear() end
function setTextColor(...) return term.setTextColor(...) end
function setBackgroundColor(...) return term.setBackgroundColor(...) end

LARGE_BUTTONS = false
SCROLL_SPEED = 1

BORDER_COLOR = colors.blue
BACKGROUND_COLOR = colors.black
TITLE_COLOR = colors.white

local modem = peripheral.wrap("back")
local taxiStatus = 0 -- 0 is selecting, 1 is taxi on the way, 2 is error with taxi
local taxiStatusStation = " "

local stations = {}

function getStationsList()
    modem.open(42070)
    modem.transmit(42069, 42070, {message = "query_stations"})
    while true do
        local event, side, channel, reply, data, distance= os.pullEvent("modem_message")
        if channel == 42070 then
            for ind, station_name in ipairs(data) do
                stations[ind] = station_name
            end
            modem.close(42070)
            return
        end
    end
end


function main()

    local taxiScreenScroll = 0
    local otherScreenScroll = 0
    local screenID = 0

    getStationsList()
    
    drawTaxiScreen(0, 0, nil, nil)

    while true do

        parallel.waitForAny(
        
            function()
                local event, button, x, y = os.pullEvent("mouse_click")

                screenID = checkTitleClick(screenID, x, y)

                if screenID == 0 then
                    drawTaxiScreen(taxiScreenScroll, taxiStatus)
                    taxiStatus = checkTaxiClick(taxiScreenScroll, taxiStatus, x, y)
                    
                    
                end

                if screenID == 1 then
                    drawGPSScreen()
                end
        
                if screenID == 2 then
                    drawOtherScreen(otherScreenScroll, x, y)
                end
            end,

            function()

                local event, dir, x, y = os.pullEvent("mouse_scroll")

                if screenID == 0 then
                    taxiScreenScroll = taxiScreenScroll - dir
                    if taxiScreenScroll >= 0 then
                        taxiScreenScroll = 0
                    end
                    drawTaxiScreen(taxiScreenScroll, taxiStatus, nil, nil)
                end
        
                if screenID == 1 then
                    drawGPSScreen()
                end
        
                if screenID == 2 then
                    drawOtherScreen(otherScreenScroll)
                end

            end
        )
        os.sleep(0)
    end

    
end


function drawTaxiScreen(scroll, status)
    -- Draw background
    setBackgroundColor(BACKGROUND_COLOR)
    clear()

    -- Draw buttons
    for i in ipairs(stations) do
        local station = stations[i]

        if (LARGE_BUTTONS) then
            drawButton(4, i * 4 - 1 + scroll * SCROLL_SPEED, 20, 3, 1, 1, station.nice_name, station.text_color, station.background_color)
        else
            drawButton(4, i * 2 + 1 + scroll * SCROLL_SPEED, 20, 1, 1, 0, station.nice_name, station.text_color, station.background_color)
        end
        
    end

    -- Draw foreground
    drawBorders()
    drawTitle(0)
    drawTaxiStatus(status, taxiStatusStation)
end


function checkTaxiClick(scroll, status, x, y)

    if x < 4 or x > 23 or y < 2 or y > 15 then
        return status
    end

    if (LARGE_BUTTONS) then
        
    else
        local clickedRow = (y - scroll * SCROLL_SPEED - 1) / 2
        if clickedRow % 1 == 0 and clickedRow <= #stations then
            local clickedStation = stations[clickedRow]
            callTrain(clickedStation.name)
            return 1
        end
    end
    return status
end

function callTrain(station_name)
    local x, y, z = gps.locate()
    local data = {
        message = "call_train",
        station = station_name,
        pos = {
            x = x,
            y = y,
            z = z
        }
    }

    modem.transmit(42069, 42071, data)
    modem.open(42071)
    while true do
        local event, side, channel, replay, data, distance = os.pullEvent("modem_message")
        if channel == 42071 then
            if data.message == "no_train" then
                taxiStatus = 2
            elseif data.message == "train_sent" then
                taxiStatus = 1
            elseif data.message == "at_station" then
                taxiStatus = 3
            end
            modem.close(42071)
            taxiStatusStation = data.station
            drawTaxiStatus(taxiStatus, taxiStatusStation)
            sleep(5)
            taxiStatusStation = " "
            taxiStatus = 0
            drawTaxiStatus(taxiStatus, taxiStatusStation)
            return
        end
    end
end


function drawGPSScreen()
    setBackgroundColor(BACKGROUND_COLOR)
    clear()

    setPos(3, 3)
    setTextColor(colors.red)
    term.write("Coming Soon...")

    drawBorders()
    drawTitle(1)
end


function drawOtherScreen(scroll, clickX, clickY)
    setBackgroundColor(BACKGROUND_COLOR)
    clear()

    setPos(3, 3)
    setTextColor(colors.red)
    term.write("Coming Soon...")

    drawBorders()
    drawTitle(2)
end


function drawTitle(menu)
    if menu == 0 then
        setBackgroundColor(BACKGROUND_COLOR)
    else
        setBackgroundColor(BORDER_COLOR)
    end
    setPos(4, 1)
    setTextColor(TITLE_COLOR)
    term.write(" Taxi ")

    if menu == 1 then
        setBackgroundColor(BACKGROUND_COLOR)
    else
        setBackgroundColor(BORDER_COLOR)
    end
    setPos(11, 1)
    setTextColor(TITLE_COLOR)
    term.write(" GPS ")

    if menu == 2 then
        setBackgroundColor(BACKGROUND_COLOR)
    else
        setBackgroundColor(BORDER_COLOR)
    end
    setPos(17, 1)
    setTextColor(TITLE_COLOR)
    term.write(" Other ")

end


function drawBorders()
    paintutils.drawLine(1, 1, 1, 20, BORDER_COLOR)
    paintutils.drawLine(1, 20, 26, 20, BORDER_COLOR)
    paintutils.drawLine(26, 20, 26, 1, BORDER_COLOR)
    paintutils.drawLine(26, 1, 1, 1, BORDER_COLOR)
end


function drawTaxiStatus(status, station)

    paintutils.drawFilledBox(1, 15, 26, 20, BORDER_COLOR)
    paintutils.drawFilledBox(2, 16, 25, 19, BACKGROUND_COLOR)

    setPos(3, 17)
    setBackgroundColor(BACKGROUND_COLOR)

    if status == 0 then
        setTextColor(TITLE_COLOR)
        term.write("Select a station to")
        setPos(3, 18)
        term.write("travel to.")
    end

    if status == 1 then
        setTextColor(colors.green)
        term.write("Your train is on the")
        setPos(3, 18)
        if station == nil then
            term.write("way!")
        else
            term.write("way to " .. station)
        end
    end

    if status == 2 then
        setTextColor(colors.red)
        term.write("No train at station,")
        setPos(3, 18)
        term.write("please try again later")
    end

    if status == 3 then
        setTextColor(colors.red)
        term.write("You are already at")
        setPos(3, 18)
        term.write("desired Station")
    end
end

function checkTitleClick(screenID, x, y)

    if not(y == 1) then
        return screenID
    end

    if x >= 4 and x <= 9 then
        return 0
    end

    if x >= 11 and x <= 15 then
        return 1
    end

    if x >= 17 and x <= 23 then
        return 2
    end

end


function drawButton(x, y, w, h, tx, ty, text, textColor, backgroundColor)
    paintutils.drawFilledBox(x, y, x + w - 1, y + h - 1, backgroundColor)
    setPos(x + tx, y + ty)
    setTextColor(textColor)
    setBackgroundColor(backgroundColor)
    term.write(text)
end


main()
