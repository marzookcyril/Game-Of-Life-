PROGRAM gameOfLife;
USES Crt, sysutils;


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
	DEBUG = TRUE;
	
TYPE typePosition = RECORD
	x, y : INTEGER;
END;

TYPE tabPosition = array [0..M] of typePosition;
	
TYPE typeGrille  = array [0..N - 1, 0..N - 1] of BOOLEAN;


PROCEDURE afficherGrille(grille :  typeGrille);
VAR
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			IF(grille[i,j] = VIE) THEN
				write(' v')
			ELSE
				write(' .');
		END;
		writeln();
	END;
END;

FUNCTION readTableauPosition(s : string) : tabPosition;
VAR
	g,d,L,i,ii : INTEGER;
	tableau : tabPosition;
	position : typePosition;
BEGIN
	i := 0;
	REPEAT 
		l := length(s);
		g := pos('(', s);
		d := pos(')' , s);
		position.x := strtoint(copy(s, g+1, 1));
		position.y := strtoint(copy(s, d-1, 1));
		s := copy(s, g+1, l - length(copy(s, 1, l - d)));
		tableau[i] := position;
		inc(i);
		writeln('boucle');
	UNTIL (s = ']');
	FOR ii := 0 TO i do
	BEGIN
		writeln(tableau[i].x, ' , ', tableau[i].y);
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

FUNCTION calculerValeurCellule(grille : typeGrille; x, y : INTEGER) : INTEGER;
VAR
	result, i, j, k, l : integer;
BEGIN
	result := 0;
	FOR i := -1 TO 1 DO
	BEGIN
		FOR j := -1 TO 1 DO
		BEGIN
			k := (x + i) MOD N;
			l := (y + j) MOD N;
			if (k < 0) then
				k := N - 1;
			if (l < 0) then
				l := N - 1;
			if(grille[k, l] = TRUE) then
				result := result + 1;
		END;
	END;
	if(grille[x, y] = TRUE) then
				result := result - 1;
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
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
					nouvelleGrille[x,y]:= MORT;
			END
			ELSE
			BEGIN
				IF (valeur = 3) THEN
				BEGIN
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
				BEGIN
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

FUNCTION compteCellule(grille : typeGrille) : INTEGER;
VAR
	i, result : INTEGER;
BEGIN
	result := 0;
	FOR i := 0 TO N * N - 1 DO
	BEGIN
		IF (grille[i MOD N, i DIV N] = VIE) THEN
			result := result + 1
	END;
	compteCellule := result;
END;

FUNCTION run(grilleInitiale : typeGrille; n : INTEGER) : typeGrille;
VAR
	tmp : integer;
BEGIN
	tmp := 0;
	REPEAT
		grilleInitiale := calculerNouvelleGrille(grilleInitiale);
		inc(tmp);
		IF DEBUG THEN
		BEGIN
			writeln('GRILLE GENERATION : ', tmp - 1, ' / ', n);
			afficherGrille(grilleInitiale);
		END;
	UNTIL ((compteCellule(grilleInitiale) = 0) or (tmp > n));
	run := grilleInitiale;
END;

VAR
	grille : typeGrille;
BEGIN
	Randomize;
	grille := initGrille(25);
	writeln('GRILLE DE DEPART');
	afficherGrille(grille);
	run(grille, 10);
	//readTableauPosition('[(100 200)]')
END.

