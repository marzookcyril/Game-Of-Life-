PROGRAM gameOfLife;
USES Crt, sysutils, gameOfLife_partie4;

VAR
	nombreGeneration : integer;

PROCEDURE afficherGeneration(generation : typeGeneration);
VAR
	i,j : INTEGER;
BEGIN
	logGrillePart2(generation, nombreGeneration);
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			IF(generation[i,j].age >= 0) THEN
				write(' ', generation[i,j].age)
			ELSE
				write(' ·');
		END;
		writeln();
	END;
END;

PROCEDURE setToZero(VAR grille : typeGeneration);
VAR
	i, j : INTEGER;
	morte : typeHerbe;
BEGIN
	morte.age := -1;
	morte.energie := 0;
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			grille[i, j] := morte;
		END;
	END;
END;

FUNCTION initialiserGeneration(listePosition : tabPosition) : typeGeneration;
VAR
		prairie : typeGeneration;
		i     : INTEGER;
		herbe : typeHerbe;
BEGIN
	herbe.age := 0;
	herbe.energie := 1;

	setToZero(prairie);

	FOR i := 0 TO M - 1 DO
	BEGIN
		IF (listePosition[i].x > 0) and (listePosition[i].y > 0) THEN
			prairie[listePosition[i].x, listePosition[i].y] := herbe;
	END;


	initialiserGeneration := prairie;
END;

FUNCTION reproduire(prairie : typeGeneration; x, y : integer) : typeGeneration;
VAR
	herbe : typeHerbe;
	nouvellePrairie : typeGeneration;
	i, j, k, l : integer;
BEGIN
	herbe.age := 0;
	herbe.energie := 1;
	setToZero(nouvellePrairie);
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
			
			writeln(k, ' ', l);
			writeln(prairie[k, l].age);
			
			IF (prairie[k, l].age < 0) then
			BEGIN
				writeln('je suis la');
				nouvellePrairie[k, l] := herbe;
			End
			else
			BEGIN
				nouvellePrairie[k, l] := prairie[k, l];
			END;
		END;
	END;
	reproduire := nouvellePrairie;
END;

FUNCTION calculerNouvelleGeneration(generation : typeGeneration) : typeGeneration;
VAR
	nouvellePrairie : typeGeneration;
	morte : typeHerbe;
	i, j : integer;
BEGIN
	morte.age := -1;
	morte.energie := 0;
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			if(generation[i, j].age >= 0) then
			BEGIN
				inc(generation[i, j].age);
				generation[i, j].energie := generation[i, j].energie + ENERGIE;
				nouvellePrairie[i,j] := generation[i, j];

				IF (generation[i, j].age >= AGE_MORT) THEN
					nouvellePrairie[i, j] := morte;

				IF ((generation[i, j].age < AGE_MORT) and (generation[i, j].energie >= ENERGIE_REPRODUCTION)) THEN
				BEGIN
					nouvellePrairie := reproduire(nouvellePrairie, i, j);
					nouvellePrairie[i, j].energie := generation[i, j].energie - ENERGIE_REPRODUCTION;
				END;
			END
			ELSE
				nouvellePrairie[i, j] := morte;
		END;
	END;
	calculerNouvelleGeneration := nouvellePrairie;
END;

FUNCTION compteCellule(prairie : typeGeneration) : INTEGER;
VAR
	i, result : INTEGER;
BEGIN
	result := 0;
	FOR i := 0 TO N * N - 1 DO
	BEGIN
		IF (prairie[i MOD N, i DIV N].age >= 0) THEN
			result := result + 1
	END;
	compteCellule := result;
END;

FUNCTION run(prairie : typeGeneration; n : INTEGER) : typeGeneration;
VAR
	tmp : integer;
BEGIN
	tmp := 0;
	REPEAT
		prairie := calculerNouvelleGeneration(prairie);
		if (n > 0) then
			inc(tmp);
		ClrScr;
		writeln('GRILLE GENERATION : ', tmp - 1, ' / ', n);
		afficherGeneration(prairie);
		Delay(1500);
		inc(nombreGeneration);
	UNTIL ((compteCellule(prairie) = 0) or ((tmp > n) and (n > 0)));
	run := prairie;
END;

FUNCTION initPrairie(pourcentage : INTEGER) : typeGeneration;
VAR
	x, y, nbrDeCellules : INTEGER;
	prairie : typeGeneration;
	herbe : typeHerbe;
BEGIN
	herbe.age := 0;
	herbe.energie := 1;
	setToZero(prairie);
	nbrDeCellules := round((pourcentage / 100) * (N * N));
	WHILE nbrDeCellules > 0 DO
	BEGIN
		x := random(N);
		y := random(N);
		WHILE prairie[x, y].age >= 0 DO
		BEGIN
			x := random(N);
			y := random(N);
		END;
		prairie[x, y] := herbe;
		dec(nbrDeCellules);
	END;
	initPrairie := prairie;
END;

FUNCTION initPrairieByHand() : typeGeneration;
VAR
	nbrHerbe, posX, posY,i  : integer;
	tableau : tabPosition;
	position : typePosition;
BEGIN
	writeln('nbr herbe');
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

	FOR i:= nbrHerbe TO M DO
	BEGIN
		position.x := -1;
		position.y := -1;
		tableau[i] := position;
	END;
	initPrairieByHand := initialiserGeneration(tableau);
END;
VAR
	prairie : typeGeneration;
	test    : importFile;
BEGIN
	test := handleArgs();
	IF (test.typeRun = 'R') then
		prairie := initPrairie(test.randomPctg)
	else
		prairie := initialiserGeneration(test.vecteur1);
	run(prairie, test.nbrGen);
END.
