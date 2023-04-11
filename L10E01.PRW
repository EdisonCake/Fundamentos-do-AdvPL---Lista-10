#INCLUDE 'TOTVS.CH'
#INCLUDE 'REPORT.CH'

/*/{Protheus.doc} User Function L10E01
    Função para impressão do relatório de produtos da tabela SB1 através de TReport.
    @type  Function
    @author Edison Cake
    @since 05/04/2023
    /*/
User Function L10E01()
    local oRelatorio := GetReport()

    oRelatorio:PrintDialog()
Return 

Static Function GetReport()
    local cAlias := GetNextAlias()
    local oRel
    local oSection

    oRel := TReport():New("TREPORT", "Relatório de Produtos",, {|oRel| Imprime(oRel, cAlias)}, "Relatório de produtos.", .F.)

    oSection := TRSection():New(oRel, "Cadastro de Produtos")

    TRCell():New(oSection, "B1_COD", "SB1", "CODIGO", /* cPicture */, 8, /* lPixel */, /* bBlock */, "CENTER", .T., "CENTER", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
    TRCell():New(oSection, "B1_DESC", "SB1", "DESCRICAO", /* cPicture */, 20, /* lPixel */, /* bBlock */, "LEFT", .T., "LEFT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
    TRCell():New(oSection, "B1_UM", "SB1", "U.M.", /* cPicture */, 4, /* lPixel */, /* bBlock */, "CENTER", .T., "CENTER", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
    TRCell():New(oSection, "B1_PRV1", "SB1", "PREÇO", /* cPicture */, 10, /* lPixel */, /* bBlock */, "RIGHT", .T., "RIGHT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
    TRCell():New(oSection, "B1_LOCPAD", "SB1", "ARMAZÉM", /* cPicture */, 7, /* lPixel */, /* bBlock */, "CENTER", .T., "CENTER", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
    
Return oRel

Static Function Imprime(oRel, cAlias)
    local oSection  := oRel:Section(1)
    local nTotReg   := 0
    local cQuery    := GeraQuery()

    DbUseArea(.T., "TOPCONN", TCGENQRY( NIL, NIL, cQuery ), cAlias, .T., .T.)
    Count TO nTotReg

    oRel:SetMeter(nTotReg)
    oRel:SetTitle("Relatório de Produtos")

    oRel:StartPage()
    oSection:Init()

    (cAlias)->(DbGoTop())

    While (cAlias)->(!Eof())
        if oRel:Cancel()
            Exit
        endif

        oSection:Cell("B1_COD"):SetValue((cAlias)->(B1_COD))
        oSection:Cell("B1_DESC"):SetValue((cAlias)->(B1_DESC))
        oSection:Cell("B1_UM"):SetValue((cAlias)->(B1_UM))
        oSection:Cell("B1_PRV1"):SetValue((cAlias)->(B1_PRV1))
        oSection:Cell("B1_LOCPAD"):SetValue((cAlias)->(B1_LOCPAD))

        oSection:PrintLine()
        oRel:IncMeter()
        oRel:ThinLine()

        (cAlias)->(DbSkip())
    End Do

    oSection:Finish()

    oRel:EndPage()
Return

Static Function GeraQuery()
    local cQuery := ""
    
    cQuery := "SELECT B1_COD, B1_DESC, B1_UM, B1_PRV1, B1_LOCPAD FROM " + RetSqlName("SB1") + " SB1 WHERE D_E_L_E_T_ = ' '"

Return cQuery
