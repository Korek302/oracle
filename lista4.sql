--zad47

--KOCURY
create or replace type KocuryT as object
(
    imie varchar2(15),
    plec varchar2(1),
    pseudo varchar2(15),
    w_stadku_od date,
    przydzial_myszy number(3),
    myszy_extra number(3),
    final map member function Porownaj return varchar2,
    member function Dane return varchar2,
    final member function getPseudo return varchar2,
    final member function getImie return varchar2,
    member function Przydzial return number
)not final;

alter type KocuryT
add attribute szef ref ElitaT
cascade;

create or replace type body KocuryT as
    final map member function Porownaj return varchar2 is
    begin
        return pseudo;
    end;
    final member function getPseudo return varchar2 is
    begin
        return pseudo;
    end;
    final member function getImie return varchar2 is
    begin
        return imie;
    end;
    member function Dane return varchar2 is
        temp varchar2(15);
    begin
        select deref(szef).pseudo into temp from dual; --the DEREF must be in a SQL Statement
        return pseudo||', '||imie||', '||plec||', '||nvl(temp, ' ')||', '||nvl(w_stadku_od, ' ')||', '||nvl(przydzial_myszy, 0)||', '||nvl(myszy_extra, 0);
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
        return pseudo||', '||imie||', '||plec||', '||nvl(temp1, ' ')||', '||nvl(w_stadku_od, ' ')||', '||nvl(przydzial_myszy, 0)||', '||nvl(myszy_extra, 0)||', '||nvl(temp2, ' ');
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
();

alter type PlebsT
add member function PseudoPana return varchar2
invalidate;

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
    data_incydentu date,
    opis_incydentu varchar2(50),
    map member function Porownaj return number,
    member function Dane return varchar2
);

create or replace type body wrogowie_kocurowT as
    map member function Porownaj return number is
    begin
        return nr_incydentu;
    end;
    member function Dane return varchar2 is
        temp varchar(15);
    begin
        select deref(kocur).pseudo into temp from dual;
        return nr_incydentu||', '||temp||', '||data_incydentu||', '||nvl(opis_incydentu, ' ');
    end;
end;

create table wrogowie_kocurowO of wrogowie_kocurowT
(
    CONSTRAINT wko_datai_nn check(data_incydentu is NOT NULL),
    CONSTRAINT wko_nr_pk PRIMARY KEY (nr_incydentu)
);



INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    VALUES ('MRUCZEK','M','TYGRYS',NULL,'2002-01-01',103,33,NULL);
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'MAN')
where pseudo = 'TYGRYS';

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'PUCEK','M','RAFA',REF(O),'2006-10-15',65,NULL,null FROM ElitaO O where O.pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'LASKA')
where pseudo = 'RAFA';

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'KOREK','M','ZOMBI',REF(O),'2004-03-16',75,13,null FROM ElitaO O where O.pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'BOLEK')
where pseudo = 'ZOMBI';

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'BOLEK','M','LYSY',REF(O),'2006-08-15',72,21,null FROM ElitaO O where O.pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'MALY')
where pseudo = 'LYSY';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra, sluga)
    SELECT 'PUNIA','D','KURKA',REF(o),'2008-01-01',61,NULL, null from ElitaO o where o.pseudo = 'ZOMBI';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'PUSZYSTA')
where pseudo = 'KURKA';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'MICKA','D','LOLA',REF(O),'2009-10-14',25,47,NULL FROM ElitaO O where O.pseudo = 'TYGRYS';
    
update ElitaO
set sluga = (select ref(o) from PlebsO o where o.pseudo = 'ZERO')
where pseudo = 'LOLA';


INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'KSAWERY','M','MAN',REF(O),'2008-07-12',51,NULL FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'JACEK','M','PLACEK',REF(O),'2008-12-01',67,NULL FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'BARI','M','RURA',REF(O),'2009-09-01',56,NULL FROM ElitaO O where O.pseudo = 'LYSY';
    
INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
   SELECT 'LUCEK','M','ZERO',REF(O),'2010-03-01',43,NULL FROM ElitaO O where O.pseudo = 'KURKA';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'SONIA','D','PUSZYSTA',REF(O),'2010-11-18',20,35 FROM ElitaO O where O.pseudo = 'ZOMBI';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'LATKA','D','UCHO',REF(O),'2011-01-01',40,NULL FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'DUDEK','M','MALY',REF(O),'2011-05-15',40,NULL FROM ElitaO O where O.pseudo = 'RAFA';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'CHYTRY','M','BOLEK',REF(O),'2002-05-05',50,NULL FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'ZUZIA','D','SZYBKA',REF(O),'2006-07-21',65,NULL FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'RUDA','D','MALA',REF(O),'2006-09-17',22,42 FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'BELA','D','LASKA',REF(O),'2008-02-01',24,28 FROM ElitaO O where O.pseudo = 'LYSY';

INSERT INTO PlebsO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    SELECT 'MELA','D','DAMA',REF(O),'2008-11-01',51,NULL FROM ElitaO O where O.pseudo = 'RAFA';
    
    
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





