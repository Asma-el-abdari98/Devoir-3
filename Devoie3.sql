 
    //Procédures Stockées
   
 //QUESTION 1 
  //Ecrire une procédure « AJOUT_PILOTE » qui permet la création d’un nouveau pilote.   
  
CREATE OR REPLACE PROCEDURE ajoutPilote ( 
  nump PILOTE.NOPILOT%TYPE,
  nomp PILOTE.NOM%TYPE,
  villep PILOTE.VILLE%TYPE,
  salp PILOTE.SAL%TYPE,
  commp PILOTE.COMM%TYPE,
  embauchep PILOTE.EMBAUCHE%TYPE
 ) 
 IS    
  nb NUMBER(2):=0;   
  pilote_existe EXCEPTION ; 
  pilote_noexiste EXCEPTION ;
BEGIN  
  SELECT count(*) INTO nb FROM PILOTE WHERE NOPILOT = nump; 
  IF(nb>0) 
	 THEN RAISE pilote_existe;
  ELSE 
	 RAISE pilote_noexiste;    
  END IF;
EXCEPTION  
  WHEN pilote_noexiste THEN    
  INSERT INTO PILOTE(NOPILOT,NOM,VILLE,SAL,COMM,EMBAUCHE) 
  VALUES(nump, nomp, villep, salp, commp, embauchep);
  DBMS_OUTPUT.PUT_LINE('Pilote inséré avec succés!');      
  WHEN pilote_existe 
  THEN   
  DBMS_OUTPUT.PUT_LINE('Code pilote dupliqué!');
END;
  EXEC ajoutPilote('1222','Sebbar','Agadir',5000,12,'01-JAN-00'); 
	
	//QUESTION 2
	//Ecrire une procédure «SUPPRIME_PILOTE» qui permet la suppression d’un pilote à partir de son numéro. 
	
	CREATE OR REPLACE PROCEDURE supprimePilote
(  
nump PILOTE.NOPILOT%TYPE
)
IS
 nb NUMBER(2):=0;
 nb2 NUMBER(2):=0;
 pilote_noexiste EXCEPTION ;
 pilote_existe_aff EXCEPTION ;
BEGIN
 SELECT count(*) INTO nb FROM PILOTE WHERE NOPILOT = nump;
 IF(nb=0) THEN
 RAISE pilote_noexiste;
 ELSE
 SELECT count(*) INTO nb2 FROM AFFECTATION WHERE PILOTE = nump;
 IF(nb2!=0) THEN
 RAISE pilote_existe_aff;
 ELSE
 DELETE FROM PILOTE WHERE NOPILOT = nump;
 COMMIT;
 DBMS_OUTPUT.PUT_LINE('Pilote supprimé avec succés!');
 END IF;
 END IF;
EXCEPTION
 WHEN pilote_noexiste THEN
 DBMS_OUTPUT.PUT_LINE('Pilote existe pas!');
 WHEN pilote_existe_aff THEN
 DBMS_OUTPUT.PUT_LINE('Pilote dejà affecté à un vol!');
END;
EXEC supprimePilote('1333');

     //QUESTION 4
	 //Ecrire une procédure stockée nommé «AFFICHE_PILOTE_N » permettant 
	 //d’afficher les noms des n premiers pilote de la table PILOTE. La variable n devra être le paramètre d’entrée. 
	 
CREATE OR REPLACE PROCEDURE affichePilote_N
 (n NUMBER)
IS
  nb NUMBER(2):=0;
  cNom PILOTE.NOM%TYPE;
  n_grand_nuplets EXCEPTION;
  CURSOR c1 IS SELECT NOM FROM PILOTE ;
BEGIN
  SELECT count(*) INTO nb FROM PILOTE;
  IF(nb>=n) THEN
  OPEN c1;
  LOOP
  FETCH c1 INTO cNom;
  EXIT WHEN (c1%ROWCOUNT > n) OR (c1%NOTFOUND);
  dbms_output.put_line('Nom (' || c1%ROWCOUNT || '): ' || cNom );
END LOOP;
  ELSE
  RAISE n_grand_nuplets;
  CLOSE c1;
  END IF;
EXCEPTION
  WHEN n_grand_nuplets THEN
  dbms_output.put_line('n est plus grand que le nomre de n-uplets de la table');
END;
EXEC affichePilote_N(2);



    //Fonctions Stockées 
    //QUESTION 1
 
CREATE OR REPLACE FUNCTION nombreMoyenHeureVol
(
numav AVION.TYPE%TYPE
)
RETURN VARCHAR2
IS
 nb NUMBER(2):=0;
 nb2 NUMBER(2):=0;
 nb3 NUMBER(10):=0;
 type_noexiste EXCEPTION;
 avion_pasdevol EXCEPTION;
BEGIN 
 SELECT count(*) INTO nb FROM APPAREIL WHERE CODETYPE=numav;
 IF(nb!=0) THEN
 SELECT count(*) INTO nb2 FROM AVION WHERE TYPE=numav;
 IF(nb2!=0) THEN
 SELECT DISTINCT(AVG(NBHVOL)) INTO nb3 FROM AVION WHERE
TYPE=numav;
 RETURN('Le nombre moyen d’heures de vol des avions
appartenant à la famille: '|| numav|| ' est: ' ||nb3);
 ELSE
 RAISE avion_pasdevol;
 END IF;
 ELSE
 RAISE type_noexiste;
 END IF;
EXCEPTION
 WHEN avion_pasdevol THEN
 RETURN('Cet avion n a pas effectué un vol!');
 WHEN type_noexiste THEN
 RETURN('Ce type d avion n existe pas!');
END;



  //QUESTION 2
  // Écrire une fonction qui effectue la conversion des Euros en Dirhams. 1€ =11,48 DH 






 //Paquetages 
 
 
 CREATE OR REPLACE PACKAGE GEST_PILOTE
IS
 PROCEDURE afficheContenu;
 PROCEDURE commSupSal(nump PILOTE.NOPILOT%TYPE);
 FUNCTION nbPil RETURN NUMBER;
 PROCEDURE supprimePilote(nump PILOTE.NOPILOT%TYPE);
 FUNCTION nombreMoyenHeureVol(typeAv AVION.TYPE%TYPE) RETURN VARCHAR2;
 PROCEDURE modifiePilote(nump PILOTE.NOM%TYPE, nomp PILOTE.NOM%TYPE,
villep PILOTE.VILLE%TYPE, salp PILOTE.SAL%TYPE);
END GEST_PILOTE;

CREATE OR REPLACE PACKAGE BODY GEST_PILOTE
IS
 PROCEDURE afficheContenu
 IS
 vEnreg PILOTE%ROWTYPE;
 CURSOR c1 IS SELECT * FROM PILOTE ;
 BEGIN
 OPEN c1;
 LOOP
 FETCH c1 INTO vEnreg;
 EXIT WHEN c1%NOTFOUND;
 dbms_output.put_line('Numero: ' || vEnreg.NOPILOT || ', Nom:
' || vEnreg.NOM || ', Ville: ' || vEnreg.VILLE || ', Salaire: ' ||
vEnreg.SAL);
 END LOOP;
 CLOSE c1;
 END afficheContenu;

 PROCEDURE commSupSal(nump PILOTE.NOPILOT%TYPE)
 IS
 nb NUMBER(2):=0;
 comm_superieur_sal EXCEPTION;
 BEGIN
 SELECT count(*) INTO nb FROM PILOTE WHERE COMM>SAL AND
NOPILOT=nump;
 IF(nb!=0) THEN
 RAISE comm_superieur_sal;
 END IF;
 EXCEPTION
 WHEN comm_superieur_sal THEN
 dbms_output.put_line('La commission est supérieur au salaire
pour ce pilote');
 END commSupSal;
 END GESTE_PILOTE;


