
param ([string] $left, [string] $right = ".");

function normalizeFilepath( $file ) 
{
    $result = $file.fullname.ToLowerInvariant();
    $result = $result.TrimEnd( ( '\' ) );
    return $result;
}

function getRelativePath( $root, $file) {

    $rootPath = normalizeFilepath( $root);
    
    $fullPath = normalizeFilepath( $file);
    
    if (!$fullPath.StartsWith( $rootPath)) {
        throw "$fullPath does not seem rooted by $rootPath.";
    }
        
    return $fullPath.Substring($rootPath.Length + 1);
}

function getWorkingDirectories {

    if ($env:USERPROFILE -eq $null) {
        throw 'Environment variable $env:USERPROFILE is required, as a base path to gitndiff''s working directory.';
    }

    $basedir = $env:USERPROFILE + '\.gitndiff';
    $leftdir = $basedir + '\left';
    $rightdir = $basedir + '\right';
    
    if ([System.IO.Directory]::Exists( $leftdir)) {
        remove-item $leftdir -recurse 
    }

    if ([System.IO.Directory]::Exists( $rightdir)) {
        remove-item $rightdir -recurse
    }
    
    if (![System.IO.Directory]::Exists($basedir)) {
        & mkdir $basedir | out-null
    }
    
    if (![System.IO.Directory]::Exists($leftdir)) {
        & mkdir $leftdir | out-null
    }
    
    if (![System.IO.Directory]::Exists($rightdir)) {
        & mkdir $rightdir | out-null
    }

    return ( (get-item $leftdir), (get-item $rightdir));
}

function getRepositoryDirectory() {

    $gitroot = (git rev-parse --git-dir).Replace('/', '\'); 
    if ($gitroot.LastIndexOf('\') -lt 0) {
        $gitroot = (get-item .).fullname
    } else {
        $gitroot = $gitroot.SubString(0, $gitroot.LastIndexOf('\'));
    }

    return (get-item $gitroot);
}

function getFilesToExclude() {

    $excludedFiles = (git ls-files -o) | 
        % { $_.Replace( '/', '\') } |
        % { [System.IO.Path]::Combine( (get-item .), $_) }
        ? { [System.IO.File]::Exists( $_ ) -or [System.IO.Directory]::Exists( $_ ) } |
        % { get-item $_ }

    return $excludedFiles;
}

function getFilesToInclude() {

    $excludedFiles = getFilesToExclude

    $includedFiles = gci . * -rec | 
        ? { $excludedFiles -notcontains $_.fullname } |
        ? { ! $_.PSIsContainer }

    return $includedFiles;
}

function copyCurrentDirectoryToRepositoryMirrorAt($targetRoot) {

    $includedFiles = getFilesToInclude

    function copyTarget( [System.IO.FileInfo] $fileToCopy, [System.IO.DirectoryInfo] $targetRoot ) {

        $relativePath = getRelativePath $gitroot $fileToCopy;

        $targetPath = [System.IO.Path]::Combine( $targetRoot.fullname, $relativePath);
        
        copy-item $fileToCopy.Directory -filter $fileToCopy.Name -Destination $targetPath
    }

    foreach ($file in $includedFiles)
    {
        copyTarget $file $targetRoot;
    }
}

$gitroot = getRepositoryDirectory;

"Running git ndiff for repository at $gitroot" | write-host;

([System.IO.DirectoryInfo] $leftTargetDirectory, [System.IO.DirectoryInfo] $rightTargetDirectory) = getWorkingDirectories;

"Running with working trees $left and $right" | write-host

if ($left -ne '.')
{
    (& git stash) | write-host
    
    (& git checkout $left) | write-host
}

copyCurrentDirectoryToRepositoryMirrorAt($leftTargetDirectory);

if ($left -eq '.') {
    (& git stash) | write-host
}

if ($right -eq '.') { 

    (& git stash pop) | write-host
} else {

    (& git checkout $right) | write-host
}

copyCurrentDirectoryToRepositoryMirrorAt($rightTargetDirectory);
    
if ($right -ne '.') { 
    (& git stash pop) | write-host
}

& diffmerge $leftTargetDirectory $rightTargetDirectory
