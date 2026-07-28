$urls = @(
    "http://10.10.28.89:8004/api/v1/admin/storybooks?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093&limit=1",
    "http://10.10.28.89:8004/admin/storybooks?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093&limit=1",
    "http://10.10.28.89:8004/api/v1/storybook/94a948bf-902d-40a7-bed1-16ae247c6740",
    "http://10.10.28.89:8004/storybook/94a948bf-902d-40a7-bed1-16ae247c6740"
)

foreach ($url in $urls) {
    try {
        $res = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5
        Write-Host "URL: $url -> Status: $($res.StatusCode)"
    } catch {
        Write-Host "URL: $url -> Error Status/Message: $_"
    }
}
