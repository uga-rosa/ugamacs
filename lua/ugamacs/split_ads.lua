#!/usr/bin/env lua

local lfs = require("steel.lfs")
local array = require("steel.array")
local str = require("steel.string")
local json = require("json")

local function get_aus_z(filename)
    local res = array.new()
    local lines = lfs.readlines(filename)
    for i = 3, #lines - 1 do
        local line = lines[i]
        local z_coord = tonumber(str.trim(line:sub(37, 44)))
        local atom_name = str.trim(line:sub(11, 15))
        if atom_name == "AUS" then
            res:append(z_coord)
        end
    end
    local last = str.trim(lines[#lines])
    local box_z = tonumber(str.split(last, "%s+")[3])
    return res:deduplicate(), box_z
end

local function get_peg_z(dirname)
    local res = {}
    local files = lfs.walkdir(dirname, "file")
    for _, file in ipairs(files) do
        res[file] = array.new(lfs.readlines(file))
            :filter(function(line)
                return not (str.startswith(line, "@") or str.startswith(line, "#"))
            end)
            :map(function(line)
                local nums, c = {}, 0
                line = str.trim(line)
                for w in str.gsplit(line, "%s") do
                    if c > 0 then
                        nums[c] = tonumber(w)
                    end
                    c = c + 1
                end
                return nums
            end)
    end
    return res
end

local function is_ads(a, b, boxsize, region)
    for i = 1, #a do
        for j = 1, #b do
            local distance = math.abs(a[i] - b[j])
            if distance > boxsize / 2 then
                distance = boxsize - distance
            end
            if distance <= region then
                return true
            end
        end
    end
    return false
end

local function separate_by_ads(gro_file, peg_o_dir)
    local aus, box_z = get_aus_z(gro_file)
    local peg_o = get_peg_z(peg_o_dir)
    local REGION = 0.7
    local res = {}
    for file, peg_z in pairs(peg_o) do
        local num = file:match("%d+")
        res[num] = {}
        for step = 1, #peg_z do
            res[num][step] = is_ads(aus, peg_z[step], box_z, REGION)
        end
    end
    return res
end

local AUS_FILE = "md_run.gro"
local PEG_DIR = "peg_o"

local res = separate_by_ads(AUS_FILE, PEG_DIR)
local json_res = json.encode(res)
print(json_res)
