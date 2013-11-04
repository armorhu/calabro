color 0a
echo off
title proto_gen_as
for %%i in ("%~f0") do set root=%%~dpi
cd /d %root%
cls

set asOut=\\psf\Home\Documents\workspace\个人项目\summoner\branches\herolot_proj\trunk\src\com\arm\herolot\model\data\protobuf
set proto=\\psf\Home\Documents\workspace\个人项目\summoner\branches\herolot_proj\proto\herolot.proto
set protoc=\\psf\Home\Documents\workspace\开源库\protoc-gen-as

echo start proto....
%protoc%\protoc.exe --plugin=protoc-gen-as3="%protoc%\as_plugin\protoc-gen-as3.bat" --as3_out=%asOut% %proto%
echo TASK COMPLETE! PRESS ANY KEY TO EXIT...
pause>nul
exit