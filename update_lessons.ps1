# Script to update all lesson files with correct navigation and MathJax

# Function to update file content
function Update-FileContent {
    param (
        [string]$FilePath,
        [string]$SearchText,
        [string]$ReplaceText
    )
    
    $content = Get-Content -Path $FilePath -Raw
    if ($content -match [regex]::Escape($SearchText)) {
        $content = $content -replace [regex]::Escape($SearchText), $ReplaceText
        Set-Content -Path $FilePath -Value $content
        Write-Host "Updated $FilePath"
    }
}

# Function to add mark-done/mark-undone functionality
function Add-MarkAsDoneFunctionality {
    param (
        [string]$FilePath
    )
    
    $content = Get-Content -Path $FilePath -Raw
    
    # First check if the functionality is already there
    if ($content -match "mark-done" -and $content -match "mark-undone") {
        Write-Host "Mark as Done functionality already exists in $FilePath"
        return
    }
    
    # Add MathJax if it's not already there
    if (-not ($content -match "MathJax")) {
        $mathJaxConfig = @"
    <script>
        window.MathJax = {
            tex: { inlineMath: [['$', '$'], ['\\(', '\\)']] },
            svg: { fontCache: 'global' }
        };
    </script>
    <script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>
"@
        $content = $content -replace '(?<=<head>.*?)(?=<style>|<\/head>)', "`n$mathJaxConfig`n"
    }
    
    # Replace KaTeX with MathJax if needed
    if ($content -match "katex") {
        # Replace KaTeX with MathJax
        $content = $content -replace '<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.css"[^>]*>', ''
        $content = $content -replace '<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/katex.min.js"[^>]*></script>', ''
        $content = $content -replace '<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.9/dist/contrib/auto-render.min.js"[^>]*></script>', ''
    }
    
    # Fix navigation links
    if ($content -match "math_platform_main_page_he.html") {
        $content = $content -replace 'math_platform_main_page_he.html', 'index.html'
    }
    
    if ($content -match "questionnaire_35182_toc.html") {
        $content = $content -replace 'questionnaire_35182_toc.html', 'questionnaire_35182_lessons_he.html'
    }
    
    if ($content -match "questionnaire_35381_lessons_page_he.html") {
        $content = $content -replace 'questionnaire_35381_lessons_page_he.html', 'questionnaire_35381_lessons_he.html'
    }
    
    if ($content -match "questionnaire_35382_lessons_page_he.html") {
        $content = $content -replace 'questionnaire_35382_lessons_page_he.html', 'questionnaire_35382_lessons_he.html'
    }
    
    if ($content -match "lessonchoicemenue.html") {
        $content = $content -replace 'lessonchoicemenue.html', 'index.html'
    }
    
    if ($content -match "questionnaire_35182_analytic_geometry_toc.html") {
        $content = $content -replace 'questionnaire_35182_analytic_geometry_toc.html', 'questionnaire_35182_lessons_he.html'
    }
    
    # Add mark-done/mark-undone functionality if not already there
    $lessonId = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $markAsDoneScript = @"
<script>
  document.addEventListener("DOMContentLoaded", function() {
    const lessonId = "$lessonId";
    const markDoneButton = document.getElementById("mark-done");
    const markUndoneButton = document.getElementById("mark-undone");

    function updateButtons() {
        const isDone = localStorage.getItem(lessonId) === "done";
        markDoneButton.style.display = isDone ? "none" : "inline-block";
        markUndoneButton.style.display = isDone ? "inline-block" : "none";
    }

    markDoneButton.addEventListener("click", function() {
        localStorage.setItem(lessonId, "done");
        updateButtons();
    });

    markUndoneButton.addEventListener("click", function() {
        localStorage.removeItem(lessonId);
        updateButtons();
    });

    updateButtons();
  });
</script>
"@

    $markAsDoneButtons = @"
<div class="flex justify-center mt-4">
    <button id="mark-done" class="bg-green-500 hover:bg-green-600 text-white font-semibold py-2 px-4 rounded-md mr-2">Mark as Done</button>
    <button id="mark-undone" class="bg-red-500 hover:bg-red-600 text-white font-semibold py-2 px-4 rounded-md">Mark as Undone</button>
</div>
"@

    # Add buttons before end of body
    $content = $content -replace '(?=</body>)', $markAsDoneScript
    
    # Add buttons before end of main content
    $content = $content -replace '(?=</main>)', $markAsDoneButtons
    
    Set-Content -Path $FilePath -Value $content
    Write-Host "Added Mark as Done functionality to $FilePath"
}

# Process all lesson files
$lessonFiles = Get-ChildItem -Path "." -Filter "lesson_*.html" -File

foreach ($file in $lessonFiles) {
    Add-MarkAsDoneFunctionality -FilePath $file.FullName
}

Write-Host "All lesson files have been updated!"
