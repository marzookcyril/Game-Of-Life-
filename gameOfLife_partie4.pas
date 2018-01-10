unit gameOfLife_partie4;

INTERFACE
uses Process, sysutils;

CONST 
	M = 20;

TYPE typePosition = RECORD
	x, y : INTEGER;
END;

type tabPosition = array [0..M] of typePosition;

TYPE importFile = Record
	nbrGen        : INTEGER;
	typeRun       : STRING;
	randomPctg    : INTEGER;
	vecteur1      : tabPosition;
	vecteur2      : tabPosition;
END;


FUNCTION  handleInportFile(fichier : string) : importFile;
FUNCTION handleOutputFile(fichier : string) : importFile;
FUNCTION handleArgs() : importFile;

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

FUNCTION handleOutputFile(fichier : string) : importFile;
BEGIN
END;

FUNCTION handleArgs() : importFile;
VAR
	 i : INTEGER;
	 command : string;
	 foo : ansiString;
	 inFile : importFile;
BEGIN
	FOR i := 0 TO ParamCount DO
	BEGIN
		IF ((ParamStr(i) = '-i') and FileExists(ParamStr(i+1))) THEN
			inFile := handleInportFile(ParamStr(i+1));
		
		IF (ParamStr(i) = '-o') THEN
			IF FileExists(ParamStr(i+1)) THEN
				inFile := handleOutputFile(ParamStr(i+1))
			ELSE
			BEGIN
				// si le fichier n'existe pas (possible) on le créé
				command := 'touch ' + ParamStr(i+1);
				RunCommand(command, foo);
				inFile := handleOutputFile(ParamStr(i+1))
			END;
	END;
	handleArgs := inFile;
END;
END.
