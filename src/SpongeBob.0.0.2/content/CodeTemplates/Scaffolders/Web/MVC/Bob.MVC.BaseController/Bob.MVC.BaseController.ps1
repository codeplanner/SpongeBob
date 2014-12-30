[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.MVC.BaseController here")][CmdletBinding()]
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
$mvcProjectName = $namespace
$coreProjectName = $rootNamespace + ".Core"

##############################################################
# Create the BaseController
##############################################################
$outputPath = "Controllers\BaseController"
$namespace = $mvcProjectName + ".Controllers"
$ximports = $coreProjectName + ".Interfaces.Service"

Add-ProjectItemViaTemplate $outputPath -Template BaseController `
	-Model @{Namespace = $namespace; ExtraUsings = $ximports} `
	-SuccessMessage "Added BaseController to MVC {0}" `
	-TemplateFolders $TemplateFolders -Project $mvcProjectName -CodeLanguage $CodeLanguage -Force:$Force