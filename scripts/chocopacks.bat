:: Ensure C:\Chocolatey\bin is on the path
set /p PATH=<C:\Windows\Temp\PATH

:: Install all the things; for example:
cmd /c choco install -y notepadplusplus Firefox GoogleChrome
cmd /c choco install -y jre8 eclipse git SourceTree
cmd /c choco install -y ant maven gradle

