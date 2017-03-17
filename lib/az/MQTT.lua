-- by Qige from 6Harmonics
-- @ 2017.03.07



mqtt = {}

mqtt.conf = {}
mqtt.conf.broker = 'OttawaOffice.azure-devices.com'
mqtt.conf.broker_port = 1883
mqtt.conf.subscription_id = 'c53151fc-c4e2-4b51-919a-0f1533e04077'
mqtt.conf.iothub_name = 'OttawaOffice'
mqtt.conf.sap_id = 'iothubowner'


local MSAzure = nil

function callback(
  topic,    -- string
  message)  -- string

  print("Topic: " .. topic .. ", message: '" .. message .. "'")

  MSAzure:publish(args.topic_p, message)
end


function mqtt.Test()
	local host = mqtt.conf.broker
	local port = mqtt.conf.broker_port
	local id = mqtt.conf.sap_id

	local MQTT = require 'az/mqtt/mqtt_library'
	
	MSAzure = MQTT.client.create(host, port)
	MSAzure:connect(id)
	io.write("dbg> connected.\n")
	MSAzure:subscribe({ 'noise' })
	
	local error_msg = nil
	while(error_msg == nil) do
		error_msg = MSAzure:handler()
		scoket.sleep(1.0)
	end

	if (error_msg == nil) then
		MSAzure:unsubscribe({ 'noise' })
		MSAzure:destroy()
	else
		print(error_msg)
	end
end


return mqtt