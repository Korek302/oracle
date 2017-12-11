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
        SELECT przydzial_myszy, pseudo, funkcja
        FROM Kocury
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
            SELECT max_myszy INTO fmax FROM Funkcje WHERE funkcja = rekord.funkcja;
            SELECT przydzial_myszy INTO stary FROM Kocury WHERE pseudo = rekord.pseudo;
            nowy := NVL(rekord.przydzial_myszy, 0) * 1.1;
            IF nowy > fmax THEN
                nowy := fmax;
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

--zad42
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
    fmax number := 0;
    fmin number := 0;
    roznica number := 0;
begin
    select max_myszy, min_myszy into fmax, fmin from Funkcje where funkcja = :new.funkcja;
    roznica := :new.przydzial_myszy - :old.przydzial_myszy;
    if :new.funkcja = 'MILUSIA'
        then 
        if roznica < 0
            then :new.przydzial_myszy := :old.przydzial_myszy;
        end if;
        if roznica < 0.1 * pamiec.przydzial
            then pamiec.kara := pamiec.kara + 1;
            :new.przydzial_myszy := :new.przydzial_myszy + 0.1 * pamiec.przydzial;
            :new.myszy_extra := :new.myszy_extra + 5;
        else
            pamiec.nagroda := pamiec.nagroda + 1;
        end if;
    end if;
    
    if :new.przydzial_myszy > fmax
        then :new.przydzial_myszy := fmax;
    elsif :new.przydzial_myszy < fmin
        then :new.przydzial_myszy := fmin;
    end if;
end;

create or replace trigger rozliczenie
after update on Kocury
declare
      tmp NUMBER DEFAULT 0;
BEGIN
    if pamiec.kara > 0 
        then tmp := pamiec.kara;
        pamiec.kara := 0; -- przeciwdziala petli nieskonczonej
        update Kocury 
        set przydzial_myszy = przydzial_myszy * ( 1 - (0.1 * tmp))
        where pseudo = 'TYGRYS';
	end if;
	if pamiec.nagroda > 0 
		then tmp := pamiec.nagroda;
        pamiec.nagroda := 0; -- przeciwdziala petli nieskonczonej
        update Kocury 
        set myszy_extra = myszy_extra + (pamiec.nagroda * 5)
		where pseudo = 'TYGRYS';
	END IF;
END;


SELECT * FROM Kocury;

UPDATE Kocury SET przydzial_myszy = przydzial_myszy + 1;

SELECT * FROM Kocury;

ROLLBACK;




