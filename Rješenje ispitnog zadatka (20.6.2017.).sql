--- > ISPITNI 20.6.2017 <---

--1.	Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. 
--	Fajlove baze podataka smjestiti na sljedeæe lokacije:
--	a)	Data fajl: D:\BP2\Data
--	b)	Log fajl: D:\BP2\Log

-- Ukoliko folderi (data i log) ne postoje na disku,potrebno ih je kreirati!

DECLARE @BP2 VARCHAR(100)
SET @BP2 = 'C:\BP2'
EXEC master.dbo.xp_create_subdir @BP2
GO

DECLARE @Data VARCHAR(100)
SET @Data = 'C:\BP2\Data'
EXEC master.dbo.xp_create_subdir @Data

DECLARE @Log VARCHAR(100)
SET @Log = 'C:\BP2\Log'
EXEC master.dbo.xp_create_subdir @Log


CREATE DATABASE IB160060 ON
( 
	NAME='IB160060_data',FILENAME='C:\BP2\Data\IB160060_mdf'
)
LOG ON
(
   NAME='IB160060_log',FILENAME='C:\BP2\Log\IB160060_mdf'
)
GO
	--2.	U svojoj bazi podataka kreirati tabele sa sljedeæom strukturom:
	--a)	Proizvodi
	--i.	ProizvodID, cjelobrojna vrijednost i primarni kljuè
	--ii.	Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
	--iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
	--iv.	Kategorija, polje za unos 50 UNICODE karaktera (obavezan unos)
	--v.	Cijena, polje za unos decimalnog broja (obavezan unos)

	USE IB160060
	GO

	CREATE TABLE Proizvodi (
	ProizvodID INT PRIMARY KEY ,
	Sifra NVARCHAR (25) UNIQUE NOT NULL,
	Naziv NVARCHAR (50) NOT NULL,
	Kategorija NVARCHAR (50) NOT NULL,
	Cijena DECIMAL (18,2) NOT NULL
	)
	--b)Narudzbe
		--i.	NarudzbaID, cjelobrojna vrijednost i primarni kljuè,
		--ii.	BrojNarudzbe, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
		--iii.	Datum, polje za unos datuma (obavezan unos),
		--iv.	Ukupno, polje za unos decimalnog broja (obavezan unos)

	 CREATE TABLE Narudzbe (
	 NarudzbaID INT PRIMARY KEY ,
	 BrojNarudzbe NVARCHAR (25) UNIQUE NOT NULL,
	 Datum DATE NOT NULL,
	 Ukupno DECIMAL(18,2) NOT NULL  )

	--c)StavkeNarudzbe
	--i.	ProizvodID, cjelobrojna vrijednost i dio primarnog kljuèa,
	--ii.	NarudzbaID, cjelobrojna vrijednost i dio primarnog kljuèa,
	--iii.	Kolicina, cjelobrojna vrijednost (obavezan unos)
	--iv.	Cijena, polje za unos decimalnog broja (obavezan unos)
	--v.	Popust, polje za unos decimalnog broja (obavezan unos)
	--vi.	Iznos, polje za unos decimalnog broja (obavezan unos)

	CREATE TABLE StavkeNarudzbe (
	ProizvodID INT FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	NarudzbaID INT FOREIGN KEY REFERENCES Narudzbe (NarudzbaID),
	Kolicina INT NOT NULL,
	Cijena DECIMAL (18,2) NOT NULL,
	Popust DECIMAL (18,2) NOT NULL,
	Iznos DECIMAL (18,2) NOT NULL,
	PRIMARY KEY (ProizvodID,NarudzbaID)
	)


--3.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeæe podatke:
	--a)	U tabelu Proizvodi dodati sve proizvode koji su prodavani u 2014. godini
	--	i.	ProductNumber -> Sifra
	--	ii.	Name -> Naziv
	--	iii.	ProductCategory (Name) -> Kategorija
	--	iv.	ListPrice -> Cijena
	--Napomena: Zadržati identifikatore zapisa!	

INSERT INTO Proizvodi
SELECT  DISTINCT P.ProductID,
        P.ProductNumber,
		P.Name,
		PC.Name,
		P.ListPrice
 FROM AdventureWorks2014.Production.Product AS P  JOIN AdventureWorks2014.Production.ProductSubcategory AS PS
                                            ON P.ProductSubcategoryID=PS.ProductSubcategoryID
									JOIN AdventureWorks2014.Production.ProductCategory AS PC
									        ON PS.ProductCategoryID=PC.ProductCategoryID
									JOIN AdventureWorks2014.Sales.SalesOrderDetail AS SOD
									        ON P.ProductID=SOD.ProductID
									JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH
									        ON SOD.SalesOrderID=SOH.SalesOrderID
 WHERE YEAR (SOH.OrderDate)=2014 
 ORDER BY P.ProductID ASC


-- b)	U tabelu Narudzbe dodati sve narudžbe obavljene u 2014. godini
		--i.	SalesOrderNumber -> BrojNarudzbe
		--ii.	OrderDate - > Datum
		--iii.	TotalDue -> Ukupno
INSERT INTO Narudzbe
SELECT SOH.SalesOrderID,
       SOH.SalesOrderNumber,
	   SOH.OrderDate,
	   SOH.TotalDue
FROM AdventureWorks2014.Sales.SalesOrderHeader AS SOH 
WHERE YEAR (SOH.OrderDate)=2014
ORDER BY SOH.SalesOrderID 

--c)	U tabelu StavkeNarudzbe prebaciti sve podatke o detaljima narudžbi uraðenih u 2014. godini
	--i.	OrderQty -> Kolicina
	--ii.	UnitPrice -> Cijena
	--iii.	UnitPriceDiscount -> Popust
	--iv.	LineTotal -> Iznos 

	INSERT INTO StavkeNarudzbe
	SELECT SOD.ProductID,
		   SOD.SalesOrderID,
	       SOD.OrderQty,
	       SOD.UnitPrice,
		   SOD.UnitPriceDiscount,
		   SOD.LineTotal
	FROM AdventureWorks2014.Sales.SalesOrderDetail AS SOD JOIN AdventureWorks2014.Sales.SalesOrderHeader AS SOH
	                                               ON SOD.SalesOrderID=SOH.SalesOrderID

    WHERE YEAR (SOH.OrderDate)=2014
	ORDER BY SOD.ProductID 
	SELECT * FROM AdventureWorks2014.Sales.SalesOrderDetail 


	--4.	U svojoj bazi podataka kreirati novu tabelu Skladista sa poljima SkladisteID i Naziv, 
	--a zatim je povezati sa tabelom Proizvodi u relaciji više prema više. 
	--Za svaki proizvod na skladištu je potrebno èuvati kolièinu (cjelobrojna vrijednost).	 

	CREATE TABLE Skladista (
	SkladisteID INT IDENTITY (1,1) PRIMARY KEY,
    Naziv NVARCHAR (40) NOT NULL
	)

	CREATE TABLE ProizvodiUSkladistu(
	 ProizvodID INT FOREIGN KEY REFERENCES Proizvodi (ProizvodID),
	 SkladisteID INT FOREIGN KEY REFERENCES Skladista (SkladisteID),
	 Kolicina INT NOT NULL,
	 PRIMARY KEY (ProizvodID,SkladisteID)

	)

	--5.	U tabelu Skladista  dodati tri skladišta proizvoljno, a zatim za sve proizvode na svim skladištima
	-- postaviti kolièinu na 0 komada.

	INSERT INTO Skladista VALUES ( 'Skladiste 1'),
	                             ('Skladiste 2'),
								 ('Skladiste 3')

								 SELECT * FROM Skladista
      INSERT INTO ProizvodiUSkladistu VALUES ( (SELECT TOP 1 ProizvodID  FROM Proizvodi ORDER BY NEWID()),1,0),
	                                         ( (SELECT TOP 1 ProizvodID  FROM Proizvodi ORDER BY RAND() ),2,0),
											 ((SELECT TOP 1 ProizvodID  FROM Proizvodi ORDER BY ProizvodID ),3,0)

	--6.	Kreirati uskladištenu proceduru koja vrši izmjenu stanja skladišta (kolièina).
	-- Kao parametre proceduri proslijediti identifikatore proizvoda i skladišta, te kolièinu.	
	GO
	ALTER PROCEDURE usp_ProizvodiUSkladistu_Update (
	@ProizvodID INT ,
	@SkladisteID INT,
	@Kolicina INT
	)
	AS
	BEGIN
	           UPDATE ProizvodiUSkladistu
			   SET Kolicina=Kolicina+@Kolicina
			   WHERE ProizvodID=@ProizvodID AND SkladisteID=@SkladisteID 
			   IF @ProizvodID NOT IN (SELECT ProizvodID FROM Proizvodi)
			   PRINT 'Proizvod ne postoji ili nije na skladistu'
			   IF @SkladisteID NOT IN (SELECT SkladisteID FROM Skladista)
			   PRINT 'Skladiste ne postoji'
   END

	EXEC usp_ProizvodiUSkladistu_Update 701,3,4 
	GO
	EXEC usp_ProizvodiUSkladistu_Update 707,3,-1
	SELECT * FROM ProizvodiUSkladistu


	--7.	Nad tabelom Proizvodi kreirati non-clustered indeks nad poljima Sifra i Naziv, 
	--a zatim napisati proizvoljni upit koji u potpunosti iskorištava kreirani indeks. 
	--Upit obavezno mora sadržavati filtriranje podataka.
	SELECT * FROM Proizvodi
	CREATE NONCLUSTERED INDEX IX_SifraNaziv_Proizvodi ON Proizvodi (
	Sifra, Naziv
	)

	SELECT Sifra,Naziv FROM Proizvodi 

	--8.	Kreirati trigger koji æe sprijeèiti brisanje zapisa u tabeli Proizvodi.
	GO
	CREATE TRIGGER tr_SprijeciBrisanje ON Proizvodi 
	INSTEAD OF DELETE AS
	PRINT ' Nemate privilegiju brisanja proizvoda'
	ROLLBACK;

	DELETE FROM Proizvodi WHERE ProizvodID= 707
	SELECT * FROM Proizvodi WHERE ProizvodID=707

	--9.	Kreirati view koji prikazuje sljedeæe kolone: šifru, naziv i cijenu proizvoda, ukupnu prodanu kolièinu 
	--i ukupnu zaradu od prodaje.
	GO
	CREATE VIEW v_Novi AS
	SELECT P.Sifra,
		   P.Naziv,
		   P.Cijena,
		   SUM(S.Kolicina) AS 'Ukupna prodana kolicina',
		   SUM(S.Kolicina*S.Cijena) AS 'Ukupna zarada od prodaje'
	FROM Proizvodi AS P JOIN StavkeNarudzbe AS S
	                ON P.ProizvodID=S.ProizvodID
	GROUP BY P.Sifra, P.Naziv,P.Cijena

	--10.	Kreirati uskladištenu proceduru koja æe za unesenu šifru proizvoda prikazivati ukupnu prodanu kolièinu i 
	--ukupnu zaradu. Ukoliko se ne unese šifra proizvoda procedura treba da prikaže prodaju svih proizovda.
	-- U proceduri koristiti prethodno kreirani view.	

	ALTER PROCEDURE usp_UkupnaP_Select (
	@Sifra NVARCHAR (25)
	)
	AS
	BEGIN
	           IF @Sifra IN (SELECT Sifra FROM v_Novi)
	           SELECT [Ukupna prodana kolicina],[Ukupna zarada od prodaje]
			   FROM v_Novi
			   WHERE Sifra=@Sifra

			   ELSE IF @Sifra NOT IN (SELECT Sifra FROM v_Novi)
			   SELECT *
			   FROM v_Novi
	END
	

	SELECT SUM(Kolicina) FROM StavkeNarudzbe WHERE ProizvodiD=994
	SELECT Sifra,ProizvodID FROM Proizvodi WHERE Sifra='BB-7421'

	EXEC usp_UkupnaP_Select 'BB-7421'
	EXEC usp_UkupnaP_Select 'BBBBBBB'
	--11.	U svojoj bazi podataka kreirati novog korisnika za login student 
	--te mu dodijeliti odgovarajuæu permisiju kako bi mogao izvršavati prethodno kreiranu proceduru.
	
	CREATE LOGIN '[\Student]'
	FROM WINDOWS

	CREATE USER AdnaM FOR LOGIN [DESKTOP]

  GRANT EXECUTE ON [dbo].[usp_ProizvodiUSkladistu_Update] TO [AdnaM]
