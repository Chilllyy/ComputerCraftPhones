local log = require "/os/lib/log"
local apps = require "/os/lib/app"
local git = require "/os/lib/git"

local function getInstalledApps(folder)
    local list = fs.list(folder)

    term.setCursorPos(1, 1)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()

    for _,app in pairs(list) do
        local data_file, err = fs.open(folder .. app .. "/info.json", 'r')
        if err then log.log_error("App " .. app .. " doesn't have a info.json") goto continue end
        local data_file_json = textutils.unserializeJSON(data_file.readAll())
        data_file.close()

        new_app = apps.Base:new(data_file_json, app, folder)

        checkAppForUpdate(new_app)

        ::continue::
    end
end

function checkAppForUpdate(app) 
    local git_user = app:getUser()
    local git_repo = app:getRepo()
    local version = app:getVersion()

    if git_user == nil or git_repo == nil then return end

    local git_info = git.getWebTable(git_user, git_repo, "main", "info.json")

    if tonumber(git_info.version) <= tonumber(version) then return end

    log.log_sys("Updating app " .. app:getName())

    local folder = app:getFolder()

    fs.delete(folder)

    git.clone(git_user, git_repo, "main", folder)
end

function run()
    getInstalledApps("/apps/")
    getInstalledApps("/os/apps/")
end

return {run = run}