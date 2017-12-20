--zad47
create or replace type Kocury as object
(imie varchar2(15),
plec varchar2(1),
pseudo varchar2(15),
szef varchar2(15),
w_stadku_od date default sysdate,
przydzial_myszy number(3),
myszy_extra number(3)
);

create or replace type Elita under Kocury
(sluga Plebs,
member function getImie return varchar2,
pragma restrict_references())
final;


create or replace type Plebs under Kocury
(
);

create or replace type Konto as object
(data_wprowadzenia date,
data_usuniecia date,
wlasciciel Elita
);

create or replace type wrogowie_kocurow as object
(indeks,
pseudo,
date_incydentu,
opis_incydentu
)