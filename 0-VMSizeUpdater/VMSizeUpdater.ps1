
# VM PAth
param(
    [Parameter(Mandatory=$true)]
    [string]$VMListPath
)

# Import the CSV into a variable
Write-Host -ForegroundColor Cyan "Importing CSV file"
$vmList = Import-Csv -Path $VMListPath
$notFoundVMs = @()

Write-Host -ForegroundColor Green "Grouping Subscriptions for Selecting appropriate context"
$groupedVMs = $vmList | Group-Object -Property "SUBSCRIPTION ID" # The input is in this format because in the CSV extracted by the portal, the Subscription ID information is in the "SUBSCRIPTION ID" column.
# Create a set to track the subscriptions already set in the context

$userlogged = (Get-AzContext -ErrorAction SilentlyContinue)

if ($userlogged -eq $null) {
    Write-Host -ForegroundColor Yellow "No user logged in. Please log in with Connect-AzAccount"
    exit
}

foreach ($subscription in $groupedVMs) {
    # When set as $subscription.Name, the name attribute corresponds to the group created in the "groupedVMs" variable. The group name is precisely the SubscriptionId.
    Write-Host -ForegroundColor Yellow "Setting context to subscription '$($subscription.Name)'"
    try {
        Set-AzContext -SubscriptionId $subscription.Name
    }

    catch {
        Write-Host -ForegroundColor Yellow "ERROR MESSAGE PLEASE READ ME: Error setting context to subscription '$($subscription.Name)'. Check if the subscription exists and you have access to it."
    }

    foreach ($row in $subscription.Group) {
        
        $resourceGroupName = $row."RESOURCE GROUP"
        $vmName = $row."NAME"
        $vmSize = $row."SIZE"
        # Change the VM size
        # Note that -NoWait is used so that the command does not wait for the operation to complete
        # This will allow the script to proceed with the next iteration
        # While the operation continues in the background

        Write-Host -ForegroundColor Yellow "Updating VM '$($vmName)' in resource group '$($resourceGroupName)' to size '$($vmSize)'"
        try {
            $vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction SilentlyContinue
            $vm.HardwareProfile.VmSize = $vmSize
            Update-AzVM -VM $vm -ResourceGroupName $resourceGroupName -NoWait -ErrorAction Continue
            Write-Host ""
        }
        catch {
            Write-Host ""
            Write-Host -ForegroundColor Yellow "ERROR MESSAGE PLEASE READ ME: Error updating VM '$($vmName)' in resource group '$($resourceGroupName)' to size '$($vmSize)'. Check if the VM exists and try again."
            Write-Host ""
            Write-Host ""
            Write-Host -ForegroundColor Red $_.Exception.
            Write-Host ""
            $notFoundVMs += New-Object PSObject -Property @{
                ResourceGroupName = $resourceGroupName
                VmName            = $vmName
            }
        }
    }
}
if ($notFoundVMs.Count -eq 0) {
    Write-Host -ForegroundColor Green "..::All VMs were updated successfully::.."
}
else {
    Write-Host -ForegroundColor Yellow "The following VMs were not found and could not be updated"
    $notFoundVMs | Format-Table -AutoSize
    $notfoundPath = Read-Host -Prompt "Enter the full path to the CSV file to export the VMs not found (ex: C:\users\user\desktop\notfound.csv)"
    $notFoundVMs | Export-Csv -Path $notfoundPath  -NoTypeInformation
}
