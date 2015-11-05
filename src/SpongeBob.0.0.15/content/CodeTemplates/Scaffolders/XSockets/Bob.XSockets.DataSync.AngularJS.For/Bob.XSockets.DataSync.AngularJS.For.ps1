[T4Scaffolding.Scaffolder(Description = "Enter a description of Bob.XSockets.DataSync.AngularJS.For here")][CmdletBinding()]
param(   
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$ModelType,   
	[parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)][string]$NgAppName = "myApp",         
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
# Info about ModelType
##############################################################
$foundModelType = Get-ProjectType $ModelType -Project $coreProjectName
if (!$foundModelType) { return }

Write-Host "Collecting properties for the model, this might take a while" -ForegroundColor Blue

#Get regular properties
$properties = @()
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -ne 1 -and $_.Type.CodeType.Name -ne "Nullable" } | ForEach{ 
	$properties = $properties + $_.Name
}
#DateTime
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 11 -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
	$properties = $properties + $_.Name
}
#Enums
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 10 -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
	$properties = $properties + $_.Name
}
#Nullables
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.CodeType.Name -eq "Nullable" -and $_.Type.TypeKind -eq 1} | ForEach{	
	$properties = $properties + $_.Name
}

#Get "realtions, not actually parents..."
#$parents = @()
#(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 1 -and $_.Type.IsGeneric -eq $false} | ForEach{	
#	$p = "$($_.Name),$($_.Type.AsString)";
#	$parents = $parents + $p
#}

#Get "children"
#$children = @()
#(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.IsGeneric -eq $true -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
#	$p = "$($_.Name),$($_.Type.AsString)";
#	$children = $children + $p
#}

##############################################################
# Add NgView
##############################################################
$outputPath = "app\views\"+$ModelType.toLower()+"\default"

Write-Host $properties

Add-ProjectItemViaTemplate $outputPath -Template view `
-Model @{ 	 
DataTypeName = $foundModelType.Name; 
Properties = $properties;
} `
-SuccessMessage "Added NgView for $ModelType {0}" `
-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

##################
# Add NgApp
##################
$outputPath = "app\"+$NgAppNAme
Add-ProjectItemViaTemplate $outputPath -Template app `
-Model @{ 	
DataTypeName = $ModelType;
AppName = $NgAppNAme
} `
-SuccessMessage "Added NgModule $($NgAppName) {0}" `
-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

##################
# Add Controller
##################
$outputPath = "app\controllers\"+ $ModelType.toLower() +"controller"
Add-ProjectItemViaTemplate $outputPath -Template controller `
-Model @{ 	
DataTypeName = $ModelType;
} `
-SuccessMessage "Added NgController for $($NgAppName) {0}" `
-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

##################
# Add Container
##################
$outputPath = $NgAppName
Add-ProjectItemViaTemplate $outputPath -Template container `
-Model @{ 	
DataTypeName = $ModelType;
AppName = $NgAppNAme
} `
-SuccessMessage "Added NgContainer for $($NgAppName) {0}" `
-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force


