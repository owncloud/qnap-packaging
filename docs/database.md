# database

navigate to the ownCloud app root (eg. `/share/CACHEDEV1_DATA/.qpkg/ownCloud`)

## backup

```bash
system-docker-compose exec db pg_dumpall -c -U owncloud > ownCloud_database_$(date +%Y-%m-%d_%H_%M_%S).sql
```

## restore

```bash
# delete / drop the current database
system-docker-compose exec db dropdb owncloud -U owncloud
# create new database
system-docker-compose exec db createdb owncloud -U owncloud
# restore data to database
cat ownCloud_database_xxxxx.sql | system-docker-compose exec -T db psql -U owncloud -d owncloud
```
