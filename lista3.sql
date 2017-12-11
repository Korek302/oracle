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

declare
    nr Bandy.nr_bandy%type := 9;
    n Bandy.nazwa%type := 'asda';
    t Bandy.teren%type := 'd';
begin
    dodaj_bande(nr, n, t);
end;

rollback;


--zad41
