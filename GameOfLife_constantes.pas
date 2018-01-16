unit GameOfLife_constantes;

INTERFACE
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
	grille               : typeGrille;
END;

	
IMPLEMENTATION
END.
