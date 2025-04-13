local update = require "/os/sys/update/update"
local log = require "/os/lib/log"

local apps = require "/os/lib/app"

local apps_list = {}


function init()
    log.log_sys(" ")
    init_apps('/os/apps/')
    init_apps('/apps/')

    local app_run = {}
    for _,app in pairs(apps_list) do
        local file_path = app:getFolder() .. "/startup"

        if not fs.exists(file_path .. ".lua") then goto continue end
        local app_req = require(string.format(file_path))
        app_run[#app_run + 1] = app_req.run

        ::continue::
    end

    parallel.waitForAll(unpack(app_run))
end

function init_apps(folder)
    local folder_list = fs.list(folder)
    for _, app in pairs(folder_list) do
        local data_file, err = fs.open(folder .. app .. "/info.json", 'r')
        if err then log_error("App " .. app .. " doesn't have a info.json") goto continue end
        local data_file_json = textutils.unserializeJSON(data_file.readAll())
        data_file.close()


        apps_list[#apps_list + 1] = apps.Base:new(data_file_json, app, folder) --TODO Run apps listener.lua files
        log_sys("App " .. app .. " Successfully initialized")

        ::continue::
    end
end

function getAppList()
    return apps_list
end

return {init = init, getAppList = getAppList, update = update, error = log.log_error, log = log.log_sys}