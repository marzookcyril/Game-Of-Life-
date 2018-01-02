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

FUNCTION trouverCellulePourDeplacement(grille : typeGrille; x, y : integer) : typePosition;
VAR
	herbeAuxAlentour : boolean;
	i, j, k, l : integer;
	pos : typePosition;
BEGIN
	herbeAuxAlentour := false;
	pos.x := -1;
	pos.y := -1;

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
			if (grille[k, l] = UNE_HERBE) then
				pos.x := k;
				pos.y := l;
				herbeAuxAlentour := true;
		END;
	END;

	// Il faut trouver le plus court chemin vers l'herbe la plus
	// proche ???
	// ou le mouton ne bouge pas
	// ou bouge aléatoirement ??

	IF not herbeAuxAlentour then
	BEGIN
		pos.x := Random(1) - Random(1);
		pos.y := Random(1) - Random(1);
	END;
	trouverCellulePourDeplacement := pos;
END;

FUNCTION trouverCelluleNouveauMouton(grille : typeGrille; x, y : integer) : typePosition;
VAR
	i, k, l, j : integer;
	pos : typePosition;
BEGIN
	pos.x := -1;
	pos.y := -1;
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
			if (((grille[k, l] <> UN_MOUTON) or (grille[k, l] <> UNE_HERBE_ET_UN_MOUTON)) and (k <> x) and (l <> y)) then
				pos.x := k;
				pos.y := l;
		END;
	END;
	trouverCelluleNouveauMouton := pos;
END;

FUNCTION calculerNouvelleGeneration(gen : typeGeneration2) : typeGeneration2;
VAR
	i, ii, j, k, l, x, y, counterElement : integer;
	grille : typeGrille;
	vecteurObjects : array of typeElement;
	mouton, herbe : typeElement;
	pos : typePosition;
BEGIN
	// on ne peut pas prevoir la taille de cet array
	setLength(vecteurObjects, 2*N*N);
	counterElement := 0;
	setToZero(grille);
	FOR i := 0 TO gen.tailleVecteurObjects DO
	BEGIN
		// MOUTON
		IF gen.vecteurObjects[i].element = ELEMENT_MOUTON THEN
		BEGIN
			// mourir
			if (gen.vecteurObjects[i].age < AGE_MORT_MOUTON) THEN
				inc(gen.vecteurObjects[i].age);
				// manger ?
				if (gen.grille[gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y] = UNE_HERBE_ET_UN_MOUTON) THEN
				BEGIN
					grille[gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y] := UN_MOUTON;
					gen.vecteurObjects[i].energie := gen.vecteurObjects[i].energie + 14; // TODO A remplacer par des CONST
					vecteurObjects[counterElement] := gen.vecteurObjects[i];
					inc(counterElement);
				END
				ELSE
				BEGIN
					// reproduction
					IF (gen.vecteurObjects[i].energie >= 20) THEN
					BEGIN
						pos := trouverCelluleNouveauMouton(gen.grille, gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y);
						if pos.x > 0 then
						BEGIN
							grille[pos.x, pos.y] := UN_MOUTON;
							mouton := NOUVEAU_MOUTON;
							mouton.position.x := pos.x;
							mouton.position.y := pos.y;
							vecteurObjects[counterElement] := mouton;
							inc(counterElement);
						END;
					END
					ELSE
					// deplacer le mouton
					BEGIN
						pos := trouverCellulePourDeplacement(gen.grille, gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y);
						if pos.x > 0 then
						BEGIN
							grille[pos.x, pos.y] := UN_MOUTON;
							gen.vecteurObjects[i].energie := gen.vecteurObjects[i].energie - 2;
							vecteurObjects[counterElement] := gen.vecteurObjects[i];
							inc(counterElement);
						END
						ELSE
						// il ne fait rien
						BEGIN
							gen.vecteurObjects[i].energie := gen.vecteurObjects[i].energie - 1;
							vecteurObjects[counterElement] := gen.vecteurObjects[i];
							inc(counterElement);
						END;
					END;
				END;
		END
		ELSE
		// HERBE
		BEGIN
			if gen.vecteurObjects[i].age < 5 then
			BEGIN
				inc(gen.vecteurObjects[i].age);
				gen.vecteurObjects[i].energie := gen.vecteurObjects[i].energie + 4;
				// reproduire l'herbe
				if (gen.vecteurObjects[i].energie > 10) then
				BEGIN
					herbe.age := 0;
					herbe.energie := 1;
					x := gen.vecteurObjects[i].position.x;
					y := gen.vecteurObjects[i].position.y;
					FOR ii := -1 TO 1 DO
					BEGIN
						FOR j := -1 TO 1 DO
						BEGIN
							k := (x + ii) MOD N;
							l := (y + j) MOD N;
							if (k < 0) then
								k := N - 1;
							if (l < 0) then
								l := N - 1;
							// on trouve une case sans herbe
							IF (gen.grille[k, l] = UN_MOUTON) then
							BEGIN
								grille[k, l] := UNE_HERBE_ET_UN_MOUTON;
								herbe := NOUVEAU_HERBE;
								herbe.position.x := k;
								herbe.position.y := l;
								vecteurObjects[counterElement] := herbe;
								inc(counterElement);
							END
							ELSE
							BEGIN
								IF (gen.grille[k, l] = LE_VIDE) then
								BEGIN
									grille[k, l] := UNE_HERBE;
									herbe := NOUVEAU_HERBE;
									herbe.position.x := k;
									herbe.position.y := l;
									vecteurObjects[counterElement] := herbe;
									inc(counterElement);
								END;
							END;
						END;
					END;
				END
				ELSE
				BEGIN
					IF (grille[gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y] = UN_MOUTON) THEN
						grille[gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y] := UNE_HERBE_ET_UN_MOUTON
					ELSE
						grille[gen.vecteurObjects[i].position.x, gen.vecteurObjects[i].position.y] := UNE_HERBE;
					vecteurObjects[counterElement] := gen.vecteurObjects[i];
					inc(counterElement);
				END;
			END;
		END;
	END;

	gen.vecteurObjects := vecteurObjects;
	setLength(gen.vecteurObjects, counterElement);
	gen.tailleVecteurObjects := counterElement;
	gen.grille := grille;
	calculerNouvelleGeneration := gen;
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
	WHILE (i < nombreGen) DO
	BEGIN
		//ClrScr;
		writeln('Nouvelle Generation : ', i);
		gen := calculerNouvelleGeneration(gen);
		afficherGrille(gen);
		IF (nombreGen > 0) THEN
			inc(i);
		//Delay(1000);
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
	runGeneration2(gen, 30);
END.
