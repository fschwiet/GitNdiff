
param ([string] $left, [string] $right = ".");

    function getWorkingDirectories {

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

        return ( $leftdir, $rightdir);
    }

    function getRepositoryDirectory() {

        $gitroot = (git rev-parse --git-dir).Replace('/', '\'); 
        if ($gitroot.LastIndexOf('\') -lt 0) {
            $gitroot = (get-item .).fullname
        } else {
            $gitroot = $gitroot.SubString(0, $gitroot.LastIndexOf('\'));
        }

        return $gitroot;
    }

    $gitroot = getRepositoryDirectory;
    
    "Running git ndiff for repository at $gitroot" | write-host;

    $leftdir, $rightdir = getWorkingDirectories;

    "Running with working trees $leftdir and $rightdir" | write-host

    if ($left -ne '.')
    {
#        (& git stash) | write-host
        
#        (& git checkout $left) | write-host
    }
    
    $excludedFiles = (git ls-files -o) | 
        % { $_.Replace( '/', '\') } |
        % { [System.IO.Path]::Combine( (get-item .).fullname, $_) }
        ? { [System.IO.File]::Exists( $_ ) -or [System.IO.Directory]::Exists( $_ ) } |
        % { get-item $_ }

    $includedFiles = gci . * -rec | ? { $excludedFiles -notcontains $_.fullname }
    
    function getCopyTarget( $file, [string] $targetDir ) {
    
        $relativePath = getRelativePath($gitroot, $file.fullname);
    
        #return [System.IO.Path]::Combine( $targetDir, $relativePath )
    }
    
    foreach ($file in $includedFiles)
    {
        getCopyTarget($file, $leftdir);
        #$relativePath = $getRelativePath(
    }
    
    #get-item $excludedFiles[1] | gm
    
    #$exclude = [string]::Join( '+', $excludedFilenames[-3] ).Replace('/', '\')
    
    #$exclude
    #(& xcopy $path $leftdir /i /s /y /exclude:"$exclude") | write-host
    
    
    
    
    
    
    
    

