# TODO: replace this line with path to file containing IPs of targets
$IP_ADDRS = get-content -path "C:\Users\Administrator\Documents\Gartmann\TLEST.txt"


$IP_ADDRS | Foreach-Object -ThrottleLimit 5 -Parallel {
    $ip = $PSItem
    $bin_dir = "C:\Users\Administrator\Downloads"
    $local_dir = "\\win-hunt-1\C$\temp\$ip"
    $target_dir = "\\$ip\C$\temp"

    new-item -path $local_dir -ItemType "directory" -Force
    new-item -path $target_dir -ItemType "directory" -Force

    copy-item "$BIN_DIR\winPEASx64.exe" -Destination "$target_dir\winPEASx64.exe" -Force
    invoke-command -ComputerName $ip -ScriptBlock {C:\temp\winPEASx64.exe > "C:\temp\winpeas.out"}
    copy-item "$target_dir\winpeas.out" -Destination $local_dir

    copy-item "$BIN_DIR\Seatbelt.exe" -Destination "$target_dir\Seatbelt.exe" -Force
    invoke-command -ComputerName $ip -ScriptBlock {C:\temp\Seatbelt.exe -group=all > "C:\temp\seatbelt.out"}
    copy-item "$target_dir\seatbelt.out" -Destination $local_dir

    copy-item "$BIN_DIR\jaws-enum.ps1" -Destination "$target_dir\jaws-enum.ps1" -Force
    invoke-command -ComputerName $ip -ScriptBlock {C:\temp\jaws-enum.ps1 > "C:\temp\jaws.out"}
    copy-item "$target_dir\jaws.out" -Destination $local_dir

    invoke-command -ComputerName $ip -ScriptBlock {grep -r -i -I pass C: | > "C:\temp\grep.out"}
    copy-item "$target_dir\grep.out" -Destination $local_dir

    new-item -path "C:\temp\$ip\nmap" -ItemType "directory" -Force
    nmap -sC -sV -oA "C:\temp\$ip\common-ports" $ip -v
}
