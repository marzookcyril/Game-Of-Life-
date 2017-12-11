PROGRAM gameOfLife;
USES Crt;

{
*	M    = taille par défault d'un vecteur de tabPosition
*	N    = taille de la grille
* 	MORT = état MORT de la cellule
* }

CONST 
	M    = 1;
	N    = 3;
	MORT = 0;
	VIE  = 1;
	
TYPE typePosition = RECORD
	x, y : INTEGER;
END;

TYPE tabPosition = array [0..M] of typePosition;
	
TYPE typeGrille  = array [0..N, 0..N] of INTEGER;

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
		BEGIN
			writeLigne();
			writeln();
		END
		ELSE
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				IF(grille[i DIV 2, j] = 1) then
					write('|', '█')
				else
					write('|', ' ');
			END;
			writeln('|');
		END;
	END;
END;

//on met la grille a zero
PROCEDURE setToZero(VAR grille : typeGrille);
VAR
	i, j : INTEGER;
BEGIN
	FOR i := 0 TO N DO
	BEGIN
		FOR j := 0 TO N DO
		BEGIN
			grille[i, j] := MORT;
		END;
	END;
END;

//on remplit la grille en fonction du tableau 
FUNCTION remplirGrille(tableau : tabPosition) : typeGrille;
VAR
		grille : typeGrille;
		i 	   : INTEGER;
BEGIN
	setToZero(grille);
	FOR i := 0 TO M DO
	BEGIN
		grille[tableau[i].x, tableau[i].y] := VIE;
	END;
	remplirGrille := grille;
END;

//writeln('x + i : ',x + i,',y + j : ',y + j,', (x + i) MOD N : ',(x + i) MOD N,', (y + j) MOD N : ',(y + j) MOD N,', ii : ', ii,', jj : ',jj,' : RESULT : ');

FUNCTION calculerValeurCellule(grille : typeGrille; x, y : INTEGER) : INTEGER;
VAR
	result, i, j, ii, jj : integer;
BEGIN
	result := 0;
	FOR i := -1 TO 1 DO
	BEGIN
		FOR j := -1 TO 1 DO
		BEGIN
			ii := (x + i) MOD N;
			jj := (y + j) MOD N;
			writeln('ii : ', ii, ' ,jj : ', jj);
			if (ii < 0) then
				ii := N + ii;
			if (jj < 0) then
				jj := N + jj;
			writeln('NOUVEAU ii : ', ii, ' ,jj : ', jj);
		END;
	END;
	result := result - grille[x, y];
	calculerValeurCellule := result;
END;

FUNCTION calculerNouvelleGrille(grille : typeGrille) : typeGrille;
VAR
	x, y, valeur : integer;
	nouvelleGrille : typeGrille;
BEGIN
	FOR x := 0 TO N - 1 DO
	BEGIN
		FOR y := 0 TO N - 1 DO
		BEGIN
			valeur := calculerValeurCellule(grille, x, y);
			IF (((valeur <= 1) or (valeur >= 4)) and (grille[x,y] = VIE)) then
				nouvelleGrille[x,y] := MORT;
			IF ((valeur = 2) or (valeur = 3) and (grille[x,y] = VIE)) then
				nouvelleGrille[x,y] := VIE;
			IF ((valeur = 3) and (grille[x,y] = MORT)) then
				nouvelleGrille[x,y] := VIE;
		END;
	END;
	calculerNouvelleGrille := nouvelleGrille;
END;

//on remplit la grille de façon aléatoire en fonction d'un pourcentage
FUNCTION initGrille(pourcentage : INTEGER) : typeGrille;
VAR
	x, y, nbrDeCellules : INTEGER;
	grille : typeGrille;
BEGIN
	setToZero(grille);
	nbrDeCellules := round((pourcentage / 100) * (N * N));
	WHILE nbrDeCellules > 0 DO
	BEGIN
		x := random(N);
		y := random(N);
		WHILE grille[x, y] <> 0 DO
		BEGIN
			x := random(N);
			y := random(N);
		END;
		grille[x, y] := VIE;
		dec(nbrDeCellules);
	END;
	initGrille := grille;
END;

VAR
	next ,grille : typeGrille;
BEGIN
	Randomize;
	grille := initGrille(50);
	writeln('GRILLE DE DEPART');
	afficherGrille(grille);
	calculerValeurCellule(grille, 0, 0);
	{next := calculerNouvelleGrille(grille);
	writeln('GENERATION 1');
	afficherGrille(next);}
END.

