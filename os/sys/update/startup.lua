local git = require "/startup/git"

local user = "Chilllyy"
local repo = "ComputerCraftPhones"
local branch = settings.get("upd_branch") or "stable"

local url_template = "https://api.github.com/repos/" .. user .. "/" .. repo .. "/"

print("Downloading Update, please wait")

local complete = false

local max = 23

local value = 4

function bar()
    term.setBackgroundColor(colors.lightGray)
    term.setTextColor(colors.black)
    term.clear()
    term.setCursorPos(10, 10)
    term.write("Updating...")
    term.setCursorPos(10, 11)
    term.write("Please Wait")
    paintutils.drawFilledBox(value, 12, max, 13, colors.gray)
    repeat
        paintutils.drawFilledBox(4, 12, value, 13, colors.red)
        if value <= max - 2 then
            value = value + math.random(1, 2)
        else
            value = value + 1
        end
        sleep(1)
    until value == max

    term.setBackgroundColor(colors.lightGray)

    if complete then
        term.clear()
        term.setCursorPos(10, 12)
        term.setTextColor(colors.green)
        term.write("Update Successful")
        sleep(3)
        os.reboot()
    else
        term.clear()
        term.setCursorPos(4, 12)
        term.setTextColor(colors.red)
        term.write("Update Unsuccessful")
        sleep(3)
        os.shutdown()
    end
end

function backend()
    shell.run("rm", "/os")
    git.clone(user, "ComputerCraftPhones", branch, "/tmp/upd")
    shell.run("rm", "/startup")
    shell.run("cp", "/tmp/upd/*", "/")
    shell.run("rm", "/tmp/upd")

    fs.makeDir("/os/apps/appstore/")
    git.clone(user, "CCAppstore", "main", "/os/apps/appstore")

    fs.makeDir("/os/apps/settings")
    git.clone(user, "CCSettings", "main", "/os/apps/settings")
    complete = true
end

parallel.waitForAll(backend, bar)