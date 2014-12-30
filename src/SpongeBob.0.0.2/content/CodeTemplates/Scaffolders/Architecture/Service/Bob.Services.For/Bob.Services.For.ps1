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
[T4Scaffolding.Scaffolder(Description = "Enter a description of SpongeBob.Services.For here")][CmdletBinding()]
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
$coreProjectName = $rootNamespace + ".Core"
$serviceProjectName = $rootNamespace + ".Service"

##############################################################
# Add Service - ModelType
##############################################################
$outputPath = $ModelType + "Service"
$namespace = $serviceProjectName
$ximports = $coreProjectName + ".Model," + $coreProjectName + ".Interfaces.Service," + $coreProjectName + ".Interfaces.Data," + $coreProjectName +".ViewModel"

Add-ProjectItemViaTemplate $outputPath -Template Service `
	-Model @{ Namespace = $namespace; ClassName = $ModelType; ExtraUsings = $ximports } `
	-SuccessMessage "Added Service at {0}" `
	-TemplateFolders $TemplateFolders -Project $serviceProjectName -CodeLanguage $CodeLanguage -Force:$Force

$file = Get-ProjectItem "$($outputPath).cs" -Project $serviceProjectName
$file.Open()
$file.Document.Activate()
$DTE.ActiveDocument.Save()

##############################################################
# create service interface for modeltype
##############################################################
$outputPath = "Interfaces\Service\I" + $ModelType + "Service"
$namespace = $coreProjectName + ".Interfaces.Service"
$ximports = $coreProjectName + ".Model," + $coreProjectName +".ViewModel"

Add-ProjectItemViaTemplate $outputPath -Template IService `
	-Model @{ Namespace = $namespace; ClassName = $ModelType; ExtraUsings = $ximports } `
	-SuccessMessage "Added IService of $ModelType output at {0}" `
	-TemplateFolders $TemplateFolders -Project $coreProjectName -CodeLanguage $CodeLanguage -Force:$Force

try{
	$file = Get-ProjectItem "$($outputPath).cs" -Project $coreProjectName
	$file.Open()
	$file.Document.Activate()	
	$DTE.ExecuteCommand("Edit.FormatDocument", "")
	$DTE.ActiveDocument.Save()
}catch {
	Write-Host "Hey, you better not be clicking around in VS while we generate code" -ForegroundColor DarkRed
}