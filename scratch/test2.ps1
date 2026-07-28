$urls = @(
    "http://10.10.28.89:8004/api/v1/storybook?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093",
    "http://10.10.28.89:8004/api/v1/storybook/user/de1631a9-5cea-4160-a7c9-3f3647ef6093",
    "http://10.10.28.89:8004/api/v1/storybook/client/de1631a9-5cea-4160-a7c9-3f3647ef6093",
    "http://10.10.28.89:8004/api/v1/storybook/list?user_id=de1631a9-5cea-4160-a7c9-3f3647ef6093"
)

foreach ($url in $urls) {
    try {
        $res = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 5
        Write-Host "URL: $url -> Status: $($res.StatusCode)"
    } catch {
        Write-Host "URL: $url -> Error Status/Message: $_"
    }
}
