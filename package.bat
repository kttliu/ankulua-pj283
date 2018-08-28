@echo off
set /p Build=<ver.txt
set /a Build=%Build%+1
echo %Build%>ver.txt

rem Get the time from WMI - at least that's a format we can work with
set X=
for /f "skip=1 delims=" %%x in ('wmic os get localdatetime') do if not defined X set X=%%x
echo.%X%

rem dissect into parts
set DATE.YEAR=%X:~0,4%
set DATE.MONTH=%X:~4,2%
set DATE.DAY=%X:~6,2%
set DATE.HOUR=%X:~8,2%
set DATE.MINUTE=%X:~10,2%
set DATE.SECOND=%X:~12,2%
set DATE.FRACTIONS=%X:~15,6%
set DATE.OFFSET=%X:~21,4%

set datetimef=%DATE.YEAR%-%DATE.MONTH%-%DATE.DAY%
set package_name=PJ283_%datetimef%_Build_%Build%

cd luac
mkdir %package_name%
cd %package_name%
mkdir image
mkdir module
cd ..
xcopy /s /q ..\CapTsubasa\image\*.* %package_name%\image
luac5.1 -s -o %package_name%\%package_name%.luac                        ..\CapTsubasa\201808-Summer-Event.lua
luac5.1 -s -o %package_name%\module\Collection.lua                             ..\CapTsubasa\module\Collection.lua
luac5.1 -s -o %package_name%\module\mod_create_game.lua             ..\CapTsubasa\module\mod_create_game.lua
luac5.1 -s -o %package_name%\module\mod_logger.lua                          ..\CapTsubasa\module\mod_logger.lua
luac5.1 -s -o %package_name%\module\mod_runner_in_match.lua       ..\CapTsubasa\module\mod_runner_in_match.lua
luac5.1 -s -o %package_name%\module\mod_runner_pk.lua                   ..\CapTsubasa\module\mod_runner_pk.lua
luac5.1 -s -o %package_name%\module\mod_sell.lua                               ..\CapTsubasa\module\mod_sell.lua
cd ..

mkdir build
move luac\%package_name% build
cd build
..\7zip\7za a %package_name%.zip %package_name%
rd /s/q %package_name%
move %package_name%.zip ..\build
cd..
