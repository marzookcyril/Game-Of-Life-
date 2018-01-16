unit gameOfLife_partie4;

INTERFACE
uses Process, sysutils;

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
	N    				        = 20;
	VIE                         = 1;
	MORT                        = 0;
	ENERGIE                     = 4;
	ENERGIE_MOUTON			    = 14;
	AGE_MORT				    = 5;
	ENERGIE_REPRODUCTION	    = 10;
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
	nbrGen        : INTEGER;
	typeRun       : STRING;
	randomPctg    : INTEGER;
	vecteur1      : tabPosition;
	vecteur2      : tabPosition;
END;

FUNCTION handleInportFile(fichier : string) : importFile;
FUNCTION handleArgs() : importFile;
PROCEDURE logGrillePart1(grille : typeGrille; ng : integer);
PROCEDURE logGrillePart2(gen : typeGeneration; ng : integer);
PROCEDURE logGrillePart3(gen : typeGeneration2; ng : integer);

IMPLEMENTATION

PROCEDURE handleVectorInput(s : string; VAR tableau : tabPosition);
VAR
	position : typePosition;
	stringTmp : string;
	i, counter : integer;
BEGIN
	counter := 0;
	FOR i := 0 TO length(s) DO
	BEGIN
		IF (s[i] = '(') THEN
		BEGIN
			stringTmp := copy(s, i, length(s));
			position.x := strtoint(copy(stringTmp, 2, pos(' ', stringTmp) - 2));
			writeln('posX : ', position.x);
			position.y := strtoint(copy(stringTmp, pos(' ', stringTmp) + 1, pos(')', stringTmp) - pos(' ', stringTmp) - 1));
			writeln('posY : ', position.y);
			tableau[counter] := position;
			inc(counter);
			writeln('counter : ', counter);
		END;
	END;
END;

FUNCTION handleInportFile(fichier : string) : importFile;
VAR
	inFile : importFile;
	ligne : string;
	fic   : text;	
BEGIN
	// on traite le fichier
	
	assign(fic, fichier);
	reset(fic);
	if (IOResult <> 0) then 
		writeln('Le fichier n''existe pas')
	else
	BEGIN
		REPEAT
			readln(fic, ligne);
			IF (pos('Position', ligne) <> 0) THEN
			BEGIN
				IF (pos('PositionH', ligne) <> 0) then
				BEGIN
					writeln('1 : ', ligne);
					inFile.typeRun := 'V';
					handleVectorInput(ligne, inFile.vecteur2);
				END
				ELSE
				BEGIN
					IF (pos('PositionM', ligne) <> 0) then
					BEGIN
						inFile.typeRun := 'V';
						writeln('2 : ', ligne);
						handleVectorInput(ligne, inFile.vecteur1);
					END
					ELSE
					BEGIN
						writeln('3 : ', ligne);
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
				writeln('nombre de generation : ' , inFile.nbrGen);
			END;
			
		UNTIL eof(fic);
		close(fic);
		
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
	FOR i := 0 TO ParamCount DO
	BEGIN
		IF ((ParamStr(i) = '-i') and FileExists(ParamStr(i+1))) THEN
			inFile := handleInportFile(ParamStr(i+1));
		
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
