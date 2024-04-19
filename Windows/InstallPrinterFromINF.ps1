Pnputil /add-driver "C:\Temp\p\drivers\x3UNIVP.inf"
Add-PrinterDriver -Name "Xerox Global Print Driver PS" -InfPath "C:\Windows\System32\DriverStore\FileRepository\x3univp.inf_amd64_7d555b37967ab342\x3UNIVP.inf"
Add-PrinterPort -Name "Xerox Printer Port" -PrinterHostAddress "192.168.1.365"
Add-Printer -Name "Xerox Printer" -DriverName "Xerox Global Print Driver PS" -PortName "Xerox Printer Port"
