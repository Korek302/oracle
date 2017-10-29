-- Zadanie 17
-- Wyświetlić pseudonimy, przydziały myszy oraz nazwy band dla kotów
-- operujących na terenie POLE posiadających przydział myszy większy od 50.
-- Uwzględnić fakt, że są w stadzie koty posiadające prawo do polowań
-- na całym „obsługiwanym” przez stado terenie. Nie stosować podzapytań.

SELECT
  pseudo "POLUJE W POLU",
  przydzial_myszy "PRZYDZIAL MYSZY",
  nazwa "BANDA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
      przydzial_myszy > 50
  AND teren IN ('POLE', 'CALOSC')
ORDER BY przydzial_myszy DESC;


-- Zadanie 18
-- Wyświetlić bez stosowania podzapytania imiona
-- i daty przystąpienia do stada kotów, które przystąpiły do stada przed kotem
-- o imieniu ’JACEK’. Wyniki uporządkować malejąco
-- wg daty przystąpienia do stadka.

SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od "POLUJE OD"
FROM
  Kocury, Kocury Kocury2
WHERE
      Kocury2.imie = 'JACEK'
  AND Kocury.w_stadku_od < Kocury2.w_stadku_od
ORDER BY Kocury.w_stadku_od DESC;


-- Zadanie 19
-- Dla kotów pełniących funkcję KOT i MILUSIA wyświetlić
-- w kolejności hierarchii imiona wszystkich ich szefów.

SELECT
  Kocury.imie "Imie",
  '|' "'|'",
  Kocury.funkcja "Funkcja",
  '|' "'|'",
  NVL(Kocury2.imie, ' ') "Szef 1",
    '|' "'|' ",
  NVL(Kocury3.imie, ' ') "Szef 2",
  '|' "'|'  ",
  NVL(Kocury4.imie, ' ') "Szef 3"
FROM
  Kocury
LEFT JOIN Kocury Kocury2 ON Kocury.szef=Kocury2.pseudo
LEFT JOIN Kocury Kocury3 ON Kocury2.szef=Kocury3.pseudo
LEFT JOIN Kocury Kocury4 ON Kocury3.szef=Kocury4.pseudo
WHERE
      Kocury.funkcja IN ('KOT', 'MILUSIA');
--CONNECT BY PRIOR Kocury.pseudo = Kocury.szef
--START WITH Kocury.szef IS NULL;


-- Zadanie 20
-- Wyświetlić imiona wszystkich kotek,
-- które uczestniczyły w incydentach po 01.01.2007.
-- Dodatkowo wyświetlić nazwy band do których należą kotki,
-- imiona ich wrogów wraz ze stopniem wrogości oraz datę incydentu.

SELECT
  Kocury.imie "Imie kotki",
  Bandy.nazwa "Nazwa bandy",
  Wrogowie.imie_wroga "Imie wroga",
  Wrogowie.stopien_wrogosci "Ocena wroga",
  Wrogowie_Kocurow.data_incydentu "Data inc."
FROM
  Wrogowie_Kocurow
LEFT JOIN Kocury ON Wrogowie_Kocurow.pseudo=Kocury.pseudo
LEFT JOIN Bandy ON Kocury.nr_bandy=Bandy.nr_bandy
LEFT JOIN Wrogowie ON Wrogowie_Kocurow.imie_wroga=Wrogowie.imie_wroga
WHERE
      Kocury.plec = 'D'
  AND Wrogowie_Kocurow.data_incydentu > '2007-01-01';


-- Zadanie 21
-- Określić ile kotów w każdej z band posiada wrogów.

SELECT
  Bandy.nazwa "Nazwa bandy",
  COUNT (DISTINCT Kocury.pseudo)  "Koty z wrogami"
FROM
  Bandy
RIGHT JOIN Kocury ON Bandy.nr_bandy=Kocury.nr_bandy
JOIN Wrogowie_Kocurow ON Kocury.pseudo=Wrogowie_Kocurow.pseudo
GROUP BY Bandy.nazwa;

--SELECT
--  Bandy.nazwa "Nazwa bandy",
--  Kocury.pseudo
--  COUNT(*)  "Koty z wrogami"
--FROM
--  Kocury
--RIGHT JOIN Bandy ON Bandy.nr_bandy=Kocury.nr_bandy
--LEFT JOIN Wrogowie_Kocurow ON Kocury.pseudo=Wrogowie_Kocurow.pseudo;
--GROUP BY Bandy.nazwa;


-- Zadanie 22
-- Znaleźć koty (wraz z pełnioną funkcją),
-- które posiadają więcej niż jednego wroga.

SELECT
  MIN(Kocury.funkcja) "Funkcja",
  Kocury.pseudo "Pseudonim kota",
  COUNT(Wrogowie_Kocurow.pseudo)  "Liczba wrogow"
FROM
  Kocury
RIGHT JOIN Wrogowie_Kocurow ON Kocury.pseudo = Wrogowie_Kocurow.pseudo
GROUP BY Kocury.pseudo, Wrogowie_Kocurow.pseudo
HAVING COUNT(Wrogowie_Kocurow.pseudo) > 1;


-- Zadanie 23
-- Wyświetlić imiona kotów, które dostają „myszą” premię
-- wraz z ich całkowitym rocznym spożyciem myszy.
-- Dodatkowo jeśli ich roczna dawka myszy przekracza 864
-- wyświetlić tekst ’powyzej 864’, jeśli jest równa 864 tekst ’864’,
-- jeśli jest mniejsza od 864 tekst ’poniżej 864’.
-- Wyniki uporządkować malejąco wg rocznej dawki myszy.
-- Do rozwiązania wykorzystać operator zbiorowy UNION.

SELECT
  Kocury.imie "IMIE",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "DAWKA ROCZNA",
  'powyzej 864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 > 864
UNION SELECT
  Kocury.imie "IMIE",
  864 "DAWKA ROCZNA",
  '864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 = 864
UNION SELECT
  Kocury.imie "IMIE",
  (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 "DAWKA ROCZNA",
  'ponizej 864' "DAWKA"
FROM
  Kocury
WHERE
      NVL(myszy_extra, 0) > 0
  AND (NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))*12 < 864
ORDER BY "DAWKA ROCZNA" DESC;


-- Zadanie 24
-- Znaleźć bandy, które nie posiadają członków.
-- Wyświetlić ich numery, nazwy i tereny operowania.
-- Zadanie rozwiązać na dwa sposoby:
-- bez podzapytań i operatorów zbiorowych
-- oraz wykorzystując operatory zbiorowe.

SELECT
  Bandy.nr_bandy "NR BANDY",
  Bandy.nazwa "NAZWA",
  Bandy.teren "TEREN"
FROM
  Bandy
LEFT JOIN Kocury ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE Kocury.nr_bandy IS NULL;

SELECT
  Bandy.nr_bandy "NR BANDY",
  Bandy.nazwa "NAZWA",
  Bandy.teren "TEREN"
FROM
  Bandy
WHERE (SELECT COUNT(*) FROM Kocury WHERE Kocury.nr_bandy = Bandy.nr_bandy) = 0;


-- Zadanie 25
-- Znaleźć koty, których przydział myszy jest nie mniejszy
-- od potrojonego najwyższego przydziału spośród przydziałów
-- wszystkich MILUŚ operujących w SADZIE. Nie stosować funkcji MAX.

SELECT
  imie "IMIE",
  funkcja "FUNKCJA",
  przydzial_myszy "PRZYDZIAL MYSZY"
FROM
  Kocury
WHERE
  przydzial_myszy >= 3 * (
    SELECT przydzial_myszy FROM
      (SELECT * FROM Kocury ORDER BY przydzial_myszy DESC) x
    LEFT JOIN Bandy ON x.nr_bandy = Bandy.nr_bandy
    WHERE funkcja='MILUSIA' AND (teren='SAD' OR teren='CALOSC') AND rownum=1
  );


-- Zadanie 26
-- Znaleźć funkcje (pomijając SZEFUNIA),
-- z którymi związany jest najwyższy i najniższy
-- średni całkowity przydział myszy.
-- Nie używać operatorów zbiorowych (UNION, INTERSECT, MINUS).

SELECT
  funkcja "Funkcja",
  ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) "Srednio najw. i najm. myszy"
FROM
  Kocury
WHERE
  funkcja <> 'SZEFUNIO'
GROUP BY
  funkcja
HAVING
  ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) ))
  IN ( (
      SELECT * FROM (
        SELECT ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) x
        FROM Kocury
        WHERE funkcja != 'SZEFUNIO'
        GROUP BY funkcja
        ORDER BY x ASC
      ) WHERE rownum=1
    ), (
      SELECT * FROM (
        SELECT ROUND(AVG( NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) )) x
        FROM Kocury
        WHERE funkcja != 'SZEFUNIO'
        GROUP BY funkcja
        ORDER BY x DESC
      ) WHERE rownum=1
    ))
;


-- Zadanie 27
-- Znaleźć koty zajmujące pierwszych n miejsc
-- pod względem całkowitej liczby spożywanych myszy
-- (koty o tym samym spożyciu zajmują to samo miejsce!).
--
-- Zadanie rozwiązać na trzy sposoby:
-- a. wykorzystując podzapytanie skorelowane,
-- b. wykorzystując pseudokolumnę ROWNUM,
-- c. wykorzystując łączenie relacji Kocury z relacją Kocury.

-- A
SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury
WHERE
  &n >= (
    SELECT COUNT(*)
    FROM Kocury Kocury2
    WHERE NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
       < NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0)
  )
ORDER BY "ZJADA" DESC;

-- B
SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury
WHERE
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) >= (
    SELECT x FROM (
      SELECT rownum rn, x FROM (
        SELECT DISTINCT NVL(przydzial_myszy,0) + NVL(myszy_extra,0) x
        FROM Kocury
        ORDER BY x DESC
      )
    ) WHERE rn=&n
  )
ORDER BY "ZJADA" DESC;

-- B (inne)
SELECT
  pseudo "PSEUDO",
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) "ZJADA"
FROM
  Kocury
WHERE
  NVL(przydzial_myszy,0) + NVL(myszy_extra,0) >= ANY(
      SELECT x FROM (
      SELECT DISTINCT NVL(przydzial_myszy,0) + NVL(myszy_extra,0) x
      FROM Kocury
      ORDER BY x DESC
    ) WHERE rownum <= &n
  )
ORDER BY "ZJADA" DESC;

-- C
SELECT
  Kocury.pseudo "PSEUDO",
  NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0) "ZJADA"
FROM
  Kocury, Kocury Kocury2
WHERE
     NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
  <= NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0)
GROUP BY
  Kocury.pseudo, NVL(Kocury.przydzial_myszy,0) + NVL(Kocury.myszy_extra,0)
HAVING
  COUNT(DISTINCT NVL(Kocury2.przydzial_myszy,0) + NVL(Kocury2.myszy_extra,0))
    <= &n
ORDER BY "ZJADA" DESC;


-- Zadanie 28
-- Określić lata, dla których liczba wstąpień do stada jest najbliższa
-- (od góry i od dołu) średniej liczbie wstąpień dla wszystkich lat
-- (średnia z wartości określających liczbę wstąpień w poszczególnych latach).
-- Nie stosować perspektywy.

SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT COUNT(pseudo) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) >= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(pseudo) ASC
    ) WHERE rownum=1
  )
UNION ALL SELECT
  'Srednia' "ROK",
  AVG(COUNT(pseudo))  "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
UNION ALL SELECT
  TO_CHAR(EXTRACT(YEAR FROM w_stadku_od)) "ROK",
  COUNT(pseudo) "LICZBA WSTAPIEN"
FROM
  Kocury
GROUP BY
  EXTRACT(YEAR FROM w_stadku_od)
HAVING
  COUNT(pseudo) = (
    SELECT * FROM (
      SELECT COUNT(pseudo) FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
      HAVING COUNT(pseudo) <= (SELECT AVG(COUNT(pseudo)) FROM Kocury GROUP BY EXTRACT(YEAR FROM w_stadku_od))
      ORDER BY COUNT(pseudo) DESC
    ) WHERE rownum=1
  );


-- Zadanie 29
-- Dla kocurów (płeć męska), dla których całkowity przydział myszy
-- nie przekracza średniej w ich bandzie wyznaczyć następujące dane:
-- imię, całkowite spożycie myszy, numer bandy,
-- średnie całkowite spożycie w bandzie.
-- Nie stosować perspektywy. Zadanie rozwiązać na trzy sposoby:
-- a. ze złączeniem ale bez podzapytań,
-- b. ze złączenie i z jedynym podzapytaniem w klauzurze FROM,
-- c. bez złączeń i z dwoma podzapytaniami: w klauzurach SELECT i WHERE

-- A
SELECT
  Kocury.imie "IMIE",
  MIN( NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) ) "ZJADA",
  MIN(Kocury.nr_bandy) "NR BANDY",
  TO_CHAR(
    AVG(NVL(Kocury2.przydzial_myszy, 0) + NVL(Kocury2.myszy_extra, 0))
  , '99.99') "SREDNIA BANDY"
FROM
  Kocury
RIGHT JOIN Kocury Kocury2 ON Kocury.nr_bandy = Kocury2.nr_bandy
WHERE
  Kocury.plec = 'M'
GROUP BY
  Kocury.imie
HAVING
     MIN(NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0))
  <= AVG(NVL(Kocury2.przydzial_myszy, 0) + NVL(Kocury2.myszy_extra, 0));

-- B
SELECT
  Kocury.imie "IMIE",
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) "ZJADA",
  Kocury.nr_bandy "NR BANDY",
  TO_CHAR(srednia, '99.99') "SREDNIA BANDY"
FROM
  Kocury
LEFT JOIN (
  SELECT
    AVG(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) srednia,
    nr_bandy banda
  FROM Kocury GROUP BY nr_bandy
) ON banda=Kocury.nr_bandy
WHERE
      NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) < srednia
  AND plec = 'M';

-- C
SELECT
  Kocury.imie "IMIE",
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) "ZJADA",
  Kocury.nr_bandy "NR BANDY",
  ( SELECT
      TO_CHAR(AVG(NVL(x.przydzial_myszy, 0) + NVL(x.myszy_extra, 0)), '99.99')
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ) "SREDNIA BANDY"
FROM
  Kocury
WHERE
  NVL(Kocury.przydzial_myszy, 0) + NVL(Kocury.myszy_extra, 0) < (
    SELECT AVG(NVL(x.przydzial_myszy, 0) + NVL(x.myszy_extra, 0))
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ) AND plec = 'M';


-- Zadanie 30
-- Wygenerować listę kotów z zaznaczonymi kotami
-- o najwyższym i o najniższym stażu w swoich bandach.
-- Zastosować operatory zbiorowe.

SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od || ' <---' "WSTAPIL DO STADKA",
  'NAJSTARSZY STAZEM W BANDZIE ' || Bandy.nazwa " "
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
  Kocury.w_stadku_od = (
    SELECT MIN(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  )
UNION SELECT
  Kocury.imie "IMIE",
  Kocury.w_stadku_od || ' <---' "WSTAPIL DO STADKA",
  'NAJMLODSZY STAZEM W BANDZIE ' || Bandy.nazwa " "
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
  Kocury.w_stadku_od = (
    SELECT MAX(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  )
UNION SELECT
  Kocury.imie "IMIE",
  TO_CHAR(Kocury.w_stadku_od) "WSTAPIL DO STADKA",
  ' ' " "
FROM
  Kocury
WHERE
  Kocury.w_stadku_od NOT IN (
  (
    SELECT MAX(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ),(
    SELECT MIN(x.w_stadku_od)
    FROM Kocury x
    GROUP BY x.nr_bandy
    HAVING x.nr_bandy=Kocury.nr_bandy
  ));


-- Zadanie 31
-- Zdefiniować perspektywę wybierającą następujące dane:
-- nazwę bandy, średni, maksymalny i minimalny przydział myszy w bandzie,
-- całkowitą liczbę kotów w bandzie oraz liczbę kotów pobierających
-- w bandzie przydziały dodatkowe.
--
-- Posługując się zdefiniowaną perspektywą wybrać następujące dane o kocie,
-- którego pseudonim podawany jest interaktywnie z klawiatury:
-- pseudonim, imię, funkcja, przydział myszy,
-- minimalny i maksymalny przydział myszy w jego bandzie
-- oraz datę wstąpienia do stada.

DROP VIEW Perspektywa;
CREATE VIEW Perspektywa (
  NAZWA_BANDY, SRE_SPOZ, MAX_SPOZ, MIN_SPOZ, KOTY, KOTY_Z_DOD
) AS SELECT
  Bandy.nazwa,
  AVG(NVL(przydzial_myszy, 0)) " ",
  MAX(NVL(przydzial_myszy, 0)) " ",
  MIN(NVL(przydzial_myszy, 0)) " ",
  COUNT(pseudo),
  COUNT(myszy_extra)
FROM
  Bandy
LEFT JOIN Kocury ON Kocury.nr_bandy = Bandy.nr_bandy
GROUP BY Bandy.nazwa;

SELECT * FROM Perspektywa;

SELECT
  pseudo "PSEUDONIM",
  imie  "IMIE",
  funkcja "FUNKCJA",
  NVL(przydzial_myszy, 0) "ZJADA",
  'OD ' || MIN_SPOZ || ' DO ' || MAX_SPOZ "GRANICE SPOZYCIA",
  w_stadku_od "LOWI OD"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
LEFT JOIN Perspektywa ON Bandy.nazwa = NAZWA_BANDY
WHERE
  pseudo = '&p';

-- Zadanie 32
-- Dla kotów o trzech najdłuższym stażach w połączonych bandach
-- CZARNI RYCERZE i ŁACIACI MYŚLIWI zwiększyć przydział myszy
-- o 10% minimalnego przydziału w całym stadzie
-- lub o 10 w zależności od tego czy podwyżka dotyczy kota płci żeńskiej
-- czy kota płci męskiej.
-- Przydział myszy extra dla kotów obu płci zwiększyć
-- o 15% średniego przydziału extra w bandzie kota.
--
-- Wyświetlić na ekranie wartości przed i po podwyżce
-- a następnie wycofać zmiany.

SELECT
  pseudo "Pseudonim",
  plec "Plec",
  NVL(przydzial_myszy, 0) "Myszy przed podw.",
  NVL(myszy_extra, 0) "Extra przed podw."
FROM
  Kocury
WHERE
  Kocury.pseudo IN (
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'CZARNI RYCERZE'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
      UNION ALL
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'LACIACI MYSLIWI'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
    );

SET AUTOCOMMIT OFF;

UPDATE
  Kocury
SET
  Kocury.przydzial_myszy = CASE Kocury.plec
    WHEN 'M' THEN NVL(Kocury.przydzial_myszy,0) + 10
    WHEN 'D' THEN NVL(Kocury.przydzial_myszy,0) + (
      SELECT MIN(NVL(x.przydzial_myszy, 0)) FROM Kocury x
    ) * 0.1
  END
WHERE
    Kocury.pseudo IN (
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'CZARNI RYCERZE'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
      UNION ALL
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'LACIACI MYSLIWI'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
    );

SELECT
  pseudo "Pseudonim",
  plec "Plec",
  NVL(przydzial_myszy, 0) "Myszy po podw.",
  NVL(myszy_extra, 0) "Extra po podw."
FROM
  Kocury
WHERE
  Kocury.pseudo IN (
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'CZARNI RYCERZE'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
      UNION ALL
      SELECT * FROM (
        SELECT pseudo FROM Kocury x
        LEFT JOIN Bandy ON Bandy.nr_bandy = x.nr_bandy
        WHERE Bandy.nazwa = 'LACIACI MYSLIWI'
        ORDER BY x.w_stadku_od ASC
      ) WHERE rownum <= 3
    );
    
ROLLBACK;
SET AUTOCOMMIT ON;

-- Zadanie 33
-- Napisać zapytanie, w ramach którego obliczone zostaną
-- sumy całkowitego spożycia myszy przez koty sprawujące każdą z funkcji
-- z podziałem na bandy i płcie kotów.
-- Podsumować przydziały dla każdej z funkcji. 

SELECT * FROM ( -- fix, order nie moze byc przed UNION !!!
SELECT
  DECODE(plec, 'M', ' ', 'D', nazwa) "NAZWA BANDY",
  DECODE(plec, 'M', 'Kocur', 'D', 'Kotka') "PLEC",
  TO_CHAR(count(*)) "ILE",
  TO_CHAR(SUM(DECODE(funkcja,
    'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "SZEFUNIO",
  TO_CHAR(SUM(DECODE(funkcja,
    'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "BANDZIOR",
  TO_CHAR(SUM(DECODE(funkcja,
    'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LOWCZY",
  TO_CHAR(SUM(DECODE(funkcja,
    'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,
    'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "KOT",
  TO_CHAR(SUM(DECODE(funkcja,
    'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,
    'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SUMA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
GROUP BY
  nazwa, plec
ORDER BY nazwa ASC )
UNION ALL SELECT
  'Z----------------',
  '------',
  '----',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '---------',
  '-------'
FROM DUAL
UNION ALL SELECT
  'ZJADA RAZEM',
  ' ',
  ' ',
  TO_CHAR(SUM(DECODE(funkcja,
    'SZEFUNIO', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "SZEFUNIO",
  TO_CHAR(SUM(DECODE(funkcja,
    'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "BANDZIOR",
  TO_CHAR(SUM(DECODE(funkcja,
    'LOWCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LOWCZY",
  TO_CHAR(SUM(DECODE(funkcja,
    'LAPACZ', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "LAPACZ",
  TO_CHAR(SUM(DECODE(funkcja,
    'KOT', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "KOT",
  TO_CHAR(SUM(DECODE(funkcja,
    'MILUSIA', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "MILUSIA",
  TO_CHAR(SUM(DECODE(funkcja,
    'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0), 0
    ))) "DZIELCZY",
  TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))) "SUMA"
FROM
  Kocury
LEFT JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy;
