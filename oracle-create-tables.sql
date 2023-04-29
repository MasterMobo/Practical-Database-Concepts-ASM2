CREATE TABLE PATIENT (
	pID INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    birth_day DATE,
    phone INTEGER,
    address VARCHAR(100),
    disease VARCHAR(100) NOT NULL,
    treatment VARCHAR(100) NOT NULL,
    day_in DATE NOT NULL,
    day_out DATE NOT NULL,
    PRIMARY KEY (pID)
);

CREATE TABLE STAFF (
	sID INT NOT NULL,
    name VARCHAR(50) NOT NULL,
	birth_day DATE,
    phone INTEGER,
    PRIMARY KEY (sID)
);

CREATE TABLE DOCTOR (
	sID INT NOT NULL,
    name VARCHAR(50) NOT NULL,
	birth_day DATE,
    phone INTEGER,
    specialty VARCHAR(50),
    PRIMARY KEY (sID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

CREATE TABLE NURSE (
	sID INT NOT NULL,
    name VARCHAR(50) NOT NULL,
	birth_day DATE,
    phone INTEGER,
    shift VARCHAR(20) NOT NULL CONSTRAINT shift_check CHECK (shift IN ('Morning', 'Evening', 'Night')),

    PRIMARY KEY (sID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

CREATE TABLE WARD_BOY (
	sID INT NOT NULL,
    name VARCHAR(50) NOT NULL,
	birth_day DATE,
    phone INTEGER,
    duty VARCHAR(50),
    PRIMARY KEY (sID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

CREATE TABLE ROOM (
    rID INT,
    name VARCHAR(50),
    capacity INT,
    availability VARCHAR(20) NOT NULL CONSTRAINT availability_check CHECK (availability IN ('available', 'unavailable')),
    PRIMARY KEY (rID)
);

CREATE TABLE CLINICAL_LAB(
    rID INT,
    name VARCHAR(50),
    capacity INT,
    availability VARCHAR(20) NOT NULL CONSTRAINT availability_check1 CHECK (availability IN ('available', 'unavailable')),  
    lab_type VARCHAR(50),
    PRIMARY KEY (rID),
    FOREIGN KEY (rID) REFERENCES ROOM(rID)
);

CREATE TABLE OPERATION_THEATER(
    rID INT,
    name VARCHAR(50),
    capacity INT,
    availability VARCHAR(20) NOT NULL CONSTRAINT availability_check2 CHECK (availability IN ('available', 'unavailable')), 
    op_type VARCHAR(50),
    PRIMARY KEY (rID),
    FOREIGN KEY (rID) REFERENCES ROOM(rID)
);

CREATE TABLE ICU(
    rID INT,
    name VARCHAR(50),
    capacity INT,
    availability VARCHAR(20) NOT NULL CONSTRAINT availability_check3 CHECK (availability IN ('available', 'unavailable')),  
    icu_type VARCHAR(50),
    PRIMARY KEY (rID),
    FOREIGN KEY (rID) REFERENCES ROOM(rID)
);

-- CREATE OR REPLACE SEQUENCE bill_seq
-- START WITH 1
-- INCREMENT BY 1;

CREATE TABLE BILL (
	bID INT DEFAULT bill_seq.NEXTVAL,
    pID INT,
    duration INT NOT NULL,
    due_day DATE NOT NULL,
    price INT NOT NULL,
    PRIMARY KEY (bID),
    FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

-- RELATIONSHIPS -----------------------------------------------------------------
CREATE TABLE HANDLE (
	sID INT,
    pID INT,
    PRIMARY KEY (sID, pID),
    FOREIGN KEY (sID) REFERENCES DOCTOR(sID),
	FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

CREATE TABLE ADMITTED_TO (
	rID INT,
    pID INT,
    PRIMARY KEY (rID, pID),
	FOREIGN KEY (rID) REFERENCES ROOM(rID),
	FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

CREATE TABLE MAINTAIN (
	rID INT UNIQUE NOT NULL,
    sID INT UNIQUE NOT NULL,
    PRIMARY KEY (rID, sID),
    FOREIGN KEY (rID) REFERENCES ROOM(rID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

CREATE TABLE TAKE_CARE (
	pID INT UNIQUE NOT NULL,
    sID INT UNIQUE NOT NULL,
    PRIMARY KEY (pID, sID),
    FOREIGN KEY (pID) REFERENCES PATIENT(pID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

-- TRIGGERS -----------------------------------------------------------------

CREATE OR REPLACE TRIGGER insert_bill
AFTER INSERT ON ADMITTED_TO
FOR EACH ROW
DECLARE
    v_duration NUMBER;
    v_price NUMBER;
    v_day_in DATE;
    v_day_out DATE;
BEGIN
    SELECT day_in, day_out INTO v_day_in, v_day_out FROM PATIENT WHERE pID = :NEW.pID;
    v_duration := (v_day_out - v_day_in);
    v_price := v_duration * 60;

    INSERT INTO BILL (bID, pID, duration, due_day, price)
    VALUES (bill_seq.nextval, :NEW.pID, v_duration, v_day_out + 7, v_price);
END;
/


create or replace TRIGGER insert_doctor
AFTER INSERT ON DOCTOR
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

create or replace TRIGGER insert_nurse
AFTER INSERT ON NURSE
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

create or replace TRIGGER insert_wardboy
AFTER INSERT ON WARD_BOY
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

create or replace TRIGGER insert_lab
AFTER INSERT ON CLINICAL_LAB
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/

create or replace TRIGGER insert_op
AFTER INSERT ON OPERATION_THEATER
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/

create or replace TRIGGER insert_icu
AFTER INSERT ON ICU
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/
