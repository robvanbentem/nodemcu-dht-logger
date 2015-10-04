### NodeMCU Temperature Logger

#### Instructions

Make sure you have the latest NodeMCU firmware on your ESP8266 before you start.

- Download `luatool.py` from https://github.com/4refr0nt/luatool
- Copy luatool.py next to the `init.lua` and `conf.lua.example` files.
- Copy `conf.lua.example` to `conf.lua` and change settings to your liking
- Run `./luatool.py -p /dev/ttyUSB0 -f conf.lua` and `./luatool.py -p /dev/ttyUSB0 -f init.lua` to copy the lua files to your esp8266. If you are having trouble with this step, run `luatool.py --help` for help with the tool.
- Done! Your esp8266 should now be sending temperature and humidity data to your webserver.


