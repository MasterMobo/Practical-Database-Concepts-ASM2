-- Reports
	-- Patient Report
		Select pID, name, birth_day, phone, address, disease, treatment, day_in, day_out from PATIENT;

	-- Staff Report
		Select sID, name, birth_day, phone from STAFF;

	-- Room Report
		Select rID, name, capacity, availability from ROOM;

	-- Bill Report
		select BID, PID, PATIENT_NAME, DURATION, DUE_DAY, PRICE, PAID,
		CASE Paid
		WHEN 'yes' THEN 'success'
		WHEN 'no' THEN 'danger'
		END AS BADGE_STATE,
		CASE Paid
		WHEN 'yes' THEN 'fa-check'
		WHEN 'no' THEN 'fa-exclamation'
		END AS BADGE_ICON
		FROM BILL;

	-- Handle Report
		Select sID, doctor_name, pID, patient_name from HANDLE;

	-- Take care Report
		Select pID, patient_name, sID, nurse_name from TAKE_CARE;

	-- Maintain Report	
		Select rID, room_name, sID, room_name from MAINTAIN;

	-- Admission Report
		Select rID, room_name, room_name, room_name from ADMISSION;

-- Charts
	-- Patient
		-- Monthly New Patients
			SELECT TO_CHAR(day_in, 'MM-YYYY') AS month, COUNT(*) AS patient_count
				FROM PATIENT
				GROUP BY TO_CHAR(day_in, 'MM-YYYY')
				ORDER BY month DESC;
        -- Disease Distribution
			SELECT disease, COUNT(*) AS count
				FROM PATIENT
				GROUP BY disease
				ORDER BY count DESC;
        -- Age Distribution 
			SELECT 
				CASE
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 10 THEN '0-10'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 20 THEN '11-20'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 30 THEN '21-30'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 40 THEN '31-40'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 50 THEN '41-50'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 60 THEN '51-60'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 70 THEN '61-70'
    ELSE '70+' END AS AGE_GROUP, 
				COUNT(*) AS TOTAL
				FROM PATIENT
				GROUP BY 
				CASE
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 10 THEN '0-10'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 20 THEN '11-20'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 30 THEN '21-30'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 40 THEN '31-40'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 50 THEN '41-50'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 60 THEN '51-60'
    WHEN FLOOR(MONTHS_BETWEEN(SYSDATE, birth_day)/12) <= 70 THEN '61-70'
				ELSE '70+' END;
	-- Staff
		-- Staff Break-Down
			SELECT 'Doctors' AS category, COUNT(*) AS count
				FROM DOCTOR
				UNION ALL
			SELECT 'Nurses' AS category, COUNT(*) AS count
				FROM NURSE
				UNION ALL
			SELECT 'Ward Boys' AS category, COUNT(*) AS count
				FROM WARD_BOY;
		-- Doctor Speciality
			SELECT SID,
				NAME,
				BIRTH_DAY,
				PHONE,
				SPECIALTY
			from DOCTOR;
		-- Nurse Shift
			select SID,
				NAME,
				BIRTH_DAY,
				PHONE,
				SHIFT
			from NURSE;
    -- Room
		-- Room Break-down
			SELECT 'Clinical Lab' AS room_type, COUNT(*) AS num_rooms
				FROM CLINICAL_LAB
				UNION
			SELECT 'Operation Theater' AS room_type, COUNT(*) AS num_rooms
				FROM OPERATION_THEATER
				UNION
			SELECT 'ICU' AS room_type, COUNT(*) AS num_rooms
				FROM ICU;
		-- Room Availability
			SELECT RID,
				NAME,
				CAPACITY,
				AVAILABILITY
			FROM ROOM;
    -- Bill
		-- Monthly Earnings
			SELECT TO_CHAR(due_day, 'MM-YYYY') AS month_year, SUM(price) AS total_earnings
				FROM BILL
				WHERE paid = 'yes'
				GROUP BY TO_CHAR(due_day, 'MM-YYYY')
				ORDER BY TO_DATE(month_year, 'MM-YYYY');
		-- Total Bills Paid
			select BID,
				PID,
				PATIENT_NAME,
				DURATION,
				DUE_DAY,
				PRICE,
				PAID
			from BILL;
		