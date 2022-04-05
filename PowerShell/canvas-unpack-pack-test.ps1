
function Invoke-CanvasUnpackPack-Test()
{
	. "canvas-unpack-pack.ps1"
    Remove-Item -Path "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri_repacked.msapp" -Force
    Remove-Item -Path "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri_msapp_src" -Force -Recurse
    Invoke-CanvasUnpackPack "unpack" "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri.msapp" "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri_msapp_src"
    Invoke-CanvasUnpackPack "pack" "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri_msapp_src" "C:\source\repos\coe-alm-accelerator-templates-azdo\PowerShell\TestData\Solutions\coe-starter-kit-azdo\CenterofExcellenceALMAccelerator\SolutionPackage\CanvasApps\cat_poweropsdevopsedition_7f3f4_DocumentUri_repacked.msapp"
}
Invoke-CanvasUnpackPack-Test
