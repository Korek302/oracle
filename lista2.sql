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
