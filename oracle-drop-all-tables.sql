BEGIN
   FOR cur_rec IN (SELECT object_name, object_type FROM user_objects WHERE object_type IN ('TABLE'))
   LOOP
      BEGIN
         EXECUTE IMMEDIATE ('DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '" CASCADE CONSTRAINTS');
         DBMS_OUTPUT.PUT_LINE('DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '" CASCADE CONSTRAINTS');
      EXCEPTION
         WHEN OTHERS THEN
            IF SQLCODE != -942 THEN
               DBMS_OUTPUT.PUT_LINE('FAILED: DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '" CASCADE CONSTRAINTS -- ' || SQLERRM);
            END IF;
      END;
   END LOOP;
END;