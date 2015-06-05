:: Ensure C:\Chocolatey\bin is on the path
set /p PATH=<C:\Windows\Temp\PATH

:: Install all the things; for example:
cmd /c choco install -y notepadplusplus Firefox GoogleChrome
cmd /c choco install -y jre8 eclipse git
cmd /c choco install -y ant maven gradle
:: SourceTree triggers the install of .Net Framework 4.5

