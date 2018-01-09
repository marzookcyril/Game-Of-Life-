unit gameOfLife_partie4;

INTERFACE
uses Process, sysutils;

TYPE typePosition = RECORD
	x, y : INTEGER;
END;

TYPE importFile = Record
	nbrGen        : INTEGER;
	random        : BOOLEAN;
	vecteur1 : array of typePosition;
	vecteur2 : array of typePosition;
END;


FUNCTION  handleInportFile(fichier : string) : importFile;
PROCEDURE handleOutputFile(fichier : string);
PROCEDURE handleArgs();

IMPLEMENTATION

PROCEDURE handleVectorInput(s : string; VAR tableau : array of typePosition);
VAR
	position : typePosition;
	stringTmp : string;
	i, counter : integer;
BEGIN 
	setLength(tableau, 500);
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
			writeln(counter);
		END;
	END;
	setLength(tableau, counter);
END;

FUNCTION handleInportFile(fichier : string) : importFile;
VAR
	inFile : importFile;
	ligne : string;
	fic   : text;	
BEGIN
	// on traite le fichier
	
	inFile.random := False;
	assign(fic, fichier);
	reset(fic);
	if (IOResult <> 0) then 
		writeln('Le fichier n''existe pas')
	else
	BEGIN
		REPEAT
			readln(fic, ligne);
			IF (pos('Position', ligne) <> 0) then
			BEGIN
				handleVectorInput(ligne, inFile.vecteur1)
			END;
			
			IF (pos('Random', ligne) <> 0) then
			BEGIN
				inFile.random := True
			END;
			
			IF (pos('NombreGeneration', ligne) <> 0) then
			BEGIN
				inFile.nbrGen := strtoint(copy(ligne, pos('=', ligne) + 1, length(ligne)));
				writeln('nombre de generation : ' , inFile.nbrGen);
			END;
			
		UNTIL eof(fic);
		close(fic);
	END;
END;

PROCEDURE handleOutputFile(fichier : string);
BEGIN
END;

PROCEDURE handleArgs();
VAR
	 i : INTEGER;
	 command : string;
	 foo : ansiString;
BEGIN
	FOR i := 0 TO ParamCount DO
	BEGIN
		IF ((ParamStr(i) = '-i') and FileExists(ParamStr(i+1))) THEN
			handleInportFile(ParamStr(i+1));
		
		IF (ParamStr(i) = '-o') THEN
			IF FileExists(ParamStr(i+1)) THEN
				handleOutputFile(ParamStr(i+1))
			ELSE
			BEGIN
				// si le fichier n'existe pas (possible) on le créé
				command := 'touch ' + ParamStr(i+1);
				RunCommand(command, foo);
				handleOutputFile(ParamStr(i+1))
			END;
	END;
END;
END.
