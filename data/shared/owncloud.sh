#!/bin/sh
QPKG_CONF=/etc/config/qpkg.conf
QPKG_NAME=owncloud
QPKG_DISPLAY_NAME=$(/sbin/getcfg $QPKG_NAME Display_Name -f $QPKG_CONF)
CONTAINER_STATION_DIR=$(/sbin/getcfg container-station Install_Path -f $QPKG_CONF)
OWNCLOUD_ROOT=$(/sbin/getcfg $QPKG_NAME Install_Path -f $QPKG_CONF)

CRON_JOB="*/5 * * * *  $OWNCLOUD_ROOT/owncloud.sh get-licenses"
CRON_FILE=/etc/config/crontab

QTS_LOG_TAG="$QPKG_DISPLAY_NAME"
. $CONTAINER_STATION_DIR/script/qpkg-functions
. $CONTAINER_STATION_DIR/script/dqpkg-functions


load_images() {
    DOCKER_IMAGES_SOURCE=$OWNCLOUD_ROOT/docker-images/DOCKER_IMAGES
    if test -f "$DOCKER_IMAGES_SOURCE"; then
        DOCKER_IMAGES=$(cat $DOCKER_IMAGES)

        for docker_image in $DOCKER_IMAGES; do
            $CONTAINER_STATION_DIR/bin/system-docker inspect $docker_image
            exit_status=$?
            if [ ! $exit_status -eq 1]; then
                cat $OWNCLOUD_ROOT/docker-images/$(echo $docker_image | sed -e 's?/?-?' -e 's?:?_?').tar | $CONTAINER_STATION_DIR/bin/system-docker load
            fi
        done
    fi
}

case "$1" in
    start)
        if ! qts_qpkg_is_enabled $QPKG_NAME; then
            qts_error_exit "$QPKG_DISPLAY_NAME is disabled."
        fi

        $OWNCLOUD_ROOT/owncloud.sh get-licenses || true
        load_images

        wait_qcs_ready
        qbus_cmd start
        complete_action "configure installing installed starting running stopping stopped" 120

        grep -qF "$CRON_JOB" "$CRON_FILE"  || echo "$CRON_JOB" | tee -a "$CRON_FILE"
        crontab $CRON_FILE
    ;;

    stop)
        qbus_cmd stop
        complete_action "stopped" 120
    ;;

    restart)
        $0 stop
        $0 start
    ;;

    remove)
        ESCAPED_CRON_JOB=$(printf '%s\n' "$CRON_JOB" | sed -e 's/[]\/$*.^[]/\\&/g');
        sed -i "/$ESCAPED_CRON_JOB/d" $CRON_FILE
        crontab $CRON_FILE
        $0 stop
        qbus_cmd remove
        complete_action "removed" 120
    ;;

    get-licenses)
        mkdir -p $OWNCLOUD_ROOT/licenses
        /usr/local/bin/qlicense_tool installed_list -n -d -a $QPKG_NAME > $OWNCLOUD_ROOT/licenses/owncloud.json
    ;;

    ready-check)
        # ready check does not work. Blocks forever if we do not return a zero exit code right away
        #set -e
        #$CONTAINER_STATION_DIR/bin/system-docker-compose exec owncloud wait-for-it localhost:8080 300
    ;;

    debug-status)
        $QBUS get com.qnap.dqpkg/qpkg/${QPKG_NAME}
    ;;

    debug-container-status)
        $CONTAINER_STATION_DIR/bin/system-docker-compose ps
    ;;

    debug-owncloud-logs)
        $CONTAINER_STATION_DIR/bin/system-docker-compose logs -f owncloud
    ;;

    debug-db-logs)
        $CONTAINER_STATION_DIR/bin/system-docker-compose logs -f db
    ;;

    debug-redis-logs)
        $CONTAINER_STATION_DIR/bin/system-docker-compose logs -f redis
    ;;

    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
esac

exit 0
