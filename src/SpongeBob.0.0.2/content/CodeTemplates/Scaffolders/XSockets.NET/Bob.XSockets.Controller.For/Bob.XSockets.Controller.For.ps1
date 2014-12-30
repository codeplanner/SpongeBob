[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.XSockets.Controller.For here")][CmdletBinding()]
param(        
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Controller, 
	[parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$ProjectName = "", 
    [string]$Project,
	[string]$CodeLanguage,
	[string[]]$TemplateFolders,
	[switch]$Force = $false
)

$defaultProject = Get-Project

#
#Use default proj if not set
#
if($ProjectName -eq ""){ $ProjectName = $Project }

$currentProj = Get-Project $Project
$defaultProjectName = [System.IO.Path]::GetFilename($currentProj.FullName)
$refPath =  $currentProj.FullName.Replace($defaultProjectName,'')

#
#Get PluginPath to set in post build event
#
$sln = [System.IO.Path]::GetFilename($dte.DTE.Solution.FullName)
$path = $dte.DTE.Solution.FullName.Replace($sln,'').Replace('\\','\')
$pluginPath = $path + "XSocketServerPlugins"
$sln = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

#
#Add new project if it does not exist
#
if(($DTE.Solution.Projects | Select-Object -ExpandProperty Name) -notcontains $ProjectName){
Write-Host "Adding new project"
$templatePath = $sln.GetProjectTemplate("ClassLibrary.zip","CSharp")
$sln.AddFromTemplate($templatePath, $path+$ProjectName,$ProjectName)
$file = Get-ProjectItem "Class1.cs" -Project $ProjectName
$file.Remove()

Write-Host (Get-Project $ProjectName).Name Installing : XSockets.Core -ForegroundColor DarkGreen
Install-Package XSockets.Core -ProjectName (Get-Project $ProjectName).Name

$defProjName = (Get-Project $Project).ProjectName
(Get-Project $Project).Object.References.AddProject((Get-Project $ProjectName))
(Get-Project $ProjectName).Object.References.AddProject((Get-Project $($defProjName + ".Core")))
(Get-Project $ProjectName).Object.References.AddProject((Get-Project $($defProjName + ".Data")))
(Get-Project $ProjectName).Object.References.AddProject((Get-Project $($defProjName + ".Service")))
(Get-Project $ProjectName).Object.References.Add("System.ComponentModel.DataAnnotations");

}

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
# Create the base partial controller if it not exists
# Each entity will have its own partial class
##############################################################
if((Get-ProjectItem "$($Controller).cs" -Project $ProjectName) -eq $null){
	Scaffold Bob.XSockets.BaseController $Controller $ProjectName
}

##############################################################
# Create the ninject module if it does not exists
# Each entity will have its own partial class
##############################################################
if((Get-ProjectItem "Ninject\ServiceModule.cs" -Project $ProjectName) -eq $null){
	Scaffold Bob.XSockets.NinjectModule $ProjectName
}

##############################################################
# Create the Model\Page if it does not exists
##############################################################
if((Get-ProjectItem "Model\Page.cs" -Project $ProjectName) -eq $null){
	Scaffold Bob.XSockets.PageModel $ProjectName
}

##############################################################
# Create the Controller.ModelType
##############################################################
$outputPath = "$($Controller).$($ModelType)"

$ximports = $coreProjectName + ".ViewModel," + $coreProjectName + ".Model," + $coreProjectName + ".Interfaces.Service," + $ProjectName + ".Model"

if($Controller.lastindexOf("\") -eq -1){
	$addedNS = ""
	$fileName = "$($Controller)"
}
else{
	$addedNS = "." + $Controller.Substring(0,$Controller.lastindexOf("\")).Replace("\",".")
	$fileName =  $Controller.Substring($Controller.lastindexOf("\")+1)
}
$namespace = (Get-Project $ProjectName).Properties.Item("DefaultNamespace").Value + $addedNS


Add-ProjectItemViaTemplate $outputPath -Template Controller `
	-Model @{Namespace = $namespace; DataTypeName = $fileName; ModelType = $ModelType; ExtraUsings = $ximports} `
	-SuccessMessage "Added Controller to $($projectname) {0}" `
	-TemplateFolders $TemplateFolders -Project $projectname -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}