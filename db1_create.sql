CREATE EXTENSION IF NOT EXISTS dblink;
SELECT dblink_connect('db2', 'dbname=db2 host=db2 user=db2 password=password');

CREATE TABLE IF NOT EXISTS t1 (
    id SERIAL PRIMARY KEY,
    field1 VARCHAR(255)
);

DROP TRIGGER IF EXISTS copy_t1_to_t2 ON t1;
DROP FUNCTION IF EXISTS copy_t1_to_t2();
CREATE FUNCTION copy_t1_to_t2() RETURNS trigger AS $copy_t1_to_t2$
  DECLARE
    f1 VARCHAR;
  BEGIN
    RAISE NOTICE 'DEBUG field1 %', NEW.field1;
    RAISE NOTICE 'DEBUG id %', NEW.id;
    PERFORM dblink('dbname=db2 host=db2 user=db2 password=password', 'INSERT INTO t2 (id, field2) VALUES(' || NEW.id ||', ''' || NEW.field1 || ''')');
    RETURN NEW;
  END;
$copy_t1_to_t2$ LANGUAGE plpgsql;

CREATE TRIGGER copy_t1_to_t2 AFTER INSERT ON t1 FOR EACH ROW EXECUTE PROCEDURE copy_t1_to_t2();
