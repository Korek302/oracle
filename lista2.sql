--zad17
SELECT PSEUDO "POLUJE W POLU", PRZYDZIAL_MYSZY "PRZYDZIAL MYSZY", NAZWA "BANDA"
FROM KOCURY K JOIN BANDY B ON K.NR_BANDY = B.NR_BANDY
WHERE (TEREN = 'POLE' OR TEREN = 'CALOSC')
    AND PRZYDZIAL_MYSZY > 50;
    
--zad18
SELECT K1.IMIE, K1.W_STADKU_OD "POLUJE OD"
FROM KOCURY K1 JOIN KOCURY K2 ON K1.W_STADKU_OD < K2.W_STADKU_OD
WHERE K2.IMIE = 'JACEK'
ORDER BY K1.W_STADKU_OD DESC;

--zad19a
select k1.imie "Imie", k1.funkcja "Funkcja", NVL(k2.imie, ' ') "Szef 1", NVL(k3.imie, ' ') "Szef 2", NVL(k4.imie, ' ') "Szef 3"
from ((kocury k1 join kocury k2 on k1.szef = k2.pseudo) left join kocury k3 on k2.szef = k3.pseudo) left join kocury k4 on k3.szef = k4.pseudo
where k1.funkcja = 'MILUSIA' or k1.funkcja = 'KOT';

--zad19b

--zad19c

--zad19c

--zad20
SELECT k.imie "Imie kotki", b.nazwa "Nazwa bandy", 
    wk.imie_wroga "Imie wroga", w.stopien_wrogosci "Ocena wroga", 
    wk.data_incydentu "Data incydentu"
FROM ((kocury k join bandy b on k.nr_bandy = b.nr_bandy) 
    join wrogowie_kocurow wk on k.pseudo = wk.pseudo) 
    join wrogowie w on w.imie_wroga = wk.imie_wroga
WHERE k.plec = 'D' AND wk.data_incydentu > '2007-01-01';

--zad21
select b.nazwa "Nazwa bandy", count(*) "Koty z wrogami"
from (select nr_bandy, count(*) 
    from kocury k join wrogowie_kocurow wk on k.pseudo = wk.pseudo
    group by nr_bandy) g1
    join bandy b on g1.nr_bandy = b.nr_bandy;
    
select nr_bandy, count(*) 
    from (kocury k 
        join (select distinct m.pseudo from wrogowie_kocurow m) n
        on k.pseudo = n.pseudo)
    group by nr_bandy;
    
SELECT b.nazwa "Nazwa bandy", COUNT (DISTINCT k.pseudo) "Koty z wrogami"
FROM Bandy b RIGHT JOIN Kocury k ON b.nr_bandy= k.nr_bandy JOIN Wrogowie_Kocurow wk ON k.pseudo = wk.pseudo
GROUP BY b.nazwa;

--zad22
select k.funkcja "Funkcja", k.pseudo "Pseudonim kota", count(k.pseudo) "Liczba wrogow"
from Kocury k join Wrogowie_Kocurow wk on k.pseudo = wk.pseudo
group by k.pseudo, k.funkcja
having count(k.pseudo) > 1;

--zad23
select k.imie, 
12*(k.przydzial_myszy + myszy_extra)"DAWKA ROCZNA",
'powyzej 864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(k.przydzial_myszy + myszy_extra) > 864
union
select k.imie, 
12*(k.przydzial_myszy + myszy_extra)"DAWKA ROCZNA",
'ponizej 864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(k.przydzial_myszy + myszy_extra) < 864
union
select k.imie, 
12*(k.przydzial_myszy + myszy_extra)"DAWKA ROCZNA",
'        864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(k.przydzial_myszy + myszy_extra) = 864
order by "DAWKA ROCZNA" desc;

--zad24
--bez operatorow zbiorowych
select distinct b.nr_bandy, b.nazwa, b.teren
from Bandy b left join Kocury k on b.nr_bandy = k.nr_bandy
where k.nr_bandy is null;

--z operatorami zbiorowymi
select distinct b.nr_bandy, b.nazwa, b.teren
from Bandy b left join Kocury k on b.nr_bandy = k.nr_bandy
minus
select distinct b.nr_bandy, b.nazwa, b.teren
from Bandy b join Kocury k on b.nr_bandy = k.nr_bandy;

--zad25
select k.imie, k.funkcja, k.przydzial_myszy
from Kocury k
where k.przydzial_myszy >= 3 * 
    (select przydzial_myszy 
    from (select nr_bandy, funkcja, przydzial_myszy 
            from Kocury order by przydzial_myszy desc) koc 
        join bandy b on koc.nr_bandy = b.nr_bandy 
    where koc.funkcja = 'MILUSIA' 
        and (b.teren = 'SAD' or b.teren = 'CALOSC') 
        and rownum = 1);
        
--zad26
select f.funkcja "Funkcja", 
    round(avg(nvl(k.myszy_extra,0)+k.przydzial_myszy)) 
    "Srednio najw. i najm. myszy"
from Funkcje f join Kocury k on f.funkcja = k.funkcja
group by f.funkcja
having f.funkcja <> 'SZEFUNIO'
    and (round(avg(nvl(k.myszy_extra,0)+k.przydzial_myszy)) =
        max(round(avg(nvl(k.myszy_extra,0)+k.przydzial_myszy)))
        or
        round(avg(nvl(k.myszy_extra,0)+k.przydzial_myszy)) =
        min(round(avg(nvl(k.myszy_extra,0)+k.przydzial_myszy))));










