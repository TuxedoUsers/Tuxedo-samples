           EXEC SQL DECLARE                                             00001000
           CLIENTE TABLE                                                00002000
           ( CODIGO                DECIMAL(3, 0)        NOT NULL        00003000
            ,NOME                  CHAR(30)                             00004000
            ,ENDERECO              CHAR(30)                             00005000
            ,CIDADE                CHAR(20)                             00006000
            ,ESTADO                CHAR(2)                              00007000
            ,CEP                   DECIMAL(8, 0)                        00008000
           ) END-EXEC.                                                  00009000
      *>  --------------------------------------------------------------00010000
      *> COBOL DECLARATION FOR TABLE CLIENTE                            00011000
      *>  --------------------------------------------------------------00012000
       01  DCL-CLIENTE.                                                 00013000
           03 CODIGO-CLI                   PIC S9(03) COMP-3.           00014000
           03 NOME-CLI                     PIC X(30).                   00015000
           03 ENDERECO-CLI                 PIC X(30).                   00016000
           03 CIDADE-CLI                   PIC X(20).                   00017000
           03 ESTADO-CLI                   PIC X(2).                    00018000
           03 CEP-CLI                      PIC S9(08) COMP-3.           00019000
      *>  --------------------------------------------------------------00020000
      *> COBOL INDICATOR VARIABLES FOR TABLE                            00021000
      *>  --------------------------------------------------------------00022000
       01  DCL-CLIENTE-NULL.                                            00023000
           03 CLIENTE-NOME-NULL                PIC S9(04)  COMP  .      00024000
           03 CLIENTE-ENDERECO-NULL            PIC S9(04)  COMP  .      00025000
           03 CLIENTE-CIDADE-NULL              PIC S9(04)  COMP  .      00026000
           03 CLIENTE-ESTADO-NULL              PIC S9(04)  COMP  .      00027000
           03 CLIENTE-CEP-NULL                 PIC S9(04)  COMP  .      00028000
