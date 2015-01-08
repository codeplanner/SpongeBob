[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.ViewModel.For here")][CmdletBinding()]
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
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}
#DateTime
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 11 -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}
#Enums
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 10 -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}
#Nullables
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.CodeType.Name -eq "Nullable" -and $_.Type.TypeKind -eq 1} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)"; 
	$properties = $properties + $p
}

#Get "realtions, not actually parents..."
$parents = @()
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.CodeType.Kind -eq 1 -and $_.Type.IsGeneric -eq $false} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)";
	$parents = $parents + $p
}

#Get "children"
$children = @()
(Get-ProjectType $ModelType).Children | Where-Object{$_.Kind -eq 4 -and $_.Type.TypeKind -eq 1 -and $_.Type.IsGeneric -eq $true -and $_.Type.CodeType.Name -ne "Nullable"} | ForEach{	
	$p = "$($_.Name),$($_.Type.AsString)";
	$children = $children + $p
}

##############################################################
# Create the viewmodel
##############################################################
$outputPath = "ViewModel\"+$foundModelType.Name+"ViewModel"
$namespace = $namespace + ".Core.ViewModel"
$ximports = $coreProjectName + ".Model"

Write-Host $properties
Write-Host $parents
Write-Host $children

Add-ProjectItemViaTemplate $outputPath -Template ViewModel `
	-Model @{ 	
	Namespace = $namespace; 
	DataType = [MarshalByRefObject]$foundModelType;	
	DataTypeName = $foundModelType.Name; 
	Properties = $properties;
	Parents = $parents;
	Children = $children;
	ExtraUsings = $ximports
	} `
	-SuccessMessage "Added ViewModel for $ModelType {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	
}