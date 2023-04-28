DECLARE
  v_sql VARCHAR2(200);
BEGIN
  FOR t IN (SELECT table_name FROM user_tables)
  LOOP
    v_sql := 'TRUNCATE TABLE ' || t.table_name;
    EXECUTE IMMEDIATE v_sql;
  END LOOP;
END;