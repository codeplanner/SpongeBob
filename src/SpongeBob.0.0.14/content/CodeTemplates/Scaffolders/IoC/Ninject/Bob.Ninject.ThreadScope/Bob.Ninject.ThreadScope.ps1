[T4Scaffolding.Scaffolder(Description = "Provides code for registering services/repositories in threadscope")][CmdletBinding()]
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
$files = (Get-Project $coreProjectName).ProjectItems | Where-Object {$_.Name -eq "Model"} | ForEach{$_.ProjectItems }
$files | ForEach{$_.Open(); $_.Document.Activate()}

Start-Sleep -s 2

$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
$classes = $namespaces | ForEach{$_.Children}

Write-Host "Bind<IUnitOfWork>().To<UnitOfWork>().InThreadScope();" -ForegroundColor DarkGreen
Write-Host "Bind<IDatabaseFactory>().To<DatabaseFactory>().InThreadScope();" -ForegroundColor DarkGreen

$classes | ForEach{		
	$current = $_
	if($_.IsAbstract -eq $false){
		$_.Bases | ForEach{
			if($_.Name -eq "PersistentEntity"){							
				Write-Host "Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InThreadScope();" -ForegroundColor DarkGreen
				Write-Host "Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InThreadScope();" -ForegroundColor DarkGreen
			}
			#if($_.Name -eq "PersistentTrackingEntity"){							
			#	Write-Host "Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InThreadScope();" -ForegroundColor DarkGreen
			#	Write-Host "Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InThreadScope();" -ForegroundColor DarkGreen
			#}
		}		
	}
}