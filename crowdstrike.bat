@echo off
cls
echo "Started CrowdStrike Fix Batch"

:: Check if BitLocker is enabled and locked
for /f "delims=" %%a in ('manage-bde -status') do (
    echo %%a | find /i "Lock Status:          Locked" >nul && goto BitLockerOn
)
goto BitLockerOff

:BitLockerOn
:: Find the drive letter
for /f "delims=" %%a in ('manage-bde -status') do (
    echo %%a | find /i "Volume " >nul && for /f "tokens=2" %%i in ("%%a") do set "drive=%%i"
)
echo BitLocker detected.
echo Using drive %drive%
echo If your device is BitLocker encrypted, use your phone to log on to https://aka.ms/aadrecoverykey.
echo Log on with your Email ID and domain account password to find the BitLocker recovery key associated with your device.
echo.
manage-bde -protectors %drive% -get -type RecoveryPassword
echo.
set /p reckey="Enter recovery key for this drive if required: "
if not "%reckey%"=="" (
    echo Unlocking drive %drive%
    manage-bde -unlock %drive% -recoverypassword %reckey%
)
goto DeleteLogic

:BitLockerOff
:: Find the drive with the specific CrowdStrike file
echo BitLocker Off logic triggered.
for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\Windows\System32\drivers\CrowdStrike\C-00000291*.sys" (
        set "drive=%%D:"
        echo Using drive %drive%
        echo.
        goto DeleteLogic
    )
)
goto endFN

:DeleteLogic
del %drive%\Windows\System32\drivers\CrowdStrike\C-00000291*.sys
goto end

:endFN
echo File not found or it may have already been deleted.

:end
echo Done performing cleanup operation.
