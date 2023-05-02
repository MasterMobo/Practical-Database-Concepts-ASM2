-- This file creates the tables and relationships for the hospital database.
-- IMPORTANT: Run the following file as a script under SQL Workshop > SQL Scripts in Oracle APEX. Any other platform may be subject to errors.

-- Create Tables -----------------------------------------------------------------------------------------------------------------
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

-- Sequence for the BILL table (auto-incrementing primary key)
CREATE SEQUENCE bill_seq
START WITH 1
INCREMENT BY 1;

-- The BILL table is automatically populated by a trigger when a new patient is inserted into the PATIENT table
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

-- This trigger inserts a new row into the BILL table when a new patient is inserted into the PATIENT table
create or replace TRIGGER insert_bill
AFTER INSERT ON PATIENT
FOR EACH ROW
BEGIN
  INSERT INTO BILL (bID, pID, patient_name, duration, due_day, price, paid)
  VALUES (bill_seq.NEXTVAL, :NEW.pID, :NEW.name, (:NEW.day_out - :NEW.day_in), :NEW.day_out + 7, (:NEW.day_out - :NEW.day_in) * 60, 'no');
END;
/

-- This trigger inserts a new row into the STAFF table when a new doctor is inserted into the DOCTOR table
create or replace TRIGGER insert_doctor
AFTER INSERT ON DOCTOR
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

-- This trigger inserts a new row into the STAFF table when a new nurse is inserted into the NURSE table
create or replace TRIGGER insert_nurse
AFTER INSERT ON NURSE
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

-- This trigger inserts a new row into the STAFF table when a new wardboy is inserted into the WARD_BOY table
create or replace TRIGGER insert_wardboy
AFTER INSERT ON WARD_BOY
FOR EACH ROW
BEGIN
  INSERT INTO STAFF (sID, name, birth_day, phone)
  VALUES (:NEW.sID, :NEW.name, :NEW.birth_day, :NEW.phone);
END;
/

-- This trigger inserts a new row into the ROOM table when a new lab is inserted into the CLINICAL_LAB table
create or replace TRIGGER insert_lab
AFTER INSERT ON CLINICAL_LAB
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/

-- This trigger inserts a new row into the ROOM table when a new operation theater is inserted into the OPERATION_THEATER table
create or replace TRIGGER insert_op
AFTER INSERT ON OPERATION_THEATER
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/

-- This trigger inserts a new row into the ROOM table when a new ICU is inserted into the ICU table
create or replace TRIGGER insert_icu
AFTER INSERT ON ICU
FOR EACH ROW
BEGIN
  INSERT INTO ROOM (rID, name, capacity, availability)
  VALUES (:NEW.rID, :NEW.name, :NEW.capacity, :NEW.availability);
END;
/

-- This trigger set the patient_name and nurse_name attributes of the TAKE_CARE table when a new row is inserted
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

-- This trigger set the patient_name and doctor_name attributes of the HANDLE table when a new row is inserted
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

-- This trigger set the patient_name and room_name attributes of the ADMITTED_TO table when a new row is inserted
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

-- This trigger set the ward_boy_name and room_name attributes of the MAINTAIN table when a new row is inserted
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

-- Populate Tables -----------------------------------------------------------------
-- PATIENT ------------------------------------------------------------------------------------------------------------
INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (1, 'John Smith', TO_DATE('1990-05-15', 'YYYY-MM-DD'), 1234567890, '123 Main St', 'Flu', 'Antibiotics', TO_DATE('2023-03-01', 'YYYY-MM-DD'), TO_DATE('2023-03-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (2, 'Mary Johnson', TO_DATE('1985-09-20', 'YYYY-MM-DD'), 2345678901, '456 Elm St', 'Pneumonia', 'Antibiotics', TO_DATE('2022-08-10', 'YYYY-MM-DD'), TO_DATE('2022-08-15', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (3, 'David Lee', TO_DATE('1997-01-01', 'YYYY-MM-DD'), 3456789012, '789 Oak St', 'Appendicitis', 'Surgery', TO_DATE('2022-07-20', 'YYYY-MM-DD'), TO_DATE('2022-07-25', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (4, 'Emily Chen', TO_DATE('1980-12-01', 'YYYY-MM-DD'), 4567890123, '567 Pine St', 'Migraine', 'Painkillers', TO_DATE('2022-09-05', 'YYYY-MM-DD'), TO_DATE('2022-09-10', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (5, 'Daniel Kim', TO_DATE('1993-06-18', 'YYYY-MM-DD'), 5678901234, '234 Maple St', 'Asthma', 'Inhaler', TO_DATE('2022-06-15', 'YYYY-MM-DD'), TO_DATE('2022-06-20', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (6, 'Sarah Park', TO_DATE('1989-11-05', 'YYYY-MM-DD'), 6789012345, '789 Oak St', 'Broken Arm', 'Cast', TO_DATE('2022-05-20', 'YYYY-MM-DD'), TO_DATE('2022-06-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (7, 'Ryan Lee', TO_DATE('2000-02-29', 'YYYY-MM-DD'), 7890123456, '123 Elm St', 'Flu', 'Antibiotics', TO_DATE('2022-04-15', 'YYYY-MM-DD'), TO_DATE('2022-04-20', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (8, 'Jennifer Smith', TO_DATE('1978-07-04', 'YYYY-MM-DD'), 8901234567, '456 Oak St', 'Flu', 'Antibiotics', TO_DATE('2022-03-10', 'YYYY-MM-DD'), TO_DATE('2022-03-15', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (9, 'Steven Park', TO_DATE('2001-08-06', 'YYYY-MM-DD'), 9012345678, '135 Pine Rd', 'Acne', 'Acne medication', TO_DATE('2022-09-05', 'YYYY-MM-DD'), TO_DATE('2022-09-10', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (10, 'Rachel Kim', TO_DATE('1989-04-23', 'YYYY-MM-DD'), 0123456789, '579 Cedar St', 'Anxiety', 'Anxiety medication', TO_DATE('2022-08-10', 'YYYY-MM-DD'), TO_DATE('2022-08-15', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (11, 'Brian Lee', TO_DATE('1996-02-14', 'YYYY-MM-DD'), 2345678901, '567 Main St', 'Flu', 'Antibiotics', TO_DATE('2022-05-20', 'YYYY-MM-DD'), TO_DATE('2022-06-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (12, 'Emma Davis', TO_DATE('1987-09-20', 'YYYY-MM-DD'), 2345678901, '456 Pine St', 'Pneumonia', 'Antibiotics', TO_DATE('2023-03-25', 'YYYY-MM-DD'), TO_DATE('2023-04-01', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (13, 'Liam Wilson', TO_DATE('1985-06-02', 'YYYY-MM-DD'), 3456789012, '789 Oak St', 'COVID-19', 'Antiviral medication', TO_DATE('2023-03-29', 'YYYY-MM-DD'), TO_DATE('2023-04-15', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (14, 'Ava Brown', TO_DATE('1993-02-14', 'YYYY-MM-DD'), 4567890123, '234 Elm St', 'Migraine', 'Pain relievers', TO_DATE('2023-04-05', 'YYYY-MM-DD'), TO_DATE('2023-04-08', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (15, 'Noah Garcia', TO_DATE('1978-11-29', 'YYYY-MM-DD'), 5678901234, '567 Maple St', 'Heart disease', 'Beta blockers', TO_DATE('2023-04-10', 'YYYY-MM-DD'), TO_DATE('2023-04-20', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (16, 'Sophia Rodriguez', TO_DATE('1982-03-18', 'YYYY-MM-DD'), 6789012345, '890 Birch St', 'Acne', 'Acne medication', TO_DATE('2023-04-11', 'YYYY-MM-DD'), TO_DATE('2023-04-14', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (17, 'Jackson Wilson', TO_DATE('1998-08-12', 'YYYY-MM-DD'), 7890123456, '123 Cedar St', 'Asthma', 'Bronchodilators', TO_DATE('2023-04-12', 'YYYY-MM-DD'), TO_DATE('2023-04-18', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (18, 'Olivia Hernandez', TO_DATE('1980-01-06', 'YYYY-MM-DD'), 8901234567, '456 Oak St', 'Diabetes', 'Insulin', TO_DATE('2023-04-14', 'YYYY-MM-DD'), TO_DATE('2023-04-25', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (19, 'Ryan Park', TO_DATE('2003-01-31', 'YYYY-MM-DD'), 0123456789, '579 Pine Rd', 'Acne', 'Acne medication', TO_DATE('2023-04-10', 'YYYY-MM-DD'), TO_DATE('2023-04-20', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (20, 'Grace Kim', TO_DATE('1990-09-05', 'YYYY-MM-DD'), 1234567890, '123 Cedar St', 'Anxiety', 'Anxiety medication', TO_DATE('2023-04-30', 'YYYY-MM-DD'), TO_DATE('2023-05-02', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (21, 'Matthew Lee', TO_DATE('1995-03-28', 'YYYY-MM-DD'), 2345678901, '567 Main St', 'Flu', 'Antibiotics', TO_DATE('2023-05-05', 'YYYY-MM-DD'), TO_DATE('2023-05-09', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (22, 'Emily Lee', TO_DATE('1999-09-12', 'YYYY-MM-DD'), 3456789012, '789 Elm St', 'Asthma', 'Inhaler', TO_DATE('2023-04-29', 'YYYY-MM-DD'), TO_DATE('2023-05-03', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (23, 'William Chen', TO_DATE('1985-12-01', 'YYYY-MM-DD'), 4567890123, '234 Oak St', 'Migraine', 'Painkillers', TO_DATE('2023-04-30', 'YYYY-MM-DD'), TO_DATE('2023-05-02', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (24, 'Sophia Kim', TO_DATE('2000-07-22', 'YYYY-MM-DD'), 5678901234, '345 Maple St', 'Broken arm', 'Cast', TO_DATE('2023-05-01', 'YYYY-MM-DD'), TO_DATE('2023-05-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (25, 'Oliver Rodriguez', TO_DATE('1977-01-18', 'YYYY-MM-DD'), 6789012345, '456 Pine St', 'Diabetes', 'Insulin', TO_DATE('2023-05-02', 'YYYY-MM-DD'), TO_DATE('2023-05-06', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (26, 'Evelyn Park', TO_DATE('1992-11-30', 'YYYY-MM-DD'), 7890123456, '567 Cedar St', 'Pneumonia', 'Antibiotics', TO_DATE('2023-05-03', 'YYYY-MM-DD'), TO_DATE('2023-05-07', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (27, 'James Lee', TO_DATE('1980-03-04', 'YYYY-MM-DD'), 8901234567, '678 Walnut St', 'Flu', 'Antibiotics', TO_DATE('2023-05-04', 'YYYY-MM-DD'), TO_DATE('2023-05-08', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (28, 'Avery Smith', TO_DATE('1995-09-16', 'YYYY-MM-DD'), 9012345678, '789 Chestnut St', 'Sprained ankle', 'Bandage', TO_DATE('2023-05-05', 'YYYY-MM-DD'), TO_DATE('2023-05-09', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (29, 'Emily Johnson', TO_DATE('1997-08-12', 'YYYY-MM-DD'), 3456789012, '789 Elm St', 'Appendicitis', 'Surgery', TO_DATE('2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-04-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (30, 'Robert Williams', TO_DATE('1985-02-22', 'YYYY-MM-DD'), 4567890123, '456 Oak St', 'Gallstones', 'Surgery', TO_DATE('2023-03-21', 'YYYY-MM-DD'), TO_DATE('2023-03-25', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (31, 'Megan Davis', TO_DATE('1992-11-04', 'YYYY-MM-DD'), 5678901234, '234 Maple St', 'Hernia', 'Surgery', TO_DATE('2023-02-14', 'YYYY-MM-DD'), TO_DATE('2023-02-18', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (32, 'William Wilson', TO_DATE('1979-06-27', 'YYYY-MM-DD'), 6789012345, '345 Pine St', 'Kidney Stones', 'Surgery', TO_DATE('2023-01-05', 'YYYY-MM-DD'), TO_DATE('2023-01-09', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (33, 'Sophia Brown', TO_DATE('1988-09-17', 'YYYY-MM-DD'), 7890123456, '567 Birch St', 'Appendicitis', 'Surgery', TO_DATE('2022-12-02', 'YYYY-MM-DD'), TO_DATE('2022-12-06', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (34, 'Alice Johnson', TO_DATE('1980-07-12', 'YYYY-MM-DD'), 3456789012, '789 Oak St', 'Heart Attack', 'ICU', TO_DATE('2023-04-01', 'YYYY-MM-DD'), TO_DATE('2023-04-10', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (35, 'Benjamin Franklin', TO_DATE('1975-12-20', 'YYYY-MM-DD'), 4567890123, '456 Elm St', 'Severe Pneumonia', 'ICU', TO_DATE('2023-03-20', 'YYYY-MM-DD'), TO_DATE('2023-04-05', 'YYYY-MM-DD'));

INSERT INTO PATIENT (pID, name, birth_day, phone, address, disease, treatment, day_in, day_out)
VALUES (36, 'Catherine Lee', TO_DATE('1985-02-10', 'YYYY-MM-DD'), 5678901234, '234 Pine St', 'Brain Injury', 'ICU', TO_DATE('2023-04-15', 'YYYY-MM-DD'), TO_DATE('2023-04-30', 'YYYY-MM-DD'));

--Update BILL ----------------------------------------------------------------------

UPDATE BILL SET paid = 'yes' WHERE pID = 1;
UPDATE BILL SET paid = 'yes' WHERE pID = 2;
UPDATE BILL SET paid = 'yes' WHERE pID = 3;
UPDATE BILL SET paid = 'yes' WHERE pID = 6;
UPDATE BILL SET paid = 'yes' WHERE pID = 7;
UPDATE BILL SET paid = 'yes' WHERE pID = 8;
UPDATE BILL SET paid = 'yes' WHERE pID = 10;
UPDATE BILL SET paid = 'yes' WHERE pID = 11;
UPDATE BILL SET paid = 'yes' WHERE pID = 12;
UPDATE BILL SET paid = 'yes' WHERE pID = 15;
UPDATE BILL SET paid = 'yes' WHERE pID = 16;
UPDATE BILL SET paid = 'yes' WHERE pID = 17;
UPDATE BILL SET paid = 'yes' WHERE pID = 18;
UPDATE BILL SET paid = 'yes' WHERE pID = 19;
UPDATE BILL SET paid = 'yes' WHERE pID = 22;
UPDATE BILL SET paid = 'yes' WHERE pID = 21;
UPDATE BILL SET paid = 'yes' WHERE pID = 23;
UPDATE BILL SET paid = 'yes' WHERE pID = 24;
UPDATE BILL SET paid = 'yes' WHERE pID = 25;
UPDATE BILL SET paid = 'yes' WHERE pID = 30;
UPDATE BILL SET paid = 'yes' WHERE pID = 31;
UPDATE BILL SET paid = 'yes' WHERE pID = 32;
UPDATE BILL SET paid = 'yes' WHERE pID = 33;
UPDATE BILL SET paid = 'yes' WHERE pID = 34;
UPDATE BILL SET paid = 'yes' WHERE pID = 35;



-- DOCTORS --------------------------------------------------------------------------

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (1, 'John Smith', TO_DATE('1985-01-01', 'YYYY-MM-DD'), 1234567890, 'Cardiology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (2, 'Sarah Johnson', TO_DATE('1992-12-25', 'YYYY-MM-DD'), 2345678901, 'Pediatrics');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (3, 'Michael Brown', TO_DATE('1992-12-25', 'YYYY-MM-DD'), 3456789012, 'Oncology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (4, 'Emily Davis', TO_DATE('1985-07-21', 'YYYY-MM-DD'), 4567890123, 'Psychiatry');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (5, 'William Martinez', TO_DATE('1989-02-25', 'YYYY-MM-DD'), 5678901234, 'Neurology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (6, 'Grace Thompson', TO_DATE('1994-05-03', 'YYYY-MM-DD'), 6789012345, 'Dermatology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (7, 'Robert Taylor', TO_DATE('1985-01-01', 'YYYY-MM-DD'), 7890123456, 'Endocrinology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (8, 'Alexis Hernandez', TO_DATE('1990-04-10', 'YYYY-MM-DD'), 8901234567, 'Gynecology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (9, 'Oliver Wilson', TO_DATE('1994-05-03', 'YYYY-MM-DD'), 9012345678, 'Cardiology');

INSERT INTO DOCTOR (sID, name, birth_day, phone, specialty)
VALUES (10, 'Evelyn Lee', TO_DATE('1980-05-30', 'YYYY-MM-DD'), 1234509876, 'Ophthalmology');

-- NURSES --------------------------------------------------------------------------
INSERT INTO NURSE (sID, name, birth_day, phone, shift) 
VALUES (11, 'Emily Adams', TO_DATE('1987-11-30', 'YYYY-MM-DD'), 1234567890, 'Morning');

INSERT INTO NURSE (sID, name, birth_day, phone, shift) 
VALUES (12, 'Daniel Lee', TO_DATE('1992-04-15', 'YYYY-MM-DD'), 2345678901, 'Evening');

INSERT INTO NURSE (sID, name, birth_day, phone, shift) 
VALUES (13, 'Jessica Kim', TO_DATE('1985-09-20', 'YYYY-MM-DD'), 3456789012, 'Night');

INSERT INTO NURSE (sID, name, birth_day, phone, shift) 
VALUES (14, 'Oliver Chen', TO_DATE('1990-06-05', 'YYYY-MM-DD'), 4567890123, 'Morning');

INSERT INTO NURSE (sID, name, birth_day, phone, shift) 
VALUES (15, 'Sophia Patel', TO_DATE('1988-01-01', 'YYYY-MM-DD'), 5678901234, 'Evening');

-- WARDBOYS --------------------------------------------------------------------------
INSERT INTO WARD_BOY (sID, name, birth_day, phone, duty)
VALUES (16, 'David Johnson', TO_DATE('1990-06-25', 'YYYY-MM-DD'), 1234567890, 'Cleaning');

INSERT INTO WARD_BOY (sID, name, birth_day, phone, duty)
VALUES (17, 'Emily Brown', TO_DATE('1985-03-12', 'YYYY-MM-DD'), 2345678901, 'Room Care');

INSERT INTO WARD_BOY (sID, name, birth_day, phone, duty)
VALUES (18, 'William Davis', TO_DATE('1988-08-15', 'YYYY-MM-DD'), 3456789012, 'Laundry');

INSERT INTO WARD_BOY (sID, name, birth_day, phone, duty)
VALUES (19, 'Sophia Wilson', TO_DATE('1992-01-06', 'YYYY-MM-DD'), 4567890123, 'Stock Management');

INSERT INTO WARD_BOY (sID, name, birth_day, phone, duty)
VALUES (20, 'Benjamin Garcia', TO_DATE('1986-11-22', 'YYYY-MM-DD'), 5678901234, 'Assisting Nurses');

-- CLINICAL LABS --------------------------------------------------------------------------
INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (101, 'Lab-A', 10, 'available', 'Blood test');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (102, 'Lab-B', 8, 'available', 'Urine test');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (103, 'Lab-C', 12, 'unavailable', 'MRI scan');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (104, 'Lab-D', 6, 'available', 'X-ray');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (105, 'Lab-E', 14, 'unavailable', 'Ultrasound');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (106, 'Lab-F', 9, 'available', 'Blood test');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (107, 'Lab-G', 11, 'available', 'CT scan');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (108, 'Lab-H', 7, 'available', 'Urine test');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (109, 'Lab-I', 10, 'available', 'X-ray');

INSERT INTO CLINICAL_LAB (rID, name, capacity, availability, lab_type)
VALUES (110, 'Lab-J', 8, 'unavailable', 'MRI scan');

-- OPERATION THEATERS --------------------------------------------------------------------------

INSERT INTO OPERATION_THEATER (rID, name, capacity, availability, op_type) 
VALUES (301, 'OT-1', 10, 'available', 'General');

INSERT INTO OPERATION_THEATER (rID, name, capacity, availability, op_type) 
VALUES (302, 'OT-2', 8, 'available', 'Neuro');

INSERT INTO OPERATION_THEATER (rID, name, capacity, availability, op_type) 
VALUES (303, 'OT-3', 12, 'unavailable', 'Cardiac');

INSERT INTO OPERATION_THEATER (rID, name, capacity, availability, op_type) 
VALUES (304, 'OT-4', 6, 'available', 'Ortho');

INSERT INTO OPERATION_THEATER (rID, name, capacity, availability, op_type) 
VALUES (305, 'OT-5', 15, 'unavailable', 'ENT');

-- ICU --------------------------------------------------------------------------
INSERT INTO ICU (rID, name, capacity, availability, icu_type) 
VALUES (201, 'ICU-1', 5, 'available', 'General');

INSERT INTO ICU (rID, name, capacity, availability, icu_type) 
VALUES (202, 'ICU-2', 5, 'available', 'Cardiac');

INSERT INTO ICU (rID, name, capacity, availability, icu_type) 
VALUES (203, 'ICU-3', 5, 'available', 'Surgical');

INSERT INTO ICU (rID, name, capacity, availability, icu_type) 
VALUES (204, 'ICU-4', 5, 'unavailable', 'Neurological');

INSERT INTO ICU (rID, name, capacity, availability, icu_type) 
VALUES (205, 'ICU-5', 5, 'available', 'Pediatric');

-- MAINTAIN --------------------------------------------------------------------------
INSERT INTO MAINTAIN (RID, SID) VALUES (101, 16);
INSERT INTO MAINTAIN (RID, SID) VALUES (102, 17);
INSERT INTO MAINTAIN (RID, SID) VALUES (103, 18);
INSERT INTO MAINTAIN (RID, SID) VALUES (104, 19);
INSERT INTO MAINTAIN (RID, SID) VALUES (105, 20);
INSERT INTO MAINTAIN (RID, SID) VALUES (106, 16);
INSERT INTO MAINTAIN (RID, SID) VALUES (107, 17);
INSERT INTO MAINTAIN (RID, SID) VALUES (108, 18);
INSERT INTO MAINTAIN (RID, SID) VALUES (109, 19);
INSERT INTO MAINTAIN (RID, SID) VALUES (110, 20);
INSERT INTO MAINTAIN (RID, SID) VALUES (201, 16);
INSERT INTO MAINTAIN (RID, SID) VALUES (202, 17);
INSERT INTO MAINTAIN (RID, SID) VALUES (203, 18);
INSERT INTO MAINTAIN (RID, SID) VALUES (204, 19);
INSERT INTO MAINTAIN (RID, SID) VALUES (205, 20);
INSERT INTO MAINTAIN (RID, SID) VALUES (301, 16);
INSERT INTO MAINTAIN (RID, SID) VALUES (302, 17);
INSERT INTO MAINTAIN (RID, SID) VALUES (303, 18);
INSERT INTO MAINTAIN (RID, SID) VALUES (304, 19);
INSERT INTO MAINTAIN (RID, SID) VALUES (305, 20);
-- takecare ------------------------------------------------------
INSERT INTO TAKE_CARE (PID, SID) VALUES (11, 12);
INSERT INTO TAKE_CARE (PID, SID) VALUES (22, 11);
INSERT INTO TAKE_CARE (PID, SID) VALUES (19, 15);
INSERT INTO TAKE_CARE (PID, SID) VALUES (9, 14);
INSERT INTO TAKE_CARE (PID, SID) VALUES (32, 13);
INSERT INTO TAKE_CARE (PID, SID) VALUES (16, 11);
INSERT INTO TAKE_CARE (PID, SID) VALUES (3, 12);
INSERT INTO TAKE_CARE (PID, SID) VALUES (21, 14);
INSERT INTO TAKE_CARE (PID, SID) VALUES (26, 15);
INSERT INTO TAKE_CARE (PID, SID) VALUES (4, 13);

-- handle --------------------------------------------------
INSERT INTO HANDLE (SID, PID) VALUES (5, 34);
INSERT INTO HANDLE (SID, PID) VALUES (7, 30);
INSERT INTO HANDLE (SID, PID) VALUES (10, 3);
INSERT INTO HANDLE (SID, PID) VALUES (7, 10);
INSERT INTO HANDLE (SID, PID) VALUES (8, 29);
INSERT INTO HANDLE (SID, PID) VALUES (1, 19);
INSERT INTO HANDLE (SID, PID) VALUES (5, 9);
INSERT INTO HANDLE (SID, PID) VALUES (4, 6);
INSERT INTO HANDLE (SID, PID) VALUES (6, 25);
INSERT INTO HANDLE (SID, PID) VALUES (2, 21);
INSERT INTO HANDLE (SID, PID) VALUES (7, 14);
INSERT INTO HANDLE (SID, PID) VALUES (2, 11);
INSERT INTO HANDLE (SID, PID) VALUES (3, 29);
INSERT INTO HANDLE (SID, PID) VALUES (6, 35);
INSERT INTO HANDLE (SID, PID) VALUES (4, 26);
INSERT INTO HANDLE (SID, PID) VALUES (5, 27);
INSERT INTO HANDLE (SID, PID) VALUES (1, 30);
INSERT INTO HANDLE (SID, PID) VALUES (3, 11);
INSERT INTO HANDLE (SID, PID) VALUES (7, 26);
INSERT INTO HANDLE (SID, PID) VALUES (9, 12);
INSERT INTO HANDLE (SID, PID) VALUES (2, 31);
INSERT INTO HANDLE (SID, PID) VALUES (10, 19);
INSERT INTO HANDLE (SID, PID) VALUES (4, 30);
INSERT INTO HANDLE (SID, PID) VALUES (8, 12);

-- ADMITTED_TO --------------------------------------------------
INSERT INTO ADMITTED_TO (RID, PID) VALUES (102, 1);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (102, 2);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 3);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (104, 4);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (104, 5);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (104, 6);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (106, 7);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (106, 8);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 9);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 10);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (108, 11);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (109, 12);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 13);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (102, 14);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 15);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 16);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (109, 17);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (108, 18);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 19);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 20);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 21);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (104, 22);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 23);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 24);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (101, 25);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 26);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 27);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (107, 28);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (301, 29);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (301, 30);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (302, 31);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (304, 32);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (302, 33);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (202, 34);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (201, 35);
INSERT INTO ADMITTED_TO (RID, PID) VALUES (205, 36);
