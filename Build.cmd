@ECHO off
setlocal

set ORC_NAME=Orc.exe
set ORC_CONFIG_FOLDER=.\config
set ORC_OUTPUT_FOLDER=.\output

echo Building Orc %ORC_NAME% (configuration directory: %ORC_CONFIG_FOLDER%)

.\DFIR-ORC.exe ToolEmbed /embed=%ORC_CONFIG_FOLDER%\Embed.xml /out=%ORC_OUTPUT_FOLDER%\%ORC_NAME% /force ^

&& echo Orc %ORC_OUTPUT_FOLDER%\%ORC_NAME% built (configuration directory: %ORC_CONFIG_FOLDER%)

endlocal
