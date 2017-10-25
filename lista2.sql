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