CREATE TABLE VISAARG.CLIENTE
(
    CODIGO                    DECIMAL(3) NOT NULL,
    NOME                      CHAR(30),
    ENDERECO                  CHAR(30),
    CIDADE                    CHAR(20),
    ESTADO                    CHAR(2),
    CEP                       DECIMAL(8)
);

CREATE UNIQUE INDEX INDCLI   ON VISAARG.CLIENTE
(
     CODIGO            
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    1,
    'CLIENTE-001                   ',
    'RUA 001                       ',
    'CIDADE 001          ',
    'SP',
    7061000
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    2,
    'CLIENTE-002                   ',
    'RUA 002                       ',
    'CIDADE 002          ',
    'SP',
    2
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    3,
    'CLIENTE-003                   ',
    'RUA 003                       ',
    'CIDADE 003          ',
    'SP',
    3
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    4,
    'CLIENTE-004                   ',
    'RUA 004                       ',
    'CIDADE 004          ',
    'SP',
    4
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    5,
    'CLIENTE-005                   ',
    'RUA 005                       ',
    'CIDADE 005          ',
    'SP',
    5
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    6,
    'CLIENTE-006                   ',
    'RUA 006                       ',
    'CIDADE 006          ',
    'SP',
    6
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    7,
    'CLIENTE-007                   ',
    'RUA 007                       ',
    'CIDADE 007          ',
    'SP',
    7
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    8,
    'CLIENTE-008                   ',
    'RUA 008                       ',
    'CIDADE 008          ',
    'SP',
    8
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    9,
    'CLIENTE-009                   ',
    'RUA 009                       ',
    'CIDADE 009          ',
    'SP',
    9
);

INSERT INTO VISAARG.CLIENTE VALUES
(
    10,
    'VALTER-010                    ',
    'RUA 010                       ',
    'CIDADE 010          ',
    'SP',
    10
);
