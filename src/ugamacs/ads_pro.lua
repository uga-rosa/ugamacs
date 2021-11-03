#!/usr/bin/env lua

local json = require("json")
local array = require("steel.array")

local JSON_NAME = "steps.json"
local handle = io.open(JSON_NAME, "r")
local j_data = json.decode(handle:read("*a"))
handle:close()

local pros = {}
for num, steps in pairs(j_data) do
    j_data[tonumber(num)] = steps
end

for i = 1, #j_data do
    local steps = j_data[i]
    local pro = array.new(steps):count(true) / #steps * 100
    print(i, pro)
    table.insert(pros, pro)
end

local function mean(arr)
    local sum = 0
    for i = 1, #arr do
        sum = sum + arr[i]
    end
    return sum / #arr
end

print("mean", mean(pros))
