# Script to add MathJax to all lesson files

# Function to add MathJax to a file
function Add-MathJax {
    param (
        [string]$FilePath
    )
    
    $content = Get-Content -Path $FilePath -Raw
    
    # Skip if MathJax is already there
    if ($content -match "MathJax") {
        Write-Host "MathJax already exists in $FilePath"
        return
    }
    
    $mathJaxConfig = @"
    <script>
        window.MathJax = {
            tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
            svg: { fontCache: 'global' }
        };
    </script>
    <script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
"@
    
    # Insert MathJax after the first occurrence of </script> to ensure it's in the head
    if ($content -match '<script src="https://cdn.tailwindcss.com"></script>') {
        $content = $content -replace '<script src="https://cdn.tailwindcss.com"></script>', "<script src=`"https://cdn.tailwindcss.com`"></script>`n$mathJaxConfig"
        Set-Content -Path $FilePath -Value $content
        Write-Host "Added MathJax to $FilePath"
    }
}

# Process all lesson files
$lessonFiles = Get-ChildItem -Path "." -Filter "lesson_*.html" -File

foreach ($file in $lessonFiles) {
    Add-MathJax -FilePath $file.FullName
}

Write-Host "MathJax has been added to all lesson files!"
