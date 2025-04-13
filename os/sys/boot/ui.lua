local backend = require "/os/sys/boot/backend"
--Function Forwarders

function setPos(...) return term.setCursorPos(...) end
function clear(...) return term.clear() end
function setTextColor(...) return term.setTextColor(...) end
function setBackgroundColor(...) return term.setBackgroundColor(...) end
function box(...) return paintutils.drawFilledBox(...) end
function write(...) return term.write(...) end



local modem = peripheral.wrap("back")

BORDER_COLOR = settings.get("border_color") or colors.blue
BACKGROUND_COLOR = settings.get("background_color") or colors.lightGray
TITLE_COLOR = settings.get("title_color") or colors.white

local MAX_X, MAX_Y = term.getSize()

local TOP_BAR_HEIGHT = math.floor(MAX_Y / 10) --set Top Bar Height to 10% of screen

local grid = {}

local scroll = 0

local refresh = true

local run_app = nil

local has_update = false

function main()
    parallel.waitForAll(main2, initBackend)
end

function initBackend()
    backend.init()
    backend.log("System Booting")

    has_update = backend.update.check()
    if has_update then backend.log("System Update found") end
end

function main2()
    while true do
        setTextColor(colors.white)
        if refresh and not run_app then
            renderUI()
        end
        sleep(0)
    end
end

function renderUI() --Renders Home Screen UI
    setBackgroundColor(BACKGROUND_COLOR)
    term.clear()
    drawApps()
    drawTopBar()
    if has_update then
        drawUpdateNotif()
    end
end

function drawUpdateNotif()
    box(3, MAX_Y - 1, MAX_X - 3, MAX_Y, BORDER_COLOR)
    setPos(7, MAX_Y - 1)
    setBackgroundColor(BORDER_COLOR)
    setTextColor(colors.green)
    term.write("Update Found!")

    setPos(3, MAX_Y)
    setBackgroundColor(BORDER_COLOR)
    setTextColor(colors.green)
    term.write("Click Here to install")
end

function drawTopBar() --Top Bar
    box(1, 1, MAX_X, TOP_BAR_HEIGHT, BORDER_COLOR)
end

function drawApps()
    local x = 1
    local y = 1
    for _,app in pairs(backend.getAppList()) do
        drawAppIcon(x * 5 + (5 * (x - 1)), y * 5 + (3 * (y - 1)) - scroll, app)

        x = x + 1
        if x > 2 then
            y = y + 1
            x = 1
        end
    end
end

function drawAppIcon(x, y, app)
    box(x, y, x + 6, y + 5, BACKGROUND_COLOR)
    paintutils.drawImage(app:getIcon(), x, y)
    for temp_x=x,x+6 do
        for temp_y=y,y+5 do
            registerApp(temp_x, temp_y, app)
        end
    end
end

function registerApp(x, y, app)
    if not grid[x] then
        grid[x] = {}
    end
    grid[x][y] = app
end

function click_listener()
    while true do
        local event, click, x, y = os.pullEvent("mouse_click")
        setBackgroundColor(colors.blue)
        setTextColor(colors.black)
        setPos(1, 1)
        if has_update then
            if x >= 3 and x <= MAX_X - 3 and y >= MAX_Y - 1 and y <= MAX_Y then
                backend.log("Requesting System Update")
                backend.update.update()
                setPos(2, 3)
                setFG(colors.black)
                setBG(colors.lightGray)
                write("Grabbing Update, please wait...")
            end
        end
        if grid[x] ~= nil and grid[x][y] ~= nil then
            local app = grid[x][y]
            if click == 1 then
                setPos(1, 1)
                backend.log("Opening app: " .. app:getName())
                run_app = app:getStart()
                return
            elseif click == 2 or click == 3 then
                local name = app:getName()
                local length = string.len(name)
                local center_start = (MAX_X / 2 + 1) - (length / 2)
                setPos(center_start, 2)
                refresh = false
                print(name)
                sleep(1)
                refresh = true
                renderUI()
            end
        end
    end
end

function scroll_listener()
    while true do
        local event, dir, x, y = os.pullEvent("mouse_scroll")
        scroll = scroll + (1 * dir)
    end
end
    

parallel.waitForAny(main, click_listener, scroll_listener)
if run_app then shell.run(run_app) end