# Debug

Go to ownCloud QPKG base path, eg:
`cd /share/CACHEDEV1_DATA/.qpkg/owncloud`

## Commands

- `./owncloud.sh debug-status` shows the lifecyle status of the ownCloud QPKG
- `./owncloud.sh debug-container-status` equals a `docker-compose ps`
- `./owncloud.sh debug-owncloud-logs` shows logs of the owncloud container
- `./owncloud.sh debug-db-logs` shows logs of the database container
- `./owncloud.sh debug-redis-logs` shows logs of the redis container
