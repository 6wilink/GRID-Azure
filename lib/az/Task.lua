-- by Qige
-- 2017.03.16

local cmd = require 'six.cmd'
local fmt = require 'six.fmt'
local file = require 'six.file'

local _print = io.write
local _echo = fmt.echo
local _sleep = cmd.sleep
local _save = file.write
local _read = file.read

local _exec = cmd.exec
local _fmt = string.format


local kpi = require 'az.KPI'
local mqtt = require 'az.MQTT'


local Task = {}

Task.device = {}
Task.device._SASToken = ''
Task.device._host = 'GWS-HUB.azure-devices.net'
Task.device._sig = 'yvnof6SMr%2FDKRH1m1a8tfLKpYUoPi5Tbli3qJo3YyEc%3D'

Task.IotHub = {}
Task.IotHub._fmt_req1 = 'curl -k --data \''
Task.IotHub._fmt_req2 = '\' --header "Authorization: SharedAccessSignature sr=GWS-HUB.azure-devices.net%2Fdevices%2Fdevice1&sig=%s&se=1522777587"'
	.. ' https://GWS-HUB.azure-devices.net/devices/device1/messages/events?api-version=2016-11-14'


Task.conf = {}
Task.conf._SIGNAL = '/tmp/.grid_azure_signal'


-- clean & set signal flag
function Task.Init()
	--local _delayed = Task.coroutine.start()
	--coroutine.create(_delayed)
	Task.flag.set('azure agent up.\n')

	--Task.co._instant = coroutine.create(function(ts)
		--_echo('co> %d\n', ts)
	--end)
end

-- major task loop
-- instant update (abb/nw)
-- its coroutine update delayed (gws/sys)
function Task.Run(mode)
	local _json_data
	local data_instant, data_delayed

	local _iothub_req_fmt1 = Task.IotHub._fmt_req1
	local _iothub_req_fmt2 = Task.IotHub._fmt_req2

	while(Task.flag._SIGNAL()) do
		local ts = os.time()

		-- run coroutine
		--coroutine.resume(Task.co._instant, ts)

		_echo('> updating kpi ...\n')
		data_instant = kpi.update.Instant()

		_echo('> encoding kpi ...\n')
		_json_data = Task.data.encode(data_instant)

		--_echo('> sending via MQTT ...\n')
		_echo('> sending via HTTPs ...\n')
		local _iothub_request = _iothub_req_fmt1 .. _json_data .. _iothub_req_fmt2
		_exec(_iothub_request)
		_print(_iothub_request)

		_echo('. reading MQTT cmd ...\n')
		_echo('-------- -------- idle (%d) ------\n', ts)

		_sleep(1)
	end
end

-- clean & set signal flag
function Task.Stop()
	Task.flag.set('roger. azure agent down.\n')
end


-- operate task flag
Task.flag = {}
function Task.flag._SIGNAL()
	local f = Task.conf._SIGNAL
	local sig = _read(f)
	if (sig == 'exit' or sig == 'down' or sig == 'quit') then
		_echo('(warning) QUIT signal detected.\n')
		return false
	else
		return true
	end
end

function Task.flag.set(str)
	local f = Task.conf._SIGNAL
	_save(f, str)
end


-- data format
Task.conf.fmt = {}
Task.conf.fmt.all = '{"time":%s,"abb":%s,"nw":%s,"gws":%s,"nw":%s}'
Task.conf.fmt.ts = '{"sys": "%s", "ts": %d}'
Task.conf.fmt.abb = '{"ssid":"%s","bssid":"%s","noise":%d}'
Task.conf.fmt.nw = '{"lan_ip":"%s","wan_ip":"%s","eth_rxb":%d,"eth_txb":%d}'
Task.conf.fmt.gws = ''
Task.conf.fmt.sys = ''

-- encode, decode MQTT Msg
Task.data = {}
function Task.data.encode(data_instant, data_delayed)
	local _result
	local _abb, _gws, _sys, _nw, _ts

	if (data_instant ~= nil and type(data_instant) == 'table') then
		--if (data_instant[abb])
		local _fmt = Task.conf.fmt.abb
		local _abb_data = data_instant.abb
		_abb = string.format(_fmt, _abb_data.ssid, _abb_data.bssid, _abb_data.noise)

		--if (data_instant[abb])
		local _fmt = Task.conf.fmt.nw
		local _nw_data = data_instant.nw
		_nw = string.format(_fmt, _nw_data.lan_ip or '-', _nw_data.wan_ip or '-',
			_nw_data.eth_rxb or 0, _nw_data.eth_txb or 0)
	end

	local _ts_fmt = Task.conf.fmt.ts
	_ts = string.format(_ts_fmt, os.date("%Y-%m-%d %X"), os.time())

	local _result_fmt = Task.conf.fmt.all
	_result = string.format(_result_fmt, _ts or 'null', _abb or 'null', _nw or 'null',
		_gws or 'null', _nw or 'null')

	_echo('msg> %s\n', _result)
	return _result
end


Task.co = {}
Task.co._instant = nil
function Task.co.start()
	local i = 0
	while true do
		i = i + 1
		send(i)
	end
end

return Task
