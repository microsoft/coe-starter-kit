# Used during dev inner loop to automate unpack on local pc instead of using a pipeline

function Export-Unpack ($solutionName) {
  $exportTemp = "export-temp"  
  $unpackFolder = "$solutionName/SolutionPackage"
  $managedZip = "$exportTemp/$solutionName" + "_managed.zip"
  $unmanagedZip = "$exportTemp/$solutionName.zip"
  
  if (Test-Path $unmanagedZip) {
    Remove-Item $unmanagedZip
  }
  
  if (Test-Path $managedZip) {
    Remove-Item $managedZip
  }
  
  pac solution export --name $solutionName --path $exportTemp
  pac solution export --name $solutionName --path $managedZip --managed true
  pac solution unpack --zipfile $unmanagedZip --folder $unpackFolder --allowDelete true --packagetype both
  
  $msappFiles = Get-ChildItem -Path "$unpackFolder/CanvasApps" -Filter *.msapp
  foreach ($msappFile in $msappFiles) {
    $directoryToCreate = $msappFile.FullName.Replace(".msapp", "_msapp_src")
    New-Item -Path $directoryToCreate -Type Directory -Force
    pac canvas unpack --msapp $msappFile.FullName --sources $directoryToCreate
    Remove-Item $msappFile.FullName
  }
  
  Get-ChildItem -Path $unpackFolder -Recurse -Filter *.json | 
  ForEach-Object {
    #skip canvas app folder because canvas team already handles this for canvas unpack
    if (-not $_.FullName.Contains('CanvasApps')) {
      Write-Host $_.FullName
      $formatted = jq . $_.FullName --sort-keys
      $formatted | Out-File $_.FullName -Encoding UTF8
    }
  }

  Get-ChildItem -Path "$unpackFolder\**\Solution.xml" | 
   ForEach-Object {
        (Get-Content $_.FullName) `
            -replace '<Version>[\s\S]*?<\/Version>', '<Version>0.0.0.0</Version>' |
        Out-File $_.FullName
   }
}