CREATE OR REPLACE PROCEDURE get_key_info(schema_name text)
    LANGUAGE plpgsql
AS
$$
DECLARE
    line                   text;
    ans                    text;
    constraint_record      RECORD;
    row_num                int;
    constraint_name        text;
    constraint_type        text;
    schema_name_buff       text;
    schema_name_access     text;
    column_name            text;
    oid_schema             integer;
    table_name             text;
    referenced_table       text;
    referenced_column_name text;
    referenced_column      text;
BEGIN
    SELECT oid INTO oid_schema FROM pg_namespace WHERE nspname = schema_name;
    IF oid_schema IS NULL THEN
        RAISE EXCEPTION 'Схемы не существуюет/';
    END IF;
     ans := '';
    line := '';
    row_num := 1;
    ans := E'\n' || ans ||
           FORMAT('%25s %45s %25s %35s %25s %25s %25s', 'Номер по порядку', 'Имя ограничения целостности', 'Тип',
                  'Имя столбца',
                  'Имя таблицы', 'Имя таблицы', 'Имя столбца') || E'\n';
    FOR i in 1..235
        LOOP
            line := line || '-';
        end loop;
    ans := ans || line;
    FOR constraint_record IN
        SELECT conname,
               contype,
               attname,
               cl.relname,
               CASE WHEN contype = 'f' THEN confrelid::regclass::text END AS ref_table,
               CASE
                   WHEN contype = 'f' THEN (SELECT string_agg(attname, ', ')
                                            FROM pg_attribute
                                            WHERE attrelid = confrelid
                                              AND attnum = ANY (confkey))
                   END                                                    AS ref_column_names
        FROM pg_constraint c
                 JOIN pg_class cl ON cl.oid = c.conrelid
                 JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY (c.conkey)
                 LEFT JOIN pg_namespace n ON n.oid = cl.relnamespace
        WHERE n.nspname = schema_name
          AND contype IN ('p', 'f')
        ORDER BY conname
        LOOP
            SELECT constraint_record.conname,
                   CASE WHEN constraint_record.contype = 'p' THEN 'P' ELSE 'R' END,
                   constraint_record.attname,
                   constraint_record.relname,
                   constraint_record.ref_table,
                   constraint_record.ref_column_names
            INTO constraint_name, constraint_type, column_name, table_name, referenced_table, referenced_column_name;
            ans := ans || E'\n' ||
                   FORMAT('%25s %45s %25s %35s %25s %25s %25s', row_num, constraint_name, constraint_type, column_name,
                          replace(table_name, '"', ''), replace(referenced_table, '"', ''), referenced_column_name);
            row_num := row_num + 1;
        END LOOP;
    RAISE NOTICE '%', ans;
END;
$$;

CREATE TABLE test(
    id integer primary key

);
CREATE TABLE test2(
    id integer primary key,
    id_test integer,
    FOREIGN KEY (id_test) REFERENCES test (id)
);
