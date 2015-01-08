[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.Data here")][CmdletBinding()]
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
$dataProjectName = $rootNamespace + ".Data"
#$dataProjectNamespace = (Get-Project $dataProjectName).Properties.Item("DefaultNamespace").Value

##############################################################
# Add Data Repository - BaseRepository
##############################################################
$outputPath = "BaseRepository"
$namespace = $dataProjectName
$ximports = $coreProjectName + ".Model," + $coreProjectName + ".Interfaces.Data," + $coreProjectName + ".Interfaces.Paging," + $coreProjectName + ".Common.Paging," + $dataProjectName + ".Helpers"

Add-ProjectItemViaTemplate $outputPath -Template BaseRepository `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added BaseRepository at {0}" `
	-TemplateFolders $TemplateFolders -Project $dataProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Data UOW - UnitOfWork
##############################################################
$outputPath = "UnitOfWork"
$namespace = $dataProjectName
$ximports = $coreProjectName + ".Model," + $coreProjectName + ".Interfaces.Data"

Add-ProjectItemViaTemplate $outputPath -Template UnitOfWork `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added UnitOfWork at {0}" `
	-TemplateFolders $TemplateFolders -Project $dataProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Data DatabaseFactory - DatabaseFactory
##############################################################
$outputPath = "DatabaseFactory"
$namespace = $dataProjectName
$ximports = $coreProjectName + ".Interfaces.Data"

Add-ProjectItemViaTemplate $outputPath -Template DatabaseFactory `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added DatabaseFactory at {0}" `
	-TemplateFolders $TemplateFolders -Project $dataProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Data DataContext - DataContext
##############################################################
$outputPath = "DataContext"
$namespace = $dataProjectName
$ximports = $coreProjectName + ".Model," + $coreProjectName + ".Interfaces.Data"

Add-ProjectItemViaTemplate $outputPath -Template DataContext `
	-Model @{ Namespace = $namespace; ExtraUsings = $ximports } `
	-SuccessMessage "Added DataContext at {0}" `
	-TemplateFolders $TemplateFolders -Project $dataProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}

##############################################################
# Add Data Helpers - Searching
##############################################################
$outputPath = "Helpers\DataBaseHelper"
$namespace = $dataProjectName + ".Helpers"
$ximports = ""

Add-ProjectItemViaTemplate $outputPath -Template DataBaseHelpers `
	-Model @{ Namespace = $namespace; } `
	-SuccessMessage "Added DataBaseHelpers at {0}" `
	-TemplateFolders $TemplateFolders -Project $dataProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}