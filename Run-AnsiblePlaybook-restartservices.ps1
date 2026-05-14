$plinkPath  = 'C:\Program Files\PuTTY\plink.exe'
$server     = "172.30.10.165"
$username   = "morphadmin"
$password   = "M0rph@dmin"

$ansibleDir = "/home/morphadmin/ansible"
$playbooks = @(
    "stop_morpheus.yml",
    "stop_innodb.yml",
    "start_innodb.yml",
    "start_morpheus.yml"
)

Write-Host "Starting remote Ansible execution sequence..." -ForegroundColor Cyan

foreach ($pb in $playbooks) {
    $remoteCmd = "cd $ansibleDir && ansible-playbook $pb --vault-password-file .vault_pass.txt"
    Write-Host ("Executing on {0}: {1}" -f $server, $remoteCmd) -ForegroundColor Green

    $args = @(
        "-ssh",
        "$username@$server",
        "-pw", $password,
        "-batch",            # No interaction; fail on any prompt
        $remoteCmd
    )

    $proc = Start-Process -FilePath $plinkPath `
                          -ArgumentList $args `
                          -NoNewWindow `
                          -Wait `
                          -PassThru

    if ($proc.ExitCode -ne 0) {
        Write-Host ("Playbook {0} failed with exit code {1}" -f $pb, $proc.ExitCode) -ForegroundColor Red
        break   # Stop if failure occurs
    } else {
        Write-Host ("Playbook {0} completed successfully" -f $pb) -ForegroundColor Magenta
    }
}

Write-Host "All playbooks executed. Wait 5 minutes to login" -ForegroundColor Cyan
