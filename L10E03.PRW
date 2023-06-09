#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'REPORT.CH'

#DEFINE ROSA_PASTEL RGB(255,182,193)
#DEFINE AZUL_PASTEL RGB(128,206,255)

/*/{Protheus.doc} User Function MT120BRW
    Ponto de Entrada da Rotina MATA121 (Exerc�cio 03)
    @type  Function
    @author Edison Cake
    @since 06/04/2023
    /*/
User Function MT120BRW()
    
    aAdd(aRotina, {'Informa��es do Pedido', 'U_Relat()', 0, 6}) // Bot�o do Exerc�cio 03, com as informa��es isoladas de um pedido s�.
    aAdd(aRotina, {'Resumo dos Pedidos', 'U_Rel2()', 0, 6})     // Bot�o do Exerc�cio 05, com as informa��es detalhadas de todos os pedidos.

Return 

// Gerador do relat�rio do exerc�cio 03.
User Function Relat()
    local oRelatorio    := GetReport()
    oRelatorio:PrintDialog()
Return

Static Function GetReport()
    local cAlias    := GetNextAlias()
    local oRel      := TReport():New("TREPORT", "Relat�rio de Pedido de Compra",, {|oRel| GetInfo(oRel, cAlias)}, "Esse relat�rio imprimir� as informa��es do pedido de compra selecionado", .F.)
    local oSection1 := TRSection():New(oRel, "Informa��es do Pedido de Compra",,,,,,,,,, .T.)
    local oSection2 := TRSection():New(oSection1, "Conte�do do Pedido de Compra",,,,,,,,,, .T.)
    local oQuebra

    private cCodPed   := ""
    private cEmissao  := ""
    private cFornec   := ""
    private cLoja     := ""
    private cPagto    := ""

    private cProd     := ""
    private cDesc     := ""
    private cQtd      := ""
    private cPreco    := ""
    private cTotal    := ""

    //! New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)
    TRCell():New(oSection1, "PEDIDO", cAlias, "PEDIDO",, 20,, {|| Alltrim("Pedido: " + cCodPed)}, "LEFT", .T., "LEFT",,,,,, .T.)
    TRCell():New(oSection1, "EMISSAO", cAlias, "EMISSAO", PesqPict("SC7", "C7_EMISSAO"), 12,, {|| Alltrim(cEmissao)}, "CENTER", .T., "CENTER",,,,,, .T.)
    TRCell():New(oSection1, "FORNECEDOR", cAlias, "FORNECEDOR",, 10,, {|| Alltrim(cFornec)}, "LEFT", .T., "LEFT",,,,,, .T.)
    TRCell():New(oSection1, "LOJA", cAlias, "LOJA",, 4,, {|| Alltrim(cLoja)}, "LEFT", .T., "LEFT",,,,,, .T.)
    TRCell():New(oSection1, "PAGTO.", cAlias, "PAGTO.",, 10,, {|| Alltrim(cPagto)}, "LEFT", .T., "LEFT",,,,,, .T.)

    TRCell():New(oSection2, 'C7_PRODUTO', cAlias, 'CODIGO',, 8,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_DESCRI', cAlias, 'PRODUTO',, 50,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_QUANT', cAlias, 'QTD.',, 10,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_PRECO', cAlias, 'PRE�O',, 20,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'TOTAL', cAlias, 'TOTAL',, 20,,{|| alltrim(cTotal)}, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)

    // Quebra e totalizador do exerc�cio 04.
    oQuebra := TRBreak():New(oSection1, oSection1:Cell('PEDIDO'), "", .T.)
    TRFunction():New(oSection2:Cell('TOTAL'), 'VALTOT', 'SUM', oQuebra, 'VALOR TOTAL',,, .F., .F., .F.)
    
Return oRel

Static Function GetInfo(oRel, cAlias)
    local oSection1 := oRel:Section(1)
    local oSection2 := oSection1:Section(1)

    local cQuery  := GeraQuery()
    local nTot    := 0
    local cPedido := ""

    DbUseArea(.T., 'TOPCONN', TcGenQry(NIL, NIL, cQuery), cAlias, .T., .T.)
    Count TO nTot

    oRel:SetMeter(nTot)
    oRel:StartPage()

    (cAlias)->(DbGoTop())

    While (cAlias)->(!Eof())

        if alltrim(cPedido) <> Alltrim((cAlias)->(C7_NUM))
            if !Empty(cPedido)
                oSection2:Finish()
                oSection1:Finish()
                oRel:EndPage()
            endif
        
            oSection1:Init()

            cCodPed     := Alltrim((cAlias)->(C7_NUM))
            cEmissao    := DtoC(StoD((cAlias)->(C7_EMISSAO)))
            cFornec     := Alltrim((cAlias)->(C7_FORNECE))
            cLoja       := Alltrim((cAlias)->(C7_LOJA))
            cPagto      := Alltrim((cAlias)->(C7_COND))
            cPedido     := Alltrim((cAlias)->(C7_NUM))

            oSection1:PrintLine()

            oSection2:Init()
        endif

        oSection2:Cell('C7_PRODUTO'):SetValue((cAlias)->(C7_PRODUTO))
        oSection2:Cell('C7_DESCRI'):SetValue((cAlias)->(C7_DESCRI))
        oSection2:Cell('C7_QUANT'):SetValue((cAlias)->(C7_QUANT))
        oSection2:Cell('C7_PRECO'):SetValue((cAlias)->(C7_PRECO))
        // oSection2:Cell('C7_TOTAL'):SetValue((cAlias)->(C7_TOTAL))
        cTotal := cvaltochar((cAlias)->(C7_TOTAL))

        oSection2:PrintLine()

        (cAlias)->(DbSkip())
    End Do

    oSection1:Finish()
    oSection2:Finish()

    (cAlias)->(DbCloseArea())
    oRel:EndPage()
Return

Static Function GeraQuery()
    local cQuery := ""

    cQuery := "SELECT C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_COND, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL FROM " + RetSqlName("SC7") + " SC7 WHERE C7_NUM = '" + alltrim(SC7->C7_NUM) + "' AND D_E_L_E_T_ = ' '"

Return cQuery

// Exerc�cio 05: Criar um relat�rio que detalhe todos os pedidos com seus produtos, separados por pedidos.
User Function Rel2()
    local oRelatorio    := Repo2()
    oRelatorio:PrintDialog()
Return

Static Function Repo2()
    local cAlias    := GetNextAlias()
    local oRel      := TReport():New("TREPORT", "Relat�rio de Pedido de Compra",, {|oRel| Get2(oRel, cAlias)}, "Esse relat�rio imprimir� as informa��es de todos os pedidos de compra.", .F.)
    local oSection1 := TRSection():New(oRel, "Informa��es do Pedido de Compra",,,,,,,,,, .T.)
    local oSection2 := TRSection():New(oSection1, "Conte�do do Pedido de Compra",,,,,,,,,, .T.)
    local oQuebra

    private cCodPed   := ""
    private cEmissao  := ""
    private cFornec   := ""
    private cLoja     := ""
    private cPagto    := ""

    private cProd     := ""
    private cDesc     := ""
    private cQtd      := ""
    private cPreco    := ""
    private cTotal    := ""

    //! New(oParent, cName, cAlias, cTitle, cPicture, nSize, lPixel, bBlock, cAlign, lLineBreak, cHeaderAlign, lCellBreak, nColSpace, lAutoSize, nClrBack, nClrFore, lBold)
    TRCell():New(oSection1, "PEDIDO", cAlias, "PEDIDO",, 20,, {|| Alltrim("Pedido: " + cCodPed)}, "LEFT", .T., "LEFT",,,,AZUL_PASTEL,, .T.)
    TRCell():New(oSection1, "EMISSAO", cAlias, "EMISSAO", PesqPict("SC7", "C7_EMISSAO"), 12,, {|| Alltrim(cEmissao)}, "CENTER", .T., "CENTER",,,,AZUL_PASTEL,, .T.)
    TRCell():New(oSection1, "FORNECEDOR", cAlias, "FORNECEDOR",, 10,, {|| Alltrim(cFornec)}, "LEFT", .T., "LEFT",,,,AZUL_PASTEL,, .T.)
    TRCell():New(oSection1, "LOJA", cAlias, "LOJA",, 4,, {|| Alltrim(cLoja)}, "LEFT", .T., "LEFT",,,,AZUL_PASTEL,, .T.)
    TRCell():New(oSection1, "PAGTO.", cAlias, "PAGTO.",, 10,, {|| Alltrim(cPagto)}, "LEFT", .T., "LEFT",,,,AZUL_PASTEL,, .T.)

    TRCell():New(oSection2, 'C7_PRODUTO', cAlias, 'CODIGO',, 8,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_DESCRI', cAlias, 'PRODUTO',, 50,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_QUANT', cAlias, 'QTD.',, 10,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_PRECO', cAlias, 'PRE�O',, 20,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)
    TRCell():New(oSection2, 'C7_TOTAL', cTotal, 'TOTAL',, 20,,, 'LEFT', .T., 'LEFT',,,,ROSA_PASTEL,, .T.)

    oQuebra := TRBreak():New(oSection1, oSection1:Cell('PEDIDO'),, .T.)
    TRFunction():New(oSection2:Cell('C7_TOTAL'), 'VALTOT', 'SUM', oQuebra, 'VALOR TOTAL',,, .F., .F., .F.)
    
Return oRel

Static Function Get2(oRel, cAlias)
    local oSection1 := oRel:Section(1)
    local oSection2 := oSection1:Section(1)

    local cQuery    := Query2()
    local nTot      := 0
    local cUltimo   := ""

    DbUseArea(.T., 'TOPCONN', TcGenQry(NIL, NIL, cQuery), cAlias, .T., .T.)
    Count TO nTot

    oRel:SetMeter(nTot)
    oRel:StartPage()

    (cAlias)->(DbGoTop())

    While (cAlias)->(!Eof())

        if cUltimo <> Alltrim((cAlias)->(C7_NUM))
            if !Empty(cUltimo)
                oSection1:Finish()
                oSection2:Finish()
                oRel:EndPage()
            endif

            oSection1:Init()

            cCodPed     := Alltrim((cAlias)->(C7_NUM))
            cEmissao    := DtoC(StoD((cAlias)->(C7_EMISSAO)))
            cFornec     := Alltrim((cAlias)->(C7_FORNECE))
            cLoja       := Alltrim((cAlias)->(C7_LOJA))
            cPagto      := Alltrim((cAlias)->(C7_COND))

            cUltimo := Alltrim((cAlias)->(C7_NUM))

            oSection1:PrintLine()
            oSection2:Init()

        endif 

        oSection2:Cell('C7_PRODUTO'):SetValue((cAlias)->(C7_PRODUTO))
        oSection2:Cell('C7_DESCRI'):SetValue((cAlias)->(C7_DESCRI))
        oSection2:Cell('C7_QUANT'):SetValue((cAlias)->(C7_QUANT))
        oSection2:Cell('C7_PRECO'):SetValue((cAlias)->(C7_PRECO))
        oSection2:Cell('C7_TOTAL'):SetValue((cAlias)->(C7_TOTAL))

        oSection2:PrintLine()
        oRel:IncMeter()

        (cAlias)->(DbSkip())
    End Do

    oSection1:Finish()
    oSection2:Finish()

    (cAlias)->(DbCloseArea())
    oRel:EndPage()
Return

Static Function Query2()
    local cQuery := ""

    cQuery := "SELECT C7_NUM, C7_EMISSAO, C7_FORNECE, C7_LOJA, C7_COND, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_PRECO, C7_TOTAL FROM " + RetSqlName("SC7") + " SC7 WHERE D_E_L_E_T_ = ' '"

Return cQuery
