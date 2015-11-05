[T4Scaffolding.Scaffolder(Description = "Enter a description of Bob.XSockets.DataSyncController.For here")][CmdletBinding()]
param(  
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,   
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
#$sln = [System.IO.Path]::GetFilename($dte.DTE.Solution.FullName)
#$path = $dte.DTE.Solution.FullName.Replace($sln,'').Replace('\\','\')
#$pluginPath = $path + "XSocketServerPlugins"
#$sln = Get-Interface $dte.Solution ([EnvDTE80.Solution2])

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
# Info about ModelType
##############################################################
$foundModelType = Get-ProjectType $ModelType -Project $coreProjectName
if (!$foundModelType) { 
	Write-Host "Could not find any type mathing the passed in class name $($ModelType)"
	return 
}

##############################################################
# Create the ninject module if it does not exists
# Each entity will have its own partial class
##############################################################
if((Get-ProjectItem "NinjectModules\ServiceModule.cs" -Project $ProjectName) -eq $null){
	#Scaffold Bob.XSockets.NinjectModule $ProjectName

	$ximports = $coreProjectName + ".Interfaces.Data," + $coreProjectName + ".Interfaces.Service," + $rootNamespace + ".Data," + $rootNamespace + ".Service"

	$mappings = @()

	#open domainmodel files
	$files = (Get-Project $coreProjectName).ProjectItems | Where-Object {$_.Name -eq "Model"} | ForEach{$_.ProjectItems }
	$files | ForEach{$_.Open(); $_.Document.Activate()}

	Start-Sleep -s 2

	$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
	$classes = $namespaces | ForEach{$_.Children}

	
	$mappings = $mappings + "IUnitOfWork,UnitOfWork"
	$mappings = $mappings + "IDatabaseFactory,DatabaseFactory"

	$classes | ForEach{		
		$current = $_
		if($_.IsAbstract -eq $false){
			$_.Bases | ForEach{
				if($_.Name -eq "PersistentEntity"){	
					$p = "I$($current.Name)Repository,$($current.Name)Repository"; 
					$mappings = $mappings + $p
					$p = "I$($current.Name)Service,$($current.Name)Service"; 
					$mappings = $mappings + $p
				}
			}		
		}
	}

	Add-ProjectItemViaTemplate "NinjectModules\ServiceModule" -Template NinjectServiceModule `
	-Model @{Namespace = "$($namespace).NinjectModules"; DataTypeName = "ServiceModule"; Mappings = $mappings; ExtraUsings = $ximports} `
	-SuccessMessage "Added NinjectModule to $($projectname) {0}" `
	-TemplateFolders $TemplateFolders -Project $projectname -CodeLanguage $CodeLanguage -Force:$Force

}

##############################################################
# Create the abstract datasync class if it does not exist
##############################################################
if((Get-ProjectItem "DataSyncController.cs" -Project $ProjectName) -eq $null){
	#Scaffold DataSyncController $Controller $ProjectName

	$ximports = $coreProjectName + ".Common.Paging," + $coreProjectName + ".Common.Validation," + $coreProjectName + ".Interfaces.Service," + $coreProjectName + ".Model," + $coreProjectName + ".ViewModel," + $rootNamespace + ".NinjectModules"
	$outputPath = "XSocketsModules\XSocketsDataSyncController"

	Add-ProjectItemViaTemplate $outputPath -Template DataSyncController `
	-Model @{ 	
	Namespace = "$($namespace).XSocketsModules";
	DataTypeName = "XSocketsDataSyncController";
	ExtraUsings = $ximports
	} `
	-SuccessMessage "Added base class for DataSync" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force
}

##############################################################
# Create the controller class for datasync if it does not exist
##############################################################

$ximports = $coreProjectName + ".Model," + $coreProjectName + ".ViewModel," + $rootNamespace + ".Service"
$outputPath = "XSocketsModules\$($foundModelType.Name)Controller"

Add-ProjectItemViaTemplate $outputPath -Template DataSyncController.For `
-Model @{ 	
Namespace = "$($namespace).XSocketsModules";
DataTypeName = $foundModelType.Name;
ExtraUsings = $ximports
} `
-SuccessMessage "Added DataSync class for $($foundModelType.Name) {0}" `
-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force