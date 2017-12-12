PROGRAM gameOfLife;
USES Crt;

{
*	M    = taille par défault d'un vecteur de tabPosition
*	N    = taille de la grille
* 	MORT = état MORT de la cellule
* }

CONST 
	M    = 1;
	N    = 5;
	MORT = FALSE;
	VIE  = TRUE;
	
TYPE typePosition = RECORD
	x, y : INTEGER;
END;

TYPE tabPosition = array [0..M] of typePosition;
	
TYPE typeGrille  = array [0..N - 1, 0..N - 1] of BOOLEAN;

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
				IF(grille[i DIV 2, j] = TRUE) then
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
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
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

//writeln('x + i : ',x + i,',y + j : ',y + j,', (x + i) MOD N : ',(x + i) MOD N,', (y + j) MOD N : ',(y + j) MOD N,', ii : ', ii,', l : ',l,' : RESULT : ');

FUNCTION calculerValeurCellule(grille : typeGrille; x, y : INTEGER) : INTEGER;
VAR
	result, i, j, k, l : integer;
BEGIN
	result := 0;
	FOR i := -1 TO 1 DO
	BEGIN
		FOR j := -1 TO 1 DO
		BEGIN
			//k := (x + i) MOD N;
			//l := (y + j) MOD N;
			k := (x + i);
			l := (y + j);
			//writeln('k : ', k, ' ,l : ', l);
			if(k > N) then
				k := 0;
			if (l > N) then
				l := 0;
			if (k < 0) then
				k := N - 1;
			if (l < 0) then
				l := N - 1;
			if(grille[k, l] = TRUE) then
				result := result + 1;
			//writeln(grille[k, l]);
			//writeln('NOUVEAU k : ', k, ' ,l : ', l, ' grille[k, l] : ', grille[k, l]);
		END;
	END;
	if(grille[x, y] = TRUE) then
				result := result - 1;
	//writeln('x :', x, ',y : ', y, ' = ', result);
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
			IF (grille[x,y] = VIE) then
			BEGIN
				IF ((valeur = 3) or (valeur = 2)) THEN
				BEGIN
					//writeln('still alive', x, y);
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
					//writeln('VIE -> MORT', x, y);
					nouvelleGrille[x,y]:= MORT;
			END
			ELSE
			BEGIN
				IF (valeur = 3) THEN
				BEGIN
					//writeln('naissance', x, y);
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
				BEGIN
					//writeln('rip', x, y);
					nouvelleGrille[x,y]:= MORT;
				END;
			END;
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
		WHILE grille[x, y] <> FALSE DO
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
	grille := initGrille(25);
	writeln('GRILLE DE DEPART');
	afficherGrille(grille);
	calculerValeurCellule(grille, 0, 0);
	writeln('DEBUG');
	next := calculerNouvelleGrille(grille);
	writeln('GENERATION 1');
	afficherGrille(next);
END.

