##############################################################################
# Copyright (c) 2015 
# Ulf Tomas Bjorklund
# http://twitter.com/ulfbjo
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##############################################################################
[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.ScaffoldBackend here")][CmdletBinding()]
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
$files = (Get-Project $coreProjectName).ProjectItems | Where-Object { $_.Name -eq "Model" } | ForEach{$_.ProjectItems | Where-Object {$_.Document -ne $null } }
#$files = (Get-Project $coreProjectName).ProjectItems | Where-Object {$_.Name -eq "Model" -and $_.Document -ne $null } | ForEach{$_.ProjectItems }
$files | ForEach{$_.Open(); $_.Document.Activate()}

Start-Sleep -s 2

$namespaces = $DTE.Documents | ForEach{$_.ProjectItem.FileCodeModel.CodeElements | Where-Object{$_.Kind -eq 5}}	
	
$classes = $namespaces | ForEach{$_.Children}

$classes | ForEach{		
	$current = $_
	$_.Bases | ForEach{
		if($_.Name -eq "PersistentEntity"){							
			Scaffold Bob.ScaffoldBackend.For $current.Name -Force:$Force			
		}
		if($_.Name -eq "PersistentTrackingEntity"){							
			Scaffold Bob.ScaffoldBackend.For $current.Name -Force:$Force			
		}
	}		
}