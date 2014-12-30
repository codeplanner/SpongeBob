[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.XSockets.BaseController here")][CmdletBinding()]
param(    
	[parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)][string]$Controller,
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
$namespace = (Get-Project $ProjectName).Properties.Item("DefaultNamespace").Value

##############################################################
# Create the BaseController
##############################################################
$outputPath = $Controller
$ximports = $namespace + ".Ninject"

if($Controller.lastindexOf("\") -eq -1){
	$addedNS = ""
	$fileName = "$($Controller)"
}
else{
	$addedNS = "." + $Controller.Substring(0,$Controller.lastindexOf("\")).Replace("\",".")
	$fileName =  $Controller.Substring($Controller.lastindexOf("\")+1)
}
$namespace = (Get-Project $ProjectName).Properties.Item("DefaultNamespace").Value + $addedNS

Add-ProjectItemViaTemplate $outputPath -Template BaseController `
	-Model @{Namespace = $namespace; DataTypeName = $fileName; ExtraUsings = $ximports} `
	-SuccessMessage "Added BaseController to $($ProjectName) {0}" `
	-TemplateFolders $TemplateFolders -Project $ProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $dataProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}