local git = require "/os/lib/git"
local apps = require "/os/lib/app"

function setPos(...) return term.setCursorPos(...) end
function setBG(...) return term.setBackgroundColor(...) end
function setFG(...) return term.setTextColor(...) end
function write(...) return term.write(...) end
function box(...) return paintutils.drawFilledBox(...) end

local MAX_X, MAX_Y = term.getSize()
local scroll = 0
local grid = {}
local app_list = git.getWebTable("Chilllyy", "CCAppList", "main", "apps.json")

function init()
    setBG(colors.lightGray)
    term.clear()
    drawAppList()
    drawBorders()

    while true do
        sleep(1)
    end
end

function updateAppList()
    app_list = git.getWebTable("Chilllyy", "CCAppList", "main", "apps.json")
end

function redraw()
    setBG(colors.lightGray)
    term.clear()
    drawAppList()
    drawBorders()
end

function drawAppList()
    local x = 4
    local y = 5 - scroll
    for _,app in pairs(app_list.apps) do
        local name = app.name
        local git_user = app.git_user
        local git_repo = app.git_repo
        local installed = false

        if fs.exists("/apps/" .. name) then installed = true end

        local grid_app = {name = name, git_user = git_user, git_repo = git_repo, installed = installed}

        local color

        if installed then
            color = colors.green
        else
            color = colors.blue
        end

        for temp_x=x,x+19 do
            if not grid[temp_x] then grid[temp_x] = {} end
            for temp_y=y,y+2 do
                grid[temp_x][temp_y] = grid_app
                box(temp_x, temp_y, temp_x, temp_y, color)
            end
        end

        local len = x + 19
        local start = len / 2 - (#name / 2) + 2

        setPos(start, y + 1)
        setFG(colors.black)
        write(name)

        y = y + 4
    end
end

function drawBorders()
    box(1, 1, MAX_X, 2, colors.gray)
    box(1, 1, 1, MAX_Y, colors.gray)
    box(MAX_X, 1, MAX_X, MAX_Y, colors.gray)
    box(1, MAX_Y, MAX_X, MAX_Y, colors.gray)
end

function register_click()
    while true do
        local event, click, x, y = os.pullEvent("mouse_click")
        if not grid[x] or not grid[x][y] then goto continue end

        local app = grid[x][y]
        setPos(3, 3)
        setBG(colors.lightGray)

        if click == 1 then --Left Click, install app
            if app.installed then
                setFG(colors.red)
                write("App already installed")
                sleep(0.5)
                redraw()
            else
                setFG(colors.green)
                write("App was installed")
                git.clone(app.git_user, app.git_repo, "main", "/apps/" .. app.name)
                updateAppList()
                sleep(0.5)
                redraw()
            end
        elseif click == 2 then --Right Click, uninstall app
            if app.installed then --Uninstall app
                fs.delete("/apps/" .. app.name)
                updateAppList()
                setFG(colors.green)
                write("App was uninstalled")
                sleep(0.5)
                redraw()
            else
                setFG(colors.red)
                write("App is not installed")
                sleep(0.5)
                redraw()
            end
        end

        ::continue::
    end
end

function register_scroll()
    while true do
        local event, dir, x, y = os.pullEvent("mouse_scroll")
        scroll = scroll + (2 * dir)
        if scroll > 0 then scroll = 0 end
        redraw()
    end
end

parallel.waitForAny(init, register_click, register_scroll)
os.reboot()