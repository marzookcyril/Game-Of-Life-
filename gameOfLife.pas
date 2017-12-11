PROGRAM gameOfLife;
USES Crt;

CONST 
	M    = 20;
	N    = 20;
	MORT = 0;
	VIE  = 1;
	
// position d'une cellule
TYPE typePosition = Record
	x : integer;
	y : integer;
END;

//tableau de position de cellules (pas la grille)
TYPE tabPosition = array [0..M] of typePosition;
	
TYPE typeGrille  = array [0..N, 0..N] of INTEGER;

FUNCTION remplirGrille(tableau : tabPosition) : typeGrille;
VAR
		grille : typeGrille;
		i 	   : INTEGER;
BEGIN
	FOR i := 0 TO M DO
	BEGIN
		grille[tableau[i].x , tableau[i].y] := VIE;
	END;

END;

{
* 	+-----------------+
* 	|||    |    |   |    |
* 	+-----------------+
*   |  |  |  |  |  |  |
* 	+-----------------+
*   |  |  |  |  |  |  |
* 	+-----------------+
*   |  |  |  |  |  |  |
* 	+-----------------+
*   |  |  |  |  |  |  |
* 	+-----------------+
*   |  |  |  |  |  |  |
* 	+-----------------+
* 
* 
* 
* }

PROCEDURE writeLigne();
VAR
	i : INTEGER;
BEGIN
	write('+');
	FOR i := 0 TO 2 * (N - 1) DO
	BEGIN
		write('-');
	END;
	write('+');
END;

PROCEDURE afficherGrille(grille :  typeGrille);
VAR
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO 2 * N DO
	BEGIN
		IF (i MOD 2 = 0) then
			writeLigne()
		ELSE
			FOR j := 0 TO 2 * N DO
			BEGIN
				write('|', grille[i * 2, j], '|');
			END;
	END;
END;

BEGIN

END.

