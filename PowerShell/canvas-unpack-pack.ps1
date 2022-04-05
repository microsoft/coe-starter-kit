function Invoke-CanvasUnpackPack($packOrUnpack, $source, $destination) {
    Write-Host "Loading Assemblies"
    Get-ChildItem -Path "..\PowerAppsLanguageTooling\" -Recurse -Filter *.dll | 
    ForEach-Object {
        [System.Reflection.Assembly]::LoadFrom($_.FullName)
    }
    
    if ($packOrUnpack -eq 'pack') {
        Write-Host "Packing $source to $destination"
        $results = [Microsoft.PowerPlatform.Formulas.Tools.CanvasDocument]::LoadFromSources($source)
        if($results.HasErrors) {
            throw $results.Item2.ToString();
            return
        } else {
            Write-Host $results.Item2.ToString()
        }
        $saveResults = $results.Item1.SaveToMsApp($destination)
        if($saveResults.HasErrors) {
            throw $saveResults.ToString();
            return
        } 
        else {
            Write-Host $saveResults.ToString()
        }
    }
    else {
        if ($packOrUnpack -eq 'unpack') {
            Write-Host "Unpacking $source to $destination"
            $results = [Microsoft.PowerPlatform.Formulas.Tools.CanvasDocument]::LoadFromMsapp($source)
            if($results.HasErrors) {
                throw $results.Item2.ToString();
                return
            } else {
                Write-Host $results.Item2.ToString()
            }
    
            $saveResults = $results.Item1.SaveToSources($destination)
            if($saveResults.HasErrors) {
                throw $saveResults.ToString();
                return
            } 
            else {
                Write-Host $saveResults.ToString()
            }
        }
        else {
            throw "Invalid packOrUnpack parameter. Must be 'pack' or 'unpack'.";
        }
    }
}