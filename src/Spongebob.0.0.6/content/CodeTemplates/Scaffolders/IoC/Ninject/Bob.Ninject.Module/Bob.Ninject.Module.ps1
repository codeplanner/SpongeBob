[T4Scaffolding.Scaffolder(Description = "Procides example code for using SpongeBob and Ninject within threadscope. Good with XSockets!")][CmdletBinding()]
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

#open domainmodel files
$files = (Get-Project $coreProjectName).ProjectItems | Where-Object {$_.Name -eq "Model"} | ForEach{$_.ProjectItems }
$files | ForEach{$_.Open(); $_.Document.Activate()}

Start-Sleep -s 2

$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
$classes = $namespaces | ForEach{$_.Children}

Write-Host "//Remember to: Install-Package Ninject (if it´s not done)" -ForegroundColor Yellow 
Write-Host "public class ServiceModule : NinjectModule" -ForegroundColor DarkGreen 
Write-Host "{" -ForegroundColor DarkGreen 
Write-Host "    public override void Load()" -ForegroundColor DarkGreen 
Write-Host "    {"  -ForegroundColor DarkGreen 
Write-Host "		Bind<IUnitOfWork>().To<UnitOfWork>().InThreadScope();" -ForegroundColor DarkGreen
Write-Host "		Bind<IDatabaseFactory>().To<DatabaseFactory>().InThreadScope();" -ForegroundColor DarkGreen   

$lastName = $null
$classes | ForEach{		
	$current = $_
	if($_.IsAbstract -eq $false){
		$_.Bases | ForEach{
			if($_.Name -eq "PersistentEntity"){							
				Write-Host "		Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InThreadScope();" -ForegroundColor DarkGreen
				Write-Host "		Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InThreadScope();" -ForegroundColor DarkGreen
				$lastName = $current.Name
			}
			#if($_.Name -eq "PersistentTrackingEntity"){							
			#	Write-Host "		Bind<I$($current.Name)Repository>().To<$($current.Name)Repository>().InThreadScope();" -ForegroundColor DarkGreen
			#	Write-Host "		Bind<I$($current.Name)Service>().To<$($current.Name)Service>().InThreadScope();" -ForegroundColor DarkGreen
			#	$lastName = $current.Name
			#}
		}		
	}
}    
Write-Host "    }" -ForegroundColor DarkGreen 
Write-Host "}" -ForegroundColor DarkGreen 
Write-Host ""
Write-Host "//Example Get Ninject Module" -ForegroundColor Yellow 
Write-Host "//public partial class Demo" -ForegroundColor DarkGreen 
Write-Host "//{"
Write-Host "//    private static readonly IKernel kernel;" -ForegroundColor DarkGreen 
Write-Host "//    static Demo()" -ForegroundColor DarkGreen
Write-Host "//    {"
Write-Host "//		  //get kernel once inte static constructor" -ForegroundColor Yellow 
Write-Host "//        kernel = new StandardKernel(new ServiceModule());" -ForegroundColor DarkGreen 
Write-Host "//    }" -ForegroundColor DarkGreen 
Write-Host "//}" -ForegroundColor DarkGreen 

Write-Host ""
Write-Host "//Example Get Instance and query by id" -ForegroundColor Yellow 
Write-Host "//public $($lastName) Get$($lastName)(int id)" -ForegroundColor DarkGreen 
Write-Host "//{" -ForegroundColor DarkGreen 
Write-Host "//	using (var block = kernel.BeginBlock())" -ForegroundColor DarkGreen 
Write-Host "//	{" -ForegroundColor DarkGreen 
Write-Host "//		var $($lastName.toLower())Service = block.Get<I$($lastName)Service>();" -ForegroundColor DarkGreen 
Write-Host "//		return $($lastName.toLower())Service.GetById(id);" -ForegroundColor DarkGreen 
Write-Host "//	}" -ForegroundColor DarkGreen 
Write-Host "//}" -ForegroundColor DarkGreen 
