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

CREATE SEQUENCE bill_seq
START WITH 1
INCREMENT BY 1;

CREATE TABLE BILL (
    bID INT DEFAULT bill_seq.NEXTVAL,
    pID INT NOT NULL,
    patient_name VARCHAR(50) NOT NULL,
    duration INT NOT NULL,
    due_day DATE NOT NULL,
    price INT NOT NULL,
    paid VARCHAR(20) DEFAULT 'no' CONSTRAINT paid_check CHECK (paid IN ('yes', 'no')),
    PRIMARY KEY (bID),
    FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

-- RELATIONSHIPS -----------------------------------------------------------------
CREATE TABLE HANDLE (
	sID INT NOT NULL,
    doctor_name VARCHAR(50) NOT NULL,
    pID INT NOT NULL,
    patient_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (sID, pID),
    FOREIGN KEY (sID) REFERENCES DOCTOR(sID),
	FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

CREATE TABLE ADMITTED_TO (
	rID INT NOT NULL,
    room_name VARCHAR(50) NOT NULL,
    pID INT NOT NULL,
    patient_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (rID, pID),
	FOREIGN KEY (rID) REFERENCES ROOM(rID),
	FOREIGN KEY (pID) REFERENCES PATIENT(pID)
);

CREATE TABLE MAINTAIN (
	rID INT NOT NULL,
    room_name VARCHAR(50) NOT NULL,
    sID INT NOT NULL,
    ward_boy_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (rID, sID),
    FOREIGN KEY (rID) REFERENCES ROOM(rID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

CREATE TABLE TAKE_CARE (
	pID INT NOT NULL,
    patient_name VARCHAR(50) NOT NULL,
    sID INT NOT NULL,
    nurse_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (pID, sID),
    FOREIGN KEY (pID) REFERENCES PATIENT(pID),
    FOREIGN KEY (sID) REFERENCES STAFF(sID)
);

-- TRIGGERS -----------------------------------------------------------------

create or replace TRIGGER insert_bill
AFTER INSERT ON PATIENT
FOR EACH ROW
BEGIN
  INSERT INTO BILL (bID, pID, patient_name, duration, due_day, price, paid)
  VALUES (bill_seq.NEXTVAL, :NEW.pID, :NEW.name, (:NEW.day_out - :NEW.day_in), :NEW.day_out + 7, (:NEW.day_out - :NEW.day_in) * 60, 'no');
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

CREATE OR REPLACE TRIGGER insert_take_care
BEFORE INSERT ON TAKE_CARE
FOR EACH ROW
DECLARE
  patient_name VARCHAR(50);
  nurse_name VARCHAR(50);
BEGIN
  SELECT name INTO patient_name FROM PATIENT WHERE pID = :NEW.pID;
  SELECT name INTO nurse_name FROM STAFF WHERE sID = :NEW.sID;
  :NEW.patient_name := patient_name;
  :NEW.nurse_name := nurse_name;
END;
/

CREATE OR REPLACE TRIGGER insert_handle
BEFORE INSERT ON HANDLE
FOR EACH ROW
DECLARE
  doctor_name VARCHAR(50);
  patient_name VARCHAR(50);
BEGIN
  SELECT name INTO patient_name FROM PATIENT WHERE pID = :NEW.pID;
  SELECT name INTO doctor_name FROM DOCTOR WHERE sID = :NEW.sID;
  :NEW.patient_name := patient_name;
  :NEW.doctor_name := doctor_name;
END;
/

CREATE OR REPLACE TRIGGER insert_admitted_to
BEFORE INSERT ON ADMITTED_TO
FOR EACH ROW
DECLARE
  room_name VARCHAR(50);
  patient_name VARCHAR(50);
BEGIN
  SELECT name INTO patient_name FROM PATIENT WHERE pID = :NEW.pID;
  SELECT name INTO room_name FROM ROOM WHERE rID = :NEW.rID;
  :NEW.patient_name := patient_name;
  :NEW.room_name := room_name;
END;
/

CREATE OR REPLACE TRIGGER insert_maintain
BEFORE INSERT ON MAINTAIN
FOR EACH ROW
DECLARE
  room_name VARCHAR(50);
  ward_boy_name VARCHAR(50);
BEGIN
  SELECT name INTO ward_boy_name FROM STAFF WHERE sID = :NEW.sID;
  SELECT name INTO room_name FROM ROOM WHERE rID = :NEW.rID;
  :NEW.ward_boy_name := ward_boy_name;
  :NEW.room_name := room_name;
END;
/
