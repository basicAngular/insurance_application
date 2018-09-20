goto __start
/*************************************************************
          Sample Script: CalculateAndCreateWinREPartition.cmd

Use this script to calculate the size needed for the WinRE
partition after applying your final factory settings.

Prerequisites:
- Boot the PC into Windows PE 5.1
 - The primary hard drive (disk 0) has three partitions:
     1. System partition (ESP)
     2. MSR
     3. Windows partition - the rest of disk 0
        - Winre.wim is in this partition
 - Customize winre.wim, and store it in the Windows partition

After this script is run:
- The primary hard drive (disk 0) has four partitions:
     1. System partition (ESP)
     2. MSR
     3. Windows partition (calculated)
     4. Winre partition (calculated)
The Winre partition will include:
 - Winre.wim
 - Any other OEM tools/scripts
 - 50 MB of additional free space
**************************************************************/

REM The script starts here
:__start
@echo off
echo %date%-%time%:: Start of script %0 ,,,

if "%1" equ "" (
 echo This script calculates the size needed for the Images partition and sets it up.
 echo Usage:
 echo CalculateAndCreateWIMBootPartition.cmd ^<letter of Windows volume^> ^<path to winre.wim^> ^<additional free space to be added to Images partition in megabytes. If no additional space is needed, use 0.^>
 echo Example:
 echo CalculateAndCreateWIMBootPartition C: C:\Recycler\WIMs 300
 exit /b 0
)



REM --- Constants used to calculate free space ---
REM Overhead Ratio: assume 6 MB overhead per 1000 MB size
set /a NTFS_OVERHEAD_RATIO=500/497
REM Per-Partition Overhead: 5 MB per partition
set /a NTFS_OVERHEAD_BASE=5

REM Megabytes-to-Millions Ratio:
REM This ratio converts values from megabytes to millions of bytes, approximately. 
set /a mega_million_ratio=205/215
REM --------- Constants -------------


REM Drive letter of the Windows partition. Example: C:
set user_volume=%1

REM Path that contains winre.wim. Example: C:\Recycler\WIMs
set winre_wim_path=%2

REM Additional size to be added to Images partition in megabytes. Example: 300
set more_size=%3


echo Check input Windows volume {%user_volume%} is accessible:
echo dir %user_volume%\ /a
     dir %user_volume%\ /a
if not exist %user_volume%\ (
 echo %user_volume%\ not found. Exiting script.
  rem pause
 exit /b 3
)


echo Check if the winre.wim file {%winre_wim_path%}  is accessible:
echo dir %winre_wim_path%\ /a
     dir %winre_wim_path%\ /a
if not exist %winre_wim_path%\winre.wim  (
echo %winre_wim_path%\winre.wim not found. Exiting script.
 exit /b 3
)


echo --------- Calculate {%winre_wim_path%\winre.wim} size ,,,
for %%A in (%winre_wim_path%\winre.wim) do ( 
set winre_wim_file_bytes=%%~zA
echo winre.wim is [%winre_wim_file_bytes%] bytes.
)
set /a winre_wim_file_MB=%winre_wim_file_bytes:~0,-6%
echo After cutting off last 6 digits = [%winre_wim_file_MB%]
set /a winre_wim_file_MB=%winre_wim_file_MB%*205/215
echo Final approximate size: [%winre_wim_file_MB%] MB


echo Calculate WinRE partition size ,,,
echo Adding 50MB free space to input size {%more_size%}. This ensures WinRE partition have 50MB free space.
set /a more_size=%more_size%+50
set /a wim_partition_size_MB=%winre_wim_file_MB%
echo Total size of the WinRE.WIM file = {%wim_partition_size_MB%} MB

set /a wim_partition_size_MB=%wim_partition_size_MB%+%more_size%
echo Size after adding specified space and 50MB = {%wim_partition_size_MB%} MB
set /a wim_partition_size_MB=%wim_partition_size_MB%+%NTFS_OVERHEAD_BASE%
set /a wim_partition_size_MB=%wim_partition_size_MB%*500/497
echo Final WinRE partition size = {%wim_partition_size_MB%} MB

rem echo Remove the hibernation file, if it exists.
rem icacls C:\hiberfil.sys /grant everyone:f
rem del C:\hiberfil.sys /ah

echo Find out if we are in BIOS mode, or UEFI mode,,,
echo reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType
     reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType
for /f "tokens=2*" %%X in ('reg query HKLM\System\CurrentControlSet\Control /v PEFirmwareType') DO (SET _Firmware=%%Y)

rem if %_Firmware%==0x1 (
rem   echo The PC is booted in BIOS mode. Note: BIOS is not supported for WIMBoot.  Exiting script.
rem pause
rem  exit /b 3
rem )

if %_Firmware%==0x1 echo The PC is booted in BIOS mode.
if %_Firmware%==0x2 echo The PC is booted in UEFI mode.

echo Create a diskpart script to shrink Windows partition {%user_volume%} by desired size of {%wim_partition_size_MB%} ,,
set wim_partition_letter=M:
echo. > %~dp0dps.txt
echo list disk >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo select disk 0 >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo select volume %user_volume% >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo shrink minimum=%wim_partition_size_MB% >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo create partition primary size=%wim_partition_size_MB% >> %~dp0dps.txt
if %_Firmware%==0x1 (
echo set id=27 OVERRIDE NOERR >> %~dp0dps.txt
)
echo set id=de94bba4-06d1-4d40-a16a-bfd50179d6ac OVERRIDE NOERR >> %~dp0dps.txt
if %_Firmware%==0x2 (
echo gpt attributes=0x8000000000000001 >> %~dp0dps.txt
)
echo list volume >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo format fs=ntfs label="Windows RE Tools" >> %~dp0dps.txt
echo assign letter=%wim_partition_letter% >> %~dp0dps.txt
echo list volume >> %~dp0dps.txt
echo list partition >> %~dp0dps.txt
echo exit >> %~dp0dps.txt

echo =================== the script has:
type  %~dp0dps.txt
echo ==================================

echo %date%-%time%:: Running diskpart /s %~dp0dps.txt ,,,
diskpart /s %~dp0dps.txt 

echo dir %wim_partition_letter%\
dir %wim_partition_letter%\

md "%wim_partition_letter%\Recovery\WindowsRE"

echo dir %winre_wim_path%\winre.wim
     dir %winre_wim_path%\winre.wim
echo robocopy %winre_wim_path%\ %wim_partition_letter%\Recovery\WindowsRE\ winre.wim 
     robocopy %winre_wim_path%\ %wim_partition_letter%\Recovery\WindowsRE\ winre.wim 
)

rem Register Windows RE
echo %date%-%time%:: %user_volume%\Windows\System32\reagentc.exe /setreimage /path %wim_partition_letter%\Recovery\WindowsRE /target %user_volume%\Windows
      %user_volume%\Windows\System32\reagentc.exe /setreimage /path %wim_partition_letter%\Recovery\WindowsRE /target %user_volume%\Windows

set output_text=%~dp0temp.txt

echo %date%-%time%:: All done.  Errorlevel={%errorlevel%}
dir %wim_partition_letter%\ /s /a


