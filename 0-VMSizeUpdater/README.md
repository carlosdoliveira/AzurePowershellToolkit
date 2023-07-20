# VM Size Updater
This script will update the VM size of a VM in Azure. This process will automatically stop and start the VM affected.

# How does it work
This script will:
* Read a CSV file containing all the VMs respective sizes you want to update
* Check if the VMs exist in Azure
* Update the VMs size
* Export a CSV file containing the VMs that were not updated

# How to use this code
1. Download the code
2. Create a CSV file containing the VMs you want to update. The CSV file should have the following format:

```csv
NAME, SUBSCRIPTION ID, RESOURCE GROUP, SIZE
```
1. Make sure you are logged in to Azure using PowerShell
2. Run the script

```powershell
.\Update-VMSize.ps1 -VMListPath "C:\VMList.csv"
```

# Pre-requisites

* PowerShell 5.1
* Azure PowerShell Module
* Azure Subscription

# About exporting the VMs that you want to update
You can export a CSV file from Azure Portal very easily. To do so, follow these steps:
1. Go to Azure Portal
2. Go to Virtual Machines
3. Click on Manage View
4. Make sure you have the required columns used in the CSV file (refer to [how to use this code](#how-to-use-this-code) section)
5. Click on Export to CSV button


# How to contribute

Feel free to contribute to this project by submitting your pull request. Make sure you test your code before submitting.

# License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details