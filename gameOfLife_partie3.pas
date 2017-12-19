PROGRAM gameOfLife;
USES Crt, sysutils;

{
* 
* 	Par convention si la vie de l'herbe est négative, l'herbe est morte.
* 
* }

CONST 
	M    = 5;
	N    = 15;
	ENERGIE = 4;
	ENERGIE_MOUTON = 14;
	AGE_MORT = 5;
	ENERGIE_REPRODUCTION = 10;
	ENERGIE_REPRODUCTION_MOUTON = 20;
	ENERGIE_INITIALE_MOUTON = 11;
	ENERGIE_INITIALE = 1;
	AGE_MORT_MOUTON = 15;


TYPE typePosition = RECORD
	x, y : INTEGER;
END;
	
TYPE typeHerbe = RECORD
	age : INTEGER;
	energie : INTEGER;
END;

TYPE tabPosition = array [0..M] of typePosition;	

TYPE typeGeneration = array [0..N - 1, 0..N - 1] of typeHerbe;

TYPE typeGrille = array [0..N - 1, 0..N - 1] of String;

PROCEDURE afficherGrille(generation : typeGrille);
VAR
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			write(' ', generation[i, j], ' ');
		END;
		writeln();
	END;
END;

PROCEDURE setToZero(VAR grille : typeGrille);
VAR
	i, j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			grille[i, j] := '--';
		END;
	END;
END;

FUNCTION initGeneration2(vecteurPositionsMoutons, vecteurPositionsHerbes : tabPosition) : typeGrille;
VAR
	grille : typeGrille;
	i : integer;
BEGIN
	setToZero(grille);
	FOR i := 0 TO M DO
	BEGIN
		IF((vecteurPositionsHerbes[i].x > 0) and (vecteurPositionsHerbes[i].y > 0)) THEN
			grille[vecteurPositionsHerbes[i].x, vecteurPositionsHerbes[i].y] := 'h-'
	END; 
	FOR i := 0 TO M DO
	BEGIN
		IF((vecteurPositionsHerbes[i].x > 0) and (vecteurPositionsHerbes[i].y > 0)) THEN
		BEGIN
			IF(grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] = 'h-') THEN
				grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] := 'hm'
			ELSE
				grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] := '-m';
		END;
	END;
	initGeneration2 := grille;
END;

FUNCTION initPrairieByHand(text : string) : tabPosition;
VAR
	nbrHerbe, posX, posY,i  : integer;
	tableau : tabPosition;
	position : typePosition;
BEGIN
	writeln('nbr ', text);
	readln(nbrHerbe);
	FOR i := 0 TO nbrHerbe - 1 DO
	BEGIN
		REPEAT
			ClrScr;
			writeln('Rentrez l''abscisse du point n°', i, ' : ');
			readln(posX);
			writeln('Rentrez l''ordonnée du point n°', i, ' : ');
			readln(posY);
		UNTIL (((posX >= 0) and (posX < N)) and ((posY >= 0) and (posY < N)));
		position.x := posX;
		position.y := posY;
		tableau[i] := position;
	END;
	
	FOR i := nbrHerbe TO M DO
	BEGIN
		position.x := -1;
		position.y := -1;
		tableau[i] := position;
	END;
	
	initPrairieByHand := tableau;
END;

FUNCTION initPrairie(pourcentageMouton, pourcentageHerbe : INTEGER) : typeGeneration;
VAR
	x, y, nbrDeCellules : INTEGER;
	prairie : typeGrille;
BEGIN
	setToZero(prairie);
	nbrDeCellules := round((pourcentageMouton / 100) * (N * N));
	WHILE nbrDeCellules > 0 DO
	BEGIN
		x := random(N);
		y := random(N);
		WHILE prairie[x, y].age >= 0 DO
		BEGIN
			x := random(N);
			y := random(N);
		END;
		prairie[x, y] := '-m';
		dec(nbrDeCellules);
	END;
	nbrDeCellules := round((pourcentageHerbe / 100) * (N * N));
	WHILE nbrDeCellules > 0 DO
	BEGIN
		x := random(N);
		y := random(N);
		WHILE prairie[x, y].age >= 0 DO
		BEGIN
			x := random(N);
			y := random(N);
		END;
		IF (prairie[x, y] = '-m') THEN
			prairie[x, y] := 'hm'
		ELSE
			prairie[x, y] := 'h-';
		
		dec(nbrDeCellules);
	END;
	initPrairie := prairie;
END;

VAR
	tabMouton, tabHerbe : tabPosition;
	grille :  typeGrille;
	
BEGIN
	tabMouton := initPrairieByHand('mouton');
	tabHerbe := initPrairieByHand('herbe');
	writeln('je suis la');
	grille := initGeneration2(tabMouton, tabHerbe);
	afficherGrille(grille);
END.
