PROGRAM gameOfLife;
USES Crt, sysutils, gameOfLife_partie4;

VAR
	nombreGeneration : integer;

PROCEDURE afficherGrille(gen : typeGeneration2);
VAR
	i,j : INTEGER;
BEGIN
	logGrillePart3(gen, nombreGeneration);
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			TextColor(White);
			IF (gen.grille[i, j] = UNE_HERBE) THEN
			BEGIN
				TextColor(Green);
				write('h');
				TextColor(White);
				write('- ');
			END;
			IF (gen.grille[i, j] = UN_MOUTON) THEN
			BEGIN
				write('-');
				TextColor(Red);
				write('m ');
			END;
			IF (gen.grille[i, j] = UNE_HERBE_ET_UN_MOUTON) THEN
			BEGIN
				TextColor(Green);
				write('h');
				TextColor(Red);
				write('m ');
			END;
			IF (gen.grille[i, j] = LE_VIDE) THEN
				write('-- ');

		END;
		writeln();
	END;
END;

PROCEDURE setToZero(VAR grille : typeGrilleString);
VAR
	i, j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			grille[i, j] := LE_VIDE;
		END;
	END;
END;

// initie la generation avec deux vecteur de moutons et herbes
FUNCTION initGeneration2(vecteurPositionsMoutons, vecteurPositionsHerbes : tabPosition) : typeGeneration2;
VAR
	gen    : typeGeneration2;
	grille : typeGrilleString;
	i, counterElement      : integer;
	herbe, mouton : typeElement;
BEGIN
	counterElement := 0;
	gen.tailleVecteurObjects := length(vecteurPositionsHerbes) + length(vecteurPositionsMoutons) + 1;
	setLength(gen.vecteurObjects, gen.tailleVecteurObjects);

	setToZero(grille);

	FOR i := 0 TO M - 1 DO
	BEGIN
		IF((vecteurPositionsHerbes[i].x >= 0) and (vecteurPositionsHerbes[i].y >= 0)) THEN
		BEGIN
			herbe := NOUVEAU_HERBE;
			grille[vecteurPositionsHerbes[i].x, vecteurPositionsHerbes[i].y] := UNE_HERBE;
			herbe.position.x := vecteurPositionsHerbes[i].x;
			herbe.position.y := vecteurPositionsHerbes[i].y;
			gen.vecteurObjects[counterElement] := herbe;
			inc(counterElement);
		END;
	END;

	FOR i := 0 TO M - 1 DO
	BEGIN
		IF((vecteurPositionsMoutons[i].x >= 0) and (vecteurPositionsMoutons[i].y >= 0)) THEN
		BEGIN
			mouton := NOUVEAU_MOUTON;
			mouton.position.x := vecteurPositionsMoutons[i].x;
			mouton.position.y := vecteurPositionsMoutons[i].y;
			gen.vecteurObjects[counterElement] := mouton;
			inc(counterElement);
			IF(grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] = UNE_HERBE) THEN
				grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] := UNE_HERBE_ET_UN_MOUTON
			ELSE
				grille[vecteurPositionsMoutons[i].x, vecteurPositionsMoutons[i].y] := UN_MOUTON;
		END;
	END;

	// si jamais des positions étaient incorectes, on ne veut pas d'array trop grand.
	gen.tailleVecteurObjects := counterElement;
	setLength(gen.vecteurObjects, counterElement);
	gen.grille := grille;
	initGeneration2 := gen;
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

PROCEDURE addElementToSimulation(element : typeElement; VAR gen : typeGeneration2);
BEGIN
	// on ajoute un element à la simulation ssi cet element n'existe pas deja
	// dans la simulation.

	setLength(gen.vecteurObjects, gen.tailleVecteurObjects + 1);

	IF (element.element = ELEMENT_HERBE) THEN
	BEGIN
		IF (gen.grille[element.position.x, element.position.y] = LE_VIDE) THEN
		BEGIN
			gen.grille[element.position.x, element.position.y] := UNE_HERBE;
			gen.vecteurObjects[gen.tailleVecteurObjects] := element;
			inc(gen.tailleVecteurObjects);
		END;
		IF (gen.grille[element.position.x, element.position.y] = UN_MOUTON) THEN
		BEGIN
			gen.grille[element.position.x, element.position.y] := UNE_HERBE_ET_UN_MOUTON;
			gen.vecteurObjects[gen.tailleVecteurObjects] := element;
			inc(gen.tailleVecteurObjects);
		END;
	END;

	IF (element.element = ELEMENT_MOUTON) THEN
	BEGIN
		IF (gen.grille[element.position.x, element.position.y] = LE_VIDE) THEN
		BEGIN
			gen.grille[element.position.x, element.position.y] := UN_MOUTON;
			gen.vecteurObjects[gen.tailleVecteurObjects] := element;
			inc(gen.tailleVecteurObjects);
		END;
		IF (gen.grille[element.position.x, element.position.y] = UNE_HERBE) THEN
		BEGIN
			gen.grille[element.position.x, element.position.y] := UNE_HERBE_ET_UN_MOUTON;
			gen.vecteurObjects[gen.tailleVecteurObjects] := element;
			inc(gen.tailleVecteurObjects);
		END;
	END;
END;

// un mouton est calculé en fonction de lui-même, de l'ancienne grille et de la nouvelle grille (pour eviter les repetitions)
// tout est fait sur nextGen.
PROCEDURE calculerNextGenerationMouton(mouton : typeElement; oldGrille : typeGrilleString; VAR nextGen : typeGeneration2);
VAR
	nouveauMouton, bebeMouton : typeElement;
	k, l, i, j : integer;
	herbe : typePosition;
BEGIN
	// le mouton veilli
	inc(mouton.age);

	// si le mouton est trop vieux, ou sans energie : il meurt.
	IF ((mouton.age < 15) and (mouton.energie > 0)) THEN
	BEGIN
		// on cree un nouveau mouton pour ne pas travailler sur celui de
		// la generation precedente.
		nouveauMouton := mouton;

		// on regarde si le mouton peut manger.
		IF (oldGrille[mouton.position.x, mouton.position.y] = UNE_HERBE_ET_UN_MOUTON) THEN
		BEGIN
			//writeln('Le mouton n°', nextGen.tailleVecteurObjects, ' mange.');
			// on ajoute 14 à l'energie du mouton et ajoute à la prochaine simulation
			nouveauMouton.energie := nouveauMouton.energie + 14;
			addElementToSimulation(nouveauMouton, nextGen);
		END
		// si il ne peut pas manger, il peut peut-etre se reproduire
		ELSE
		BEGIN
			IF (mouton.energie >= ENERGIE_REPRODUCTION_MOUTON) THEN
			BEGIN
				// on regarde dans les cases environantes si il n'y a pas de
				// de la place pour un nouveau mouton
				//writeln('Le mouton n°', nextGen.tailleVecteurObjects, ' se reproduit.');
				bebeMouton := NOUVEAU_MOUTON;

				FOR i := -1 TO 1 DO
				BEGIN
					FOR j := -1 TO 1 DO
					BEGIN
						k := (mouton.position.x + i) MOD N;
						l := (mouton.position.y + j) MOD N;
						if (k < 0) then
							k := N - 1;
						if (l < 0) then
							l := N - 1;
						IF ((oldGrille[k, l] = LE_VIDE) or (oldGrille[k, l] = UNE_HERBE)) THEN
						BEGIN
							bebeMouton.position.x := k;
							bebeMouton.position.y := l;
						END;
					END;
				END;

				// on a trouve une place pour le bebe.
				IF (bebeMouton.position.x <> -1) THEN
				BEGIN
					addElementToSimulation(bebeMouton, nextGen);
					nouveauMouton.energie := nouveauMouton.energie - 20;
				END;

				// Dans tous les cas, le mouton nouveauMouton reste dans la simulation :
				addElementToSimulation(nouveauMouton, nextGen);
			END
			// il ne peut pas se reproduire, on essais de le faire se mouvoir.
			ELSE
			BEGIN
				//writeln('Le mouton n°', nextGen.tailleVecteurObjects, ' se deplace (essais).');
				herbe.x := -1;
				FOR i := -1 TO 1 DO
				BEGIN
					FOR j := -1 TO 1 DO
					BEGIN
						k := (mouton.position.x + i) MOD N;
						l := (mouton.position.y + j) MOD N;
						if (k < 0) then
							k := N - 1;
						if (l < 0) then
							l := N - 1;
						IF (oldGrille[k, l] = LE_VIDE) THEN
						BEGIN
							nouveauMouton.position.x := k;
							nouveauMouton.position.y := l;
						END;

						IF (oldGrille[k, l] = UNE_HERBE) THEN
						BEGIN
							herbe.x := k;
							herbe.y := l;
						END;
					END;
				END;

				IF herbe.x <> -1 THEN
				BEGIN
					nouveauMouton.position := herbe;
				END;

				IF nouveauMouton.position.x <> mouton.position.x THEN
				BEGIN
					//writeln('Le mouton n°', nextGen.tailleVecteurObjects, ' a reussi a se deplacer.');
					nouveauMouton.energie := nouveauMouton.energie - 2;
				END
				// le mouton ne peut pas bouger, il fait rien.
				ELSE
				BEGIN
					//writeln('Le mouton n°', nextGen.tailleVecteurObjects, ' ne fait rien.');
					nouveauMouton.energie := nouveauMouton.energie - 1;
				END;

				addElementToSimulation(nouveauMouton, nextGen);
			END;
		END;
	END;
END;

PROCEDURE calculerNextGenerationHerbe(herbe : typeElement; oldGrille : typeGrilleString; VAR nextGen : typeGeneration2);
VAR
	nouvelleHerbe, bebeHerbe : typeElement;
	k, l, i, j : integer;
BEGIN
	IF oldGrille[herbe.position.x, herbe.position.y] <> UNE_HERBE_ET_UN_MOUTON THEN
	BEGIN
		IF herbe.age < 5 THEN
		BEGIN
			nouvelleHerbe := herbe;
			nouvelleHerbe.energie := nouvelleHerbe.energie + 4;
			inc(nouvelleHerbe.age);

			IF (herbe.energie >= 10) THEN
			BEGIN

				bebeHerbe := NOUVEAU_HERBE;

				FOR i := -1 TO 1 DO
				BEGIN
					FOR j := -1 TO 1 DO
					BEGIN
						k := (herbe.position.x + i) MOD N;
						l := (herbe.position.y + j) MOD N;
						if (k < 0) then
							k := N - 1;
						if (l < 0) then
							l := N - 1;
						IF ((oldGrille[k, l] = LE_VIDE) or (oldGrille[k, l] = UN_MOUTON)) THEN
						BEGIN
							bebeHerbe.position.x := k;
							bebeHerbe.position.y := l;
							addElementToSimulation(bebeHerbe, nextGen);
						END;
					END;
				END;

				IF bebeHerbe.position.x <> -1 THEN
					nouvelleHerbe.energie := nouvelleHerbe.energie - 10;

				addElementToSimulation(nouvelleHerbe, nextGen);
			END
			ELSE
			BEGIN
				addElementToSimulation(nouvelleHerbe, nextGen);
			END;
		END;
	END;
END;


FUNCTION calculerNouvelleGeneration(gen : typeGeneration2) : typeGeneration2;
VAR
	nextGen : typeGeneration2;
	i : integer;
BEGIN

	// on calcul pour chaque element (mouton, herbe) de la generation precedente
	// sa place (ou non) dans la nouvelle generation /!\
	// on le fait en f() i precedent pour eviter les repetitions.

	setToZero(nextGen.grille);
	nextGen.tailleVecteurObjects := 1;

	FOR i := 0 TO gen.tailleVecteurObjects - 1 DO
	BEGIN
		// on traite les moutons
		IF gen.vecteurObjects[i].element = ELEMENT_MOUTON THEN
		BEGIN
			calculerNextGenerationMouton(gen.vecteurObjects[i], gen.grille, nextGen);
		END;
		// on traite les herbes
		IF gen.vecteurObjects[i].element = ELEMENT_HERBE THEN
		BEGIN
			calculerNextGenerationHerbe(gen.vecteurObjects[i], gen.grille, nextGen);
		END;
	END;

	calculerNouvelleGeneration := nextGen;
END;

FUNCTION grilleNonVide(gen : typeGeneration2) : BOOLEAN;
VAR
	i : integer;
	result : BOOLEAN;
BEGIN
	i := 0;
	result := TRUE;
	WHILE ((i < (N-1)*(N-1)) and (result)) DO
		IF (gen.grille[i DIV N-1, i MOD N-1] <> LE_VIDE) THEN
			result := FALSE;
		inc(i);

	grilleNonVide := result;
END;

FUNCTION runGeneration2(gen : typeGeneration2; nombreGen, delayValue : INTEGER) : typeGeneration2;
VAR
	i : integer;
BEGIN
	i := 0;
	afficherGrille(gen);
	WHILE (((i < nombreGen) and (nombreGen > 0)) or (nombreGen < 0)) DO
	BEGIN
		ClrScr;
		writeln('Nouvelle Generation : ', i);
		gen := calculerNouvelleGeneration(gen);
		afficherGrille(gen);
		IF (nombreGen > 0) THEN
			inc(i);
		Delay(delayValue);
		inc(nombreGeneration);
	END;
	runGeneration2 := gen;
END;

// regarde si une pos est dans le tableau
FUNCTION isInTab(tab : tabPosition; x, y : integer) : boolean;
VAR
	i : integer;
	result : boolean;
BEGIN
	result := False;
	FOR i := 0 TO M - 1 DO
	BEGIN
		IF (tab[i].x = x) and (tab[i].y = y) THEN
			result := True;
	END;
	isInTab := result;
END;

FUNCTION initRandom(pourcentage : INTEGER) : tabPosition;
VAR
	nbrDeCellules, i : INTEGER;
	tab : tabPosition;
	position : typePosition;
BEGIN
	i := 0;
	nbrDeCellules := round((pourcentage / 100) * ((N) * (N)));
	WHILE (nbrDeCellules > 0) and (i < M) DO
	BEGIN
		position.x := Random(N) - 1;
		position.y := Random(N) - 1;
		WHILE isInTab(tab, position.x, position.y) DO
		BEGIN
			position.x := Random(N);
			position.y := Random(N);
		END;
		tab[i] := position;
		inc(i);
		dec(nbrDeCellules);
	END;
	FOR i := i TO M - 1 DO
	BEGIN
		position.x := -1;
		position.y := -1;
		tab[i] := position;
	END;
	initRandom := tab;
END;

VAR
	gen :  typeGeneration2;
	args : importFile;
BEGIN
	args := handleArgs();
	IF args.typeRun = 'V' THEN
		gen := initGeneration2(args.vecteur1, args.vecteur2);
	IF args.typeRun = 'R' THEN
		gen := initGeneration2(initRandom(args.random2), initRandom(args.random1));
	writeln('nbrGen :', args.nbrGen, args.random2, args.random1);
	afficherGrille(gen);
	gen := runGeneration2(gen, args.nbrGen, args.delay);
	logPosToFile(convertGrillePart3(gen), 'Mouton');
END.
