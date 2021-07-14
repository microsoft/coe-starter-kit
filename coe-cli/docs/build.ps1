<#
        .SYNOPSIS
        Build the CoE CLI E-book

        .DESCRIPTION
        Generate PDF version of the ebook from docs markdown files

        .EXAMPLE

        .\build.ps1
        
        Will run spell check, grammar check and generate pdf file

        .\build.ps1 -format docx

        Will run spell check and create Microsoft Word Document Version of the ebook
#>
param ([string] $branch = "main", [string] $skipGrammar = "", [string] $format = "pdf")
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

if ( $format -eq "docx" ) {
    docker run -it --rm -e "DOCX=true" -v ${path}:/docs cli-mdbook
    return
}

$skip = $false
switch($skipGrammar.ToLower()) {
    "true" { $skip = $true }
}

if ( $skip -and $format -eq "pdf" ) {
    docker run -it --rm -e "SKIP_GRAMMAR=yes" -v ${path}:/docs cli-mdbook
}

if ( -not $skip -and $format -eq "pdf" ) {
    docker run -it --rm -v ${path}:/docs cli-mdbook
}
