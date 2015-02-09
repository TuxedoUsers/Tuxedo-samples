      *   Mainframe Express 3.1  6.008.0041
      *   Micro Focus BMS Screen Painter (ver IDE_6-0-43)
      *   MapSet Name   ORA002
      *   Date Created  01/11/2015
      *   Time Created  19:09:33

      *  Input Data For Map MAPA01
         01 MAPA01I.
            03 FILLER                         PIC X(12).
            03 CODIGOL                        PIC S9(4) COMP.
            03 CODIGOF                        PIC X.
            03 FILLER REDEFINES CODIGOF.
               05 CODIGOA                        PIC X.
            03 CODIGOI                        PIC 999.
            03 NOMEL                          PIC S9(4) COMP.
            03 NOMEF                          PIC X.
            03 FILLER REDEFINES NOMEF.
               05 NOMEA                          PIC X.
            03 NOMEI                          PIC X(30).
            03 ENDERECL                       PIC S9(4) COMP.
            03 ENDERECF                       PIC X.
            03 FILLER REDEFINES ENDERECF.
               05 ENDERECA                       PIC X.
            03 ENDERECI                       PIC X(30).
            03 CIDADEL                        PIC S9(4) COMP.
            03 CIDADEF                        PIC X.
            03 FILLER REDEFINES CIDADEF.
               05 CIDADEA                        PIC X.
            03 CIDADEI                        PIC X(20).
            03 ESTADOL                        PIC S9(4) COMP.
            03 ESTADOF                        PIC X.
            03 FILLER REDEFINES ESTADOF.
               05 ESTADOA                        PIC X.
            03 ESTADOI                        PIC X(2).
            03 NOMEESTL                       PIC S9(4) COMP.
            03 NOMEESTF                       PIC X.
            03 FILLER REDEFINES NOMEESTF.
               05 NOMEESTA                       PIC X.
            03 NOMEESTI                       PIC X(25).
            03 CEPL                           PIC S9(4) COMP.
            03 CEPF                           PIC X.
            03 FILLER REDEFINES CEPF.
               05 CEPA                           PIC X.
            03 CEPI                           PIC 99999999.
            03 ERRMSGL                        PIC S9(4) COMP.
            03 ERRMSGF                        PIC X.
            03 FILLER REDEFINES ERRMSGF.
               05 ERRMSGA                        PIC X.
            03 ERRMSGI                        PIC X(60).

      *  Output Data For Map MAPA01
         01 MAPA01O REDEFINES MAPA01I.
            03 FILLER                         PIC X(12).
            03 FILLER                         PIC X(3).
            03 CODIGOO                        PIC 999.
            03 FILLER                         PIC X(3).
            03 NOMEO                          PIC X(30).
            03 FILLER                         PIC X(3).
            03 ENDERECO                       PIC X(30).
            03 FILLER                         PIC X(3).
            03 CIDADEO                        PIC X(20).
            03 FILLER                         PIC X(3).
            03 ESTADOO                        PIC X(2).
            03 FILLER                         PIC X(3).
            03 NOMEESTO                       PIC X(25).
            03 FILLER                         PIC X(3).
            03 CEPO                           PIC 99999999.
            03 FILLER                         PIC X(3).
            03 ERRMSGO                        PIC X(60).

