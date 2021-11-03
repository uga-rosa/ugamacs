#!/usr/bin/env lua

local lfs = require("steel.lfs")
local array = require("steel.array")
local str = require("steel.string")
require("steel.dump")
local json = require("json")

local function get_rg(dirname)
    local res = {}
    local files = lfs.walkdir(dirname, "file")
    for _, file in ipairs(files) do
        local num = file:match("%d+")
        res[num] = array.new(lfs.readlines(file))
            :filter(function(line)
                return not (str.startswith(line, "@") or str.startswith(line, "#"))
            end)
            :map(function(line)
                return tonumber(line:match("^%s+%S+%s+(%S+)"))
            end)
    end
    return res
end

local function separate(rgs, j_data)
    local ads, non = {}, {}
    for num, steps in pairs(j_data) do
        for i = 1, #steps do
            if steps[i] then
                ads[#ads + 1] = rgs[num][i]
            else
                non[#non + 1] = rgs[num][i]
            end
        end
    end
    table.sort(ads)
    table.sort(non)
    return ads, non
end

local JSON_NAME = "steps.json"
local handle = io.open(JSON_NAME, "r")
local j_data = json.decode(handle:read("*a"))
handle:close()

local RG_DIR = "rg"
local ads, non = separate(get_rg(RG_DIR), j_data)

local OUTPUT_ADS = "rg_ads.txt"
handle = io.open(OUTPUT_ADS, "w")
handle:write(table.concat(ads, "\n"))
handle:close()

local OUTPUT_NON = "rg_non.txt"
handle = io.open(OUTPUT_NON, "w")
handle:write(table.concat(non, "\n"))
handle:close()
