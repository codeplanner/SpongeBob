[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.XSockets.BaseController here")][CmdletBinding()]
param(    
	[parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$ProjectName,   
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

#
#Use default proj if not set
#
if($ProjectName -eq ""){ $ProjectName = $Project }

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
# Create the PageModel
##############################################################
$outputPath = "Model\Page"
$ximports = $coreProjectName + ".Interfaces.Paging"
$namespace = $ProjectName + ".Model"

Add-ProjectItemViaTemplate $outputPath -Template Page `
	-Model @{Namespace = $namespace; ExtraUsings = $ximports} `
	-SuccessMessage "Added PageModel to $($ProjectName) {0}" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $ProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}