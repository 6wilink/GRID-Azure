-- Query all KPI data from "kpi"
-- Encode KPI data into string
-- Encode & Call MQTT

local kpi_abb = require "kpi.ABB"
local kpi_gws = require "kpi.GWS"
local kpi_nw = require "kpi.NW"
local kpi_sys = require "kpi.SYS"

local az_kpi = {}

az_kpi.update = {}

function az_kpi.update.Instant()
	local _data = az_kpi.update.instant()
	return _data
end

function az_kpi.update.instant(ts)
	local _data = {}
	local abb = kpi_abb.RAW()
	local nw = kpi_nw.RAW()

	_data.abb = abb or {}
	_data.nw = nw or {}

	return _data
end

function az_kpi.update.instant_failed()
	local _data = {}
	return _data
end

function az_kpi.update.delayed(ts)
	local gws = kpi_gws.RAW()
	local sys = kpi_sys.RAW()
end

return az_kpi
