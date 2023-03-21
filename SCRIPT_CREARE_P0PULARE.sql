--CREARE TABELE
CREATE TABLE book (
    book_id          NUMBER NOT NULL,
    number_available NUMBER NOT NULL,
    book_details_id  NUMBER NOT NULL
)
LOGGING;
ALTER TABLE book ADD CONSTRAINT x_number_av_ck CHECK ( number_available >= 0 );

CREATE UNIQUE INDEX book__idx ON
    book (
        book_details_id
    ASC )
        LOGGING;

ALTER TABLE book ADD CONSTRAINT book_pk PRIMARY KEY ( book_id );

CREATE TABLE book_borrow (
    receipt_id NUMBER NOT NULL,
    book_id    NUMBER NOT NULL
)
LOGGING;

ALTER TABLE book_borrow ADD CONSTRAINT book_borrow_pk PRIMARY KEY ( receipt_id,
                                                                    book_id );

CREATE TABLE book_details (
    book_details_id NUMBER NOT NULL,
    title           VARCHAR2(35) NOT NULL,
    author          VARCHAR2(30) NOT NULL,
    genre           VARCHAR2(30) NOT NULL
)
LOGGING;

ALTER TABLE book_details
    ADD CONSTRAINT x_title_ck CHECK ( length(title) >= 2 );

ALTER TABLE book_details
    ADD CONSTRAINT x_name_ck CHECK ( REGEXP_LIKE ( author,
                                                   '^[A-Z]' ) );

ALTER TABLE book_details
    ADD CONSTRAINT x_genre_ck CHECK ( length(genre) > 4 );

ALTER TABLE book_details ADD CONSTRAINT book_details_pk PRIMARY KEY ( book_details_id );

ALTER TABLE book_details ADD CONSTRAINT book_details_un1 UNIQUE ( title,
                                                                  author );

CREATE TABLE ingredient (
    ingredient_id      NUMBER NOT NULL,
    nume               VARCHAR2(20) NOT NULL,
    available_quantity NUMBER NOT NULL,
    expiration_date    DATE NOT NULL
)
LOGGING;

ALTER TABLE ingredient
    ADD CONSTRAINT x_nume_ck CHECK ( length(nume) > 1 );

ALTER TABLE ingredient ADD CONSTRAINT x_quantity_ck CHECK ( available_quantity >= 0 );

COMMENT ON COLUMN ingredient.available_quantity IS
    '->How much of that product is left';

ALTER TABLE ingredient ADD CONSTRAINT ingredient_pk PRIMARY KEY ( ingredient_id );

ALTER TABLE ingredient ADD CONSTRAINT ingredient_un1 UNIQUE ( nume );

CREATE TABLE item_ingredient (
    item_id             NUMBER NOT NULL,
    ingredient_id       NUMBER NOT NULL,
    ingredient_quantity NUMBER NOT NULL
)
LOGGING;

ALTER TABLE item_ingredient ADD CONSTRAINT x_inq_ck CHECK ( ingredient_quantity >= 0 );

ALTER TABLE item_ingredient ADD CONSTRAINT item_ingredient_pk PRIMARY KEY ( item_id,
                                                                            ingredient_id );

CREATE TABLE item_meniu (
    item_id NUMBER NOT NULL,
    name    VARCHAR2(50) NOT NULL,
    price   NUMBER NOT NULL
)
LOGGING;

ALTER TABLE item_meniu
    ADD CONSTRAINT x_n_ck CHECK ( length(name) > 2 );

ALTER TABLE item_meniu ADD CONSTRAINT x_price_ck CHECK ( price > 0 );

ALTER TABLE item_meniu ADD CONSTRAINT item_meniu_pk PRIMARY KEY ( item_id );

ALTER TABLE item_meniu ADD CONSTRAINT item_meniu_un1 UNIQUE ( name );

CREATE TABLE item_receipt (
    item_id    NUMBER NOT NULL,
    receipt_id NUMBER NOT NULL,
    quantity   NUMBER NOT NULL
)
LOGGING;

ALTER TABLE item_receipt ADD CONSTRAINT x_qu_ck CHECK ( quantity > 0 );

ALTER TABLE item_receipt ADD CONSTRAINT item_receipt_pk PRIMARY KEY ( item_id,
                                                                      receipt_id );

CREATE TABLE receipt (
    receipt_id   NUMBER NOT NULL,
    receipt_date DATE NOT NULL,
    pay_status   VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE receipt
    ADD CHECK ( pay_status IN ( 'Paid', 'Unpaid' ) );

ALTER TABLE receipt ADD CONSTRAINT receipt_pk PRIMARY KEY ( receipt_id );

ALTER TABLE book
    ADD CONSTRAINT book_book_details_fk FOREIGN KEY ( book_details_id )
        REFERENCES book_details ( book_details_id )
    NOT DEFERRABLE;

ALTER TABLE book_borrow
    ADD CONSTRAINT book_borrow_book_fk FOREIGN KEY ( book_id )
        REFERENCES book ( book_id )
    NOT DEFERRABLE;

ALTER TABLE book_borrow
    ADD CONSTRAINT book_borrow_receipt_fk FOREIGN KEY ( receipt_id )
        REFERENCES receipt ( receipt_id )
    NOT DEFERRABLE;

ALTER TABLE item_ingredient
    ADD CONSTRAINT item_ingredient_ingredient_fk FOREIGN KEY ( ingredient_id )
        REFERENCES ingredient ( ingredient_id )
    NOT DEFERRABLE;

ALTER TABLE item_ingredient
    ADD CONSTRAINT item_ingredient_item_meniu_fk FOREIGN KEY ( item_id )
        REFERENCES item_meniu ( item_id )
    NOT DEFERRABLE;

ALTER TABLE item_receipt
    ADD CONSTRAINT item_receipt_item_meniu_fk FOREIGN KEY ( item_id )
        REFERENCES item_meniu ( item_id )
    NOT DEFERRABLE;

ALTER TABLE item_receipt
    ADD CONSTRAINT item_receipt_receipt_fk FOREIGN KEY ( receipt_id )
        REFERENCES receipt ( receipt_id )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER trg_x_date 
    BEFORE INSERT OR UPDATE ON INGREDIENT 
    FOR EACH ROW 
BEGIN
	IF( :new.Expiration_Date <= SYSDATE )
	THEN
		RAISE_APPLICATION_ERROR( -20001,
		'Data invalida: ' || TO_CHAR( :new.Expiration_Date, 'DD.MM.YYYY HH24:MI:SS' ) || ' trebuie sa fie mai mare decat data curenta.' );
	END IF;
END; 
/

CREATE SEQUENCE book_book_id_sq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER book_book_id_trg BEFORE
    INSERT ON book
    FOR EACH ROW
    WHEN ( new.book_id IS NULL )
BEGIN
    :new.book_id := book_book_id_sq.nextval;
END;
/

CREATE SEQUENCE book_details_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER book_details_id_trg BEFORE
    INSERT ON book_details
    FOR EACH ROW
BEGIN
    :new.book_details_id := book_details_id_seq.nextval;
END;
/

CREATE SEQUENCE ingredient_ingrent_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER ingredient_ingrent_id_trg BEFORE
    INSERT ON ingredient
    FOR EACH ROW
    WHEN ( new.ingredient_id IS NULL )
BEGIN
    :new.ingredient_id := ingredient_ingrent_id_seq.nextval;
END;
/

CREATE SEQUENCE item_item_id_seq START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER item_item_id_trg BEFORE
    INSERT ON item_meniu
    FOR EACH ROW
    WHEN ( new.item_id IS NULL )
BEGIN
    :new.item_id := item_item_id_seq.nextval;
END;
/

CREATE SEQUENCE receipt_receipt_id_seq START WITH 10000 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER receipt_receipt_id_seq BEFORE
    INSERT ON receipt
    FOR EACH ROW
BEGIN
    :new.receipt_id := receipt_receipt_id_seq.nextval;
END;
/
--INSERARE IN TABELE
--BOOK_DETAILS
INSERT INTO BOOK_DETAILS VALUES(null,'Cautand-o pe Alaska','John Green','Adventure');
INSERT INTO BOOK_DETAILS VALUES(null,'It','Stephen King','Horror');
INSERT INTO BOOK_DETAILS VALUES(null,'Inchisoarea Ingerilor','Stephen King','Horror');
INSERT INTO BOOK_DETAILS VALUES(null,'Capitan la 15 ani','Jules Verne','Adventure');
INSERT INTO BOOK_DETAILS VALUES(null,'1984','George Orwell','Fantasy');
INSERT INTO BOOK_DETAILS VALUES(null,'Amintiri din Copilarie','Ion Creanga','Memories');
--BOOK
INSERT INTO BOOK VALUES (null,'15','1');
INSERT INTO BOOK VALUES (null,'30','2');
INSERT INTO BOOK VALUES (null,'7','3');
INSERT INTO BOOK VALUES (null,'5','4');
INSERT INTO BOOK VALUES (null,'12','5');
INSERT INTO BOOK VALUES (null,'30','6');
--INGREDIENT
INSERT INTO INGREDIENT VALUES (null,'Lapte','15',TO_DATE('2023-05-02','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Cacao','10',TO_DATE('2024-03-15','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Lapte de Cocos','10',TO_DATE('2024-03-15','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Chifla integrala','10',TO_DATE('2023-03-15','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Unt','4',TO_DATE('2023-03-12','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Faina','100',TO_DATE('2024-07-20','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Nuttella','10',TO_DATE('2023-07-20','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Oua','45',TO_DATE('2023-04-22','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Rom','5',TO_DATE('2024-04-22','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Zahar Brun','5',TO_DATE('2024-10-22','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Cola','130',TO_DATE('2024-10-29','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Limes','19',TO_DATE('2023-04-29','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'Ceai Verde','7',TO_DATE('2027-04-29','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'BettyIce Vanilie','10',TO_DATE('2027-04-29','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'BettyIce Cacao','10',TO_DATE('2027-04-29','yyyy-mm-dd'));
INSERT INTO INGREDIENT VALUES (null,'BettyIce Berries','10',TO_DATE('2027-04-29','yyyy-mm-dd'));
--ITEM_MENIU
INSERT INTO ITEM_MENIU VALUES(null,'Cub Libre',16);
DELETE FROM ITEM_MENIU;--ndezarea va incepe de la 2 acum
INSERT INTO ITEM_MENIU VALUES(null,'Cuba Libre',16);
INSERT INTO ITEM_MENIU VALUES(null,'Ciocolata calda',11);
INSERT INTO ITEM_MENIU VALUES(null,'Ceai Verde',10);
INSERT INTO ITEM_MENIU VALUES(null,'Clatite Nutella',15);
INSERT INTO ITEM_MENIU VALUES(null,'Inghetata Mixta',19);
--ITEM_INGREDIENT
INSERT INTO ITEM_INGREDIENT VALUES(2,9,0.1);
INSERT INTO ITEM_INGREDIENT VALUES(2,11,1);
INSERT INTO ITEM_INGREDIENT VALUES(2,12,1);

INSERT INTO ITEM_INGREDIENT VALUES(3,1,0.3);
INSERT INTO ITEM_INGREDIENT VALUES(3,2,0.1);
INSERT INTO ITEM_INGREDIENT VALUES(3,10,0.001);

INSERT INTO ITEM_INGREDIENT VALUES(4,10,0.002);
INSERT INTO ITEM_INGREDIENT VALUES(4,13,1);

INSERT INTO ITEM_INGREDIENT VALUES(5,1,0.2);
INSERT INTO ITEM_INGREDIENT VALUES(5,6,0.18);
INSERT INTO ITEM_INGREDIENT VALUES(5,7,0.1);
INSERT INTO ITEM_INGREDIENT VALUES(5,8,1);
INSERT INTO ITEM_INGREDIENT VALUES(5,10,0.005);

INSERT INTO ITEM_INGREDIENT VALUES(6,14,0.2);
INSERT INTO ITEM_INGREDIENT VALUES(6,15,0.2);
INSERT INTO ITEM_INGREDIENT VALUES(6,16,0.2);

--RECEIPT
INSERT INTO RECEIPT VALUES(null,TO_DATE('2023-01-02','yyyy-mm-dd'),'Unpaid');

--se mai pot adauga din interfata

--ITEM_RECEIPT
INSERT INTO IREM_RECEIPT VALUES (2,10000);--a comandat cuba si cei verde
INSERT INTO IREM_RECEIPT VALUES (4,10000);
--BOOK_BORROW
INSERT INTO BOOK_BORROW VALUES (10000,2);
--!!!codul de inserare apelat in aceasta forma descrie inregistralile curente ale bazei de date
--totusi, numarul de carti nu va fi decrementat daca nu se utilizeaza interfata.
