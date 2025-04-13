local log = require "/os/lib/log"

local Base = {
    app_name = "",
    app_version = 0,
    start_script = "",
    git_user = "",
    git_repo = "",
    folder = "",
    icon = {}
}

function Base:getName()
    return self.app_name
end

function Base:getVersion()
    return self.app_version
end

function Base:getIcon()
    return self.icon
end

function Base:getStart()
    return self.start_script
end

function Base:getUser()
    return self.git_user
end

function Base:getRepo()
    return self.git_repo
end

function Base:getFolder()
    return self.folder
end

function Base:new(info_file, app, folder)
    
    local name = info_file.name or nil
    if name == nil then log.log_error("App " .. app .. " info.json doesnt contain name") return end
    
    local app_version = info_file.version or nil
    if app_version == nil then log.log_error("App " .. app .. " info.json doesnt contain version") return end

    local icon = paintutils.loadImage(folder .. app .. "/icon.nfp")
    if not icon then log.log_error("App " .. app .. " doesnt have a icon.nfp") icon = paintutils.loadImage("/os/sys/icon.nfp") end

    local start_script = folder .. app .. "/open.lua"
    if not fs.exists(start_script) then log_error("App " .. app .. " doesn't have a open.lua") return end

    local git_user = info_file.git_user or nil
    if git_user == nil then log.log_error("App " .. app .. " doesnt have a git user") end

    local git_repo = info_file.git_repo or nil
    if git_repo == nil then log.log_error("App " .. app .. "doesnt have a git repo") end

    local o = {}
    setmetatable(o, self)
    o.app_name = name
    o.app_version = app_version
    o.icon = icon
    o.start_script = start_script
    o.git_user = git_user
    o.git_repo = git_repo
    o.folder = folder .. app
    self.__index = self
    return o
end
return {Base = Base}