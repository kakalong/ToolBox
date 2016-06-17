@echo off
if exist "%VS140COMNTOOLS%" (
	set VCVARS="%VS140COMNTOOLS%..\..\VC\bin\"
	goto build
	) 
else (goto missing)

:build

@set ENV32="%VCVARS%vcvars32.bat"
@set ENV64="%VCVARS%amd64\vcvars64.bat"

call "%ENV32%"
echo Swtich to x86 build env
cd luajit\src
call msvcbuild.bat
copy /Y lua51.dll ..\..\prebuilt\x86\slua.dll
cd ..\..

call "%ENV64%"
echo Swtich to x64 build env
cd luajit\src
call msvcbuild.bat
copy /Y lua51.dll ..\..\prebuilt\x64\slua.dll
cd ..\..


goto :eof

:missing
echo Can't find Visual Studio 2015.
goto :eof