#alias 
new-alias rename rename-item #renomear arquivo
new-alias c clear-host #limpar tela
new-alias touch New-Item #criar arquivo
New-Alias ping Test-Connection

#get the path of the last directory accessed
$theLast = Get-Content "$env:USERPROFILE\Documents\PowerShell\theLast.txt"

#customizing the prompt
function prompt {
  $p = Split-Path -leaf -path (Get-Location)
  "$p -> "
}

#function for simulate command top from Linux
#Yeah...I know, but I think this pretty cool
function top{param([int]$intervalo, [int]$quantidade, [string]$ordenacao)
		
	
While(1) {Get-Process | Sort-Object -des $ordenacao| Select-Object -f $quantidade | Format-Table -a; Start-Sleep $intervalo; Clear-Host} 
}

#function for streamline the process for add, commit and push on git
function commit {
	$args = $args.split("/")
	git add $args[0]
	git commit -m $($args[1])
}

function pullPush {
	git pull --rebase origin master
	git push origin master
}

#open a file or web page with Firefox. It's usefull if you ara a web programer :)
function pom {
	$dependencias = '<dependencies>
  		<dependency>
			<groupId>net.imagej</groupId>
			<artifactId>ij</artifactId>
			<version>1.53c</version>
		</dependency>
</dependencies>'
	Set-Clipboard -Value $dependencias
}

#welcome mensage
write-host "Welcome aboard Captain, all system online!"

#open console commands history
function openHistory {
	code (Get-PSReadLineOption).HistorySavePath
}

#logs the event when exiting powershell 
Register-EngineEvent PowerShell.Exiting -Action {
	guardarUltimoDiretorio 
} > $null

#this funcition save the last directory accessed in notepad file
function guardarUltimoDiretorio {
	$arquivo = "$env:USERPROFILE\Documents\PowerShell\theLast.txt"
	Set-Content $arquivo ''
	Set-Content $arquivo $pwd.Path
}

function addPoint {
	$args = $args.split("/")
	$path = "$env:USERPROFILE\Documents\PowerShell\pontos.txt"
	$newPath ='$global:'+"$($args)"+" = '$PWD';"
	Add-Content -Path $path -value $newPath
	loadFile pontos.txt

}

function addProgram {
	if ($args.Count -eq 0) {
        Write-Host "Precisa-se de um Programa"
        return
    }
	$path = "$env:USERPROFILE\Documents\PowerShell\programas.txt"
	$novoPrograma = ((Get-Location).Path + $args[0].Substring(1))
	$newPath = '$global:' + "$($args[1])" + " = '$($novoPrograma)'" + " ;"

	Add-Content -Path $path -value $newPath
	
}

function loadFile {
	$path = "$env:USERPROFILE\Documents\PowerShell\" + $args[0]
	$points = Get-Content $path -Encoding utf8
	$points = [string]$points

	$sb = [scriptblock]::Create($points)
    Invoke-Command -scriptblock $sb

}

function reiniciaAudio {
	$audio = Get-Service -n *audiosrv*
	$audio.Stop()
	$audio.Start()
	
}

function this{
	if ($args.Count -eq 0) {
        (Get-Location).Path | Set-Clipboard
        return
    }
    $caminhoCompleto = (Get-Location).Path + $args[0].Substring(1)
    Set-Clipboard $caminhoCompleto
}

function organizaPasta {
	$pastaAtual = Get-Location
    
	$listaInicial = (Get-ChildItem -Path $pastaAtual).Extension
    
	$listaFinal = @()
	foreach ($item in $listaInicial) {
		if (!$listaFinal.Contains($item) && $item -ne "") {
			$listaFinal += $item
		}
	}
	foreach ($item in $listaFinal) {
		if ($item -ne "" ) {
			$extensaoAtual = $item.Replace('.', '')
			$pastaJaExiste = Test-Path $extensaoAtual
			if (!$pastaJaExiste) {
				mkdir $extensaoAtual
			}
			(Get-ChildItem -Filter "*$item") | Move-Item -Destination $extensaoAtual
		}   
	}
}

function criaAula {
	$data = Get-Date
	if($args.Count -gt 0){
		$data = $data.AddDays($args[0])
	}
	$pastaAula = "Aula $($data.Month)_$($data.Day)_$($data.Year)"
	mkdir $pastaAula > $null
	mkdir ".\$($pastaAula)\Aula" > $null
	mkdir ".\$($pastaAula)\Prévia" > $null
	mkdir ".\$($pastaAula)\Quiz" > $null
	

	
}

function fj {
	param (
		[switch] $l,
		[int] $posicaoPasta = 1
	)
	if((Get-ChildItem -Directory).Length -eq 0 ){
		Write-Host 'Este diretorio não contem pastas';
		return;
	}
	if($l){
		Set-Location (Get-ChildItem -Directory)[(Get-ChildItem -Directory).Length - 1];
		return;
	}
	if ($posicaoPasta -gt 0 -and $posicaoPasta -lt (Get-ChildItem -Directory).Length) {
		Set-Location (Get-ChildItem -Directory)[$posicaoPasta - 1];
	}
	
}

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

loadFile pontos.txt
loadFile programas.txt


