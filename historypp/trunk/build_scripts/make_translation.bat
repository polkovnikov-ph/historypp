@echo off

set TRANSNAME=hpp_translate.txt

md ..\trans > nul 2>&1
del /Q ..\trans\*.* > nul 2>&1


set TRANS=hpp_t.txt

call change_vars.bat r+ trans_header.txt ..\trans\hpp_t.txt

echo Running PHP to grab all translations...

FOR %%A IN (..\plugin\*.dfm) DO (
  \php\php -q -d html_errors=false trans.php %%A
)

cd ..\plugin

move *.trans.txt ..\trans\ > nul 2>&1
move *.trans-err.txt ..\trans\ > nul 2>&1
move *.trans-detailed.txt ..\trans\ > nul 2>&1

cd ..\trans

echo Putting them together...

FOR %%A IN (*.trans.txt) DO (
echo:>>%TRANS%
echo:>>%TRANS%
rem echo ;;>> %TRANS%
echo ;; %%A file >> %TRANS%
echo:>>%TRANS%
rem echo ;;>> %TRANS%
type %%A >> %TRANS%
)
cd ..\build_scripts

rem #
rem # Find Utils path relatively to our current dir
rem #

set UTILSPATH=utils
set TRIES=0
:loop
if exist %UTILSPATH% goto exitloop
set UTILSPATH=..\%UTILSPATH%
if "%TRIES%"=="000000" goto exitloop
set TRIES=0%TRIES%
goto loop
:exitloop

echo Transforming them with SED...

set SED=%UTILSPATH%\sed.exe

%SED% --text -f rem_dupes.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt
%SED% --text -f rem_doubles.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt

rem if you don't want to enclose strings in [], then comment it
%SED% --text -f enclose.sed ..\trans\hpp_t.txt > ..\trans\hpp_tmp.txt
move ..\trans\hpp_tmp.txt ..\trans\hpp_t.txt

move ..\trans\hpp_t.txt ..\trans\%TRANSNAME%

echo Done!

if exist ..\trans\*.trans-err.txt goto trans_have_errors

goto end

:trans_have_errors
echo:
echo ##
echo ## Warning! Translation tool found errors!
echo ##
echo:
echo List of files with errors:
dir /B ..\trans\*.trans-err.txt
echo:
pause
goto end

:end