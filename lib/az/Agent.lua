-- by Qige
-- 2017.03.16

local conf = require 'six.conf'
local fmt = require 'six.fmt'
local task = require 'az.Task'

local _echo = fmt.echo

local Agent = {}
Agent.name = 'Task for Microsoft Azure is running.\n'

function Agent.Run(mode)
	Agent.init()

	task.Init()
	task.Run()
	task.Stop()
end

function Agent.init()
	local name = Agent.name
	local version = conf.file.get('grid-azure', 'v1', 'release') or '(version unknown)'
	_echo(name)
	_echo("%s\n", version)
end

return Agent
