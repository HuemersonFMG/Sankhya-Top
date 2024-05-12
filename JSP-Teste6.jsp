<gadget >
    <prompt-parameters>
      <parameter  id="CODEMP" description="Empresa" metadata="integer" required="false" keep-last="true" keep-date="false" show-inactives="false" label="CODEMP : Número Inteiro" order="0"/>
      <parameter  id="PERIODO" description="Período:" metadata="datePeriod" required="false" keep-last="true" keep-date="false" show-inactives="false" label="PERIODO : Período" order="1"/>
      <parameter  id="PROJETO" description="Projeto" metadata="multiList:Text" listType="sql" required="false" keep-last="true" keep-date="false" show-inactives="false" label="PROJETO : multiList:Text" order="2">
        <expression type="SQL">
          <![CDATA[

          SELECT
           DISTINCT CAB.CODPROJ AS VALUE,
           PRJ.CODPROJ || ' - '|| PRJ.IDENTIFICACAO
        AS LABEL
            FROM TCSPRJ PRJ, TGFCAB CAB
            WHERE PRJ.CODPROJ = CAB.CODPROJ
        ORDER BY 1

        ]]>
        </expression>
      </parameter>
    </prompt-parameters>
    <level id="06V" description="Relatorio 020">
      <args>
        <arg  id="APELIDO" type="text" label="APELIDO : Texto"/>
      </args>
      <container orientacao="V" tamanhoRelativo="100">
        <container orientacao="V" tamanhoRelativo="190">
          <grid id="grd_06X" useNewGrid="S">
            <title>
              <![CDATA[RELATORIO 020 DINAMICO]]>
            </title>
            <expression type="sql" data-source="MGEDS">
              <![CDATA[SELECT V.SEQUENCIA, CAB.CODEMP, CAB.CODPROJ,
      CASE WHEN CAB.TIPMOV = 'V' THEN (V.NUNOTAORIG) ELSE (CAB.NUNOTA) END AS NOTA_PEDIDO,

      CASE CAB.CODTIPOPER
          WHEN 1000 THEN 'MG COM EST. BAS' WHEN 1001 THEN 'MG V. FUTURA BAS' WHEN 1002 THEN 'MG SEM EST BAS' WHEN 1003 THEN 'MG BONIF. BAS'
          WHEN 1005 THEN 'RJ COM EST. BAS' WHEN 1006 THEN 'RJ SEM EST. BAS' WHEN 1007 THEN 'RJ V. FUTURA BAS' WHEN 1008 THEN 'RJ BONIF. BAS'
          WHEN 1100 THEN 'VENDA NFE' WHEN 1111 THEN 'SF. ENT. FUTURA' WHEN 1117 THEN 'V. BONIFICAÇÃO' WHEN 1124 THEN 'OUTRAS SAIDAS BRINDES' WHEN 1118 THEN 'V. CONTA/ORDEM'
          ELSE 'OUTROS' END AS CODTIPOPER,

      PAR.RAZAOSOCIAL, PRO.DESCRPROD,
      (SELECT SUM(NVL(TGFPRO.PESOBRUTO,0) * TGFITE.QTDNEG) FROM TGFITE
          INNER JOIN TGFPRO ON TGFITE.CODPROD = TGFPRO.CODPROD
          WHERE TGFITE.NUNOTA = CAB.NUNOTA AND TGFITE.USOPROD = 'D') PESO,
       CAB.DTNEG, CAB.DTPREVENT DT_TRANSF,

      (SELECT (CASE WHEN CAB.CODTIPOPER = 900 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'ORC PLANEJADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN (MAX(LIB.REPROVADO) IS NULL OR MAX(LIB.REPROVADO) = 'N') AND MAX(LIB.ORDEM) = '1' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'CRÉDITO' ELSE
          (CASE WHEN MAX(LIB.REPROVADO) = 'S' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'REPROVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) <> MAX(LIB.VLRATUAL) THEN 'RESERVADO OP' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          'COM ERRO' END) END) END) END) END) END) END) END) END) END) END) END) AS LABEL
              FROM TSILIB LIB INNER JOIN TGFCAB C ON CAB.NUNOTA = LIB.NUCHAVE WHERE C.CODEMP = CAB.CODEMP) FIN_PCP,

      CAB.QTDVOL, OPTION_LABEL('TGFCAB','MODENTREGA',CAB.MODENTREGA) MODENTREGA, CAB.AD_VALOR_FRETE,
      (SELECT CID.NOMECID FROM TGFCAB CCID
          LEFT JOIN TGFCTT CTT ON CTT.CODPARC = CCID.CODPARC AND CTT.CODCONTATO = CCID.CODCONTATO
          INNER JOIN TGFPAR PCID ON PCID.CODPARC = CCID.CODPARC
          INNER JOIN TSICID CID ON CID.CODCID = CASE WHEN CTT.CODCID IS NULL OR  CTT.CODBAI IS NULL OR CTT.CODEND IS NULL THEN  PCID.CODCID ELSE CTT.CODCID END
      WHERE CCID.NUNOTA = CAB.NUNOTA AND CCID.CODEMP = CAB.CODEMP) AS NOMECID,
      UFS.UF UFDESTINO,  CAB.VLRNOTA, CAB.AD_MARGEMMEDIA, VEN.APELIDO VENDEDOR, USU.NOMEUSU, CAB.CODTIPVENDA, TV.DESCRTIPVENDA,

      NVL(TO_CHAR(DTPREVENT-1),'') DTFAB,  CAB.DTPREVENT

      FROM TGFCAB CAB
      INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
      INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA AND ITE.USOPROD ='V'
      INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
      INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
      INNER JOIN TGFITE ITEPA ON ITEPA.NUNOTA = CAB.NUNOTA AND ITEPA.USOPROD='V'
      INNER JOIN TGFLOC LOC ON ITEPA.CODLOCALORIG = LOC.CODLOCAL
      INNER JOIN TGFTPV TPV ON TPV.CODTIPVENDA = CAB.CODTIPVENDA AND CAB.DHTIPVENDA = TPV.DHALTER
      INNER JOIN TSICID CID ON CID.CODCID = PAR.CODCID
      INNER JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
      INNER JOIN TSIUSU USU ON USU.CODUSU = STP_GET_CODUSULOGADO
      INNER JOIN TGFVAR V   ON CAB.NUNOTA = V.NUNOTA
      INNER JOIN TGFTPV TV ON TV.CODTIPVENDA = CAB.CODTIPVENDA

          WHERE CAB.CODEMP = :CODEMP AND CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN AND CAB.CODPROJ = ANY :PROJETO /*Incolletion*/
          AND (CAB.CODTIPOPER IN (1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008) AND CAB.PENDENTE <> 'N' OR CAB.CODTIPOPER IN (1100, 1111, 1124, 1118))
          AND CAB.CODPROJ IN (10001001, 10001002, 10001003)
          AND (CAB.STATUSNFE IS NULL OR CAB.STATUSNFE <> 'A')
          AND V.NUNOTA <> V.NUNOTAORIG
          AND V.SEQUENCIA = 1

          ORDER BY 22 ASC]]>
            </expression>
            <metadata>
              <field name="SEQUENCIA" label="SEQUENCIA" type="I" visible="true" useFooter="false"></field>
              <field name="CODEMP" label="EMP" type="I" visible="true" useFooter="false"></field>
              <field name="CODPROJ" label="MODELO" type="I" visible="true" useFooter="false"></field>
              <field name="NOTA_PEDIDO" label="NOTA_PEDIDO" type="I" visible="true" useFooter="false"></field>
              <field name="CODTIPOPER" label="CODTIPOPER" type="S" visible="true" useFooter="false"></field>
              <field name="RAZAOSOCIAL" label="RAZAOSOCIAL" type="S" visible="true" useFooter="false"></field>
              <field name="DESCRPROD" label="DESCRPROD" type="S" visible="true" useFooter="false"></field>
              <field name="PESO" label="PESO" type="I" visible="true" useFooter="false"></field>
              <field name="DTNEG" label="DTNEG" type="D" visible="true" useFooter="false"></field>
              <field name="DT_TRANSF" label="DT_TRANSF" type="D" visible="true" useFooter="false"></field>
              <field name="FIN_PCP" label="STATUS" type="S" visible="true" useFooter="false"></field>
              <field name="QTDVOL" label="QTDVOL" type="I" visible="true" useFooter="false"></field>
              <field name="MODENTREGA" label="MODENTREGA" type="S" visible="true" useFooter="false"></field>
              <field name="AD_VALOR_FRETE" label="FRETE" type="F" visible="true" useFooter="false"></field>
              <field name="NOMECID" label="NOMECID" type="S" visible="true" useFooter="false"></field>
              <field name="UFDESTINO" label="UFDESTINO" type="S" visible="true" useFooter="false"></field>
              <field name="VLRNOTA" label="VLRNOTA" type="F" visible="true" useFooter="false"></field>
              <field name="AD_MARGEMMEDIA" label="MKP" type="F" visible="true" useFooter="false"></field>
              <field name="VENDEDOR" label="VENDEDOR" type="S" visible="true" useFooter="false"></field>
              <field name="NOMEUSU" label="NOMEUSU" type="S" visible="true" useFooter="false"></field>
              <field name="CODTIPVENDA" label="CODTIPVENDA" type="I" visible="true" useFooter="false"></field>
              <field name="DESCRTIPVENDA" label="DESCRTIPVENDA" type="S" visible="true" useFooter="false"></field>
              <field name="DTFAB" label="DTFAB" type="S" visible="true" useFooter="false"></field>
              <field name="DTPREVENT" label="ENTREGA" type="D" visible="true" useFooter="false"></field>
            </metadata>
            <on-click  navigate-to="047"/>
          </grid>
        </container>
        <container orientacao="V" tamanhoRelativo="10">
          <simple-value id="svl_09O">
            <value-expression>
              <![CDATA[<table border="0" style="width: 100%; background-color: #B0E0E6;"><tbody><tr><td style="width: 100%; text-align: center;"><span style='font-size: 18px;'><strong>Tabela dinâmica >></strong></span></td></tr></tbody></table>]]>
            </value-expression>
            <on-click  navigate-to="0JJ"/>
          </simple-value>
        </container>
      </container>
    </level>
    <level id="047" description="Gráfico">
      <args >
        <arg id="APELIDO" type="text" label="APELIDO : Texto"/>
      </args>
      <container orientacao="V" tamanhoRelativo="100">
        <chart id="cht_06F" type="column">
          <title>
            <![CDATA[GRÁFICO - RELATÓRIO 020]]>
          </title>
          <expression type="sql" data-source="MGEDS">
            <![CDATA[SELECT V.SEQUENCIA, CAB.CODEMP, CAB.NUNOTA NUNOTA_B, CAB.CODPROJ,
      CASE WHEN CAB.TIPMOV = 'V' THEN (V.NUNOTAORIG) ELSE (CAB.NUNOTA) END AS NUNOTA,

      CASE CAB.CODTIPOPER
          WHEN 1000 THEN 'PED. RESERVA' WHEN 1001 THEN 'VENDA FUTURA' WHEN 1002 THEN 'PED. SEM EST' WHEN 1003 THEN 'BONIFICAÇÃO'
          WHEN 1005 THEN 'RJ PED. RESERVA' WHEN 1006 THEN 'RJ VENDA FUTURA' WHEN 1007 THEN 'RJ PED. SEM EST' WHEN 1008 THEN 'RJ BONIFICAÇÃO'
          WHEN 1100 THEN 'VENDA NFE' WHEN 1111 THEN 'V. FUTURA' WHEN 1117 THEN 'V. BONIFICAÇÃO' WHEN 1124 THEN 'O. S. BRINDES' WHEN 1118 THEN 'V. CONTA/ORDEM'
          ELSE 'OUTROS' END AS CODTIPOPER,

      PAR.RAZAOSOCIAL, PRO.DESCRPROD,
      (SELECT SUM(NVL(TGFPRO.PESOBRUTO,0) * TGFITE.QTDNEG) FROM TGFITE
          INNER JOIN TGFPRO ON TGFITE.CODPROD = TGFPRO.CODPROD
          WHERE TGFITE.NUNOTA = CAB.NUNOTA AND TGFITE.USOPROD = 'D') PESO,
       CAB.DTNEG, CAB.DTPREVENT DT_TRANSF,

      (SELECT (CASE WHEN CAB.CODTIPOPER = 900 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'ORC PLANEJADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '1' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'CRÉDITO' ELSE
          (CASE WHEN MAX(LIB.REPROVADO) = 'S' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'REPROVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) <> MAX(LIB.VLRATUAL) THEN 'RESERVADO OP' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          'COM ERRO' END) END) END) END) END) END) END) END) END) END) END) END) AS LABEL
              FROM TSILIB LIB INNER JOIN TGFCAB C ON CAB.NUNOTA = LIB.NUCHAVE WHERE C.CODEMP = CAB.CODEMP) FIN_PCP,

      CAB.QTDVOL, OPTION_LABEL('TGFCAB','MODENTREGA',CAB.MODENTREGA) MODENTREGA, CAB.AD_VALOR_FRETE,
      (SELECT CID.NOMECID FROM TGFCAB CCID
          LEFT JOIN TGFCTT CTT ON CTT.CODPARC = CCID.CODPARC AND CTT.CODCONTATO = CCID.CODCONTATO
          INNER JOIN TGFPAR PCID ON PCID.CODPARC = CCID.CODPARC
          INNER JOIN TSICID CID ON CID.CODCID = CASE WHEN CTT.CODCID IS NULL OR  CTT.CODBAI IS NULL OR CTT.CODEND IS NULL THEN  PCID.CODCID ELSE CTT.CODCID END
      WHERE CCID.NUNOTA = CAB.NUNOTA AND CCID.CODEMP = CAB.CODEMP) AS NOMECID,
      UFS.UF UFDESTINO,  CAB.VLRNOTA, CAB.AD_MARGEMMEDIA, VEN.APELIDO VENDEDOR, USU.NOMEUSU,

      NVL(TO_CHAR(DTPREVENT-1),'') DTFAB,  CAB.DTPREVENT

      FROM TGFCAB CAB
      INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
      INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA AND ITE.USOPROD ='V'
      INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
      INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
      INNER JOIN TGFITE ITEPA ON ITEPA.NUNOTA = CAB.NUNOTA AND ITEPA.USOPROD='V'
      INNER JOIN TGFLOC LOC ON ITEPA.CODLOCALORIG = LOC.CODLOCAL
      INNER JOIN TGFTPV TPV ON TPV.CODTIPVENDA = CAB.CODTIPVENDA AND CAB.DHTIPVENDA = TPV.DHALTER
      INNER JOIN TSICID CID ON CID.CODCID = PAR.CODCID
      INNER JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
      INNER JOIN TSIUSU USU ON USU.CODUSU = STP_GET_CODUSULOGADO
      INNER JOIN TGFVAR V   ON CAB.NUNOTA = V.NUNOTA

          WHERE CAB.CODEMP = :CODEMP AND CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN AND CAB.CODPROJ = ANY :PROJETO /*Incolletion*/
          AND (CAB.CODTIPOPER IN (1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008) AND CAB.PENDENTE <> 'N' OR CAB.CODTIPOPER IN (1100, 1111, 1124, 1118))
          AND (ITE.CODLOCALORIG) IN (1000000 ,1010000, 1020000)
          AND (CAB.STATUSNFE IS NULL OR CAB.STATUSNFE <> 'A')
          AND V.NUNOTA <> V.NUNOTAORIG
          AND V.SEQUENCIA = 1

          ORDER BY CAB.CODEMP, DTPREVENT, CAB.NUNOTA ASC]]>
          </expression>
          <metadata>
            <field name="SEQUENCIA" label="SEQUENCIA" type="I" visible="true" useFooter="false"></field>
            <field name="CODEMP" label="CODEMP" type="I" visible="true" useFooter="false"></field>
            <field name="NUNOTA_B" label="NUNOTA_B" type="I" visible="true" useFooter="false"></field>
            <field name="CODPROJ" label="CODPROJ" type="I" visible="true" useFooter="false"></field>
            <field name="NUNOTA" label="NUNOTA" type="I" visible="true" useFooter="false"></field>
            <field name="CODTIPOPER" label="CODTIPOPER" type="S" visible="true" useFooter="false"></field>
            <field name="RAZAOSOCIAL" label="RAZAOSOCIAL" type="S" visible="true" useFooter="false"></field>
            <field name="DESCRPROD" label="DESCRPROD" type="S" visible="true" useFooter="false"></field>
            <field name="PESO" label="PESO" type="I" visible="true" useFooter="false"></field>
            <field name="DTNEG" label="DTNEG" type="D" visible="true" useFooter="false"></field>
            <field name="DT_TRANSF" label="DT_TRANSF" type="D" visible="true" useFooter="false"></field>
            <field name="FIN_PCP" label="FIN_PCP" type="S" visible="true" useFooter="false"></field>
            <field name="QTDVOL" label="QTDVOL" type="I" visible="true" useFooter="false"></field>
            <field name="MODENTREGA" label="MODENTREGA" type="S" visible="true" useFooter="false"></field>
            <field name="AD_VALOR_FRETE" label="AD_VALOR_FRETE" type="F" visible="true" useFooter="false"></field>
            <field name="NOMECID" label="NOMECID" type="S" visible="true" useFooter="false"></field>
            <field name="UFDESTINO" label="UFDESTINO" type="S" visible="true" useFooter="false"></field>
            <field name="VLRNOTA" label="VLRNOTA" type="F" visible="true" useFooter="false"></field>
            <field name="AD_MARGEMMEDIA" label="AD_MARGEMMEDIA" type="F" visible="true" useFooter="false"></field>
            <field name="VENDEDOR" label="VENDEDOR" type="S" visible="true" useFooter="false"></field>
            <field name="NOMEUSU" label="NOMEUSU" type="S" visible="true" useFooter="false"></field>
            <field name="DTFAB" label="DTFAB" type="S" visible="true" useFooter="false"></field>
            <field name="DTPREVENT" label="DTPREVENT" type="D" visible="true" useFooter="false"></field>
          </metadata>
          <horizontal-axis>
            <category field="undefined" rotation="-63" dropLabel="false">
              <initView value="first"></initView>
            </category>
          </horizontal-axis>
          <series>
            <set type="stacked">
              <serie type="column">
                <xField>VENDEDOR</xField>
                <yField>QTDVOL</yField>
                <display>
                  <![CDATA[QTD X VEND]]>
                </display>
                <on-click-launcher  resource-id="br.com.sankhya.com.mov.CentralNotas">
                  <NUNOTA>$NUNOTA</NUNOTA>
                </on-click-launcher>
              </serie>
            </set>
            <serie type="line">
              <xField>DTFAB</xField>
              <yField>DTPREVENT</yField>
              <display>
                <![CDATA[ENTREGA]]>
              </display>
            </serie>
          </series>
          <legend position="bottom" direction="h"></legend>
        </chart>
      </container>
    </level>
    <level id="0JJ" description="020 D TABELA D">
      <container orientacao="V" tamanhoRelativo="100">
        <pivot-table id="pvt_0JL">
          <expression type="sql" data-source="MGEDS">
            <![CDATA[SELECT V.SEQUENCIA, CAB.CODEMP, CAB.CODPROJ,
      CASE WHEN CAB.TIPMOV = 'V' THEN (V.NUNOTAORIG) ELSE (CAB.NUNOTA) END AS NOTA_PEDIDO,

      CASE CAB.CODTIPOPER
          WHEN 1000 THEN 'MG COM EST. BAS' WHEN 1001 THEN 'MG V. FUTURA BAS' WHEN 1002 THEN 'MG SEM EST BAS' WHEN 1003 THEN 'MG BONIF. BAS'
          WHEN 1005 THEN 'RJ COM EST. BAS' WHEN 1006 THEN 'RJ SEM EST. BAS' WHEN 1007 THEN 'RJ V. FUTURA BAS' WHEN 1008 THEN 'RJ BONIF. BAS'
          WHEN 1100 THEN 'VENDA NFE' WHEN 1111 THEN 'SF. ENT. FUTURA' WHEN 1117 THEN 'V. BONIFICAÇÃO' WHEN 1124 THEN 'OUTRAS SAIDAS BRINDES' WHEN 1118 THEN 'V. CONTA/ORDEM'
          ELSE 'OUTROS' END AS CODTIPOPER,

      PAR.RAZAOSOCIAL, PRO.DESCRPROD,
      (SELECT SUM(NVL(TGFPRO.PESOBRUTO,0) * TGFITE.QTDNEG) FROM TGFITE
          INNER JOIN TGFPRO ON TGFITE.CODPROD = TGFPRO.CODPROD
          WHERE TGFITE.NUNOTA = CAB.NUNOTA AND TGFITE.USOPROD = 'D') PESO,
       CAB.DTNEG, CAB.DTPREVENT DT_TRANSF,

      (SELECT (CASE WHEN CAB.CODTIPOPER = 900 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'ORC PLANEJADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) IS NULL AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' AND CAB.APROVADO = 'N' THEN 'PLANEJADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '1' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'CRÉDITO' ELSE
          (CASE WHEN MAX(LIB.REPROVADO) = 'S' AND MAX(LIB.VLRLIBERADO) = 0 THEN 'REPROVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) <> MAX(LIB.VLRATUAL) THEN 'RESERVADO OP' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO'  ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN MAX(LIB.ORDEM) = '2' AND MAX(LIB.VLRLIBERADO) = MAX(LIB.VLRATUAL) AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'L' AND CAB.PENDENTE = 'S' THEN 'RESERVADO' ELSE
          (CASE WHEN CAB.CODTIPOPER = 1003 AND CAB.STATUSNOTA = 'A' AND CAB.PENDENTE = 'N' THEN 'TRANSPORTE' ELSE
          'COM ERRO' END) END) END) END) END) END) END) END) END) END) END) END) AS LABEL
              FROM TSILIB LIB INNER JOIN TGFCAB C ON CAB.NUNOTA = LIB.NUCHAVE WHERE C.CODEMP = CAB.CODEMP) FIN_PCP,

      CAB.QTDVOL, OPTION_LABEL('TGFCAB','MODENTREGA',CAB.MODENTREGA) MODENTREGA, CAB.AD_VALOR_FRETE,
      (SELECT CID.NOMECID FROM TGFCAB CCID
          LEFT JOIN TGFCTT CTT ON CTT.CODPARC = CCID.CODPARC AND CTT.CODCONTATO = CCID.CODCONTATO
          INNER JOIN TGFPAR PCID ON PCID.CODPARC = CCID.CODPARC
          INNER JOIN TSICID CID ON CID.CODCID = CASE WHEN CTT.CODCID IS NULL OR  CTT.CODBAI IS NULL OR CTT.CODEND IS NULL THEN  PCID.CODCID ELSE CTT.CODCID END
      WHERE CCID.NUNOTA = CAB.NUNOTA AND CCID.CODEMP = CAB.CODEMP) AS NOMECID,
      UFS.UF UFDESTINO,  CAB.VLRNOTA, CAB.AD_MARGEMMEDIA, VEN.APELIDO VENDEDOR, USU.NOMEUSU,

      NVL(TO_CHAR(DTPREVENT-1),'') DTFAB,  CAB.DTPREVENT

      FROM TGFCAB CAB
      INNER JOIN TGFPAR PAR ON CAB.CODPARC = PAR.CODPARC
      INNER JOIN TGFITE ITE ON ITE.NUNOTA = CAB.NUNOTA AND ITE.USOPROD ='V'
      INNER JOIN TGFPRO PRO ON PRO.CODPROD = ITE.CODPROD
      INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
      INNER JOIN TGFITE ITEPA ON ITEPA.NUNOTA = CAB.NUNOTA AND ITEPA.USOPROD='V'
      INNER JOIN TGFLOC LOC ON ITEPA.CODLOCALORIG = LOC.CODLOCAL
      INNER JOIN TGFTPV TPV ON TPV.CODTIPVENDA = CAB.CODTIPVENDA AND CAB.DHTIPVENDA = TPV.DHALTER
      INNER JOIN TSICID CID ON CID.CODCID = PAR.CODCID
      INNER JOIN TSIUFS UFS ON UFS.CODUF = CID.UF
      INNER JOIN TSIUSU USU ON USU.CODUSU = STP_GET_CODUSULOGADO
      INNER JOIN TGFVAR V   ON CAB.NUNOTA = V.NUNOTA

          WHERE CAB.CODEMP = :CODEMP AND CAB.DTNEG BETWEEN :PERIODO.INI AND :PERIODO.FIN AND CAB.CODPROJ = ANY :PROJETO /*Incolletion*/
          AND (CAB.CODTIPOPER IN (1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008) AND CAB.PENDENTE <> 'N' OR CAB.CODTIPOPER IN (1100, 1111, 1124, 1118))
          AND (ITE.CODLOCALORIG) IN (1000000 ,1010000, 1020000)
          AND (CAB.STATUSNFE IS NULL OR CAB.STATUSNFE <> 'A')
          AND V.NUNOTA <> V.NUNOTAORIG
          AND V.SEQUENCIA = 1

          ORDER BY 22 ASC]]>
          </expression>
          <metadata>
            <field name="SEQUENCIA" label="SEQUENCIA" type="I" visible="true" useFooter="false"></field>
            <field name="CODEMP" label="CODEMP" type="I" visible="true" useFooter="false"></field>
            <field name="CODPROJ" label="CODPROJ" type="I" visible="true" useFooter="false"></field>
            <field name="NOTA_PEDIDO" label="NOTA_PEDIDO" type="I" visible="true" useFooter="false"></field>
            <field name="CODTIPOPER" label="CODTIPOPER" type="S" visible="true" useFooter="false"></field>
            <field name="RAZAOSOCIAL" label="RAZAOSOCIAL" type="S" visible="true" useFooter="false"></field>
            <field name="DESCRPROD" label="DESCRPROD" type="S" visible="true" useFooter="false"></field>
            <field name="PESO" label="PESO" type="I" visible="true" useFooter="false"></field>
            <field name="DTNEG" label="DTNEG" type="D" visible="true" useFooter="false"></field>
            <field name="DT_TRANSF" label="DT_TRANSF" type="D" visible="true" useFooter="false"></field>
            <field name="FIN_PCP" label="FIN_PCP" type="S" visible="true" useFooter="false"></field>
            <field name="QTDVOL" label="QTDVOL" type="I" visible="true" useFooter="false"></field>
            <field name="MODENTREGA" label="MODENTREGA" type="S" visible="true" useFooter="false"></field>
            <field name="AD_VALOR_FRETE" label="AD_VALOR_FRETE" type="F" visible="true" useFooter="false"></field>
            <field name="NOMECID" label="NOMECID" type="S" visible="true" useFooter="false"></field>
            <field name="UFDESTINO" label="UFDESTINO" type="S" visible="true" useFooter="false"></field>
            <field name="VLRNOTA" label="VLRNOTA" type="F" visible="true" useFooter="false"></field>
            <field name="AD_MARGEMMEDIA" label="AD_MARGEMMEDIA" type="F" visible="true" useFooter="false"></field>
            <field name="VENDEDOR" label="VENDEDOR" type="S" visible="true" useFooter="false"></field>
            <field name="NOMEUSU" label="NOMEUSU" type="S" visible="true" useFooter="false"></field>
            <field name="DTFAB" label="DTFAB" type="S" visible="true" useFooter="false"></field>
            <field name="DTPREVENT" label="DTPREVENT" type="D" visible="true" useFooter="false"></field>
          </metadata>
          <initial>
            <column-ini>DTPREVENT</column-ini>
            <line-ini>NOTA_PEDIDO</line-ini>
            <rendererName-ini>TABELA</rendererName-ini>
            <vals-ini>VLRNOTA</vals-ini>
          </initial>
        </pivot-table>
      </container>
    </level>
  </gadget>