
--1

CREATE DATABASE BPII_7_9
GO

USE BPII_7_9


CREATE TABLE Klijenti(
Ime NVARCHAR (30) NOT NULL,
Prezime NVARCHAR (30) NOT NULL,
Grad NVARCHAR (50) NOT NULL,
Email NVARCHAR (50) NOT NULL,
Telefon NVARCHAR (50) NOT NULL
)

CREATE TABLE Racuni (
DatumOtvaranja DATE NOT NULL,
TipRacuna NVARCHAR (50) NOT NULL,
BrojRacuna NVARCHAR (16) NOT NULL,
Stanje DECIMAL (18,2) NOT NULL

)

CREATE TABLE Transakcije (
Datum DATETIME NOT NULL,
Primatelj NVARCHAR (50) NOT NULL,
BrojRacunaPrimatelja NVARCHAR (16) NOT NULL,
MjestoPrimatelja NVARCHAR (50) NOT NULL,
AdresaPrimatelja NVARCHAR (50) ,
Svrha NVARCHAR (200),
Iznos DECIMAL(18,2)

)

ALTER TABLE Klijenti
ADD KlijentID INT IDENTITY (1,1) PRIMARY KEY

ALTER TABLE Racuni
ADD RacunID INT IDENTITY (1,1) PRIMARY KEY,
 KlijentID INT FOREIGN KEY REFERENCES Klijenti(KlijentID)

ALTER TABLE Transakcije
ADD TransakcijaID INT IDENTITY (1,1) PRIMARY KEY,
RacunID INT FOREIGN KEY REFERENCES Racuni (RacunID) 

--2

ALTER TABLE Klijenti
ADD UNIQUE (Email)

ALTER TABLE Racuni
ADD UNIQUE (BrojRacuna)

--3
SELECT * FROM Racuni WHERE 0=1
GO

CREATE PROCEDURE usp_Racuni_Insert (
@DatumOtvaranja	DATE,
@TipRacuna	NVARCHAR (50),
@BrojRacuna	NVARCHAR (16),
@Stanje		DECIMAL,
@KlijentID INT
)
AS
BEGIN
             INSERT INTO Racuni
			 VALUES (@DatumOtvaranja,@TipRacuna,@BrojRacuna,@Stanje,@KlijentID)
END

EXEC usp_Racuni_Insert '2018-07-07','Neki tip','12345',34.5,1


SELECT * FROM Klijenti WHERE 0=1

INSERT INTO Klijenti VALUES ('Adna','Maric','Mostar','adna-ma1@hotmail.com','0000000000')

--4

INSERT INTO Klijenti 
SELECT DISTINCT LEFT (C.ContactName, CHARINDEX(' ', C.ContactName)),
       SUBSTRING(C.ContactName,CHARINDEX(' ', C.ContactName),30),
	   C.City,
	   CONCAT(LOWER(REPLACE(C.ContactName,' ','.')),'@northwind.ba'),
	   C.Phone
FROM NORTHWND.dbo.Customers AS C JOIN NORTHWND.dbo.Orders AS O 
                            ON C.CustomerID=O.CustomerID
WHERE YEAR(O.OrderDate)=1996
GO



DECLARE @TrenutacniDatum DATE 
SET @TrenutacniDatum = GETDATE() 
DECLARE @RandomKupac INT 
SET @RandomKupac = (SELECT TOP 1 K.KlijentID FROM Klijenti AS K ORDER BY NEWID())

EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 1','12',50.23, @RandomKupac 
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 2','13',60.00, 91
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 3','14',70.00, 92
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 4','15',80.00, 93
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 5','16',90.00, 94     
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 6','17',100.00, 95
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 7','18',15.00, 95  
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 8','19',678.00, 96
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 9','20',1000.00, 97
EXEC usp_Racuni_Insert @TrenutacniDatum ,'Test 10','21',22.00, 98

--- Provjera, delete itd. 
SELECT * FROM Racuni

EXEC usp_Racuni_Insert '2019-03-03','nEKI','12',20.45,3

DELETE FROM Racuni WHERE KlijentID <> 1 OR TipRacuna LIKE 'Test 2%'


DELETE FROM Racuni WHERE TipRacuna LIKE 'Test 2%'


--C

SELECT * FROM Racuni WHERE 0=1
GO


INSERT INTO Transakcije (Datum,Primatelj,BrojRacunaPrimatelja,MjestoPrimatelja,AdresaPrimatelja,Iznos,RacunID)
SELECT TOP 10  O.OrderDate,
       O.ShipName,
	   CONCAT(O.OrderID,00000123456),
	   O.ShipCity,
	   O.ShipAddress,
	   OD.Quantity*OD.UnitPrice,
       1
FROM NORTHWND.dbo.Orders AS O JOIN NORTHWND.dbo.[Order Details] AS OD
                         ON O.OrderID=OD.OrderID
WHERE O.ShipName IS NOT NULL
ORDER BY NEWID()

DELETE FROM Transakcije 

INSERT INTO Transakcije (Datum,Primatelj,BrojRacunaPrimatelja,MjestoPrimatelja,AdresaPrimatelja,Iznos,RacunID)
SELECT TOP 10  O.OrderDate,
       O.ShipName,
	   CONCAT(O.OrderID,00000123456),
	   O.ShipCity,
	   O.ShipAddress,
	   OD.Quantity*OD.UnitPrice,
       56
FROM NORTHWND.dbo.Orders AS O JOIN NORTHWND.dbo.[Order Details] AS OD
                         ON O.OrderID=OD.OrderID
WHERE O.ShipName IS NOT NULL
ORDER BY NEWID()


INSERT INTO Transakcije (Datum,Primatelj,BrojRacunaPrimatelja,MjestoPrimatelja,AdresaPrimatelja,Iznos,RacunID)
SELECT TOP 10  O.OrderDate,
       O.ShipName,
	   CONCAT(O.OrderID,00000123456),
	   O.ShipCity,
	   O.ShipAddress,
	   OD.Quantity*OD.UnitPrice,
       65
FROM NORTHWND.dbo.Orders AS O JOIN NORTHWND.dbo.[Order Details] AS OD
                         ON O.OrderID=OD.OrderID
WHERE O.ShipName IS NOT NULL
ORDER BY NEWID()

--5

UPDATE Racuni 
SET Stanje+=500
FROM Racuni AS R
INNER JOIN Klijenti AS KL
ON R.KlijentID=KL.KlijentID
WHERE KL.Grad='London' AND MONTH( R.DatumOtvaranja)=6

--6
CREATE VIEW v_NekiView AS
SELECT CONCAT(KL.Ime,' ',KL.Prezime) AS 'Ime i prezime',
       KL.Grad,
	   KL.Email,
	   KL.Telefon,
	   R.TipRacuna,
	   R.BrojRacuna,
	   R.Stanje,
	   T.Primatelj,
	   T.BrojRacunaPrimatelja,
	   T.Iznos
FROM Klijenti AS KL  LEFT JOIN Racuni AS R
              ON KL.KlijentID=R.KlijentID
			 JOIN Transakcije AS T
			  ON R.RacunID=T.RacunID

--Kreirati uskladištenu proceduru koja æe na osnovu proslijeðenog broja raèuna klijenta prikazati podatke o
--vlasniku raèuna (ime i prezime, grad i telefon), broj i stanje raèuna te ukupan iznos transakcija provedenih sa
--raèuna. Ukoliko se ne proslijedi broj raèuna, potrebno je prikazati podatke za sve raèune. Sve kolone koje
--prikazuju NULL vrijednost formatirati u 'N/A'. U proceduri koristiti prethodno kreirani view. Obavezno provjeriti
--ispravnost kreirane procedure.

--ISNULL ne znam kako cu staviti ! 

ALTER PROCEDURE usp_VlasnikPodaci_Select(

@BrojRacuna INT

)
AS
BEGIN
      IF @BrojRacuna IN (SELECT BrojRacuna FROM Racuni)
       SELECT KL.Ime,
	          KL.Prezime,
			  KL.Grad,
			  KL.Telefon,
			  R.BrojRacuna,
			  R.Stanje,
			  SUM(T.Iznos) AS 'Ukupan iznos transakcija'
	   FROM Klijenti AS KL JOIN Racuni AS R 
	                 ON KL.KlijentID=R.KlijentID
					JOIN Transakcije AS T
					 ON R.RacunID=T.RacunID
	  WHERE R.BrojRacuna=@BrojRacuna
	GROUP BY KL.Ime,KL.Prezime, KL.Grad, KL.Telefon, R.BrojRacuna, R.Stanje

	ELSE IF @BrojRacuna NOT IN (SELECT BrojRacuna FROM Racuni)
	SELECT * FROM v_NekiView

END

SELECT * FROM Racuni

EXEC usp_VlasnikPodaci_Select 22

--8. Kreirati uskladištenu proceduru koja æe na osnovu unesenog identifikatora klijenta vršiti brisanje 
--klijenta ukljuèujuæi sve njegove raèune zajedno sa transakcijama. Obavezno provjeriti ispravnost kreirane procedure. 
GO
ALTER PROCEDURE usp_Klijent_Brisanje(

@KlijentID int 


)
AS
BEGIN 
    DELETE FROM Transakcije
	FROM Transakcije AS T JOIN Racuni AS R ON T.RacunID=R.RacunID JOIN Klijenti AS K ON R.KlijentID=K.KlijentID
	WHERE K.KlijentID=@KlijentID AND R.RacunID=T.RacunID
	DELETE FROM Racuni
	FROM Racuni AS R JOIN Klijenti AS K  ON R.KlijentID=K.KlijentID
	WHERE R.KlijentID=@KlijentID
	DELETE FROM Klijenti
	WHERE KlijentID=@KlijentID
END




SELECT * FROM Klijenti
SELECT * FROM Racuni WHERE KlijentID=159
SELECT * FROM Transakcije WHERE RacunID=68

EXEC usp_Klijent_Brisanje 98
EXEC usp_Klijent_Brisanje 93
EXEC usp_Klijent_Brisanje 159

INSERT INTO Klijenti VALUES(' Probni', 'Test', 'Mostar','unique@emial.com','1234567')
INSERT INTO Racuni VALUES (GETDATE(),'Novi tip',9549886,33.56,159),
                          (GETDATE(),'Novi tip',3495885,33.56,159)

INSERT INTO Transakcije VALUES (GETDATE(),'ProbniPrimatelj',1356969,'Lithuania','DFOR-R',NULL,1113.3,68),
								(GETDATE(),'ProbniPrimatelj',8576849,'Lithuania','DFOR-R',NULL,1113.3,69)

--9. Komandu iz zadatka 5. pohraniti kao proceduru a kao parametre proceduri proslijediti naziv grada,
-- mjesec i iznos uveæanja raèuna. Obavezno provjeriti ispravnost kreirane procedure. 
GO
CREATE PROCEDURE usp_Racuni_Update(

@NazivGrada nvarchar (50),
@Mjesec int,
@Uvecanje int

)
AS
BEGIN
		UPDATE Racuni 
		SET Stanje+=@Uvecanje
		FROM Racuni AS R
		INNER JOIN Klijenti AS KL
		ON R.KlijentID=KL.KlijentID
		WHERE KL.Grad=@NazivGrada AND MONTH( R.DatumOtvaranja)=@Mjesec

END

EXEC usp_Racuni_Update @NazivGrada='Mostar', @Mjesec=7,@Uvecanje=-200

SELECT * FROM Racuni AS R JOIN Klijenti AS K ON R.KlijentID=K.KlijentID WHERE K.Grad='Mostar' AND MONTH(R.DatumOtvaranja)=7

SELECT * FROM Klijenti
