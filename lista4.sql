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
        return pseudo||', '||imie||', '||plec||', '||nvl(temp, ' ')||', '||nvl(to_char(w_stadku_od), ' ')||', '||nvl(przydzial_myszy, 0)||', '||nvl(myszy_extra, 0);
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


--TRIGGERY do KocuryO
create or replace trigger dodawanie_kocuraO_elita
before insert on ElitaO
for each row
begin
    insert into KocuryO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    values (:new.imie,:new.plec,:new.pseudo,:new.szef,:new.w_stadku_od,:new.przydzial_myszy,:new.myszy_extra);
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
    insert into KocuryO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra)
    values (:new.imie,:new.plec,:new.pseudo,:new.szef,:new.w_stadku_od,:new.przydzial_myszy,:new.myszy_extra);
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
    myszy_extra = myszy_extra, k.szef = szef;
end;

create or replace trigger modyfikowanie_kocuraO_elita
after update on ElitaO
for each row
begin
    update KocuryO k
    set k.pseudo = pseudo, k.imie = imie, k.plec = plec, k.w_stadku_od = w_stadku_od, k.przydzial_myszy = przydzial_myszy,
    myszy_extra = myszy_extra, k.szef = szef;
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

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    VALUES ('MRUCZEK','M','TYGRYS',NULL,'2002-01-01',103,33,NULL);

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'PUCEK','M','RAFA',REF(O),'2006-10-15',65,NULL,null FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'KOREK','M','ZOMBI',REF(O),'2004-03-16',75,13,null FROM ElitaO O where O.pseudo = 'TYGRYS';

INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'BOLEK','M','LYSY',REF(O),'2006-08-15',72,21,null FROM ElitaO O where O.pseudo = 'TYGRYS';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra, sluga)
    SELECT 'PUNIA','D','KURKA',REF(o),'2008-01-01',61,NULL, null from ElitaO o where o.pseudo = 'ZOMBI';
    
INSERT INTO ElitaO(imie,plec,pseudo,szef,w_stadku_od,przydzial_myszy,myszy_extra,sluga)
    SELECT 'MICKA','D','LOLA',REF(O),'2009-10-14',25,47,NULL FROM ElitaO O where O.pseudo = 'TYGRYS';
    
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

(select e.getPseudo() PSEUDO, e.Przydzial() ZJADA
from ElitaO e
where (
        select count(distinct e1.Przydzial())
        from ElitaO e1
        where e1.Przydzial() > e.Przydzial()
      ) < &n
)
union
(select p.getPseudo() PSEUDO, p.Przydzial() ZJADA
from PlebsO p
where (
        select count(distinct p1.Przydzial())
        from PlebsO p1
        where p1.Przydzial() > p.Przydzial()
      ) < &n
)order by 2 desc, 1 desc;

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
    waga_myszy number constraint my_wm_ch check(waga_myszy between 25 and 50),
    data_zlowienia date,
    data_wydania date
    )';
end;

declare
    zapotrzebowanie number;
    srednieZapotrzebowanie number;
    przydzial number;
    ps Kocury.Pseudo%type;
    srodaPoprzednia date := to_date('2004-01-01');
    sroda date := '2004-01-01';
    tempData date;
    tempData2 date;
    tempData3 date;
    type pseudoT is table of Kocury.Pseudo%type;
    koty pseudoT;
    type dateT is table of Date;
    datyDostarczenia dateT;
    lbKotow number;
    zapytanie varchar2(500);
begin
    while sroda < next_day(last_day(add_months('2018-01-09', -1)) - 7, 'WEDNESDAY') 
    loop
        sroda := NEXT_DAY(LAST_DAY(srodaPoprzednia + 7) - 7, 'WEDNESDAY');
        
        execute immediate 
        'select pseudo from Kocury where w_stadku_od < ' || q'[']' || sroda || q'[']' bulk collect into koty;
        
        lbKotow := koty.count;
        
        select sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) into zapotrzebowanie 
        from Kocury 
        where w_stadku_od < sroda;
        
        srednieZapotrzebowanie := zapotrzebowanie / lbKotow;
        
        for i in 1..srednieZapotrzebowanie
        loop
            for j in 1..lbKotow
            loop
                select w_stadku_od into tempData from Kocury where pseudo = koty(j);
                tempData2 := tempData + dbms_random.value(0, sroda - tempData);
                tempData3 := srodaPoprzednia + dbms_random.value(0, sroda - srodaPoprzednia);
                if tempData between srodaPoprzednia and sroda then
                    execute immediate 
                    'insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
                    values(' || ':kot' || ', null, ' || round(dbms_random.value(25,50), 1) || 
                    ', ' || q'[']' || tempData2 || q'[']' || ', ' || q'[']' ||  sroda  || q'[']' || ')'
                    using koty(j);
                else
                    execute immediate
                    'insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
                    values(' || ':kot' || ', null, ' || round(dbms_random.value(25,50), 1) || 
                    ', ' || q'[']' || tempData3 || q'[']' || ', ' || q'[']' ||  sroda  || q'[']' || ')'
                    using koty(j);
                end if;
            end loop;
            --insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
            --values ('TYGRYS', 'TYGRYS', dbms_random.value(25,50), sysdate + dbms_random.value(0, to_date('2016-09-04') - to_date('2015-12-12')), sysdate);
        end loop;
        
        for i in 1..lbKotow
        loop
            select nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), pseudo into przydzial, ps from Kocury where pseudo = koty(i);
            for j in 1..przydzial
            loop
                update Myszy set zjadacz = ps
                where zjadacz = null and rownum <= przydzial;
            end loop;
        end loop;
        
        
        for kot in 
        (select pseudo,nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) przydzial
        from kocury where w_stadku_od < sroda order by przydzial desc) 
        loop
            update Myszy set zjadacz = kot.pseudo
            where zjadacz = null and rownum <= kot.przydzial;
        end loop;
        
        commit;
        
        srodaPoprzednia := sroda;
    end loop;
end;

select count(nr_myszy)
from Myszy;


forall j in 1..lbKotow
            execute immediate 
            'insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
            values(' || koty(j) || ', null' || dbms_random.value(25,50) || ', :da_dost, ' || sroda || ')'
            using datyDostarczenia(j);


        
for i in 1..lbKotow
loop
    select w_stadku_od into tempData from Kocury where pseudo = koty(i);
    if tempData between srodaPoprzednia and sroda then
        datyDostarczenia.extend; datyDostarczenia(i) := dbms_random.date(tempData, sroda);
    else
        execute immediate
        'insert into datyDostarczenia values (dbms_random.date(srodaPoprzednia, sroda))';
    end if;
end loop;

select w_stadku_od into tempData from Kocury where pseudo = koty(i);
                if tempData between srodaPoprzednia and sroda then
                    execute immediate 
                    'insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
                    values(' || koty(j) || ', ' || koty(j) || ', ' || dbms_random.value(25,50) || ', ' || trunc(tempData) + dbms_random.value(0, trunc(sroda) - trunc(tempData)) || ', ' || sroda || ')';
                else
                    execute immediate 
                    'insert into Myszy(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
                    values(' || koty(j) || ', ' || koty(j) || ', ' || dbms_random.value(25,50) || ', ' || trunc(srodaPoprzednia) + dbms_random.value(0, trunc(sroda) - trunc(srodaPoprzednia)) || ', ' || sroda || ')';
                end if;
                
                execute immediate 
                'insert into Mysz(lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania) 
                values(' || ':kot' || ', ' || ':kot' || ', ' || dbms_random.value(25,50) || ', ' || q'[']' || to_date('2014-01-01') || q'[']' || ', ' || q'[']' || sroda || q'[']' || ')'
                using koty(j), koty(j);