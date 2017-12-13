--zad34
DECLARE
    nazwa VARCHAR(20);
BEGIN
    SELECT DISTINCT funkcja INTO nazwa
    FROM Kocury
    WHERE funkcja = '&Funkcja';
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota z funkcja: ' || nazwa);
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('Nie znaleziono');
END;

--zad35
DECLARE
    rocznyPrzydzial NUMBER;
    imieK VARCHAR(20);
    miesPrzyst VARCHAR(20);
BEGIN
    SELECT 12*(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)), imie, to_char(extract(month from w_stadku_od)) 
        into rocznyPrzydzial, imieK, miesPrzyst
    FROM Kocury
    WHERE pseudo = '&Pseudo';
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

--zad36
DECLARE
    CURSOR kursor IS
        SELECT przydzial_myszy, pseudo, funkcja, max_myszy
        FROM Kocury NATURAL JOIN Funkcje
        ORDER BY przydzial_myszy DESC
        FOR UPDATE OF przydzial_myszy;
    rekord kursor%ROWTYPE;
    fmax NUMBER(4) :=0;
    stary NUMBER(4) :=0;
    nowy NUMBER(4) :=0;
    suma NUMBER(4) :=0;
    i NUMBER(4) :=0;
BEGIN
    SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
    WHILE suma < 1051
    LOOP
        OPEN kursor;
        LOOP
            FETCH kursor INTO rekord; EXIT WHEN kursor%NOTFOUND;
            SELECT przydzial_myszy INTO stary FROM Kocury WHERE pseudo = rekord.pseudo;
            nowy := NVL(rekord.przydzial_myszy, 0) * 1.1;
            IF nowy > rekord.max_myszy THEN
                nowy := rekord.max_myszy;
            END IF;
            UPDATE Kocury SET przydzial_myszy = nowy WHERE pseudo = rekord.pseudo;
            SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
            IF stary <> nowy THEN
                i := i+1;
            END IF;
            --IF suma > 1050 THEN
            --    EXIT;
            --END IF;
        END LOOP;
        CLOSE kursor;
    END LOOP;
    DBMS_OUTPUT.put_line('Calk. przydzial w stadku ' || suma || '   Zmian - ' || i);
END;

SELECT imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" FROM Kocury ORDER BY przydzial_myszy DESC;

ROLLBACK;

alter trigger zakaz_przekroczenia disable;
alter trigger zakaz_przekroczenia enable;

alter trigger kara_milus disable;
alter trigger kara_milus enable;

alter trigger przydzial disable;
alter trigger przydzial enable;

alter trigger utulenie_zalu disable;
alter trigger utulenie_zalu enable;

alter trigger rozliczenie disable;
alter trigger rozliczenie enable;

--zad37
declare
    sa_wiersze boolean := false;
    brak_kotow exception;
    i number(4) := 1;
begin
    dbms_output.put_line(rpad('Nr', 3) || rpad('Pseudonim', 10) || lpad('Zjada', 6));
    for rekord in ( select pseudo, nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) ZJADA
                    from Kocury k
                    where (
                            select count(distinct nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))
                            from Kocury
                            where nvl(przydzial_myszy, 0) + NVL(myszy_extra, 0) > NVL(k.przydzial_myszy, 0) + NVL(k.myszy_extra, 0)
                          ) < 5)
    loop
        sa_wiersze := true;
        dbms_output.put_line(rpad(i, 3) || rpad(rekord.pseudo, 10) || lpad(rekord.ZJADA, 6));
        i := i + 1;
    end loop;
    if not sa_wiersze
        then raise brak_kotow;
    end if;
exception
    when brak_kotow then dbms_output.put_line('Brak kotow');
    when others then dbms_output.put_line(sqlerrm);
end;

--zad38
declare
    max_lvl number := &lb_przelozonych;
    curr_kot Kocury%rowtype;
begin
    dbms_output.put_line('Wynik dla liczby przelozonych = ' || max_lvl);
    
    dbms_output.put(rpad('Imie', 10));
    for i in 1..max_lvl
    loop
        dbms_output.put('  |  ' || rpad('Szef ' || i, 10));
    end loop;
    dbms_output.put_line(' ');
    
    dbms_output.put(rpad('----------', 10));
    for i in 1..max_lvl
    loop
        dbms_output.put(' --- ' || rpad('----------', 10));
    end loop;
    dbms_output.put_line(' ');
    
    for rekord in (select * from Kocury where funkcja in ('KOT', 'MILUSIA'))
    loop
        dbms_output.put(rpad(rekord.imie, 10));
        curr_kot := rekord;
        for curr_lvl in 1..max_lvl
        loop
            if curr_kot.szef is null 
                then dbms_output.put('  |  ' || rpad(' ', 10));
            else
                select * into curr_kot from Kocury where pseudo = curr_kot.szef;
                dbms_output.put('  |  ' || rpad(curr_kot.imie, 10));
            end if;
        end loop;
        dbms_output.put_line(' ');
    end loop;
end;

--zad39
declare
    nr_nowy Bandy.nr_bandy%type := &numer;
    nazwa_nowa Bandy.nazwa%type := '&nazwa';
    teren_nowy Bandy.teren%type := '&teren';
    lb number := 0;
    zla_wartosc exception;
    zly_nr exception;
    komunikat varchar(50) := '';
begin
    select count(nr_bandy) into lb from Bandy where nr_bandy = nr_nowy;
    if nr_nowy < 1
        then raise zly_nr;
    end if;
    if lb > 0
        then komunikat := nr_nowy;
    end if;
    select count(nazwa) into lb from Bandy where nazwa = nazwa_nowa;
    if lb > 0
        then 
        if length(komunikat) > 0
            then komunikat := komunikat || ', ' || nazwa_nowa;
        else
            komunikat := nazwa_nowa;
        end if;
    end if;
    select count(teren) into lb from Bandy where teren = teren_nowy;
    if lb > 0
        then 
        if length(komunikat) > 0
            then komunikat := komunikat || ', ' || teren_nowy;
        else
            komunikat := teren_nowy;
        end if;
    end if;
    if length(komunikat) > 0
        then raise zla_wartosc;
    end if;
    insert into Bandy(nr_bandy, nazwa, teren)
    values (nr_nowy, nazwa_nowa, teren_nowy);
    dbms_output.put_line('ok');
exception
    when zly_nr
        then dbms_output.put_line('Podales ujemny numer bandy!');
    when zla_wartosc
        then dbms_output.put_line(komunikat || ': juz istnieje');
end;

rollback;

--zad40
create or replace procedure dodaj_bande(nr_nowy Bandy.nr_bandy%type, nazwa_nowa Bandy.nazwa%type, teren_nowy Bandy.teren%type)
as
    lb number := 0;
    zla_wartosc exception;
    zly_nr exception;
    komunikat varchar(50) := '';
begin
    select count(nr_bandy) into lb from Bandy where nr_bandy = nr_nowy;
    if nr_nowy < 1
        then raise zly_nr;
    end if;
    if lb > 0
        then komunikat := nr_nowy;
    end if;
    select count(nazwa) into lb from Bandy where nazwa = nazwa_nowa;
    if lb > 0
        then 
        if length(komunikat) > 0
            then komunikat := komunikat || ', ' || nazwa_nowa;
        else
            komunikat := nazwa_nowa;
        end if;
    end if;
    select count(teren) into lb from Bandy where teren = teren_nowy;
    if lb > 0
        then 
        if length(komunikat) > 0
            then komunikat := komunikat || ', ' || teren_nowy;
        else
            komunikat := teren_nowy;
        end if;
    end if;
    if length(komunikat) > 0
        then raise zla_wartosc;
    end if;
    insert into Bandy(nr_bandy, nazwa, teren)
    values (nr_nowy, nazwa_nowa, teren_nowy);
    dbms_output.put_line('ok');
exception
    when zly_nr
        then dbms_output.put_line('Podales ujemny numer bandy!');
    when zla_wartosc
        then dbms_output.put_line(komunikat || ': juz istnieje');
end;

begin
    dodaj_bande(9, 'asda', 'd');
end;

rollback;


--zad41
create or replace trigger nr_nowej_bandy
before insert on Bandy
for each row
begin
    select max(nr_bandy) + 1 into :new.nr_bandy from Bandy;
end;

begin
    dodaj_bande(9, 'as', 'd');
end;

rollback;

--zad42a
create or replace package pamiec as
    przydzial number := 0;
    kara number := 0;
    nagroda number := 0;
end pamiec;

create or replace trigger przydzial
before update on Kocury
begin
    select przydzial_myszy into pamiec.przydzial
    from Kocury
    where pseudo = 'TYGRYS';
end;

create or replace trigger utulenie_zalu
before update on Kocury
for each row
declare
    --fmax number := 0;
    --fmin number := 0;
    roznica number := 0;
begin
    --select max_myszy, min_myszy into fmax, fmin from Funkcje where funkcja = :new.funkcja;
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;
    if :new.funkcja = 'MILUSIA'
        then 
        if roznica < 0
            then :new.przydzial_myszy := :old.przydzial_myszy;
        end if;
        if roznica < 0.1 * pamiec.przydzial
            then pamiec.kara := pamiec.kara + 0.1 * pamiec.przydzial;
            --:new.przydzial_myszy := :new.przydzial_myszy + 0.1 * pamiec.przydzial;
            :new.myszy_extra := :new.myszy_extra + 5;
        else
            pamiec.nagroda := pamiec.nagroda + 5;
        end if;
    end if;
    
    --if :new.przydzial_myszy > fmax
    --    then :new.przydzial_myszy := fmax;
    --elsif :new.przydzial_myszy < fmin
    --    then :new.przydzial_myszy := fmin;
    --end if;
end;

create or replace trigger rozliczenie
after update on Kocury
declare
     tmp number := 0;
begin
    if pamiec.kara > 0 
        then tmp := pamiec.kara;
        pamiec.kara := 0;
        update Kocury 
        set przydzial_myszy = przydzial_myszy  - tmp
        where pseudo = 'TYGRYS';
	end if;
	if pamiec.nagroda > 0 
		then tmp := pamiec.nagroda;
        pamiec.nagroda := 0;
        update Kocury 
        set myszy_extra = myszy_extra + tmp
		where pseudo = 'TYGRYS';
	end if;
end;


select * from Kocury where pseudo = 'PUSZYSTA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 3 where pseudo = 'PUSZYSTA';

select * from Kocury where pseudo = 'KURKA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 5 where pseudo = 'KURKA';

select * from Kocury where funkcja = 'MILUSIA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 7 where funkcja = 'MILUSIA';

rollback;

--zad42b
create or replace trigger zlozone_utulenie_zalu
    for update on Kocury
    compound trigger 
        przydzial number := 0;
        kara number := 0;
        nagroda number := 0;
        --fmax number := 0;
        --fmin number := 0;
    before statement is
    begin
        select przydzial_myszy into przydzial
        from Kocury
        where pseudo = 'TYGRYS';
    end before statement;
    
    before each row is 
        roznica number := 0;
    begin
        --select max_myszy, min_myszy into fmax, fmin from Funkcje where funkcja = :new.funkcja;
        roznica := :new.przydzial_myszy - :old.przydzial_myszy;
        if :new.funkcja = 'MILUSIA'
            then 
            if roznica < 0
                then :new.przydzial_myszy := :old.przydzial_myszy;
            end if;
            if roznica < 0.1 * przydzial
                then kara := kara + 0.1 * przydzial;
                --:new.przydzial_myszy := :new.przydzial_myszy + 0.1 * przydzial;
                :new.myszy_extra := :new.myszy_extra + 5;
            else
                nagroda := nagroda + 5;
            end if;
        end if;
        
        --if :new.przydzial_myszy > fmax
        --    then :new.przydzial_myszy := fmax;
        --elsif :new.przydzial_myszy < fmin
        --    then :new.przydzial_myszy := fmin;
        --end if;
    end before each row;
    
    after statement is
        tmp number := 0;
    begin
        if kara > 0 
            then tmp := kara;
            kara := 0;
            update Kocury 
            set przydzial_myszy = przydzial_myszy  - tmp
            where pseudo = 'TYGRYS';
        end if;
        if nagroda > 0 
            then tmp := nagroda;
            nagroda := 0;
            update Kocury 
            set myszy_extra = myszy_extra + tmp
            where pseudo = 'TYGRYS';
        end if;
    end after statement;
end zlozone_utulenie_zalu;

alter trigger przydzial disable;
alter trigger przydzial enable;

alter trigger utulenie_zalu disable;
alter trigger utulenie_zalu enable;

alter trigger rozliczenie disable;
alter trigger rozliczenie enable;

alter trigger zlozone_utulenie_zalu disable;
alter trigger zlozone_utulenie_zalu enable;

select * from Kocury where pseudo = 'PUSZYSTA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 3 where pseudo = 'PUSZYSTA';

select * from Kocury where pseudo = 'KURKA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 5 where pseudo = 'KURKA';

select * from Kocury where funkcja = 'MILUSIA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 4 where funkcja = 'MILUSIA';

rollback;



--zad43
declare
    cursor curFunkcje is
        select distinct f.funkcja
        from Kocury k left join Funkcje f on k.funkcja = f.funkcja;
    cursor curBandy is
        select distinct b.nr_bandy, b.nazwa
        from Kocury k left join Bandy b on k.nr_bandy = b.nr_bandy;
    cursor curPlec is
        select distinct plec
        from Kocury k;
  plec Kocury.plec%type;
  ile number;
begin
  dbms_output.put(rpad('NAZWA BANDY', 20) || rpad('PLEC', 7) || rpad('ILE', 5));
  for f in curFunkcje 
  loop
      dbms_output.put(rpad(f.funkcja, 10));
  end loop;
  dbms_output.put_line(rpad('SUMA', 10));
  dbms_output.put(lpad(' ', 20, '-') || lpad(' ', 7, '-') || lpad(' ', 5, '-'));
  for funkcja in curFunkcje 
  loop
      dbms_output.put(' ---------');
  end loop;
  dbms_output.put_line(' ---------');
  
  for b in curBandy
  loop
      dbms_output.put(rpad(b.nazwa, 20));
      for pl in curPlec
      loop
        if pl.plec = 'M' then
          dbms_output.put(rpad('Kocur',7));
        else
          dbms_output.put(rpad(' ',20));
          dbms_output.put(rpad('Kotka',7));
        end if;
        
        select count(*) into ile
        from Kocury
        where plec = pl.plec and nr_bandy = b.nr_bandy;
        dbms_output.put(lpad(ile || ' ',5));
        for f in curFunkcje
        loop
            select sum(decode(funkcja, f.funkcja, nvl(przydzial_myszy,0) + nvl(myszy_extra,0), 0)) 
            into ile
            from Kocury
            where plec = pl.plec and nr_bandy = b.nr_bandy;
            dbms_output.put(lpad(ile || ' ',10));
        end loop;
            
        select sum(nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) into ile
        from Kocury
        where plec = pl.plec and nr_bandy = b.nr_bandy;
        
        dbms_output.put(lpad(ile || ' ',10));
        dbms_output.put_line('');
      end loop;
  end loop;
  dbms_output.put('Z' || lpad(' ', 19, '-') || lpad(' ', 7, '-') || lpad(' ', 5, '-'));
  for f in curFunkcje
  loop
        dbms_output.put(lpad(' ', 10, '-'));
  end loop;
  
  dbms_output.put_line(lpad(' ', 10, '-'));
  dbms_output.put(rpad('ZJADA RAZEM', 20) || lpad(' ', 7) || lpad(' ', 5));
  
  for f in curFunkcje
  loop
    select sum(nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) into ile
    from Kocury k 
    where k.funkcja = f.funkcja;
    
    dbms_output.put(lpad(ile || ' ', 10));
  end loop;
  
  select sum(nvl(przydzial_myszy,0) + nvl(myszy_extra,0)) into ile from Kocury;
  
  dbms_output.put(lpad(ile || ' ',10));
  dbms_output.put_line('');
end;


--zad44
create or replace package zad44 
as
  procedure dodaj_bande(nr_nowy Bandy.nr_bandy%type, nazwa_nowa Bandy.nazwa%type, teren_nowy Bandy.teren%type);  
  function podatek_poglowy(ps Kocury.pseudo%type) return number;
end Zad44;

create or replace package body zad44 
as
    procedure dodaj_bande(nr_nowy Bandy.nr_bandy%type, nazwa_nowa Bandy.nazwa%type, teren_nowy Bandy.teren%type)
    as
        lb number := 0;
        zla_wartosc exception;
        zly_nr exception;
        komunikat varchar(50) := '';
    begin
        select count(nr_bandy) into lb from Bandy where nr_bandy = nr_nowy;
        if nr_nowy < 1
            then raise zly_nr;
        end if;
        if lb > 0
            then komunikat := nr_nowy;
        end if;
        select count(nazwa) into lb from Bandy where nazwa = nazwa_nowa;
        if lb > 0
            then 
            if length(komunikat) > 0
                then komunikat := komunikat || ', ' || nazwa_nowa;
            else
                komunikat := nazwa_nowa;
            end if;
        end if;
        select count(teren) into lb from Bandy where teren = teren_nowy;
        if lb > 0
            then 
            if length(komunikat) > 0
                then komunikat := komunikat || ', ' || teren_nowy;
            else
                komunikat := teren_nowy;
            end if;
        end if;
        if length(komunikat) > 0
            then raise zla_wartosc;
        end if;
        insert into Bandy(nr_bandy, nazwa, teren)
        values (nr_nowy, nazwa_nowa, teren_nowy);
        dbms_output.put_line('ok');
    exception
        when zly_nr
            then dbms_output.put_line('Podales ujemny numer bandy!');
        when zla_wartosc
            then dbms_output.put_line(komunikat || ': juz istnieje');
    end dodaj_bande;
    
    function podatek_poglowy(ps Kocury.pseudo%type) return number 
    is
        wynik number := 0;
        tmp number := 0;
        tmpF Kocury.funkcja%type;
    begin
        select ceil(0.05 * (nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) ) into wynik
        from Kocury where pseudo = ps;
        
        select count(pseudo) into tmp
        from Kocury where szef = ps;
        if tmp = 0 then
            wynik := wynik + 2;
        end if;
        
        select count(pseudo) into tmp
        from Wrogowie_Kocurow where pseudo = ps;
        if tmp = 0 then
            wynik := wynik + 1;
        end if;
        
        select funkcja into tmpF from Kocury
        where pseudo = ps;
        if tmpF = 'MILUSIA' then
            wynik := wynik + 5;
        end if;
        return wynik;
    end podatek_poglowy;
    
end zad44;


declare
    cursor cur is
        select distinct pseudo
        from Kocury;
begin
    dbms_output.put_line(rpad('PSEUDO', 10) || '   ' || rpad('Podatek Poglowy', 16));
    dbms_output.put_line('');
    for kot in cur
    loop
        dbms_output.put_line(rpad(kot.pseudo, 10) || ' - ' || rpad(zad44.podatek_poglowy(kot.pseudo), 5));
    end loop;
end;



--zad45
create table Dodatki_extra (
    pseudo varchar2(15) 
    constraint de_fk_ps references Kocury(pseudo)
    constraint de_pk_ps primary key,
    dod_extra number(3) not null
);

drop table Dodatki_extra;

create or replace trigger kara_milus
after update of przydzial_myszy on Kocury
for each row
declare
    pragma autonomous_transaction;
begin
    if :new.przydzial_myszy > :old.przydzial_myszy and :new.funkcja = 'MILUSIA' and LOGIN_USER != 'TYGRYS' then
    execute immediate 
        'declare
            cursor cur is
                select pseudo from Kocury where funkcja = ''MILUSIA'';
            tmp number := 0;
        begin
            for kot in cur
            loop
                select count(*) into tmp from Dodatki_extra where kot.pseudo = pseudo;
                if tmp = 0 then
                    insert into Dodatki_extra(pseudo, dod_extra)
                    values (kot.pseudo, -10);
                else
                    update Dodatki_extra set dod_extra = dod_extra - 10 WHERE pseudo = kot.pseudo;
                end if;
            end loop;
        end;';
        commit;
    end if;
end;

rollback;

select * from Dodatki_extra;

select * from Kocury where pseudo = 'PUSZYSTA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 3 where pseudo = 'PUSZYSTA';

select * from Kocury where pseudo = 'KURKA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 5 where pseudo = 'KURKA';

select * from Kocury where funkcja = 'MILUSIA' or pseudo = 'TYGRYS';
update Kocury set przydzial_myszy = przydzial_myszy + 1 where funkcja = 'MILUSIA';


--zad46
create table Proby_przekroczenia (
    id_proby number(2) generated by default on null as identity
    constraint pp_pk_id primary key,
    kto varchar(15),
    kiedy date,
    komu varchar(15),
    jak varchar(15)
);

create or replace trigger zakaz_przekroczenia
before insert or update of przydzial_myszy on Kocury
for each row
declare
    fmin number := 0;
    fmax number := 0;
    kto varchar(15);
    jak varchar(15);
    --tmpUser number := 0;
    --tmpLogin varchar(15);
    pragma autonomous_transaction;
begin
    select max_myszy, min_myszy into fmax, fmin from Funkcje where funkcja = :new.funkcja;
    
    --tmpLogin := login_user;
    --select count(*) into tmpUser from Kocury where pseudo = tmpLogin;
    
    if :new.przydzial_myszy > fmax then
        if updating then
            jak := 'UPDATE';
        elsif inserting then
            jak := 'INSERT';
        end if;
        
        --if tmpUser = 0 then
        --    kto := 'PUSZYSTA';
        --else
        --    kto := login_user;
        --end if;
        kto := login_user;
        insert into Proby_przekroczenia(kto, kiedy, komu, jak) values(kto, sysdate, :new.pseudo, jak);
        commit;
        raise_application_error(-20001, 'Przydzial myszy przekroczyl maksimum pelnionej funkcji');
    elsif :new.przydzial_myszy < fmin then
        if updating then
            jak := 'UPDATE';
        elsif inserting then
            jak := 'INSERT';
        end if;
        kto := login_user;
        insert into Proby_przekroczenia(kto, kiedy, komu, jak) values(kto, sysdate, :new.pseudo, jak);
        commit;
        raise_application_error(-20002, 'Przydzial myszy przekroczyl minimum pelnionej funkcji');
    end if;
end;

drop table Proby_przekroczenia;

select * from Kocury where pseudo = 'PUSZYSTA';
update Kocury set przydzial_myszy = przydzial_myszy + 13 where pseudo = 'PUSZYSTA';

insert into Kocury(imie,plec,pseudo,funkcja,szef,w_stadku_od,przydzial_myszy,myszy_extra,nr_bandy)
    values ('OLA','D','FASOLA','LAPACZ','TYGRYS',sysdate,25,10,3);

select * from Proby_przekroczenia;

rollback;





