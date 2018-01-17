PROGRAM gameOfLife;
USES gameOfLife_partie4, Crt;

VAR
	nombreGeneration : integer;

PROCEDURE afficherGrille(grille :  typeGrille);
VAR
	i, j : INTEGER;
BEGIN
	logGrillePart1(grille, nombreGeneration);
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			IF(grille[i,j] = VIE) THEN
				write(' v')
			ELSE
				write(' ·');
		END;
		writeln();
	END;
END;

// compte le nombre d'occurence d'un char c dans une string s.
FUNCTION nombreOccurence(s : string; c : char) : INTEGER;
VAR
	i, res : integer;
BEGIN
	res := 0;
	FOR i := 1 TO length(s) DO
	BEGIN
		IF (s[i] = c) then
			inc(res);
	END;
	nombreOccurence := res;
END;

//on met la grille a zero
PROCEDURE setToZero(VAR grille : typeGrille);
VAR
	i, j : INTEGER;
BEGIN
	FOR i := 0 TO N - 1 DO
	BEGIN
		FOR j := 0 TO N - 1 DO
		BEGIN
			grille[i, j] := MORT;
		END;
	END;
END;

//on remplit la grille en fonction du tableau
FUNCTION remplirGrille(tableau : tabPosition) : typeGrille;
VAR
		grille : typeGrille;
		i 	   : INTEGER;
BEGIN
	setToZero(grille);
	FOR i := 0 TO M DO
	BEGIN
		IF ((tableau[i].x >= 0) and (tableau[i].x < N)) and ((tableau[i].y >= 0) and (tableau[i].y < N)) then
			grille[tableau[i].x, tableau[i].y] := VIE
	END;
	remplirGrille := grille;
END;

//la valeur d'une cellule est son nombre de voisin. Cette fonction compte le nombre de voisins.
FUNCTION calculerValeurCellule(grille : typeGrille; x, y : INTEGER) : INTEGER;
VAR
	result, i, j, k, l : integer;
BEGIN
	result := 0;
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
			if(grille[k, l] = VIE) then
				result := result + 1;
		END;
	END;
	
	// la cellule elle-même n'est pas comptée comme voisin.
	if(grille[x, y] = VIE) then
		result := result - 1;

	calculerValeurCellule := result;
END;

FUNCTION calculerNouvelleGrille(grille : typeGrille) : typeGrille;
VAR
	x, y, valeur : integer;
	nouvelleGrille : typeGrille;
BEGIN
	FOR x := 0 TO N - 1 DO
	BEGIN
		FOR y := 0 TO N - 1 DO
		BEGIN
			valeur := calculerValeurCellule(grille, x, y);
			IF (grille[x,y] = VIE) then
			BEGIN
				IF ((valeur = 3) or (valeur = 2)) THEN
				BEGIN
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
					nouvelleGrille[x,y]:= MORT;
			END
			ELSE
			BEGIN
				IF (valeur = 3) THEN
				BEGIN
					nouvelleGrille[x,y]:= VIE;
				END
				ELSE
				BEGIN
					nouvelleGrille[x,y]:= MORT;
				END;
			END;
		END;
	END;
	calculerNouvelleGrille := nouvelleGrille;
END;

//on remplit la grille de façon aléatoire en fonction d'un pourcentage (entre 0 et 100).
FUNCTION initGrille(pourcentage : INTEGER) : typeGrille;
VAR
	x, y, nbrDeCellules : INTEGER;
	grille : typeGrille;
BEGIN
	setToZero(grille);
	nbrDeCellules := round((pourcentage / 100) * (N * N));
	WHILE nbrDeCellules > 0 DO
	BEGIN
		x := random(N);
		y := random(N);
		WHILE grille[x, y] <> MORT DO
		BEGIN
			x := random(N);
			y := random(N);
		END;
		grille[x, y] := VIE;
		dec(nbrDeCellules);
	END;
	initGrille := grille;
END;

FUNCTION compteCellule(grille : typeGrille) : INTEGER;
VAR
	i, result : INTEGER;
BEGIN
	result := 0;
	FOR i := 0 TO N * N - 1 DO
	BEGIN
		IF (grille[i MOD N, i DIV N] = VIE) THEN
			result := result + 1
	END;
	compteCellule := result;
END;

FUNCTION run(grilleInitiale : typeGrille; n : INTEGER) : typeGrille;
VAR
	tmp : integer;
BEGIN
	tmp := 0;
	REPEAT
		grilleInitiale := calculerNouvelleGrille(grilleInitiale);
		if (n > 0) then
			inc(tmp);
		
		ClrScr;
		
		writeln('GRILLE GENERATION : ', tmp - 1, ' / ', n);
		afficherGrille(grilleInitiale);
		Delay(500);
		
		inc(nombreGeneration);
	UNTIL ((compteCellule(grilleInitiale) = 0) or ((tmp > n) and (n > 0)));
	
	run := grilleInitiale;
END;

// on verifie si les positions d'un tableau existent deja ou non
FUNCTION verifierSiExiste(tableau : tabPosition; posX, posY, index : integer) :  boolean;
VAR
	stop : boolean;
	i : integer;
BEGIN
	stop := false;
	i := 0;
	REPEAT
		IF ((tableau[i].x = posX) and (tableau[i].y = posY)) then
		BEGIN
			stop := true;
			verifierSiExiste := true;
		END;
		inc(i);
	UNTIL (i >= index) or (stop);
	if not stop then
		verifierSiExiste := false;
END;

// genere un tableau de position en fonction de données rentrées à la main.
FUNCTION genererTableau() : tabPosition;
VAR
	nbrPosition, i, posX, posY : INTEGER;
	position                   : typePosition;
	tableau                    : tabPosition;
BEGIN
	ClrScr;
	REPEAT
		writeln('Combien de positions voulez vous rentrer ?');
		readln(nbrPosition);
	UNTIL (nbrPosition <= 	M);
	FOR i := 0 TO nbrPosition - 1 DO
	BEGIN
		REPEAT
			ClrScr;
			writeln('Rentrez l''abscisse du point n°', i, ' : ');
			readln(posX);
			writeln('Rentrez l''ordonnée du point n°', i, ' : ');
			readln(posY);
		UNTIL (((posX >= 0) and (posX < N)) and ((posY >= 0) and (posY < N)) and not verifierSiExiste(tableau ,posX, posY, i));
		position.x := posX;
		position.y := posY;
		tableau[i] := position;
	END;
	position.x := -1;
	position.y := -1;
	FOR i := nbrPosition + 1 TO M DO
	BEGIN
		tableau[i] := position;
	END;
	ClrScr;
	genererTableau := tableau;
END;

PROCEDURE menu;
VAR
	choix, p , g, nbrPosition, i : integer;
	posX, posY : integer;
	grille   : typeGrille;
	position : typePosition;
	tableau  : tabPosition;
BEGIN
	REPEAT
		writeln(' --> 1   : Choisir le pourcentage de cellules vivantes');
		writeln(' --> 2   : Entrer les positions sois même');
		writeln(' --> 3   : Entrer les positions par une string');
		writeln(' --> 12  : Quitter');
		readln(choix);
		IF  (choix = 1) or (choix = 2) THEN
		BEGIN
			IF (choix = 1) THEN
			BEGIN
				ClrScr;
				writeln(' Quel est le pourcentage?');
				readln(p);
				grille := initGrille(p);
				writeln('Maintenant, combien de générations souhaitez vous générer?');
				readln(g);
				ClrScr;
				writeln('Grille de départ :');
				afficherGrille(grille);
				run(grille , g);
			END;
			IF (choix = 2) THEN
			BEGIN
				grille := remplirGrille(genererTableau());
				writeln('Maintenant, combien de générations souhaitez vous générer?');
				readln(g);
				ClrScr;
				writeln('Grille de départ :');
				afficherGrille(grille);
				run(grille , g);
			END;

		END;
	UNTIL (choix = 12);
	ClrScr;
	writeln('Bye, bye');
END;

VAR
	grille : typeGrille;
	args   : importFile;
BEGIN

	{
	* 	L'utilisation de handleArgs() (de la partie 4) est expliqué
	* 	en détail dans le fichier LaTeX.
	* }

	args := handleArgs();
	IF (args.typeRun = 'R') then
		grille := initGrille(args.randomPctg)
	else
		grille := remplirGrille(args.vecteur1);
		
	run(grille, args.nbrGen);
END.
