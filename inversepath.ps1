
function normalizeFilepath( [string] $filepath ) 
{
    $result = (get-item $filepath).fullname.ToLowerInvariant();
    $result = $result.TrimEnd( ( '\' ) );
    return $result;
}

function getRelativePath( [string] $rootPath, [string] $fullPath) {

    $rootPath = normalizeFilepath $rootPath;
    
    $fullPath = normalizeFilepath( $fullPath);
    
    if (!$fullPath.StartsWith( $rootPath)) {
        throw "$fullPath does not seem rooted by $rootPath.";
    }
        
    return "." + $fullPath.Substring($rootPath.Length);
}
