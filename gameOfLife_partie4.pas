unit gameOfLife_partie4;

INTERFACE
uses Crt, Process, sysutils;

VAR
	outPutFile : string;
	logFile : string;

CONST
	N = 20;
	M = N*N;

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

TYPE typeHerbe = RECORD
	age : INTEGER;
	energie : INTEGER;
END;

CONST
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
	HERBE_MORTE                 : typeHerbe   = (age: -1; energie: 0);
	NOUV_HERBE_P2               : typeHerbe   = (age: 0;  energie: 1);
	NOUVEAU_MOUTON              : typeElement = (element: ELEMENT_MOUTON; age: 0; energie: ENERGIE_INITIALE_MOUTON; position: (x: -1; y: -1));
	NOUVEAU_LOUP                : typeElement = (element: ELEMENT_LOUP; age: 0; energie: ENERGIE_INITIALE_LOUP; position: (x: -1; y: -1));
	NOUVEAU_HERBE               : typeElement = (element: ELEMENT_HERBE; age: 0; energie: ENERGIE_INITIALE_HERBE; position: (x: -1; y: -1));

// Type general utilisé pour logger les grilles
TYPE tabPrint = array [0..N, 0..N] of String;

// Grille pour la partie 1
TYPE typeGrille  = array [0..N - 1, 0..N - 1] of INTEGER;

// Grille pour la partie 3
TYPE typeGrilleString  = array [0..N - 1, 0..N - 1] of String;

TYPE typeGeneration = array [0..N - 1, 0..N - 1] of typeHerbe;

TYPE typeGeneration2 = RECORD
	// la taille de vecteurObjects est defini à chaque tour avec setLength(array, tailleVecteurObjects)
	vecteurObjects       : array of typeElement;
	tailleVecteurObjects : INTEGER;
	grille               : typeGrilleString;
END;

// type perso explique dans le latex
TYPE importFile = Record
	partie        : INTEGER;
	nbrGen        : INTEGER;
	typeRun       : STRING;
	random1       : INTEGER;
	random2       : INTEGER;
	random3       : INTEGER;
	delay         : INTEGER;
	nbrPos1       : INTEGER;
	nbrPos2       : INTEGER;
	nbrPos3       : INTEGER;
	vecteur1      : tabPosition;
	vecteur2      : tabPosition;
	vecteur3      : tabPosition;
END;

type longString = array [0..10000] of char;

FUNCTION  handleArgs() : importFile;
PROCEDURE logGrillePart1(grille : typeGrille; ng : integer);
PROCEDURE logGrillePart2(gen : typeGeneration; ng : integer);
PROCEDURE logGrillePart3(gen : typeGeneration2; ng : integer);

IMPLEMENTATION

// verifie si un char est un nombre ou non.
FUNCTION isNumber(c : char) : boolean;
BEGIN
	isNumber := ((ord(c) > 47) and (ord(c) < 58));
END;

// permet de convertir une série de position dans un fichier text en position
// utilisable par les programmes
PROCEDURE handleVectorInput(s : longstring; VAR tableau : tabPosition; VAR tabCounter : integer);
VAR
	position : typePosition;
	i, j, numberCounter, numberBeginIndex : integer;
	stop : boolean;
BEGIN
	i := 0;
	tabCounter := 0;
	stop := False;
	WHILE (i < length(s) - 1) and (not stop) DO
	BEGIN
		if s[i + 1] = ']' THEN
			stop := True;
		position.x := -1;
		position.y := -1;
		IF isNumber(s[i]) THEN
		BEGIN
			numberCounter := 1;
			numberBeginIndex := i;
			j := i + 1;
			// on trouve les nombres (peuvent etre très grand...)
			WHILE isNumber(s[j]) and (j < length(s)) DO
			BEGIN
				inc(numberCounter);
				inc(j);
			END;

			position.x := strtoint(copy(s, numberBeginIndex + 1, numberCounter));
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

			position.y := strtoint(copy(s, numberBeginIndex + 1, numberCounter));
			writeln('posY : ', position.y, ', n : ', tabCounter);

			i := j;
			tableau[tabCounter] := position;
			inc(tabCounter);
		END
		ELSE
			inc(i);
	END;
	FOR i := tabCounter to M - 1 DO
	BEGIN
		position.x := -1;
		position.y := -1;
		tableau[i] := position;
	END;
END;

// lit les fichiers passé en -i et les interprete.
FUNCTION handleInportFile(fichier : string; inFile : importFile) : importFile;
VAR
	//ligne : string;
	ligne : longString;
	fic   : text;
	i : integer;
	textPartie, delayHasChange : boolean;
BEGIN
	delayHasChange := False;
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
			writeln(length(ligne));

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

			IF ((pos('Loup', ligne) <> 0) and (inFile.partie = 5)) THEN
			BEGIN
				textPartie := True;
			END;

			IF (pos('Position', ligne) <> 0) THEN
			BEGIN
				IF (pos('PositionH', ligne) <> 0) then
				BEGIN
					inFile.typeRun := 'V';
					handleVectorInput(ligne, inFile.vecteur2, inFile.nbrPos1);
				END
				ELSE
				BEGIN
					IF (pos('PositionM', ligne) <> 0) then
					BEGIN
						inFile.typeRun := 'V';
						handleVectorInput(ligne, inFile.vecteur1, inFile.nbrPos2);
					END
					ELSE
					BEGIN
						IF (pos('PositionL', ligne) <> 0) then
						BEGIN
							inFile.typeRun := 'V';
							handleVectorInput(ligne, inFile.vecteur3,inFile.nbrPos3);
						END
						ELSE
						BEGIN
							inFile.typeRun := 'V';
							handleVectorInput(ligne, inFile.vecteur1, inFile.nbrPos1);
						END;
					END;
				END;
			END;

			IF (pos('Random', ligne) <> 0) THEN
			BEGIN
				IF (pos('RandomH', ligne) <> 0) then
				BEGIN
					inFile.typeRun := 'R';
					inFile.random1 := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
				END
				ELSE
				BEGIN
					IF (pos('RandomM', ligne) <> 0) then
					BEGIN
						inFile.typeRun := 'R';
						inFile.random2 := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
					END
					ELSE
					BEGIN
						IF (pos('RandomL', ligne) <> 0) then
						BEGIN
							inFile.typeRun := 'R';
							inFile.random3 := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
						END
						ELSE
						BEGIN
							inFile.typeRun := 'R';
							inFile.random1 := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
						END;
					END;
				END;
			END;

			IF (pos('Delay', ligne) <> 0) then
			BEGIN
				inFile.delay := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
				delayHasChange := True;
			END;

			IF (pos('NombreGeneration', ligne) <> 0) then
			BEGIN
				inFile.nbrGen := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
			END;

		UNTIL eof(fic) or not textPartie;
		close(fic);

		if not delayHasChange THEN
			inFile.delay := 500;

		IF not textPartie THEN
		BEGIN
			writeln('Le fichier -i ne peut pas etre utilisé pour ce type de simulation. (ex: on ne fait pas de simulation de jeu de la vie avec des positions de moutons)');
			Halt (1);
		END
		ELSE
			handleInportFile := inFile;
	END;
END;

// Permet d'enregistrer chaque simulation (grille) dans un
// fichier
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

// permet de creer un fichier CSV contenant le nombre d'element dans chaque simulations
// pour faire des belles courbes
PROCEDURE logValueToFile(logGrille : tabPrint; ng : integer);
VAR
	i, j, nbrHerbe, nbrMouton, nbrLoup : integer;
	fichier : text;
BEGIN
	writeln('je suis la');
	assign(fichier, logFile);
	append(fichier);
	nbrHerbe := 0;
	nbrMouton := 0;
	nbrLoup := 0;

	if (ng = 0) THEN
		writeln(fichier,'nbrGen, herbe, mouton, loup');

	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			IF (pos('h', logGrille[i, j]) <> 0) or (pos('#', logGrille[i,j]) <> 0) THEN
				inc(nbrHerbe);
			IF (pos('m', logGrille[i, j]) <> 0) THEN
				inc(nbrMouton);
			IF (pos('l', logGrille[i, j]) <> 0) THEN
				inc(nbrLoup);
		END;
	END;
	writeln(fichier, ng, ',', nbrHerbe, ',', nbrMouton, ',', nbrLoup);
	close(fichier);
END;

{
	logGrillePartX sont des procedure pour convertir une grille (de chaque partie)
	en grille général. Ce sont un peu les drivers de la partie 4.
}

PROCEDURE logGrillePart1(grille : typeGrille; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	IF (outPutFile <> '') or (logFile <> '') THEN
	BEGIN
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				IF grille[i, j] = 1 THEN
					logGrille[i, j] := ' #'
				ELSE
					logGrille[i, j] := ' .';
			END;
		END;
		IF outPutFile <> '' THEN
			logGrilleToFile(logGrille, ng);
		IF logFile <> '' THEN
			logValueToFile(logGrille, ng);
	END;
END;

PROCEDURE logGrillePart2(gen : typeGeneration; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	IF (outPutFile <> '') or (logFile <> '') THEN
	BEGIN
		writeln(outputfile);
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				IF(gen[i,j].age >= 0) THEN
					logGrille[i,j] := ' #'
				ELSE
					logGrille[i,j] := ' .';
			END;
		END;
		IF outPutFile <> '' THEN
			logGrilleToFile(logGrille, ng);
		IF logFile <> '' THEN
			logValueToFile(logGrille, ng);
	END;
END;

PROCEDURE logGrillePart3(gen : typeGeneration2; ng : integer);
VAR
	i, j : integer;
	logGrille : tabPrint;
BEGIN
	writeln(outputfile);
	IF (outPutFile <> '') or (logFile <> '') THEN
	BEGIN
		FOR i := 0 TO N - 1 DO
		BEGIN
			FOR j := 0 TO N - 1 DO
			BEGIN
				logGrille[i,j] := gen.grille[i, j];
			END;
		END;
		if outPutFile <> '' THEN
			logGrilleToFile(logGrille, ng);
		if logFile <> '' THEN
			logValueToFile(logGrille, ng);
	END;
END;


// fonction principale du paquet. Prend les args** en entrée en les execute.
FUNCTION handleArgs() : importFile;
VAR
	 i : INTEGER;
	 command : string;
	 foo : ansiString;
	 inFile : importFile;
	 genToRun : boolean;
	 // variable globale
BEGIN

	genToRun := False;

	FOR i := 1 TO 5 DO
	BEGIN
		IF pos('partie' + inttostr(i), ParamStr(0)) <> 0 THEN
		BEGIN
			inFile.partie := i;
		END;
	END;

	FOR i := 0 TO ParamCount DO
	BEGIN
		IF (ParamStr(i) = '-h') THEN
		BEGIN
			writeln('Projet Informatique - Paul Planchon et Cyril Marzook');
			writeln('HELP : -i permet d''entrer un fichier génération.');
			writeln('       -o permet d''enregistrer les simulations.');
			writeln('       -l permet des valeur numériques sur les simulations.');
			writeln('       -h affiche cette commande.');
			halt(1);
		END;

		IF ((ParamStr(i) = '-i') and FileExists(ParamStr(i+1))) THEN
		BEGIN
			inFile := handleInportFile(ParamStr(i+1), inFile);
			genToRun := True;
		END;

		IF (ParamStr(i) = '-o') THEN
		BEGIN
			IF FileExists(ParamStr(i+1)) THEN
			BEGIN
				outputFile := ParamStr(i+1);
				genToRun := True;
			END
			ELSE
			BEGIN
				// si le fichier n'existe pas (possible) on le créé
				command := 'touch ' + ParamStr(i+1);
				RunCommand(command, foo);
				outputFile := ParamStr(i+1);
				genToRun := True;
			END;
		END;

		IF (ParamStr(i) = '-l') THEN
		BEGIN
			IF FileExists(ParamStr(i+1)) THEN
			BEGIN
				logFile := ParamStr(i+1);
			END
			ELSE
			BEGIN
				// si le fichier n'existe pas (possible) on le créé
				command := 'touch ' + ParamStr(i+1);
				RunCommand(command, foo);
				logFile := ParamStr(i+1);
			END;
		END;
	END;

	IF (genToRun) THEN
		handleArgs := inFile
	ELSE
	BEGIN
		writeln('Pas de simulation a lancer.');
		halt(1);
	END;
END;

END.
