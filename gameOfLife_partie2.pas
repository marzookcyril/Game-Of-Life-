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
				write(' #')
			ELSE
				write(' ·');
		END;
		writeln();
	END;
END;

PROCEDURE setToZero(VAR grille : typeGeneration);
VAR
	i, j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			grille[i, j] := HERBE_MORTE;
		END;
	END;
END;

FUNCTION initialiserGeneration(listePosition : tabPosition) : typeGeneration;
VAR
		prairie : typeGeneration;
		i     : INTEGER;
BEGIN
	setToZero(prairie);

	FOR i := 0 TO M - 1 DO
	BEGIN
		IF (listePosition[i].x > 0) and (listePosition[i].y > 0) THEN
			prairie[listePosition[i].x, listePosition[i].y] := NOUV_HERBE_P2;
	END;
	initialiserGeneration := prairie;
END;

FUNCTION reproduire(prairie : typeGeneration; x, y : integer) : typeGeneration;
VAR
	i, j, k, l : integer;
BEGIN
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

			IF (prairie[k, l].age < 0) then
				prairie[k, l] := NOUV_HERBE_P2;
		END;
	END;
	reproduire := prairie;
END;

FUNCTION calculerNouvelleGeneration(generation : typeGeneration) : typeGeneration;
VAR
	nouvellePrairie : typeGeneration;
	i, j : integer;
BEGIN
	nouvellePrairie := generation;

	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			IF (generation[i, j].age >= 0) THEN
			BEGIN
				inc(nouvellePrairie[i,j].age);
				nouvellePrairie[i, j].energie := nouvellePrairie[i, j].energie + ENERGIE;

				IF (nouvellePrairie[i, j].age >= AGE_MORT) THEN
				BEGIN
					nouvellePrairie[i, j] := HERBE_MORTE;
				END
				ELSE
				BEGIN
					IF (generation[i, j].energie >= ENERGIE_REPRODUCTION) THEN
					BEGIN
						nouvellePrairie := reproduire(nouvellePrairie, i, j);
						nouvellePrairie[i, j].energie := nouvellePrairie[i, j].energie - ENERGIE_REPRODUCTION;
					END;
				END;
			END;
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

FUNCTION run(prairie : typeGeneration; n, delayValue : INTEGER) : typeGeneration;
VAR
	tmp : integer;
BEGIN
	tmp := 0;
	REPEAT
		prairie := calculerNouvelleGeneration(prairie);
		ClrScr;
		writeln('GRILLE GENERATION : ', tmp, ' / ', n);
		afficherGeneration(prairie);
		Delay(delayValue);
		if (n > 0) then
		BEGIN
			inc(tmp);
			inc(nombreGeneration);
		END;
	UNTIL ((compteCellule(prairie) = 0) or ((tmp > n) and (n > 0)));

	run := prairie;
END;

FUNCTION initPrairie(pourcentage : INTEGER) : typeGeneration;
VAR
	x, y, nbrDeCellules : INTEGER;
	prairie : typeGeneration;
BEGIN
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
		prairie[x, y] := NOUV_HERBE_P2;
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
	args    : importFile;
BEGIN
	args := handleArgs();
	IF (args.typeRun = 'R') then
		prairie := initPrairie(args.random1)
	else
		prairie := initialiserGeneration(args.vecteur1);
	prairie := run(prairie, args.nbrGen, args.delay);
	logPosToFile(convertGrillePart2(prairie), 'Herbe');
END.
