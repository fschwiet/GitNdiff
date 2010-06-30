
param ([string] $left, [string] $right = ".", [string] $path = ".");

    if ($env:USERPROFILE -eq $null) {
        throw 'Environment variable $env:USERPROFILE is required, as a base path to gitndiff''s working directory.';
    }

    $leftdir = $env:USERPROFILE + '\.gitndiff\left';
    $rightdir = $env:USERPROFILE + '\.gitndiff\right';
    
    if ([System.IO.Directory]::Exists( $leftdir)) {
        "Deleting directory " + $leftdir
        remove-item $leftdir -recurse 
    }

    if ([System.IO.Directory]::Exists( $rightdir)) {
        "Deleting directory " + $rightdir
        remove-item $rightdir -recurse
    }

    if ($left -ne '.')
    {
#        (& git stash) | write-host
        
#        (& git checkout $left) | write-host
    }
    
    $excludedFilenames = (git ls-files -o) | ? { ! $_.Contains( ' ') }
    
    $exclude = [string]::Join( '+', $excludedFilenames[-3] ).Replace('/', '\')
    
    $exclude
    #(& xcopy $path $leftdir /i /s /y /exclude:"$exclude") | write-host
    
    
    
    
    
    
    
    

