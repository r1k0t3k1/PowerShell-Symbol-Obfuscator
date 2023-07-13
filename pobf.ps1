function Get-EncodedCode
{
    param([string]$code)
    ([char[]]$code|
    %{
        '${-}'+ ([int]$_  -replace "0",'${)}' -replace "1",'${!}' -replace "2",'${@}' -replace "3",'${#}' -replace "4",'${$}' -replace "5",'${%}' -replace "6",'${^}' -replace "7",'${&}' -replace "8",'${*}' -replace "9",'${(}')
    })  -join '+'
}

function Invoke-Pobf {
  param(
    [parameter(
      HelpMessage = 'Input file name.',
      Position = 0
      )][string]$FileName,
    [parameter(
      HelpMessage = 'Input script directly.',
      Position = 0
      )][string]$Script
  )

  begin {
    if(($FileName -and $Script) -or ((-not $FileName) -and (-not $Script))) {
      Write-Error "Either a file name or a script."
      exit
    }
  }

  end {
    $PlainScript = ""

    if($FileName -and (-not (Get-Item $FileName).PSIsContainer)) {
      $PlainScript = Get-Content $FileName
    } else {
      $PlainScript = $Script
    }

    ${)}=${~}=+$() #0
    ${!}=++${~}    #1
    ${@}=++${~}    #2
    ${#}=++${~}    #3
    ${$}=++${~}    #4
    ${%}=++${~}    #5
    ${^}=++${~}    #6
    ${&}=++${~}    #7
    ${*}=++${~}    #8
    ${(}=++${~}    #9

    ${;}="".("$(@{})"["${!}${$}"]+"$(@{})"["${!}${^}"]+"$(@{})"["${!}${&}"]+"$(@{})"[${$}]+"$?"[${!}]+"$(@{})"[${#}])
    ${-}="["+"$(@{})"[${&}]+"$(@{})"["${!}${(}"]+"$(@{})"["${@}${)}"]+"$?"[${!}]+"]" #[char]
    ${=}="${;}"[${#}]+"${;}"["${!}${)}"]+"${;}"["${@}${&}"] #iex

    $prep = '${)}=${~}=+$();${!}=++${~};${@}=++${~};${#}=++${~};${$}=++${~};${%}=++${~};${^}=++${~};${&}=++${~};${*}=++${~};${(}=++${~};${;}="".("$(@{})"["${!}${$}"]+"$(@{})"["${!}${^}"]+"$(@{})"["${!}${&}"]+"$(@{})"[${$}]+"$?"[${!}]+"$(@{})"[${#}]);${-}="["+"$(@{})"[${&}]+"$(@{})"["${!}${(}"]+"$(@{})"["${@}${)}"]+"$?"[${!}]+"]";${=}="${;}"[${#}]+"${;}"["${!}${)}"]+"${;}"["${@}${&}"];'
    $cmd = Get-EncodedCode $PlainScript
    Write-Host "$prep;"`"($cmd)'|${=}"|&${=}'
  }
}
