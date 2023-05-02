#abrindo o JSON como objeto
$jsonObj = Get-Content './teste.json' | ConvertFrom-Json;

#criando base da função mop
$retorno = 'function mop {
    Param(
        @parametros@
    )

    DynamicParam{
        @parametros_dinamicos@
    }

    Process{
        @execucao@
    }
}';

#percorrendo todas as chaves do JSON para montra os parametros da mop
$parametros = $jsonObj.psobject.properties | Join-String -Property {
    "[Parameter()]
    [switch]$("$" + $_.Name)"
}  -Separator ",`r`n"

#percorrendo cada linha de código de cada chave e montrando o corpo da função
$execucao = $jsonObj.psobject.properties | Join-String -Property {
    "if($("$" + $_.Name)){
        $($_.value.body | Join-String { $_.Replace("_psb", '$PSBoundParameters') } -Separator "`r`n")
    }
    "
}  -Separator "`n"

#montrando os parametros dinamicos para cada função
$parametrosDinamicos = $jsonObj.psobject.properties | Join-String -Property {
    "if($("$" + $_.Name)){
        $('$paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary')
    " + ( $_.value.parametros | Join-String -Property {
        $nomeSubParametro = $_.nome;
        $tipoParametro = $_.tipo;
        $declaracaoParametro = $('New-Object System.Management.Automation.RuntimeDefinedParameter(@subparam, [@tipo], $attributeCollection)'.Replace("@subparam", "'$($nomeSubParametro)'"))
        $declaracaoParametro = $declaracaoParametro.Replace("@tipo", $tipoParametro)

        "$("$" + $nomeSubParametro + "Atributte") = New-Object System.Management.Automation.ParameterAttribute
            $('$attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]')
            $("$" + "attributeCollection.Add($("$" + $nomeSubParametro + "Atributte"))")
            $("$" + $nomeSubParametro + "Param") = $($declaracaoParametro)
            $("$" + "paramDictionary.Add($("'$($nomeSubParametro)'"), $("$" + $nomeSubParametro + "Param"))")"
    } -Separator "`r`n") + '
        return $paramDictionary
    }'
}  -Separator "`n"


#colocando os parametros já montados na base da função
$retorno = $retorno.Replace("@parametros@", $parametros);
$retorno = $retorno.Replace("@execucao@", $execucao);
$retorno = $retorno.Replace("@parametros_dinamicos@", $parametrosDinamicos);

#declaração a função
Invoke-Expression $retorno;
# Write-Host $retorno;
