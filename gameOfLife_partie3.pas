PROGRAM gameOfLife;
USES Crt, sysutils;

TYPE typePosition = RECORD
x, y : INTEGER;
END;

TYPE typeElement = RECORD
	// element : mouton -> ELEMENT_MOUTON, herbe -> ELEMENT_HERBE
	element  : STRING;
	age      : INTEGER;
	energie  : INTEGER;
	position : typePosition;
END;

CONST
	M    				   = 5;
	N    				   = 15;
	ENERGIE                     = 4;
	ENERGIE_MOUTON			   = 14;
	AGE_MORT				   = 5;
	ENERGIE_REPRODUCTION	   = 10;
	ENERGIE_REPRODUCTION_MOUTON = 20;
	ENERGIE_INITIALE_MOUTON     = 11;
	ENERGIE_INITIALE_HERBE      = 1;
	AGE_MORT_MOUTON             = 15;
	LE_VIDE                     = '--';
	UNE_HERBE                   = 'h-';
	UN_MOUTON                   = '-m';
	UNE_HERBE_ET_UN_MOUTON      = 'hm';
	ELEMENT_MOUTON              = 'MOUTON';
	ELEMENT_HERBE               = 'HERBE';
	NOUVEAU_MOUTON              : typeElement = (element: ELEMENT_MOUTON; age: 0; energie: ENERGIE_INITIALE_MOUTON; position: (x: -1; y: -1));
	NOUVEAU_HERBE               : typeElement = (element: ELEMENT_HERBE; age: 0; energie: ENERGIE_INITIALE_HERBE; position: (x: -1; y: -1));


TYPE tabPosition = array [0..M] of typePosition;
TYPE typeGrille  = array [0..N - 1, 0..N - 1] of String;

TYPE typeGeneration2 = RECORD
	// la taille de vecteurObjects est defini à chaque tour avec setLength(array, tailleVecteurObjects)
	vecteurObjects       : array of typeElement;
	tailleVecteurObjects : INTEGER;
	grille               : typeGrille;
END;

PROCEDURE afficherGrille(gen : typeGeneration2);
VAR
	i,j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			write(gen.grille[i, j], ' ');
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
			grille[i, j] := LE_VIDE;
		END;
	END;
END;

FUNCTION initGeneration2(vecteurPositionsMoutons, vecteurPositionsHerbes : tabPosition) : typeGeneration2;
VAR
	gen    : typeGeneration2;
	grille : typeGrille;
	i, counterElement      : integer;
	herbe, mouton : typeElement;
BEGIN
	herbe.element  := ELEMENT_HERBE;
	herbe.energie  := ENERGIE_INITIALE_HERBE;
	herbe.age      := 0;
	mouton.element := ELEMENT_MOUTON;
	mouton.energie := ENERGIE_INITIALE_MOUTON;
	mouton.age     := 0;

	counterElement := 0;
	gen.tailleVecteurObjects := length(vecteurPositionsHerbes) + length(vecteurPositionsMoutons);
	setLength(gen.vecteurObjects, gen.tailleVecteurObjects);
	setToZero(grille);

	FOR i := 0 TO M DO
	BEGIN
		IF((vecteurPositionsHerbes[i].x > 0) and (vecteurPositionsHerbes[i].y > 0)) THEN
		BEGIN
			grille[vecteurPositionsHerbes[i].x, vecteurPositionsHerbes[i].y] := UNE_HERBE;
			herbe.position.x := vecteurPositionsHerbes[i].x;
			herbe.position.y := vecteurPositionsHerbes[i].y;
			gen.vecteurObjects[counterElement] := herbe;
			inc(counterElement);
		END;
	END;

	writeln('DEBUG');
	FOR i := 0 TO M DO
	BEGIN
		IF((vecteurPositionsMoutons[i].x > 0) and (vecteurPositionsMoutons[i].y > 0)) THEN
		BEGIN
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
	writeln(counterElement);
	gen.tailleVecteurObjects := counterElement;
	setLength(gen.vecteurObjects, counterElement);
	writeln(length(gen.vecteurObjects));
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
PROCEDURE calculerNextGenerationMouton(mouton : typeElement; oldGrille : typeGrille; VAR nextGen : typeGeneration2);
VAR
	nouveauMouton, bebeMouton : typeElement;
	k, l, i, ii, j : integer;
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
							nouveauMouton.position.x := k;
							nouveauMouton.position.y := l;
						END;
					END;

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

FUNCTION calculerNextGenerationHerbe(herbe : typeElement; oldGrille : typeGrille; VAR nextGen : typeGeneration2) : typeElement;
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
	i, elementCounter : integer;
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

PROCEDURE runGeneration2(gen : typeGeneration2; nombreGen : INTEGER);
VAR
	i : integer;
BEGIN
	i := 0;
	afficherGrille(gen);
	Delay(2000);
	WHILE ((i < nombreGen) and (gen.tailleVecteurObjects > 1)) DO
	BEGIN
		ClrScr;
		writeln('Nouvelle Generation : ', i);
		writeln(gen.tailleVecteurObjects);
		gen := calculerNouvelleGeneration(gen);
		afficherGrille(gen);
		IF (nombreGen > 0) THEN
			inc(i);
		Delay(2000);
	END;
END;

VAR
	tabMouton, tabHerbe : tabPosition;
	gen :  typeGeneration2;
	i : integer;
BEGIN
	tabMouton := initPrairieByHand('mouton');
	tabHerbe := initPrairieByHand('herbe');
	gen := initGeneration2(tabMouton, tabHerbe);
	runGeneration2(gen, 20);
END.
