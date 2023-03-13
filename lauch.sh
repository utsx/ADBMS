#!/bin/bash
PGUSER=s309552
PGPASSWORD=I5nWI16akJHsFp8A
PGDATABASE=studs
PGHOST=localhost

read -p "Введите название схемы: " schema

psql -h $PGHOST -d $PGDATABASE -U $PGUSER -c "CALL get_key_info('$schema');"