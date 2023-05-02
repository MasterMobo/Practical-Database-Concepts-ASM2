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
