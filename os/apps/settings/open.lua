--Function Forwarders

function setPos(...) return term.setCursorPos(...) end
function setTextColor(...) return term.setTextColor(...) end
function setBackgroundColor(...) return term.setBackgroundColor(...) end
function box(...) return paintutils.drawFilledBox(...) end
function write(...) return term.write(...) end

local MAX_X, MAX_Y = term.getSize()
local scroll = 0

function init()
    while true do
        render()

        if scroll > 50 then return end

        sleep(0.5)
    end
end

function click_listener()
    while true do
        local event, click, x, y = os.pullEvent("mouse_click")

    end
end

function scroll_listener()
    while true do
        local event, dir, x, y = os.pullEvent("mouse_scroll")
        scroll = scroll + (1 * dir)
        render()
    end
end

function render()
    clear()
    renderFrame()
    renderSettings()

    setBackgroundColor(colors.lightGray)
    setTextColor(colors.gray)
    
    setPos(3, 4)
    write("Scroll: " .. scroll)
end

function clear()
    setBackgroundColor(colors.lightGray)
    term.clear()
end

function renderFrame()
    box(1, 1, MAX_X, 2, colors.gray) -- Top Bar
    box(1, 1, 1, MAX_Y, colors.gray) -- Left Bar
    box(1, MAX_Y, MAX_X, MAX_Y, colors.gray) -- Bottom Bar
    box(MAX_X, 1, MAX_X, MAX_Y, colors.gray) -- Right Bar
    setPos(10, 2)
    setTextColor(colors.lightGray)
    write("Settings")
end

function renderSettings()

end

parallel.waitForAny(init, click_listener, scroll_listener)
os.reboot()