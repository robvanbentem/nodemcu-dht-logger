conf = require("conf")

uart.setup(0,conf.esp_baud,8,0,1)

function get_pin()
    return conf.esp_pin
end

-- connect to wifi and return ip
function wifi_connect(ssid, password) 
    wifi.setmode(wifi.STATION)
    wifi.sta.config(ssid, password)

    if(wifi.sta.getip() == nil) then
        return false
    end

    return true
end

function dht_report()
    status, temp, humi, temp_decimal, humi_decimal = dht.read(get_pin())

    if(status == dht.OK) then
        local t = string.format("%d.%03d", temp, temp_decimal)
        local h = string.format("%d.%03d", humi, humi_decimal)
        local qry = string.format(conf.report_url, t, h)

        conn = net.createConnection(net.TCP, 0)
        conn:connect(conf.report_port, conf.report_ip)

        conn:send("GET " .. qry .. " HTTP/1.0\r\nHost:" .. conf.report_host .. "\r\n" .. "Connection: close\r\n\r\n")

        return true
    else
        return false
    end
end


function dht_print ()
    status, temp, humi, temp_decimal, humi_decimal = dht.read(get_pin())
    if( status == dht.OK ) then
        print( string.format("temp:%d.%03d;hum:%d.%03d", temp, temp_decimal, humi, humi_decimal))
    elseif( status == dht.ERROR_CHECKSUM ) then
        print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
        print( "DHT Time out." );
    end
end

function report_tmr(msec)
    tmr.alarm(1, msec, 1, function()
        local tries = 1

        uart.write(0, "reporting.. ")

        while tries <= conf.report_tries do
            if dht_report() == true then 
                print("success!")
                break 
            else
                uart.write(0, "error.. ")
            end

            tries = tries + 1
            tmr.delay(1000000) -- delay 1 sec before retry
        end

        if tries == 3 then
            print("failed!")
        end

    end)
end


function print_tmr(msec)
    tmr.alarm(2, msec, 1, function()
        dht_print()
    end)
end



-- init

wifi_connect(conf.wifi_ssid, conf.wifi_pass)

if conf.report_autostart then
    report_tmr(conf.report_interval)
end
