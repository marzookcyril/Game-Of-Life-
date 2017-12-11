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

BEGIN

END.
