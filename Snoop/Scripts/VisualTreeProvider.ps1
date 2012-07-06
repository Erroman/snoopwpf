﻿$path = Split-Path $MyInvocation.MyCommand.Path
ipmo -force (Join-Path $path "PSProvider\PSProvider.psd1")

if (Test-Path tree:) {
	Remove-PSDrive tree
}

New-PSDrive tree TreeScriptProvider -root / -moduleinfo $(new-module -name tree {
	$items = @{}
	$reverse = @{}

	function Get-ValidPath([string]$path) {
		$path = $path.Replace('/','\')
		if (-not $path.EndsWith('\')) {
				$path += '\'
		}
		return $path
	}

	function Get-TreeItem([string]$path) {
		$path = Get-ValidPath $path
		
		# todo, discover on the fly
		if ($items.Count -eq 0) {
			function recurse($element, [string]$p) {
				$names = @{}
				foreach ($c in $element.Children) {
					$n = $c.Target.GetType().Name
					$names[$n]++
				}
				foreach ($c in $element.Children) {
					$n = $c.Target.GetType().Name
					if ($names[$n] -gt 1) {
						recurse $c ($p + $n + $names[$n]-- + '\')
					} else {
						recurse $c ($p + $n + '\')
					}
				}

				$items[$p] = $element
				$reverse[$element] = $p
			}
			recurse $root '\'
		}
		return $items[$path]
	}

	function ClearItem {
		[cmdletbinding()]
		param(
			[string]$path
		)

		$psprovider.WriteWarning("Clear-Item is not supported.")
	}
	function CopyItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[string]$copyPath, 
			[bool]$recurse
		)

		$psprovider.WriteWarning("Copy-Item is not supported.")
	}
	function GetChildItems {
		[cmdletbinding()]
		param(
			[string]$path, 
			[bool]$recurse
		)

		$item = Get-TreeItem $path
		if ($item) {
			foreach ($c in $item.Children) {
				$p = $reverse[$c]
				GetItem $p
			}
		} else {
			$psprovider.WriteWarning("$path was not found.")
		}
	}
	function GetChildNames {
		[cmdletbinding()]
		param(
			[string]$path, 
			[Management.Automation.ReturnContainers]$returnContainers
		)

		$psprovider.writewarning("GetChildNames:$path")
		$item = Get-TreeItem $path
		if ($item) {
			foreach ($c in $item.Children) {
				$psprovider.WriteItemObject($c.Target.GetType().Name, $p, $true)
			}
		} else {
			$psprovider.WriteWarning("$path was not found.")
		}
	}
	function GetItem {
		[cmdletbinding()]
		param(
			[string]$path
		)
		$item = Get-TreeItem $path
		$n = $item.Target.GetType().Name
		$psprovider.WriteItemObject(@{$n=$item}, $path, $true)
	}
	function HasChildItems {
		[cmdletbinding()]
		[outputtype('bool')]
		param(
			[string]$path
		)
		$item = Get-TreeItem $path
		return $item.Children.Count -gt 0
	}
	function InvokeDefaultAction {
		[cmdletbinding()]
		param(
			[string]$path
		)
		$psprovider.writewarning("InvokeDefaultAction:$path")
	}
	function IsItemContainer {
		[cmdletbinding()]
		[outputtype('bool')]
		param(
			[string]$path
		)
		return $true
	}
	function IsValidPath {
		[cmdletbinding()]
		[outputtype('bool')]
		param(
			[string]$path
		)

		$path = Get-ValidPath
		foreach ($c in $path) {
			if ($c -eq '/' -or $c -eq '\') {
				continue
			}
			if (-not [char]::IsLetter($c)) {
				return $false
			}
		}
		return $true
	}
	function ItemExists {
		[cmdletbinding()]
		[outputtype('bool')]
		param(
			[string]$path
		)
		return (Get-TreeItem $path)
	}
	function MoveItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[string]$destination
		)
		$psprovider.WriteWarning("Move-Item is not supported.")
	}
	function NewDrive {
		[cmdletbinding()]
		[outputtype('Management.Automation.PSDriveInfo')]
		param(
			[Management.Automation.PSDriveInfo]$drive
		)
		$psprovider.WriteWarning("New-Drive is not supported.")
	}
	function NewItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[string]$itemTypeName, 
			[Object]$newItemValue
		)
		$psprovider.WriteWarning("New-Item is not supported.")
	}
	function RemoveItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[bool]$recurse
		)
		$psprovider.WriteWarning("Remove-Item is not supported.")
	}
	function RenameItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[string]$newName
		)
		$psprovider.WriteWarning("Rename-Item is not supported.")
	}
	function SetItem {
		[cmdletbinding()]
		param(
			[string]$path, 
			[Object]$value
		)
		$psprovider.WriteWarning("Set-Item is not supported.")
	}
})
