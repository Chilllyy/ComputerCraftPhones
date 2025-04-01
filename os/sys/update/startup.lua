local user = "Chilllyy"
local repo = "ComputerCraftPhones"
local branch = settings.get("upd_branch") or "stable"

local url_template = "https://api.github.com/repos/" .. user .. "/" .. repo .. "/"

function getWebTable(url)
    local response = http.get(url)
    local data = response.readAll()
    local table = textutils.unserializeJSON(data)
    return table
end

function clone(url, folder)
    fs.makeDir(folder)
    response = http.get(url)
    data = textutils.unserializeJSON(response.readAll())
    for i,v in ipairs(data) do
        if v.type == "dir" then
            local new_url = v.url
            local new_dir = folder .. "/" .. v.name
            clone(new_url, new_dir)
        elseif v.type == "file" then
            local dl_url = v.download_url
            local dl_r = http.get(dl_url)
            local dl_d = dl_r.readAll()
            local file = folder .. "/" .. v.name
            local f = fs.open(file, "w")
            f.write(dl_d)
            f.close()
        end
    end
end

local url = url_template .. "contents?ref=" .. branch
local folder = "/tmp/upd"

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
    shell.run("rm", "/.gitattributes")
    if pcall(clone, url, folder) then
        shell.run("rm", "/startup")
        shell.run("cp", "/tmp/upd/*", "/")
        shell.run("rm", "/tmp/upd")
        complete = true
    end
end

parallel.waitForAll(backend, bar)