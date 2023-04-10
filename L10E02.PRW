#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'REPORT.CH'

/*/{Protheus.doc} User Function L10E02
    Browse de cadastro de Fornecedores com botão adicional de relatório.
    @type  Function
    @author user
    @since 06/04/2023
    /*/
User Function L10E02()
    local cAlias    := 'SA2'
    local cTitle    := "Cadastro de Fornecedores"
    local oBrowse   := FWMBrowse():New()

    oBrowse:SetAlias(cAlias)
    oBrowse:SetDescription(cTitle)
    oBrowse:DisableReport()
    oBrowse:DisableDetails()

    oBrowse:AddButton("Imprimir Informações", {|| PrintForn()})

    oBrowse:Activate()
Return 

Static Function MenuDef()
    local aRotina := {}

    ADD OPTION aRotina TITLE "Visualizar"   ACTION 'VIEWDEF.L10E02' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Inserir"      ACTION 'VIEWDEF.L10E02' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION 'VIEWDEF.L10E02' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION 'VIEWDEF.L10E02' OPERATION 5 ACCESS 0

Return aRotina

Static Function ModelDef()
    local oModel    := MpFormModel():New("L10E02M")
    local oStruSA2  := FWFormStruct(1, "SA2")

    oModel:AddFields("SA2MASTER",, oStruSA2)
    oModel:SetDescription("Cadastro de Fornecedores")
    oModel:SetPrimaryKey({"A2_COD"})

Return oModel

Static Function ViewDef()
    local oModel    := FwLoadModel("L10E02")
    local oStruSA2  := FWFormStruct(2, "SA2")
    local oView     := FwFormView():New()

    oView:SetModel(oModel)
    oView:AddField("VIEW_SA2", oStruSA2, "SA2MASTER")
    oView:CreateHorizontalBox("FORNECEDORES", 100)
    oView:SetOwnerView("VIEW_SA2", "FORNECEDORES")
    oView:EnableTitleView("VIEW_SA2", "Cadastro de Fornecedores")

Return oView

// Função para impressão do relatório dos dados do fornecedor selecionado através do TReport.
Static Function PrintForn()
    local oRelatorio := GetReport()
    oRelatorio:PrintDialog()
Return

Static Function GetReport()
    local cAlias    := GetNextAlias()
    local oForn
    local oSection

    oForn       := TReport():New("TREPORT", "Informações do Fornecedor",, {|oForn| GetInfo(oForn, cAlias)}, "Informações do Fornecedor", .F.)
    oSection    := TRSection():New(oForn, "Informações do Fornecedor")

    TRCell():New(oSection, "A2_CGC", "SA2", "CPF/CNPJ", /* cPicture */, 20, /* lPixel */, /* bBlock */, "CENTER", .T., "CENTER", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)

    TRCell():New(oSection, "A2_NOME", "SA2", "NOME", /* cPicture */, 30, /* lPixel */, /* bBlock */, "LEFT", .T., "LEFT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)

    TRCell():New(oSection, "A2_END", "SA2", "ENDEREÇO", /* cPicture */, 30, /* lPixel */, /* bBlock */, "LEFT", .T., "LEFT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)

    TRCell():New(oSection, "A2_BAIRRO", "SA2", "BAIRRO", /* cPicture */, 30, /* lPixel */, /* bBlock */, "LEFT", .T., "LEFT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)

    TRCell():New(oSection, "A2_EST", "SA2", "ESTADO", /* cPicture */, 8, /* lPixel */, /* bBlock */, "LEFT", .T., "LEFT", /* lCellBreak */, /* nColSpace */, .T., /* Cor Funo */, /* Cor Front */, .T.)
Return oForn

Static Function GetInfo(oForn, cAlias)
    local oSection  := oForn:Section(1)
    local nTotal    := 0
    local cQuery    := GetSQL()

    DbUseArea(.T., "TOPCONN", TCGENQRY( NIL, NIL, cQuery ), cAlias, .T., .T.)
    Count TO nTotal

    oForn:SetMeter(nTotal)
    oForn:SetTitle("Informações do fornecedor")

    oForn:StartPage()
    oSection:Init()

    (cAlias)->(DbGoTop())

    While (cAlias)->(!EoF())

        oSection:Cell("A2_CGC"):SetValue((cAlias)->(A2_CGC))
        oSection:Cell("A2_NOME"):SetValue((cAlias)->(A2_NOME))
        oSection:Cell("A2_END"):SetValue((cAlias)->(A2_END))
        oSection:Cell("A2_BAIRRO"):SetValue((cAlias)->(A2_BAIRRO))
        oSection:Cell("A2_EST"):SetValue((cAlias)->(A2_EST))

        oSection:PrintLine()
        oForn:IncMeter()
        oForn:ThinLine()

        (cAlias)->(DbSkip())
    EndDo

    oSection:Finish()
    oForn:EndPage()

Return

Static Function GetSQL()
    local cQuery := ""

    cQuery := "SELECT A2_CGC, A2_NOME, A2_END, A2_BAIRRO, A2_EST FROM " + RetSqlName("SA2") + " SA2 WHERE A2_COD = '" + alltrim(SA2->A2_COD) + "' AND D_E_L_E_T_ = ' '"

Return cQuery
