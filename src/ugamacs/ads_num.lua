#!/usr/bin/env lua

local json = require("json")

local JSON_NAME = "steps.json"
local handle = io.open(JSON_NAME, "r")
local j_data = json.decode(handle:read("*a"))
handle:close()

local nums = {}
for _, steps in pairs(j_data) do
    for i = 1, #steps do
        nums[i] = nums[i] or 0
        if steps[i] then
            nums[i] = nums[i] + 1
        end
    end
end

for i = 1, #nums do
    print(i, nums[i])
end
