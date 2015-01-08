[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.ViewModels.All here")][CmdletBinding()]
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

Write-Host "Collecting properties for the model, this might take a while" -ForegroundColor Blue

#open domainmodel files
$files = (Get-Project $coreProjectName).ProjectItems | Where-Object { $_.Name -eq "Model" } | ForEach{$_.ProjectItems } | Where-Object {$_.Document -ne $null }
$files | ForEach{$_.Open(); $_.Document.Activate()}

Start-Sleep -s 2

$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
$classes = $namespaces | ForEach{$_.Children}

$classes | ForEach{		
	$current = $_
	if($_.IsAbstract -eq $false){
		$_.Bases | ForEach{
			if($_.Name -eq "PersistentEntity"){							
				Scaffold Bob.ViewModel.For $current.Name -Force:$Force			
			}
			#if($_.Name -eq "PersistentTrackingEntity"){							
			#	Scaffold Bob.ViewModel.For $current.Name -Force:$Force			
			#}
		}		
	}
}