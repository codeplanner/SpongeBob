[T4Scaffolding.Scaffolder(Description = "Enter a description of Bob.AddClass here")][CmdletBinding()]
param(     
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,        
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
#$dataProjectName = $rootNamespace + ".Data"
#$dataProject = Get-Project $dataProjectName

##############################################################
# Add Data Repository - ModelType
##############################################################
$outputPath = "Model\"+$ModelType
$namespace = $coreProjectName + ".Model"
$ximports = ""

Add-ProjectItemViaTemplate $outputPath -Template AddClass `
	-Model @{ Namespace = $namespace; ClassName = $ModelType; ExtraUsings = "" } `
	-SuccessMessage "Added class at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	#Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}