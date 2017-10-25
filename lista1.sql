CREATE TABLE Bandy
(nr_bandy NUMBER(2) CONSTRAINT bd_pk PRIMARY KEY,
nazwa VARCHAR(20) CONSTRAINT bd_nn NOT NULL,
teren VARCHAR(15) CONSTRAINT bd_uniq_ter UNIQUE,
szef_bandy VARCHAR2(15) CONSTRAINT bd_uniq_sz UNIQUE/*, 
CONSTRAINT bd_fk FOREIGN KEY (szef_bandy) 
REFERENCES Kocury (pseudo)*/
);

CREATE TABLE Funkcje
(funkcja VARCHAR2(10) CONSTRAINT fcj_pk PRIMARY KEY,
min_myszy NUMBER(3),
max_myszy NUMBER(3),
CONSTRAINT fcj_min_ch CHECK (min_myszy > 5),
CONSTRAINT fcj_max_ch1 CHECK (max_myszy > min_myszy),
CONSTRAINT fcj_max_ch2 CHECK (max_myszy < 200)
);

ALTER TABLE Funkcje
    DROP CONSTRAINT fcj_max_ch1;
    
ALTER TABLE Funkcje
    ADD CONSTRAINT fcj_max_ch1 CHECK (max_myszy >= min_myszy);

CREATE TABLE Wrogowie
(imie_wroga VARCHAR2(15) CONSTRAINT wr_im_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20),
CONSTRAINT wr_st_ch1 CHECK (stopien_wrogosci >=1),
CONSTRAINT wr_st_ch2 CHECK (stopien_wrogosci <= 10)
);

ALTER TABLE Wrogowie
    DROP CONSTRAINT wr_st_ch1;
    
ALTER TABLE Wrogowie
    DROP CONSTRAINT wr_st_ch2;
    
ALTER TABLE Wrogowie
    ADD CONSTRAINT wr_st_ch CHECK (Stopien_wrogosci BETWEEN 1 AND 10);

CREATE TABLE Kocury
(imie VARCHAR2(15) CONSTRAINT koc_im_nn NOT NULL,
plec VARCHAR2(1) CONSTRAINT koc_pl_ch CHECK (plec IN ('M', 'D')),
pseudo VARCHAR2(15) CONSTRAINT koc_pseudo_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT koc_fcj_fk REFERENCES Funkcje (funkcja),
szef VARCHAR2(15),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT koc_nrb_fk REFERENCES Bandy (nr_bandy)
);

ALTER TABLE Kocury
    ADD CONSTRAINT fcj_szef_fk FOREIGN KEY (szef) 
    REFERENCES Kocury(pseudo);
    
ALTER TABLE Bandy
    ADD CONSTRAINT bd_szef_fk FOREIGN KEY (szef_bandy) 
    REFERENCES Kocury (pseudo);
    
CREATE TABLE Wrogowie_Kocurow
(pseudo VARCHAR2(15) CONSTRAINT wk_pseudo_fk REFERENCES Kocury (pseudo),
imie_wroga VARCHAR2(15) CONSTRAINT wk_imw_fk REFERENCES Wrogowie (imie_wroga),
data_incydentu DATE CONSTRAINT wk_datai_nn NOT NULL,
opis_incydentu VARCHAR2(50),
CONSTRAINT wk_pseudoimwr_pk PRIMARY KEY (pseudo, imie_wroga)
);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2);
    
INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4);

INSERT INTO Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4);


INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy)
    VALUES (1,'SZEFOSTWO','CALOSC','TYGRYS');
    
INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy)
    VALUES (2,'CZARNI RYCERZE','POLE','LYSY');
    
INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy)
    VALUES (3,'BIALI LOWCY','SAD','ZOMBI');
    
INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy)
    VALUES (4,'LACIACI MYSLIWI','GORKA','RAFA');
    
INSERT INTO Bandy(nr_bandy,nazwa,teren,szef_bandy)
    VALUES (5,'ROCKERSI','ZAGRODA',NULL);

ALTER TABLE Kocury DISABLE CONSTRAINT koc_nrb_fk;
ALTER TABLE Kocury DISABLE CONSTRAINT koc_fcj_fk;
ALTER TABLE Kocury DISABLE CONSTRAINT koc_szef_fk;
ALTER TABLE Kocury DISABLE CONSTRAINT fcj_szef_fk;
ALTER TABLE Funkcje DISABLE CONSTRAINT fcj_pk;
ALTER TABLE Wrogowie_kocurow DISABLE CONSTRAINT wk_pseudo_fk;

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('SZEFUNIO',90,110);
    
INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('BANDZIOR',70,90);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('LOWCZY',60,70);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('LAPACZ',50,60);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('KOT',40,50);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('MILUSIA',20,30);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('DZIELCZY',45,55);

INSERT INTO Funkcje(funkcja,min_myszy,max_myszy)
    VALUES ('HONOROWA',6,25);



INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('KAZIO',10,'CZLOWIEK','FLASZKA');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('BUREK',4,'PIES','KOSC');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('DZIKI BILL',10,'PIES',NULL);

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('REKSIO',2,'PIES','KOSC');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('BETHOVEN',1,'PIES','PEDIGRIPALL');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('CHYTRUSEK',5,'LIS','KURCZAK');

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('SMUKLA',1,'SOSNA',NULL);

INSERT INTO Wrogowie(imie_wroga,stopien_wrogosci,gatunek,lapowka)
    VALUES ('BAZYLI',3,'KOGUT','KURA DO STADA');



INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('TYGRYS','KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('ZOMBI','SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('BOLEK','KAZIO','2005-03-29','POSZCZUL BURKIEM');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('SZYBKA','GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('MALA','CHYTRUSEK','2007-03-07','ZALECAL SIE');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('TYGRYS','DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('BOLEK','DZIKI BILL','2007-11-10','ODGRYZL UCHO');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('LASKA','DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('LASKA','KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('DAMA','KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('MAN','REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('LYSY','BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('RURA','DZIKI BILL','2009-09-03','ODGRYZL OGON');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('PLACEK','BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('PUSZYSTA','SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('KURKA','BUREK','2010-12-14','POGONIL');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('MALY','CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA');
    
INSERT INTO Wrogowie_Kocurow(pseudo,imie_wroga,data_incydentu,opis_incydentu)
    VALUES ('UCHO','SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI');
    
ALTER TABLE Kocury ENABLE CONSTRAINT koc_nrb_fk;
ALTER TABLE Kocury ENABLE CONSTRAINT koc_fcj_fk;
ALTER TABLE Kocury ENABLE CONSTRAINT koc_szef_fk;
ALTER TABLE Kocury ENABLE CONSTRAINT fcj_szef_fk;
ALTER TABLE Funkcje ENABLE CONSTRAINT fcj_pk;
ALTER TABLE Wrogowie_kocurow ENABLE CONSTRAINT wk_pseudo_fk;

ALTER TABLE Kocury
    ADD CONSTRAINT koc_szef_fk FOREIGN KEY (szef) 
    REFERENCES Kocury(pseudo);
    
ALTER TABLE Kocury
    DROP CONSTRAINT fcj_szef_fk;
    
COMMIT;   



--zad1    
SELECT IMIE_WROGA "WROG", OPIS_INCYDENTU "PRZEWINA"
FROM Wrogowie_Kocurow
WHERE DATA_INCYDENTU BETWEEN '2009-01-01' AND '2009-12-31';

--zad2
SELECT IMIE, FUNKCJA, W_STADKU_OD "Z NAMI OD"
FROM KOCURY
WHERE PLEC = 'D' AND W_STADKU_OD BETWEEN '2005-09-01' AND '2007-07-31';

--zad3
SELECT IMIE_WROGA "WROG", GATUNEK, STOPIEN_WROGOSCI "STOPIEN WROGOSCI"
FROM WROGOWIE
WHERE LAPOWKA IS NULL
ORDER BY STOPIEN_WROGOSCI;

--zad4
SELECT IMIE || ' zwany ' || PSEUDO || ' (fun. ' || FUNKCJA || ') lowi myszki w bandzie ' || NR_BANDY || ' od ' || W_STADKU_OD "WSZYSTKO O KOCURACH"
FROM KOCURY
WHERE PLEC = 'M'
ORDER BY W_STADKU_OD DESC, PSEUDO ASC;

--zad5
SELECT PSEUDO, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'L', '%', 1, 1), 'A', '#', 1, 1) "Po wymianie A na # oraz L na %"
FROM KOCURY
WHERE PSEUDO LIKE '%A%L%' OR PSEUDO LIKE '%L%A%';

--zad6
SELECT IMIE, W_STADKU_OD "W stadku",ROUND(NVL(PRZYDZIAL_MYSZY, 0)/1.1, 0) "Zjadal", ADD_MONTHS(W_STADKU_OD, 6) "Podwyzka", NVL(PRZYDZIAL_MYSZY, 0) "Zjada"
FROM KOCURY
WHERE MONTHS_BETWEEN('2017-07-11', w_STADKU_OD) > 96 AND EXTRACT(MONTH FROM W_STADKU_OD) BETWEEN 3 AND 9;

--zad7
SELECT IMIE, NVL(PRZYDZIAL_MYSZY, 0)*3 "MYSZY KWARTALNIE", NVL(MYSZY_EXTRA, 0)*3 "KWARTALNE DODATKI"
FROM KOCURY
WHERE NVL(PRZYDZIAL_MYSZY, 0) > NVL(MYSZY_EXTRA, 0)*2 AND NVL(PRZYDZIAL_MYSZY, 0) > 54;

--zad8
SELECT IMIE, CASE  
    WHEN (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) * 12  < 660 THEN 'Ponizej 660'
    WHEN (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) * 12 = 660 THEN 'Limit'
    ELSE TO_CHAR((NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))* 12)  
    END "Zjada rocznie" 
FROM KOCURY;
    
--zad9
    --23.10.17
SELECT PSEUDO, W_STADKU_OD "W STADKU", CASE
    WHEN (EXTRACT(DAY FROM W_STADKU_OD) BETWEEN 1 AND 15) THEN CASE 
        WHEN NEXT_DAY(LAST_DAY(TO_DATE('2017-10-23')) - 7, 'WEDNESDAY') < TO_DATE('2017-10-23') THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-23'), 1)) - 7, 'WEDNESDAY')
        ELSE NEXT_DAY(LAST_DAY(TO_DATE('2017-10-23')) - 7, 'WEDNESDAY')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-23'), 1)) - 7, 'WEDNESDAY')
    END "WYPLATA"
FROM KOCURY;

    --26.10.17
SELECT PSEUDO, W_STADKU_OD "W STADKU", CASE
    WHEN (EXTRACT(DAY FROM W_STADKU_OD) BETWEEN 1 AND 15) THEN CASE 
        WHEN NEXT_DAY(LAST_DAY(TO_DATE('2017-10-26')) - 7, 'WEDNESDAY') < TO_DATE('2017-10-26') THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-26'), 1)) - 7, 'WEDNESDAY')
        ELSE NEXT_DAY(LAST_DAY(TO_DATE('2017-10-26')) - 7, 'WEDNESDAY')
        END
    ELSE NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('2017-10-26'), 1)) - 7, 'WEDNESDAY')
    END "WYPLATA"
FROM KOCURY;

--zad10
    --PSEUDO
SELECT DECODE(COUNT(PSEUDO), 1, PSEUDO || ' - Unikalny', PSEUDO || ' - nieunikalny') "Unikalnosc atr. PSEUDO"
FROM KOCURY
GROUP BY PSEUDO;

    --SZEF
SELECT DECODE(COUNT(SZEF), 1, SZEF || ' - Unikalny', SZEF || ' - nieunikalny') "Unikalnosc atr. SZEF"
FROM KOCURY
WHERE SZEF IS NOT NULL
GROUP BY SZEF;

--zad11
SELECT PSEUDO "Pseudonim", COUNT(PSEUDO) "Liczba wrogow"
FROM WROGOWIE_KOCUROW
GROUP BY PSEUDO
HAVING COUNT(PSEUDO) > 1;

--zad12
SELECT 'Liczba kotow=' " ", COUNT(FUNKCJA) " ", 'lowi jako' " ", FUNKCJA " ", 'i zjada max.' " ", MAX(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) " ", 'myszy miesiecznie' " "
FROM KOCURY
WHERE FUNKCJA != 'SZEFUNIO' AND PLEC = 'D'
GROUP BY FUNKCJA
HAVING AVG(NVL(PRZYDZIAL_MYSZY, 0)+NVL(MYSZY_EXTRA, 0)) > 50;

--zad13
SELECT NR_BANDY "Nr bandy", PLEC "Plec", MIN(NVL(PRZYDZIAL_MYSZY, 0)) "Minimalny przydzial"
FROM KOCURY
GROUP BY NR_BANDY, PLEC;

--zad14
SELECT level "Poziom", PSEUDO "Pseudonim", FUNKCJA "Funkcja", NR_BANDY "Nr bandy"
FROM KOCURY
WHERE PLEC = 'M'
CONNECT BY PRIOR PSEUDO = SZEF
START WITH FUNKCJA = 'BANDZIOR';

--zad15
SELECT LPAD(level - 1, 4 * (level - 1) + 1, '===>') || '            ' || IMIE "Hierarchia", 
    DECODE(CONNECT_BY_ROOT PSEUDO, PSEUDO, 'Sam sobie szefem', SZEF) "Pseudo szefa", FUNKCJA "Funkcja"
FROM KOCURY
WHERE MYSZY_EXTRA IS NOT NULL
CONNECT BY PRIOR PSEUDO = SZEF
START WITH SZEF IS NULL;

--DECODE(level, 1, '0', SYS_CONNECT_BY_PATH(level, '===>'))
--LPAD(level - 1, 4 * (level - 1) + 1, '===>')
--CASE level WHEN 1 THEN NULL ELSE '==>'
--DECODE(level, 1, 0, SYS_CONNECT_BY_PATH(level, '===>'))

--zad16
SELECT LPAD(' ', (level-1)*4) || PSEUDO "Droga sluzbowa"
FROM KOCURY
CONNECT BY PRIOR SZEF = PSEUDO
START WITH PLEC = 'M' AND MONTHS_BETWEEN('2017-07-11', w_STADKU_OD) > 96 AND MYSZY_EXTRA IS NULL;

--SYS_CONNECT_BY_PATH(NULL, '     ')







