unit gameOfLife_partie4;

INTERFACE
uses Crt, Process, sysutils;

VAR
	outPutFile : string;

CONST
	M = 5;

TYPE typePosition = RECORD
	x, y : INTEGER;
END;

type tabPosition = array [0..M] of typePosition;

// type général pour chaque entité (herbe, mouton, loup ou autre...)
TYPE typeElement = RECORD
	element  : STRING;
	age      : INTEGER;
	energie  : INTEGER;
	position : typePosition;
END;

CONST
	N    				   = 20;
	VIE                         = 1;
	MORT                        = 0;
	ENERGIE                     = 4;
	ENERGIE_MOUTON			   = 14;
	AGE_MORT				   = 5;
	ENERGIE_REPRODUCTION	   = 10;
	ENERGIE_REPRODUCTION_MOUTON = 20;
	ENERGIE_INITIALE_MOUTON     = 11;
	ENERGIE_INITIALE_LOUP       = 5;
	ENERGIE_INITIALE_HERBE      = 1;
	AGE_MORT_MOUTON             = 15;
	LE_VIDE                     = '---';
	UNE_HERBE                   = 'h--';
	UN_MOUTON                   = '-m-';
	UN_LOUP  				    = '--l';
	LOUP_ET_HERBE               = 'h-l';
	UNE_HERBE_ET_UN_MOUTON      = 'hm-';
	MOUTON_ET_LOUP              = '-ml';
	TOUT                        = 'hml';
	ELEMENT_MOUTON              = 'MOUTON';
	ELEMENT_LOUP                = 'LOUP';
	ELEMENT_HERBE               = 'HERBE';
	NOUVEAU_MOUTON              : typeElement = (element: ELEMENT_MOUTON; age: 0; energie: ENERGIE_INITIALE_MOUTON; position: (x: -1; y: -1));
	NOUVEAU_LOUP                : typeElement = (element: ELEMENT_LOUP; age: 0; energie: 5; position: (x: -1; y: -1));
	NOUVEAU_HERBE               : typeElement = (element: ELEMENT_HERBE; age: 0; energie: ENERGIE_INITIALE_HERBE; position: (x: -1; y: -1));

// Type general utilisé pour logger les grilles
TYPE tabPrint = array [0..N, 0..N] of String;

// Grille pour la partie 1
TYPE typeGrille  = array [0..N - 1, 0..N - 1] of INTEGER;

// Grille pour la partie 3
TYPE typeGrilleString  = array [0..N - 1, 0..N - 1] of String;

TYPE typeHerbe = RECORD
	age : INTEGER;
	energie : INTEGER;
END;

TYPE typeGeneration = array [0..N - 1, 0..N - 1] of typeHerbe;

TYPE typeGeneration2 = RECORD
	// la taille de vecteurObjects est defini à chaque tour avec setLength(array, tailleVecteurObjects)
	vecteurObjects       : array of typeElement;
	tailleVecteurObjects : INTEGER;
	grille               : typeGrilleString;
END;

TYPE importFile = Record
	partie        : INTEGER;
	nbrGen        : INTEGER;
	typeRun       : STRING;
	randomPctg    : INTEGER;
	vecteur1      : tabPosition;
	vecteur2      : tabPosition;
END;

FUNCTION  handleArgs() : importFile;
PROCEDURE logGrillePart1(grille : typeGrille; ng : integer);
PROCEDURE logGrillePart2(gen : typeGeneration; ng : integer);
PROCEDURE logGrillePart3(gen : typeGeneration2; ng : integer);
PROCEDURE handleVectorInput(s : string; VAR tableau : tabPosition);

IMPLEMENTATION

FUNCTION isNumber(c : char) : boolean;
BEGIN
	isNumber := ((ord(c) > 47) and (ord(c) < 58));
END;

PROCEDURE handleVectorInput(s : string; VAR tableau : tabPosition);
VAR
	position : typePosition;
	i, j, ii, numberCounter, numberBeginIndex, tabCounter : integer;
BEGIN
	i := 1;
	tabCounter := 0;
	WHILE i < length(s) DO
	BEGIN
		position.x := -1;
		position.y := -1;
		IF isNumber(s[i]) THEN
		BEGIN
			numberCounter := 0;
			numberBeginIndex := i;
			j := i;
			// on trouve les nombres (peuvent etre très grand...)
			WHILE isNumber(s[j]) and (j < length(s)) DO
			BEGIN
				inc(numberCounter);
				inc(j);
			END;

			position.x := strtoint(copy(s, numberBeginIndex, numberCounter));
			writeln('posX : ', position.x);

			WHILE (not isNumber(s[j])) and (s[j] <> ')') and (j < length(s)) DO
			BEGIN
				inc(j);
			END;

			numberBeginIndex := j;
			numberCounter := 0;

			WHILE isNumber(s[j]) and (j < length(s)) DO
			BEGIN
				inc(numberCounter);
				inc(j);
			END;

			position.y := strtoint(copy(s, numberBeginIndex, numberCounter));
			writeln('posY : ', position.y);
			i := j;
			tableau[tabCounter] := position;
			inc(tabCounter);
		END
		ELSE
			inc(i);
	END;
END;

FUNCTION handleInportFile(fichier : string; inFile : importFile) : importFile;
VAR
	ligne : string;
	fic   : text;
	textPartie : boolean;
BEGIN
	// on traite le fichier

	assign(fic, fichier);
	reset(fic);
	if (IOResult <> 0) then
		writeln('Le fichier n''existe pas')
	else
	textPartie := False;
	BEGIN
		REPEAT
			readln(fic, ligne);

			IF ((pos('Vie', ligne) <> 0) and (inFile.partie = 1)) THEN
			BEGIN
				textPartie := True;
			END;

			IF ((pos('Herbe', ligne) <> 0) and (inFile.partie = 2)) THEN
			BEGIN
				textPartie := True;
			END;

			IF ((pos('Mouton', ligne) <> 0) and (inFile.partie = 3)) THEN
			BEGIN
				textPartie := True;
			END;

			IF ((pos('Loup', ligne) <> 0) and (inFile.partie = 4)) THEN
			BEGIN
				textPartie := True;
			END;

			IF (pos('Position', ligne) <> 0) THEN
			BEGIN
				IF (pos('PositionH', ligne) <> 0) then
				BEGIN
					inFile.typeRun := 'V';
					handleVectorInput(ligne, inFile.vecteur2);
				END
				ELSE
				BEGIN
					IF (pos('PositionM', ligne) <> 0) then
					BEGIN
						inFile.typeRun := 'V';
						handleVectorInput(ligne, inFile.vecteur1);
					END
					ELSE
					BEGIN
						inFile.typeRun := 'V';
						handleVectorInput(ligne, inFile.vecteur1);
					END;
				END;
			END;

			IF (pos('Random', ligne) <> 0) then
			BEGIN
				inFile.typeRun := 'R';
				inFile.randomPctg := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
			END;

			IF (pos('NombreGeneration', ligne) <> 0) then
			BEGIN
				inFile.nbrGen := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
			END;

		UNTIL eof(fic) or not textPartie;
		close(fic);

		IF not textPartie THEN
		BEGIN
			writeln('Le fichier -i ne peut pas etre utilisé pour ce type de simulation. (ex: on ne fait pas de simulation de jeu de la vie avec des positions de moutons)');
			Halt (1);
		END
		ELSE
			handleInportFile := inFile;
	END;
END;

PROCEDURE logGrilleToFile(logGrille : tabPrint; ng : integer);
VAR
	i, j : integer;
	fichier : text;
BEGIN
	assign(fichier, outPutFile);
	append(fichier);
	writeln(fichier, 'Generation n°', ng);
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			write(fichier, logGrille[i, j]);
		END;
		writeln(fichier, '');
	END;
	writeln(fichier, '----------------------------------');
	close(fichier);
END;

PROCEDURE logGrillePart1(grille : typeGrille; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	IF outPutFile <> '' THEN
	BEGIN
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				logGrille[i, j] := inttostr(grille[i, j]);
			END;
		END;
		logGrilleToFile(logGrille, ng);
	END;
END;

PROCEDURE logGrillePart2(gen : typeGeneration; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	writeln(outputfile);
	IF outPutFile <> '' THEN
	BEGIN
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				IF(gen[i,j].age >= 0) THEN
					logGrille[i,j] := ' ' + inttostr(gen[i,j].age)
				ELSE
					logGrille[i,j] := ' .';
			END;
		END;
		logGrilleToFile(logGrille, ng);
	END;
END;

PROCEDURE logGrillePart3(gen : typeGeneration2; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	writeln(outputfile);
	IF outPutFile <> '' THEN
	BEGIN
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				logGrille[i,j] := gen.grille[i, j];
			END;
		END;
		logGrilleToFile(logGrille, ng);
	END;
END;

FUNCTION handleArgs() : importFile;
VAR
	 i : INTEGER;
	 command : string;
	 foo : ansiString;
	 inFile : importFile;
	 // variable globale
BEGIN
	FOR i := 1 TO 4 DO
	BEGIN
		IF pos('partie' + inttostr(i), ParamStr(0)) <> 0 THEN
		BEGIN
			inFile.partie := i;
		END;
	END;

	FOR i := 0 TO ParamCount DO
	BEGIN
		IF ((ParamStr(i) = '-i') and FileExists(ParamStr(i+1))) THEN
			inFile := handleInportFile(ParamStr(i+1), inFile);

		IF (ParamStr(i) = '-o') THEN
			IF FileExists(ParamStr(i+1)) THEN
				outputFile := ParamStr(i+1)
			ELSE
			BEGIN
				// si le fichier n'existe pas (possible) on le créé
				command := 'touch ' + ParamStr(i+1);
				RunCommand(command, foo);
				outputFile := ParamStr(i+1)
			END;
	END;
	handleArgs := inFile;
END;
END.
