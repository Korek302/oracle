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

--zad19
--zad19a
select k1.imie "Imie", '|' " ", k1.funkcja "Funkcja", '|' " ", NVL(k2.imie, ' ') "Szef 1", '|' " ", NVL(k3.imie, ' ') "Szef 2", '|' " ", NVL(k4.imie, ' ') "Szef 3"
from ((kocury k1 join kocury k2 on k1.szef = k2.pseudo) left join kocury k3 on k2.szef = k3.pseudo) left join kocury k4 on k3.szef = k4.pseudo
where k1.funkcja = 'MILUSIA' or k1.funkcja = 'KOT';

--zad19b
select imieRoot "Imie", '|' " ", funkcjaRoot "Funkcja", '|' " ", nvl(szef1,' ') "Szef 1", '|' " ",  nvl(szef2,' ') "Szef 2", '|' " ", nvl(szef3,' ') "Szef 3"
from 
    (
        select connect_by_root imie imieRoot, connect_by_root funkcja funkcjaRoot, level poziom, imie
        from Kocury k
        connect by prior szef = pseudo
        start with funkcja in ('KOT', 'MILUSIA')
    )
pivot(min(imie) for poziom in (2 szef1, 3 szef2, 4 szef3));

--zad19c
select connect_by_root imie "Imie", ' | ' "   ", connect_by_root funkcja "Funkcja", 
    substr(sys_connect_by_path(rpad(imie, 15), '| ') || '|', 17, 51) "Imiona kolejnych szefów"
from Kocury
where connect_by_isleaf = 1
connect by prior szef = pseudo
start with funkcja in ('MILUSIA', 'KOT');

--zad20
select k.imie "Imie kotki", b.nazwa "Nazwa bandy", 
    wk.imie_wroga "Imie wroga", w.stopien_wrogosci "Ocena wroga", 
    wk.data_incydentu "Data incydentu"
from ((kocury k join bandy b on k.nr_bandy = b.nr_bandy) 
    join wrogowie_kocurow wk on k.pseudo = wk.pseudo) 
    join wrogowie w on w.imie_wroga = wk.imie_wroga
where k.plec = 'D' AND wk.data_incydentu > '2007-01-01';

--zad21
select b.nazwa "Nazwa bandy", count(distinct k.pseudo) "Koty z wrogami"
from Bandy b right join Kocury k on b.nr_bandy = k.nr_bandy join Wrogowie_Kocurow wk on k.pseudo = wk.pseudo
group by b.nazwa;

--select nr_bandy, count(*) 
--    from (Kocury k 
--        join (select distinct m.pseudo from wrogowie_kocurow m) n
--        on k.pseudo = n.pseudo)
--    group by k.nr_bandy;



--zad22
select k.funkcja "Funkcja", k.pseudo "Pseudonim kota", count(k.pseudo) "Liczba wrogow"
from Kocury k join Wrogowie_Kocurow wk on k.pseudo = wk.pseudo
group by k.pseudo, k.funkcja
having count(k.pseudo) > 1;

--zad23
select k.imie, 
12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0))"DAWKA ROCZNA",
'powyzej 864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0)) > 864
union
select k.imie, 
12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0))"DAWKA ROCZNA",
'ponizej 864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0)) < 864
union
select k.imie, 
12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0))"DAWKA ROCZNA",
'        864' "DAWKA"
from Kocury k
where myszy_extra is not null 
and 12*(nvl(k.przydzial_myszy,0) + nvl(myszy_extra,0)) = 864
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
    round(avg(nvl(k.myszy_extra,0)+nvl(k.przydzial_myszy, 0))) 
    "Srednio najw. i najm. myszy"
from Funkcje f join Kocury k on f.funkcja = k.funkcja
group by f.funkcja
having 
    avg(nvl(k.myszy_extra,0)+nvl(k.przydzial_myszy, 0)) in
        ((select max(avg(nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszym, 0)))
            from Funkcje f1 join kocury k1 on f1.funkcja = k1.funkcja
            where f1.funkcja != 'SZEFUNIO'
            group by f1.funkcja)
        , (select min(avg(nvl(k2.myszy_extra,0)+nvl(k2.przydzial_myszy, 0)))
            from Funkcje f2 join kocury k2 on f2.funkcja = k2.funkcja
            where f2.funkcja != 'SZEFUNIO'
            group by f2.funkcja));

--zad27    
--zad27a
select pseudo, nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) ZJADA
from Kocury k
where (
        select count(distinct nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))
        from Kocury
        where nvl(przydzial_myszy, 0) + NVL(myszy_extra, 0) > NVL(k.przydzial_myszy, 0) + NVL(k.myszy_extra, 0)
      ) < &n
order by ZJADA desc, pseudo desc;

--zad27b
select pseudo, nvl(myszy_extra,0)+nvl(przydzial_myszy,0) ZJADA 
from Kocury
where nvl(myszy_extra,0)+nvl(przydzial_myszy,0) in
    (
        select *  
        from  
        (
            select distinct nvl(myszy_extra,0)+nvl(przydzial_myszy,0)
            from Kocury
            order by nvl(myszy_extra,0)+nvl(przydzial_myszy,0) desc
        )
        where rownum < &n + 1
    )
order by ZJADA desc, pseudo desc;

--zad27c
select k1.pseudo, nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0) ZJADA 
from Kocury k1 join Kocury k2 on nvl(k1.przydzial_myszy, 0) + NVL(k1.myszy_extra, 0) <= NVL(k2.przydzial_myszy, 0) + NVL(k2.myszy_extra, 0)
group by k1.pseudo, nvl(k1.przydzial_myszy, 0) + NVL(k1.myszy_extra, 0)
having count(distinct nvl(k2.przydzial_myszy, 0) + NVL(k2.myszy_extra, 0)) < &n+1
order by ZJADA desc, pseudo desc;

--zad27d
select * 
from 
    (
        select pseudo, nvl(myszy_extra,0)+nvl(przydzial_myszy,0) ZJADA,
            dense_rank() over(order by nvl(myszy_extra,0)+nvl(przydzial_myszy,0) desc) rnk
        from Kocury
    )
where rnk < &n + 1
order by ZJADA desc, pseudo desc;

--zad28
select to_char(extract(year from w_stadku_od)) "ROK", count(pseudo) "LICZBA WYSTAPIEN"
from Kocury
group by extract(year from w_stadku_od)
having count(pseudo) in
(
    (
        select * 
        from
        (
            select distinct count(pseudo)
            from Kocury
            group by extract(year from w_stadku_od)
            having count(pseudo) >
            (
                select avg(count(extract(year from w_stadku_od)))
                from Kocury
                group by extract(year from w_stadku_od)
            )
            order by count(pseudo)
        )
        where rownum = 1
    ),
    (
        select * 
        from
        (
            select distinct count(pseudo)
            from Kocury
            group by extract(year from w_stadku_od)
            having count(pseudo) <
            (
                select avg(count(extract(year from w_stadku_od)))
                from Kocury
                group by extract(year from w_stadku_od)
            )
            order by count(pseudo) desc
        )
        where rownum = 1
    )
)
union
select 'Srednia', round(avg(count(extract(year from w_stadku_od))), 7)
from Kocury
group by extract(year from w_stadku_od)
order by 2;

--zad29
--zad29a
select k1.imie, nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0) "ZJADA", k1.nr_bandy "NR BANDY", to_char(avg(nvl(k2.myszy_extra,0)+nvl(k2.przydzial_myszy,0)), '99.99') "SREDNIA BANDY"
from Kocury k1 join Kocury k2 on k1.nr_bandy = k2.nr_bandy
where k1.plec = 'M'
group by k1.imie, nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0), k1.nr_bandy
having nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0) < avg(nvl(k2.myszy_extra,0)+nvl(k2.przydzial_myszy,0))
order by avg(nvl(k2.myszy_extra,0)+nvl(k2.przydzial_myszy,0));

--zad29b
select k1.imie, nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0) "ZJADA", k1.nr_bandy "NR BANDY", k2.srednia "SREDNIA BANDY"
from Kocury k1
    join 
    (
        select nr_bandy, to_char(avg(nvl(myszy_extra,0)+nvl(przydzial_myszy,0)), '99.99') srednia
        from Kocury
        group by nr_bandy
    ) k2
    on k1.nr_bandy = k2.nr_bandy
where k1.plec = 'M' and nvl(k1.myszy_extra, 0)+nvl(k1.przydzial_myszy,0) < k2.srednia
order by k2.srednia;

--zad29c
select k1.imie, nvl(k1.myszy_extra,0)+nvl(k1.przydzial_myszy,0) "ZJADA", k1.nr_bandy "NR BANDY", 
    (
        select to_char(avg(nvl(myszy_extra,0)+nvl(przydzial_myszy,0)), '99.99')
        from Kocury k2
        where k1.nr_bandy = k2.nr_bandy
    ) "SREDNIA BANDY"
from Kocury k1
where k1.plec = 'M' and nvl(k1.myszy_extra, 0)+nvl(k1.przydzial_myszy,0) < 
    (
        select avg(nvl(myszy_extra,0)+nvl(przydzial_myszy,0))
        from Kocury k3
        where k1.nr_bandy = k3.nr_bandy
    )
order by "SREDNIA BANDY";

--zad30
select k.imie, k.w_stadku_od "WSTAPIL DO STADKA", ' ' " "
from Kocury k
where k.w_stadku_od != 
    (
        select max(w_stadku_od)
        from Kocury
        where k.nr_bandy = nr_bandy
    )
    and
    k.w_stadku_od != 
    (
        select min(w_stadku_od)
        from Kocury
        where k.nr_bandy = nr_bandy
    )
union
select k.imie, k.w_stadku_od "WSTAPIL DO STADKA", '<--- NAJMLODSZY STAZEM W BANDZIE ' ||  b.nazwa " "
from Kocury k join bandy b on k.nr_bandy = b.nr_bandy
where k.w_stadku_od = 
    (
        select max(w_stadku_od)
        from Kocury k1 
        where k1.nr_bandy = k.nr_bandy
    )
union
select k.imie, k.w_stadku_od "WSTAPIL DO STADKA", '<--- NAJSTARSZY STAZEM W BANDZIE ' ||  b.nazwa " "
from Kocury k join bandy b on k.nr_bandy = b.nr_bandy
where k.w_stadku_od = 
    (
        select min(w_stadku_od)
        from Kocury k2 
        where k2.nr_bandy = k.nr_bandy
    )
order by imie;

--zad31
create or replace view zad31(NAZWA, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD)
as
select nazwa, avg(nvl(przydzial_myszy, 0)), max(nvl(przydzial_myszy, 0)), min(nvl(przydzial_myszy, 0)), count(pseudo), count(myszy_extra)
from Kocury k join Bandy b on k.nr_bandy = b.nr_bandy
group by nazwa;

select *
from zad31;

select pseudo "PSEUDONIM", imie, funkcja, nvl(przydzial_myszy,0) "ZJADA", 'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA", w_stadku_od "LOWI OD"
from Kocury natural join Bandy natural join zad31
where pseudo = '&Pseudonim';

--zad32
create or replace view zad32
as
select pseudo, nr_bandy, plec, przydzial_myszy, myszy_extra
from Kocury
where w_stadku_od in
    (
        select w_stadku_od 
        from
        (
            select *
            from
            (
                select w_stadku_od
                from Kocury natural join Bandy
                where nazwa = 'CZARNI RYCERZE'
                order by w_stadku_od
            )
            where rownum < 4
        )
    )
or w_stadku_od in
    (
        select w_stadku_od 
        from
        (
            select *
            from
            (
                select w_stadku_od
                from Kocury natural join Bandy
                where nazwa = 'LACIACI MYSLIWI'
                order by w_stadku_od
            )
            where rownum < 4
        )
    );
    
select pseudo "Pseudonim", plec "Plec", nvl(przydzial_myszy, 0) "Myszy przed podw.", nvl(myszy_extra, 0) "Extra przed podw."
from zad32;

update zad32 up1
set przydzial_myszy = 
    case when plec = 'D' then
        przydzial_myszy + (select min(nvl(przydzial_myszy, 0)) * 0.1 from Kocury)
    else
        nvl(przydzial_myszy, 0) + 10
    end,
    myszy_extra = nvl(myszy_extra, 0) + (select avg(nvl(myszy_extra, 0)) * 0.15 from Kocury where up1.nr_bandy = nr_bandy);

select pseudo "Pseudonim", plec "Plec", nvl(przydzial_myszy, 0) "Myszy po podw.", nvl(myszy_extra, 0) "Extra po podw."
from zad32;

rollback;

--zad33
--zad33a
select decode("PLEC", 'Kocur', ' ', NAZWA) "NAZWA BANDY", "PLEC", "ILE", "SZEFUNIO", "BANDZIOR", "LOWCZY", "LAPACZ", "KOT", "MILUSIA", "DZIELCZY", "SUMA"
from 
    (
        select nazwa, decode(plec, 'M', 'Kocur', 'Kotka') "PLEC",
            to_char(count(pseudo)) "ILE",
            to_char(sum(decode(funkcja, 'SZEFUNIO', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "SZEFUNIO",
            to_char(sum(decode(funkcja, 'BANDZIOR', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "BANDZIOR",
            to_char(sum(decode(funkcja, 'LOWCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "LOWCZY",
            to_char(sum(decode(funkcja, 'LAPACZ', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "LAPACZ",
            to_char(sum(decode(funkcja, 'KOT', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "KOT",
            to_char(sum(decode(funkcja, 'MILUSIA', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "MILUSIA",
            to_char(sum(decode(funkcja, 'DZIELCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))) "DZIELCZY",
            to_char(sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))) "SUMA"
        from Kocury natural join Bandy
        group by nazwa, plec
        
        union
        
        select 'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
        from dual
        
        union
        
        select 'ZJADA RAZEM', ' ', ' ', 
            to_char(sum(decode(funkcja, 'SZEFUNIO', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'BANDZIOR', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'LOWCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'LAPACZ', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'KOT', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'MILUSIA', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'DZIELCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)))
        from Kocury
    )
order by nazwa, plec desc;

--zad33b
select decode("PLEC", 'Kocur', ' ', NAZWA) "NAZWA BANDY", "PLEC", "ILE", "SZEFUNIO", "BANDZIOR", "LOWCZY", "LAPACZ", "KOT", "MILUSIA", "DZIELCZY", "SUMA"
from 
    (
        select nazwa, decode(plec, 'M', 'Kocur', 'Kotka') "PLEC",
            to_char(ILE) ILE,
            to_char(nvl(SZEFUNIO, 0)) "SZEFUNIO",
            to_char(nvl(BANDZIOR, 0)) "BANDZIOR",
            to_char(nvl(LOWCZY, 0)) "LOWCZY",
            to_char(nvl(LAPACZ, 0)) "LAPACZ",
            to_char(nvl(KOT, 0)) "KOT",
            to_char(nvl(MILUSIA, 0)) "MILUSIA",
            to_char(nvl(DZIELCZY, 0)) "DZIELCZY",
            to_char(SUMA) SUMA
        from 
        (
            select nazwa, plec, funkcja, nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0) myszy
            from Kocury natural join Bandy
        )
        pivot
        (
            sum(myszy)
            for funkcja
            in ('SZEFUNIO' "SZEFUNIO", 'BANDZIOR' "BANDZIOR", 'LOWCZY' "LOWCZY", 'LAPACZ' "LAPACZ", 'KOT' "KOT", 'MILUSIA' "MILUSIA", 'DZIELCZY' "DZIELCZY")
        )
        natural join
        (
            select nazwa, plec, count(pseudo) ILE, to_char(sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0))) SUMA
            from Kocury natural join Bandy
            group by nazwa, plec
        )
        
        union
        
        select 'Z----------------', '------', '----', '---------', '---------', '---------', '---------', '---------', '---------', '---------', '-------'
        from dual
        
        union
        
        select 'ZJADA RAZEM', ' ', ' ', 
            to_char(sum(decode(funkcja, 'SZEFUNIO', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'BANDZIOR', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'LOWCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'LAPACZ', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'KOT', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'MILUSIA', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(decode(funkcja, 'DZIELCZY', nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0), 0))),
            to_char(sum(nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)))
        from Kocury
    )
order by nazwa, plec desc;













