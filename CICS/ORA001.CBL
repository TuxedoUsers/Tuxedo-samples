000100 ID DIVISION.                                                     00001000
000200 PROGRAM-ID. ORA001.                                              00002000
000300 AUTHOR.     DTS SOFTWARE.                                        00003000
000600*REMARKS.    ***************************************************  00004000
000700             * PROGRAMA PARA FAZER ACESSO A TABELA DE CLIENTES *  00005000
000800             ***************************************************  00006000
018500 ENVIRONMENT DIVISION.                                            00007000
018600 CONFIGURATION SECTION.                                           00008000
018700 SPECIAL-NAMES.                                                   00009000
018800     DECIMAL-POINT IS COMMA.                                      00010000
018900 DATA DIVISION.                                                   00011000
019000 WORKING-STORAGE SECTION.                                         00012000
019100 77  WS00-INICIO     PIC X(32) VALUE '*** INICIO DA WORKING *** '.00013000
       77  WS00-CODIGO     PIC 9(03) VALUE ZEROS.                       00014000
025600 77  WS00-COMMAREA   PIC X(01) VALUE SPACES.                      00015000
       77  WS00-TAM        PIC S9(04) COMP VALUE +27.                   00016000
035300                                                                  00017000
       01  WS01-FINAL      PIC X(50) VALUE                              00018000
           '*****   TRANSACAO DEMO ENCERRADA   *****'.                  00019000
                                                                        00020000
       01  WS01-REG.                                                    00021000
           05  WS01-SIGLA    PIC X(02) VALUE SPACES.                    00022000
           05  WS01-NOME-EST PIC X(25) VALUE SPACES.                    00023000
                                                                        00024000
045900 01  TAB-MSG.                                                     00025000
046000     03  FILLER      PIC X(60)       VALUE                        00026000
046100     '                   CONSULTA EFETUADA                     '. 00027000
046000     03  FILLER      PIC X(60)       VALUE                        00028000
046100     '                   INCLUSAO EFETUADA                     '. 00029000
046000     03  FILLER      PIC X(60)       VALUE                        00030000
046100     '                  ALTERACAO EFETUADA                     '. 00031000
046000     03  FILLER      PIC X(60)       VALUE                        00032000
046100     '                    DELECAO EFETUADA                     '. 00033000
046000     03  FILLER      PIC X(60)       VALUE                        00034000
046100     '                 CLIENTE NAO EXISTENTE                   '. 00035000
046000     03  FILLER      PIC X(60)       VALUE                        00036000
046100     '                 CLIENTE JA EXISTENTE                    '. 00037000
           03  FILLER.                                                  00038000
046000         05  FILLER      PIC X(08)   VALUE '  ERRO -'.            00039000
046100         05  TAB-ERR     PIC 9(04)  VALUE ZEROS.                  00040000
               05  FILLER      PIC X(49)   VALUE                        00041000
               ' NO ACESSO A TABELA. CONTATE O RESPONSAVEL   '.         00042000
           03  FILLER      PIC X(60)       VALUE                        00043000
           '                   OPCAO INVALIDA                        '. 00044000
046300                                                                  00045000
046400 01  TAB-MSG-RED     REDEFINES  TAB-MSG.                          00046000
046500     03  TAB-MENS    OCCURS  8                                    00047000
046600                     PIC X(60).                                   00048000
                                                                        00049000
           COPY ORAO02.                                                 00050000
                                                                        00051000
           COPY DFHAID.                                                 00052000
                                                                        00053000
           EXEC SQL INCLUDE CLIENTE END-EXEC.                           00054000
                                                                        00055000
           EXEC SQL INCLUDE SQLCA END-EXEC.                             00056000
                                                                        00057000
071200     EJECT                                                        00058000
124600 77  WS00-FIM        PIC X(32) VALUE '***  FIM DA WORKING  ***'.  00059000
124700     EJECT                                                        00060000
       LINKAGE SECTION.                                                 00061000
       01  DFHCOMMAREA     PIC X(01).                                   00062000
127900 PROCEDURE DIVISION.                                              00063000
128000 INICIO-00 SECTION.                                               00064000
                                                                        00065000
           EXEC CICS HANDLE CONDITION ERROR (600-00-RETURN) END-EXEC.   00066000
                                                                        00067000
           IF EIBCALEN  EQUAL ZEROS                                     00068000
              MOVE LOW-VALUES TO MAPA01O                                00069000
              GO TO 100-10-ENVIA-TELA                                   00070000
           ELSE                                                         00071000
              MOVE DFHCOMMAREA TO WS00-COMMAREA.                        00072000
                                                                        00073000
                                                                        00074000
           EXEC CICS RECEIVE MAP('MAPA01')                              00075000
                             MAPSET('ORA002')                           00076000
                             INTO(MAPA01I)                              00077000
           END-EXEC.                                                    00078000
                                                                        00079000
                                                                        00080000
           IF  EIBAID EQUAL DFHPF3                                      00081000
               PERFORM 600-00-RETURN                                    00082000
           ELSE                                                         00083000
               IF  EIBAID EQUAL DFHPF4                                  00084000
                   PERFORM 200-00-CONSULTA                              00085000
               ELSE                                                     00086000
                   IF  EIBAID EQUAL DFHPF5                              00087000
                       PERFORM 300-00-INCLUSAO                          00088000
                   ELSE                                                 00089000
                       IF  EIBAID EQUAL DFHPF6                          00090000
                           PERFORM 400-00-ALTERACAO                     00091000
                       ELSE                                             00092000
                           IF  EIBAID EQUAL DFHPF7                      00093000
                               PERFORM 500-00-DELECAO                   00094000
                           ELSE                                         00095000
                               MOVE TAB-MENS(8)    TO ERRMSGO.          00096000
                                                                        00097000
       100-10-ENVIA-TELA.                                               00098000
                                                                        00099000
           MOVE -1 TO CODIGOL.                                          00100000
                                                                        00101000
           EXEC CICS SEND MAP('MAPA01')                                 00102000
                          MAPSET('ORA002')                              00103000
                          FROM(MAPA01O)                                 00104000
                          CURSOR                                        00105000
                          ERASE                                         00106000
                          FREEKB                                        00107000
           END-EXEC.                                                    00108000
                                                                        00109000
           MOVE '1' TO WS00-COMMAREA.                                   00110000
                                                                        00111000
           EXEC CICS RETURN TRANSID('ORA0')                             00112000
                            COMMAREA(WS00-COMMAREA)                     00113000
                            LENGTH(1)                                   00114000
           END-EXEC.                                                    00115000
                                                                        00116000
       EJECT                                                            00117000
131000****************************************************************  00118000
131100*       ROTINA DE CONSULTA                                     *  00119000
131200****************************************************************  00120000
131300 200-00-CONSULTA SECTION.                                         00121000
131400                                                                  00122000
           MOVE CODIGOI TO CODIGO-CLI.                                  00123000
                                                                        00124000
           EXEC SQL SELECT CODIGO,                                      00125000
                           NOME,                                        00126000
                           ENDERECO,                                    00127000
                           CIDADE,                                      00128000
                           ESTADO,                                      00129000
                           CEP                                          00130000
                    INTO   :DCL-CLIENTE                                 00131000
                    FROM   CLIENTE                                      00132000
                    WHERE  CODIGO = :CODIGO-CLI                         00133000
           END-EXEC.                                                    00134000
133600                                                                  00135000
           IF  SQLCODE  EQUAL  ZEROS                                    00136000
               MOVE CODIGO-CLI   TO CODIGOO                             00137000
               MOVE NOME-CLI     TO NOMEO                               00138000
               MOVE ENDERECO-CLI TO ENDERECO                            00139000
               MOVE CIDADE-CLI   TO CIDADEO                             00140000
               MOVE ESTADO-CLI   TO ESTADOO                             00141000
               MOVE CEP-CLI      TO CEPO                                00142000
               MOVE TAB-MENS(01) TO ERRMSGO                             00143000
           ELSE                                                         00144000
               MOVE LOW-VALUES   TO MAPA01O                             00145000
               MOVE CODIGO-CLI   TO CODIGOO                             00146000
               MOVE SPACES       TO NOMEESTO                            00147000
               IF  SQLCODE  EQUAL  +100                                 00148000
                   MOVE TAB-MENS(05) TO ERRMSGO                         00149000
                   GO  TO  200-99-EXIT                                  00150000
               ELSE                                                     00151000
                   MOVE SQLCODE      TO TAB-ERR                         00152000
                   MOVE TAB-MENS(07) TO ERRMSGO                         00153000
                   GO  TO  200-99-EXIT.                                 00154000
                                                                        00155000
           EXEC CICS HANDLE CONDITION NOTFND (200-20-NAO-ENCONTROU)     00156000
           END-EXEC.                                                    00157000
                                                                        00158000
           MOVE  ESTADOI  TO  WS01-SIGLA.                               00159000
                                                                        00160000
           EXEC CICS READ DATASET('OR02FILE')                           00161000
                          INTO(WS01-REG)                                00162000
                          LENGTH(WS00-TAM)                              00163000
                          RIDFLD(WS01-SIGLA)                            00164000
           END-EXEC.                                                    00165000
                                                                        00166000
           MOVE  WS01-NOME-EST  TO  NOMEESTO.                           00167000
                                                                        00168000
           GO  TO  200-99-EXIT.                                         00169000
                                                                        00170000
       200-20-NAO-ENCONTROU.                                            00171000
                                                                        00172000
           MOVE  ALL '*' TO NOMEESTO.                                   00173000
                                                                        00174000
133700 200-99-EXIT.                                                     00175000
133800     EXIT.                                                        00176000
           EJECT                                                        00177000
131000****************************************************************  00178000
131100*       ROTINA DE INCLUSAO                                     *  00179000
131200****************************************************************  00180000
       300-00-INCLUSAO SECTION.                                         00181000
                                                                        00182000
           MOVE CODIGOI    TO  CODIGO-CLI                               00183000
           MOVE NOMEI      TO  NOME-CLI                                 00184000
           MOVE ENDERECI   TO  ENDERECO-CLI                             00185000
           MOVE CIDADEI    TO  CIDADE-CLI                               00186000
           MOVE ESTADOI    TO  ESTADO-CLI                               00187000
           MOVE CEPI       TO  CEP-CLI.                                 00188000
                                                                        00189000
           EXEC SQL INSERT INTO CLIENTE                                 00190000
                VALUES (:DCL-CLIENTE)                                   00191000
           END-EXEC.                                                    00192000
                                                                        00193000
           IF  SQLCODE  EQUAL  +0                                       00194000
               MOVE LOW-VALUES TO MAPA01O                               00195000
               MOVE CODIGO-CLI TO CODIGOO                               00196000
               MOVE  TAB-MENS(02) TO ERRMSGO                            00197000
           ELSE                                                         00198000
               IF  SQLCODE  EQUAL  -803                                 00199000
                   MOVE  TAB-MENS(06) TO ERRMSGO                        00200000
               ELSE                                                     00201000
                   MOVE  SQLCODE TO TAB-ERR                             00202000
                   MOVE  TAB-MENS(07) TO ERRMSGO.                       00203000
                                                                        00204000
           MOVE  SPACES   TO NOMEESTO.                                  00205000
                                                                        00206000
       300-99-EXIT.                                                     00207000
           EXIT.                                                        00208000
           EJECT                                                        00209000
131000****************************************************************  00210000
131100*       ROTINA DE ALTERACAO                                    *  00211000
131200****************************************************************  00212000
       400-00-ALTERACAO SECTION.                                        00213000
                                                                        00214000
           MOVE CODIGOI TO CODIGO-CLI.                                  00215000
                                                                        00216000
           EXEC SQL SELECT CODIGO,                                      00217000
                           NOME,                                        00218000
                           ENDERECO,                                    00219000
                           CIDADE,                                      00220000
                           ESTADO,                                      00221000
                           CEP                                          00222000
                    INTO   :DCL-CLIENTE                                 00223000
                    FROM   CLIENTE                                      00224000
                    WHERE  CODIGO = :CODIGO-CLI                         00225000
           END-EXEC.                                                    00226000
                                                                        00227000
           IF  SQLCODE  EQUAL  +0                                       00228000
               NEXT SENTENCE                                            00229000
           ELSE                                                         00230000
               IF  SQLCODE  EQUAL  +100                                 00231000
                   MOVE  TAB-MENS(05) TO ERRMSGO                        00232000
                   GO  TO  400-99-EXIT                                  00233000
               ELSE                                                     00234000
                   MOVE SQLCODE TO TAB-ERR                              00235000
                   MOVE TAB-MENS(07) TO ERRMSGO                         00236000
                   GO  TO  400-99-EXIT.                                 00237000
                                                                        00238000
           IF  NOMEI  NOT EQUAL  NOME-CLI                               00239000
               MOVE NOMEI  TO  NOME-CLI.                                00240000
                                                                        00241000
           IF  ENDERECI  NOT EQUAL  ENDERECO-CLI                        00242000
               MOVE ENDERECI TO ENDERECO-CLI.                           00243000
                                                                        00244000
           IF  CIDADEI  NOT EQUAL  CIDADE-CLI                           00245000
               MOVE CIDADEI TO CIDADE-CLI.                              00246000
                                                                        00247000
           IF  ESTADOI  NOT EQUAL  ESTADO-CLI                           00248000
               MOVE ESTADOI TO ESTADO-CLI.                              00249000
                                                                        00250000
           IF  CEPI  NOT EQUAL  CEP-CLI                                 00251000
               MOVE CEPI TO CEP-CLI.                                    00252000
                                                                        00253000
           EXEC SQL UPDATE CLIENTE                                      00254000
                    SET NOME      = :NOME-CLI,                          00255000
                        ENDERECO  = :ENDERECO-CLI,                      00256000
                        CIDADE    = :CIDADE-CLI,                        00257000
                        ESTADO    = :ESTADO-CLI,                        00258000
                        CEP       = :CEP-CLI                            00259000
                    WHERE CODIGO  = :CODIGO-CLI                         00260000
           END-EXEC.                                                    00261000
                                                                        00262000
           MOVE LOW-VALUES TO MAPA01O.                                  00263000
           MOVE CODIGO-CLI TO CODIGOO.                                  00264000
                                                                        00265000
           IF  SQLCODE  EQUAL  +0                                       00266000
               MOVE  TAB-MENS(03)  TO  ERRMSGO                          00267000
           ELSE                                                         00268000
               MOVE SQLCODE TO TAB-ERR                                  00269000
               MOVE TAB-MENS(07) TO ERRMSGO.                            00270000
                                                                        00271000
           MOVE  SPACES  TO  NOMEESTO.                                  00272000
                                                                        00273000
       400-99-EXIT.                                                     00274000
           EXIT.                                                        00275000
           EJECT                                                        00276000
131000****************************************************************  00277000
131100*       ROTINA DE DELECAO                                      *  00278000
131200****************************************************************  00279000
       500-00-DELECAO SECTION.                                          00280000
                                                                        00281000
           MOVE CODIGOI  TO  CODIGO-CLI.                                00282000
                                                                        00283000
           EXEC SQL DELETE FROM CLIENTE                                 00284000
                    WHERE  CODIGO = :CODIGO-CLI                         00285000
           END-EXEC.                                                    00286000
                                                                        00287000
           IF  SQLCODE  EQUAL  +0                                       00288000
               MOVE  LOW-VALUES TO MAPA01O                              00289000
               MOVE  TAB-MENS(04) TO ERRMSGO                            00290000
           ELSE                                                         00291000
               IF  SQLCODE  EQUAL  +100                                 00292000
                   MOVE TAB-MENS(05)  TO ERRMSGO                        00293000
               ELSE                                                     00294000
                   MOVE SQLCODE TO TAB-ERR                              00295000
                   MOVE TAB-MENS(07) TO ERRMSGO.                        00296000
                                                                        00297000
           MOVE  SPACES  TO  NOMEESTO.                                  00298000
                                                                        00299000
       500-99-EXIT.                                                     00300000
           EXIT.                                                        00301000
           EJECT                                                        00302000
       600-00-RETURN SECTION.                                           00303000
           EXEC CICS SEND TEXT FROM(WS01-FINAL)                         00304000
                               LENGTH(50)                               00305000
                               ERASE                                    00306000
                               FREEKB                                   00307000
           END-EXEC.                                                    00308000
                                                                        00309000
           EXEC CICS RETURN END-EXEC.                                   00310000
       600-99-EXIT.                                                     00311000
           EXIT.                                                        00312000
