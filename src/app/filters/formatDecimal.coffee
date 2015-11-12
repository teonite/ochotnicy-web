# 
# Portal Ochotnicy - http://ochotnicy.pl
# 
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
# 
# Development: TEONITE - http://teonite.com
# 
angular.module("wolontariat.filters").filter "formatDecimal", [->
  (input, precission) ->
    input = input.replace(/[A-Za-z]/g, "") if input and typeof input isnt "number"
    precission = precission or 0
    decSeparator = ","
    thouSeparator = " "
    sign = (if input < 0 then "-" else "")
    i = parseInt(input = Math.abs(+input or 0).toFixed(precission)) + ""
    j = (if (j = i.length) > 3 then j % 3 else 0)
    fr = parseFloat(Math.abs(input - i).toFixed(precission)) * Math.pow(10, precission)
    if fr > 0
      fr = fr.toString().split(".")[0]
    else
      fr = new Array(precission + 1).join("0")
    sign + ((if j then i.substr(0, j) + thouSeparator else "")) + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSeparator) + ((if fr then decSeparator + fr else ""))
]
