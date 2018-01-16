--zad47

--KOCURY
create or replace type KocuryT as object
(
    imie varchar2(15),
    plec varchar2(1),
    pseudo varchar2(15),
    w_stadku_od date,
    funkcja varchar2(10),
    przydzial_myszy number(3),
    myszy_extra number(3),
    nr_bandy number(2),
    map member function Porownaj return varchar2,
    member function Dane return varchar2,
    member function getPseudo return varchar2,
    member function getImie return varchar2,
    member function getMiesPrzys return varchar2,
    member function getRokPrzys return varchar2,
    member function Przydzial return number
)not final;

alter type KocuryT
add attribute szef ref ElitaT
cascade;

create or replace type body KocuryT as
    map member function Porownaj return varchar2 is
    begin
        return pseudo;
    end;
    member function getPseudo return varchar2 is
    begin
        return pseudo;
    end;
    member function getImie return varchar2 is
    begin
        return imie;
    end;
    member function getMiesPrzys return varchar2 is
    begin
        return to_char(extract(month from w_stadku_od));
    end;
    member function getRokPrzys return varchar2 is
    begin
        return to_char(extract(year from w_stadku_od));
    end;
    member function Dane return varchar2 is
        temp varchar2(15);
    begin
        select deref(szef).pseudo into temp from dual; --the DEREF must be in a SQL Statement, You can select from the dummy table DUAL because each object stored in an object table has a unique object identifier, which is part of every ref to that object.
        return pseudo||', '||imie||', '||plec||', '||nvl(temp, ' ')||', '||funkcja||', '||nvl(to_char(w_stadku_od), ' ')||', '||nvl(przydzial_myszy, 0)||', '||nvl(myszy_extra, 0)||', '||nr_bandy;
    end;
    member function Przydzial return number is
    begin
        return nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0);
    end;
end;

create table KocuryO of KocuryT
(
    szef scope is ElitaO,
    CONSTRAINT koco_im_nn CHECK (imie is NOT NULL),
    CONSTRAINT koco_pl_ch CHECK (plec IN ('M', 'D')),
    CONSTRAINT koco_pseudo_pk PRIMARY KEY(pseudo)
);


--ELITA
create or replace type ElitaT under KocuryT
(
    sluga ref PlebsT,
    overriding member function Dane return varchar2,
    member function PosiadaSluge return boolean
);

create or replace type body ElitaT as
    overriding member function Dane return varchar2 is
        temp1 varchar2(15);
        temp2 varchar2(15);
    begin
        select deref(szef).pseudo, deref(sluga).pseudo into temp1, temp2 from dual;
        return (self as KocuryT).Dane()||', '||nvl(temp2, ' ');
    end;
    member function PosiadaSluge return boolean is
    begin
        return sluga != null;
    end;
end;

create table ElitaO of ElitaT
(
    --sluga scope is PlebsO,
    szef scope is ElitaO,
    CONSTRAINT elo_im_nn CHECK (imie is NOT NULL),
    CONSTRAINT elo_pl_ch CHECK (plec IN ('M', 'D')),
    CONSTRAINT elo_pseudo_pk PRIMARY KEY(pseudo)
);

alter table ElitaO
add (scope for (sluga) is PlebsO);

--PLEBS
create or replace type PlebsT under KocuryT
(
    member function PseudoPana return varchar2
);

create or replace type body PlebsT as
    member function PseudoPana return varchar2 is
        temp varchar2(15);
    begin
        select pseudo into temp from ElitaO where deref(sluga).pseudo = self.pseudo;
        return nvl(temp, ' ');
    end;
end;

create table PlebsO of PlebsT
(
    szef scope is ElitaO,
    CONSTRAINT plebo_im_nn CHECK (imie is NOT NULL),
    CONSTRAINT plebo_pl_ch CHECK (plec IN ('M', 'D')),
    CONSTRAINT plebo_pseudo_pk PRIMARY KEY(pseudo)
);

--KONTO
create or replace type KontoT as object
(
    numer number(3),
    data_wprowadzenia date,
    data_usuniecia date,
    wlasciciel ref ElitaT,
    map member function Porownaj return varchar2,
    member function Dane return varchar2
);

create or replace type body KontoT as
    map member function Porownaj return varchar2 is
        temp varchar2(15);
    begin
        select deref(wlasciciel).pseudo into temp from dual;
        return temp;
    end;
    member function Dane return varchar2 is
        temp varchar2(15);
    begin
        select deref(wlasciciel).pseudo into temp from dual;
        return numer||', '||temp||', '||data_wprowadzenia||', '||nvl(data_usuniecia, ' ');
    end;
end;

create table KontoO of KontoT
(
    wlasciciel scope is ElitaO,
    constraint konto_wl_nn check (wlasciciel is not null),
    constraint konto_du_ch check (data_usuniecia >= data_wprowadzenia),
    constraint konto_dw_ch check (data_wprowadzenia is not null),
    constraint konto_id_pk primary key(numer)
);


--WROGOWIE_KOCUROW
create or replace type wrogowie_kocurowT as object
(
    nr_incydentu number(3),
    kocur ref KocuryT,
    imie_wroga varchar2(15),
    data_incydentu date,
    opis_incydentu varchar2(50),
    map member function Porownaj return number,
    member function Dane return varchar2
);

create or replace type body wrogowie_kocurowT as
    map member function Porownaj return number is
        temp varchar2(15);
    begin
        select deref(kocur).pseudo into temp from dual;
        return temp||', '||imie_wroga;
    end;
    member function Dane return varchar2 is
        temp varchar(15);
    begin
        select deref(kocur).pseudo into temp from dual;
        return nr_incydentu||', '||temp||', '||imie_wroga||', '||data_incydentu||', '||nvl(opis_incydentu, ' ');
    end;
end;

create table wrogowie_kocurowO of wrogowie_kocurowT
(
    CONSTRAINT wko_datai_nn check(data_incydentu is NOT NULL),
    CONSTRAINT wko_kiw_pk PRIMARY KEY (nr_incydentu)
);

--TRIGGERY do KocuryO
create or replace trigger dodawanie_kocuraO_elita
before insert on ElitaO
for each row
begin
    insert into KocuryO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    values (:new.imie,:new.plec,:new.pseudo,:new.szef,:new.funkcja,:new.w_stadku_od,:new.przydzial_myszy,:new.myszy_extra,:new.nr_bandy);
end;

create or replace trigger usuwanie_kocuraO_elita
before delete on ElitaO
for each row
begin
    delete from KocuryO k
    where k.pseudo = :old.pseudo;
end;

create or replace trigger dodawanie_kocuraO_plebs
before insert on PlebsO
for each row
begin
    insert into KocuryO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    values (:new.imie,:new.plec,:new.pseudo,:new.szef,:new.funkcja,:new.w_stadku_od,:new.przydzial_myszy,:new.myszy_extra,:new.nr_bandy);
end;

create or replace trigger usuwanie_kocuraO_plebs
before delete on PlebsO
for each row
begin
    delete from KocuryO k
    where k.pseudo = :old.pseudo;
end;

create or replace trigger modyfikowanie_kocuraO_plebs
after update on PlebsO
begin
    update KocuryO k
    set k.pseudo = pseudo, k.imie = imie, k.plec = plec, k.w_stadku_od = w_stadku_od, k.przydzial_myszy = przydzial_myszy,
    myszy_extra = myszy_extra, k.szef = szef, k.funkcja = funkcja, k.nr_bandy = nr_bandy;
end;

create or replace trigger modyfikowanie_kocuraO_elita
after update on ElitaO
for each row
begin
    update KocuryO k
    set k.pseudo = pseudo, k.imie = imie, k.plec = plec, k.w_stadku_od = w_stadku_od, k.przydzial_myszy = przydzial_myszy,
    myszy_extra = myszy_extra, k.szef = szef, k.funkcja = funkcja, k.nr_bandy = nr_bandy;
end;

update ElitaO
set pseudo = 'ASD', imie = 'asd'
where pseudo = 'TYGRYS';

--create or replace trigger zakaz_dodawania_KocuryO
--before insert on KocuryO
--for each row
--begin
--    raise_application_error(-20105, 'Nie mozna dodac do KocuryO, dodaj do ElitaO lub PlebsO');
--end;

INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    VALUES ('MRUCZEK','M','TYGRYS',NULL,'SZEFUNIO','2002-01-01',103,33,1,NULL);

INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    SELECT 'PUCEK','M','RAFA',REF(O),'LOWCZY','2006-10-15',65,NULL,4,null FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    SELECT 'KOREK','M','ZOMBI',REF(O),'BANDZIOR','2004-03-16',75,13,3,null FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    SELECT 'BOLEK','M','LYSY',REF(O),'BANDZIOR','2006-08-15',72,21,2,null FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    SELECT 'PUNIA','D','KURKA',REF(o),'LOWCZY','2008-01-01',61,NULL,3,null from ElitaO o where o.pseudo = 'ZOMBI';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,funkcja,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy,sluga)
    SELECT 'MICKA','D','LOLA',REF(O),'MILUSIA','2009-10-14',25,47,1,NULL FROM ElitaO O where O.pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'MAN')
where pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'LASKA')
where pseudo = 'RAFA';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'BOLEK')
where pseudo = 'ZOMBI';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'MALY')
where pseudo = 'LYSY';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'PUSZYSTA')
where pseudo = 'KURKA';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'ZERO')
where pseudo = 'LOLA';



INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'KSAWERY','M','MAN','LAPACZ',REF(O),'2008-07-12',51,NULL,4 FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'JACEK','M','PLACEK','LOWCZY',REF(O),'2008-12-01',67,NULL,2 FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'BARI','M','RURA','LAPACZ',REF(O),'2009-09-01',56,NULL,2 FROM ElitaO O where O.pseudo = 'LYSY';
    
INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
   SELECT 'LUCEK','M','ZERO','KOT',REF(O),'2010-03-01',43,NULL,3 FROM ElitaO O where O.pseudo = 'KURKA';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'SONIA','D','PUSZYSTA','MILUSIA',REF(O),'2010-11-18',20,35,3 FROM ElitaO O where O.pseudo = 'ZOMBI';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'LATKA','D','UCHO','KOT',REF(O),'2011-01-01',40,NULL,4 FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'DUDEK','M','MALY','KOT',REF(O),'2011-05-15',40,NULL,4 FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'CHYTRY','M','BOLEK','DZIELCZY',REF(O),'2002-05-05',50,NULL,1 FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'ZUZIA','D','SZYBKA','LOWCZY',REF(O),'2006-07-21',65,NULL,2 FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'RUDA','D','MALA','MILUSIA',REF(O),'2006-09-17',22,42,1 FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'BELA','D','LASKA','MILUSIA',REF(O),'2008-02-01',24,28,1 FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    SELECT 'MELA','D','DAMA','LAPACZ',REF(O),'2008-11-01',51,NULL,4 FROM ElitaO O where O.pseudo = 'RAFA';
    
    
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 1,'2008-11-01','2008-12-12',REF(O) FROM ElitaO O where O.pseudo = 'RAFA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 2,'2006-10-21','2007-01-17',REF(O) FROM ElitaO O where O.pseudo = 'RAFA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 3,'2017-12-30',null,REF(O) FROM ElitaO O where O.pseudo = 'RAFA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 4,'2003-05-18','2003-06-23',REF(O) FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 5,'2008-10-26','2008-10-26',REF(O) FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 6,'2018-01-08',null,REF(O) FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 7,'2007-11-29','2008-12-12',REF(O) FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 8,'2015-04-07','2015-12-12',REF(O) FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 9,'2004-06-08','2005-11-02',REF(O) FROM ElitaO O where O.pseudo = 'ZOMBI';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 10,'2008-07-01','2008-07-06',REF(O) FROM ElitaO O where O.pseudo = 'ZOMBI';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 11,'2015-12-03','2016-02-23',REF(O) FROM ElitaO O where O.pseudo = 'ZOMBI';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 12,'2017-11-22',null,REF(O) FROM ElitaO O where O.pseudo = 'ZOMBI';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 13,'2018-01-03','2018-01-04',REF(O) FROM ElitaO O where O.pseudo = 'ZOMBI';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 14,'2008-05-08','2008-12-12',REF(O) FROM ElitaO O where O.pseudo = 'KURKA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 15,'2008-11-11','2008-12-12',REF(O) FROM ElitaO O where O.pseudo = 'KURKA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 16,'2011-11-11','2012-12-12',REF(O) FROM ElitaO O where O.pseudo = 'KURKA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 17,'2013-06-17','2013-06-17',REF(O) FROM ElitaO O where O.pseudo = 'KURKA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 18,'2015-10-25','2016-03-02',REF(O) FROM ElitaO O where O.pseudo = 'KURKA';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 19,'2006-08-17','2007-02-15',REF(O) FROM ElitaO O where O.pseudo = 'LYSY';
    
INSERT INTO KontoO(numer, data_wprowadzenia, data_usuniecia, wlasciciel)
    SELECT 20,'2016-06-16','2016-07-04',REF(O) FROM ElitaO O where O.pseudo = 'LYSY';



INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 1,REF(O),'KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY' from KocuryO O where O.pseudo = 'TYGRYS';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 2,REF(O),'SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY' from KocuryO O where O.pseudo = 'ZOMBI';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 3,REF(O),'KAZIO','2005-03-29','POSZCZUL BURKIEM' from KocuryO O where O.pseudo = 'BOLEK';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 4,REF(O),'GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI' from KocuryO O where O.pseudo = 'SZYBKA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 5,REF(O),'CHYTRUSEK','2007-03-07','ZALECAL SIE' from KocuryO O where O.pseudo = 'MALA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 6,REF(O),'DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA' from KocuryO O where O.pseudo = 'TYGRYS';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 7,REF(O),'DZIKI BILL','2007-11-10','ODGRYZL UCHO' from KocuryO O where O.pseudo = 'BOLEK';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 8,REF(O),'DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA' from KocuryO O where O.pseudo = 'LASKA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 9,REF(O),'KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK' from KocuryO O where O.pseudo = 'LASKA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 10,REF(O),'KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY' from KocuryO O where O.pseudo = 'DAMA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 11,REF(O),'REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL' from KocuryO O where O.pseudo = 'MAN';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 12,REF(O),'BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA' from KocuryO O where O.pseudo = 'LYSY';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 13,REF(O),'DZIKI BILL','2009-09-03','ODGRYZL OGON' from KocuryO O where O.pseudo = 'RURA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 14,REF(O),'BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA' from KocuryO O where O.pseudo = 'PLACEK';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 15,REF(O),'SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI' from KocuryO O where O.pseudo = 'PUSZYSTA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 16,REF(O),'BUREK','2010-12-14','POGONIL' from KocuryO O where O.pseudo = 'KURKA';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 17,REF(O),'CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA' from KocuryO O where O.pseudo = 'MALY';
    
INSERT INTO Wrogowie_KocurowO(nr_incydentu,kocur,imie_wroga,data_incydentu,opis_incydentu)
    SELECT 18,REF(O),'SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI' from KocuryO O where O.pseudo = 'UCHO';




select e.getImie(), e.sluga.getPseudo(), e.getPseudo(), e.getMiesPrzys(), e.getRokPrzys(), e.Dane(), e.Przydzial() from ElitaO e;

select e.getPseudo(), e.Dane() from ElitaO e order by deref(sluga);

select k.wlasciciel.getPseudo(), count(*) 
from KontoO k 
group by k.wlasciciel.getPseudo();

select e.getPseudo()
from ElitaO e
minus
select distinct k.wlasciciel.pseudo
from KontoO k;

select p.getPseudo() PSEUDO, p.Przydzial() ZJADA
from KocuryO p
where (
        select count(distinct p1.Przydzial())
        from KocuryO p1
        where p1.Przydzial() > p.Przydzial()
      ) < &n
order by 2 desc, 1 desc;

select p.Przydzial() from KocuryO p;

select k.wlasciciel.Dane() "Kocur", count(*) "Myszy na koncie"
from KontoO k
where k.data_usuniecia is null
group by k.wlasciciel.Dane()
order by "Myszy na koncie" desc;

select e.sluga.getPseudo() from ElitaO e;



--zad18
select k1.imie, k1.w_stadku_od "POLUJE OD"
from KocuryO k1, KocuryO k2
where k1.w_stadku_od < k2.w_stadku_od and k2.imie = 'JACEK'
order by k1.w_stadku_od desc;

--zad28
select k.getRokPrzys() "ROK", count(k.pseudo) "LICZBA WYSTAPIEN"
from KocuryO k
group by k.getRokPrzys()
having count(k.pseudo) in
(
    (
        select * 
        from
        (
            select distinct count(k1.pseudo)
            from KocuryO k1
            group by k1.getRokPrzys()
            having count(k1.pseudo) >
            (
                select avg(count(k2.getRokPrzys()))
                from KocuryO k2
                group by k2.getRokPrzys()
            )
            order by count(k1.pseudo)
        )
        where rownum = 1
    ),
    (
        select * 
        from
        (
            select distinct count(k1.pseudo)
            from KocuryO k1
            group by k1.getRokPrzys()
            having count(k1.pseudo) <
            (
                select avg(count(k2.getRokPrzys()))
                from KocuryO k2
                group by k2.getRokPrzys()
            )
            order by count(k1.pseudo) desc
        )
        where rownum = 1
    )
)
union
select 'Srednia', round(avg(count(k.getRokPrzys())), 7)
from KocuryO k
group by k.getRokPrzys()
order by 2;


--zad35
DECLARE
    rocznyPrzydzial NUMBER;
    imieK VARCHAR(20);
    miesPrzyst VARCHAR(20);
BEGIN
    SELECT 12*k.Przydzial(), k.imie, k.getMiesPrzys()
        into rocznyPrzydzial, imieK, miesPrzyst
    FROM KocuryO k
    WHERE k.pseudo = '&Pseudo';
    IF rocznyPrzydzial > 700 THEN 
        DBMS_OUTPUT.PUT_LINE(imieK || ' calkowity roczny przydzial myszy > 700');
    ELSIF imieK like '%A%' THEN
        DBMS_OUTPUT.PUT_LINE(imieK || ' imie zawiera litere A');
    ELSIF miesPrzyst = '1' THEN
        DBMS_OUTPUT.PUT_LINE(imieK || ' styczen jest miesiacem przystapienia do stada');
    ELSE
        DBMS_OUTPUT.PUT_LINE(imieK || ' nie odpowiada kryteriom');
    END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono');
END;

--zad37
declare
    sa_wiersze boolean := false;
    brak_kotow exception;
    i number(4) := 1;
begin
    dbms_output.put_line(rpad('Nr', 3) || rpad('Pseudonim', 10) || lpad('Zjada', 6));
    for rekord in ( select k.getPseudo() ps, k.Przydzial() ZJADA
                    from KocuryO k
                    where (
                            select count(distinct k1.Przydzial())
                            from KocuryO k1
                            where k1.Przydzial() > k.Przydzial()
                          ) < 5)
    loop
        sa_wiersze := true;
        dbms_output.put_line(rpad(i, 3) || rpad(rekord.ps, 10) || lpad(rekord.ZJADA, 6));
        i := i + 1;
    end loop;
    if not sa_wiersze
        then raise brak_kotow;
    end if;
exception
    when brak_kotow then dbms_output.put_line('Brak kotow');
    when others then dbms_output.put_line(sqlerrm);
end;











--zad49
declare
begin
    execute immediate
    'create table Myszy (
    nr_myszy number generated by default on null as identity constraint my_nr_pk primary key,
    lowca varchar2(15) constraint my_lo_fk references Kocury(pseudo),
    zjadacz varchar2(15) constraint my_zj_fk references Kocury(pseudo),
    waga_myszy number constraint my_wm_ch check(waga_myszy between 6 and 30),
    data_zlowienia date,
    data_wydania date
    )';
end;
                
create or replace function ostatnia_sroda(akt_data date)
return date as
    ost_sroda date;
begin
    select next_day(last_day(next_day(to_date(akt_data)-1, 3))-7, 3)
    into ost_sroda from dual;
    return ost_sroda;
end;

create or replace function random_data(pop_sr date, ost_sr date)
return date as
    pop_char char(10);
    ost_char char(10);
    rand_data date;
begin
    select to_char(pop_sr+1,'J'), to_char(ost_sr,'J')
    into pop_char, ost_char from DUAL;
    select to_date(trunc(dbms_random.value(pop_char, ost_char)),'J')
    into rand_data from DUAL;
    return rand_data;
end;

create or replace procedure dodaj_myszy_kota(sr_zapo number, pop_sr date, ost_sr date, pseudo Kocury.pseudo%type, ost_msc boolean)
as
    zjad Kocury.pseudo%type;
    data_wyd date;
    type td is table of date index by binary_integer;
    type tn is table of number index by binary_integer;
    tab_waga tn;
    tab_data td;
begin
    if not ost_msc 
    then zjad := pseudo;
         data_wyd := ost_sr;
    end if;

    for j in 1..sr_zapo
    loop
        tab_waga(j) := round(dbms_random.value(6, 30), 1);
        tab_data(j) := random_data(pop_sr, ost_sr);
    end loop;

    forall j in 1..sr_zapo
    insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values(pseudo, zjad, tab_waga(j), tab_data(j), data_wyd);
end;

declare
    type tp is table of Kocury.pseudo%type;
    type tm is table of number;
    tab_pseudo tp:=tp(); tab_myszy tm:=tm();
    data_start date := '2004-01-01';
    data_stop date := '2018-01-15';
    poprz_sroda_msc date := ostatnia_sroda(data_start-30); 
    ost_sroda_msc date := ostatnia_sroda(data_start);
    rand_data date;
    ostatni_msc boolean := false;
    ind number;
    ind_temp number;
    zapo number;
    sr_zapo number;
    offset number;
    type tn is table of number index by binary_integer;
    tab_ind tn;
begin
    delete from Myszy;
    insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', 'TYGRYS', 6, null, null);
    select nr_myszy + 1 into offset from Myszy where lowca = 'TYGRYS';
    delete from Myszy;
    ind := offset;
    
    while poprz_sroda_msc < data_stop
    loop
        select pseudo, NVL(przydzial_myszy,0) + NVL(myszy_extra,0)
        bulk collect into tab_pseudo, tab_myszy
        from Kocury
        where w_stadku_od < poprz_sroda_msc;
        
        if ost_sroda_msc >= data_stop 
        then ost_sroda_msc := data_stop;
             ostatni_msc := true;
        end if;
        
        select sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) into zapo 
        from Kocury 
        where w_stadku_od < poprz_sroda_msc;
        
        sr_zapo := ceil(zapo / tab_pseudo.count);
        
        for i in 1..tab_pseudo.count
        loop
            dodaj_myszy_kota(sr_zapo, poprz_sroda_msc, ost_sroda_msc, tab_pseudo(i), ostatni_msc);  
        end loop;
        
        if not ostatni_msc
        then
            for i in 1..tab_pseudo.count
            loop
                for j in 1..tab_myszy(i)
                loop
                    ind := ind + 1;  
                    tab_ind(j) := ind;
                end loop;
                
                forall j in 1..tab_myszy(i)
                update Myszy 
                set zjadacz = tab_pseudo(i) 
                where nr_myszy = tab_ind(j);
                tab_ind.delete();
            end loop;
        end if;
        
        select offset + count(nr_myszy) + 1 into ind from Myszy;
        
        poprz_sroda_msc := ost_sroda_msc;
        ost_sroda_msc := ostatnia_sroda(ost_sroda_msc+1);
    end loop;
end;

select count(nr_myszy) from Myszy;

--procedura przyjmujaca myszy

create table Myszy_PLACEK 
(
    id_myszy number constraint mp_id_pk PRIMARY KEY,
    waga_myszy number constraint mp_wa_ch check (waga_myszy between 6 and 30)
);

create or replace procedure przyjmij_myszy(pseudo Kocury.pseudo%type)
as 
    type tw is table of number;
    tab_waga tw:=tw();
    l_myszy number;
    dynamic_command varchar2(100);
    pragma autonomous_transaction;
begin
    dynamic_command := 'select count(*) from Myszy_' || pseudo;
    execute immediate dynamic_command into l_myszy;
    
    dynamic_command := 'select waga_myszy from Myszy_' || pseudo;
    execute immediate dynamic_command bulk collect into tab_waga;

    forall i in 1..l_myszy
    insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values(pseudo, null, tab_waga(i), sysdate, null);
        
    execute immediate 'delete from Myszy_' || pseudo;
    commit;
end;

insert into Myszy_PLACEK values(1, 7);
insert into Myszy_PLACEK values(2, 15);
insert into Myszy_PLACEK values(3, 23);
insert into Myszy_PLACEK values(4, 27);
insert into Myszy_PLACEK values(5, 9);

delete from Myszy;

exec przyjmij_myszy('PLACEK');

select * from Myszy_PLACEK;
select * from Myszy;



--procedura wyplacajaca myszy

create or replace procedure wyplata(dzisiaj date)
as 
    type tp is table of Kocury.pseudo%type;
    type tm is table of number;
    tab_pseudo tp:=tp(); tab_przydzial tm:=tm(); tab_myszy tm:=tm();
    suma_myszy number;
    index_kota number; lokalny_index number;
    przydzielono boolean := false;    
    dynamic_command varchar(100);
begin
    if dzisiaj = ostatnia_sroda(dzisiaj)
    then
        select pseudo, nvl(przydzial_myszy,0) + nvl(myszy_extra,0)
        bulk collect into tab_pseudo, tab_przydzial
        from Kocury
        connect by prior pseudo=szef
        start with szef is null
        order by level;
        
        select sum(nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) 
        into suma_myszy from Kocury;
        
        select nr_myszy bulk collect into tab_myszy 
        from Myszy where zjadacz is null;
        
        dbms_output.put_line('Liczba myszy: ' || tab_myszy.count || ' i liczba kotow: ' || tab_pseudo.count);  
        
        for i in 0..(tab_myszy.count-1)
        loop
            if i < suma_myszy
            then
                przydzielono := false;
                lokalny_index := 0;
                while not przydzielono and lokalny_index < tab_pseudo.count
                loop
                    index_kota := (mod(i + lokalny_index, tab_pseudo.count) + 1);
                               
                    if tab_przydzial(index_kota) > 0 
                    then
                        update Myszy
                        set zjadacz = tab_pseudo(index_kota),
                            data_wydania = dzisiaj
                        where nr_myszy = tab_myszy(i+1);
                        przydzielono := true;
                        tab_przydzial(index_kota) := tab_przydzial(index_kota)-1;
                    end if;  
                    lokalny_index := lokalny_index + 1;
                end loop;
            end if;            
        end loop;
                
        dbms_output.put_line('Suma myszy: ' || suma_myszy || ' ~ ' || tab_myszy.count);          
    else
        dbms_output.put_line('Brak mozliwosci wyplacenia myszy - dzis nie jest ostatnia sroda tego miesiaca.');
    end if;    
end;

exec wyplata('2018-01-31');

insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
    values('TYGRYS', null, 10, '2018-01-03', null);
    