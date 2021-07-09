<#
        .SYNOPSIS
        Build the COE CLI E-book

        .DESCRIPTION
        Generate PDF version of the ebook from docs markdown files
#>
param ([string] $branch = "main")
$path = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path))
Write-Host $path
if ($branch.Length -gt 0) {
    $isUri = ($NULL -ne $branch -as [System.URI]).AbsoluteURI
    $url = $isUri ? $branch : "https://github.com/microsoft/coe-starter-kit/tree/${branch}/coe-cli/docs/"
    Write-Host "Git Repository ${url}"
    coe ebook generate -r $url
} else {
    coe ebook generate
}

docker run -it --rm -v ${path}:/docs cli-mdbook