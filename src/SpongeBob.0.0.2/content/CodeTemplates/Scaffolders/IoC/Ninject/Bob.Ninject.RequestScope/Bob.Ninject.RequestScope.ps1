[T4Scaffolding.Scaffolder(Description = "Provides the bindings for using Ninject in a classic webapplication")][CmdletBinding()]
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

Write-Host "//Remember to: Install-Package Ninject.MVC3 (if you´re using this in your webbapplication)" -ForegroundColor Yellow 
Write-Host "//And then register the lines below in the RegisterServices method for Ninject" -ForegroundColor Yellow 
Write-Host "kernel.Bind<IUnitOfWork>().To<UnitOfWork>().InRequestScope();" -ForegroundColor DarkGreen
Write-Host "kernel.Bind<IDatabaseFactory>().To<DatabaseFactory>().InRequestScope();" -ForegroundColor DarkGreen

$classes | ForEach{		
	$current = $_
	$_.Bases | ForEach{
		if($_.Name -eq "PersistentEntity"){							
			Write-Host "kernel.Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InRequestScope();" -ForegroundColor DarkGreen
			Write-Host "kernel.Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InRequestScope();" -ForegroundColor DarkGreen
		}
		if($_.Name -eq "PersistentTrackingEntity"){							
			Write-Host "kernel.Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InRequestScope();" -ForegroundColor DarkGreen
			Write-Host "kernel.Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InRequestScope();" -ForegroundColor DarkGreen
		}
	}		
}