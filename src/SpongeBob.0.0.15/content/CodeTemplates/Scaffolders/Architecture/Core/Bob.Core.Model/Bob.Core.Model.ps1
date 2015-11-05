[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.Model here")][CmdletBinding()]
param(        
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

##############################################################
# NAMESPACE
##############################################################
$namespace = (Get-Project $Project).Properties.Item("DefaultNamespace").Value
$rootNamespace = $namespace
$dotIX = $namespace.LastIndexOf('.')
if($dotIX -gt 0){
	$rootNamespace = $namespace.Substring(0,$namespace.LastIndexOf('.'))
}

##############################################################
# Project Name
##############################################################
$coreProjectName = $rootNamespace + ".Core"

##############################################################
# Add Model Entity - PersistentEntity
##############################################################
$outputPath = "Model\PersistentEntity"
$namespace = $coreProjectName + ".Model"

Add-ProjectItemViaTemplate $outputPath -Template PersistentEntity `
	-Model @{ Namespace = $namespace;  } `
	-SuccessMessage "Added PersistentEntity at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Validation Interface - IValidationContainer
##############################################################
$outputPath = "Interfaces\Validation\IValidationContainer"
$namespace = $coreProjectName + ".Interfaces.Validation"

Add-ProjectItemViaTemplate $outputPath -Template IValidationContainer `
	-Model @{ Namespace = $namespace; } `
	-SuccessMessage "Added IValidationContainer at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Validation - ValidationContainer
##############################################################
$outputPath = "Common\Validation\ValidationContainer"
$namespace = $coreProjectName + ".Common.Validation"
$ximports = $coreProjectName + ".Interfaces.Validation"

Add-ProjectItemViaTemplate $outputPath -Template ValidationContainer `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added ValidationContainer at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Validation - ValidationEngine
##############################################################
$outputPath = "Common\Validation\ValidationEngine"
$namespace = $coreProjectName + ".Common.Validation"
$ximports = $coreProjectName + ".Interfaces.Validation," + $coreProjectName + ".Model"

Add-ProjectItemViaTemplate $outputPath -Template ValidationEngine `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added ValidationEngine at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Paging Interface - IPage
##############################################################
$outputPath = "Interfaces\Paging\IPage"
$namespace = $coreProjectName + ".Interfaces.Paging"

Add-ProjectItemViaTemplate $outputPath -Template IPage `
	-Model @{ Namespace = $namespace; } `
	-SuccessMessage "Added IPage at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Paging - Page
##############################################################
$outputPath = "Common\Paging\Page"
$namespace = $coreProjectName + ".Common.Paging"
$ximports = $coreProjectName + ".Interfaces.Paging," + $coreProjectName + ".Model"

Add-ProjectItemViaTemplate $outputPath -Template Page `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added Page at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add BaseViewModel
##############################################################
$outputPath = "ViewModel\BaseViewModel"
$namespace = $coreProjectName + ".ViewModel"
$ximports = $coreProjectName + ".Model"

Add-ProjectItemViaTemplate $outputPath -Template BaseViewModel `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added BaseViewModel at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}