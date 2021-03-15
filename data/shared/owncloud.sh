#!/bin/sh
QPKG_CONF=/etc/config/qpkg.conf
QPKG_NAME=ownCloud
QPKG_DISPLAY_NAME=$(/sbin/getcfg $QPKG_NAME Display_Name -f $QPKG_CONF)
CONTAINER_STATION_DIR=$(/sbin/getcfg container-station Install_Path -f $QPKG_CONF)
QPKG_PROXY_FILE=/etc/container-proxy.d/$QPKG_NAME
OWNCLOUD_ROOT=$(/sbin/getcfg $QPKG_NAME Install_Path -f $QPKG_CONF)

CRON_JOB="*/5 * * * *  $OWNCLOUD_ROOT/owncloud.sh get-licenses"
CRON_FILE=/etc/config/crontab

cd $OWNCLOUD_ROOT

_load_images() {
    DOCKER_IMAGES_SOURCE=$OWNCLOUD_ROOT/docker-images/DOCKER_IMAGES
    if test -f "$DOCKER_IMAGES_SOURCE"; then
        DOCKER_IMAGES=$(cat $DOCKER_IMAGES_SOURCE)
        
        for docker_image in $DOCKER_IMAGES; do
            $CONTAINER_STATION_DIR/bin/system-docker inspect $docker_image
            exit_status=$?
            if [ ! $exit_status -eq 0 ]; then
                cat $OWNCLOUD_ROOT/docker-images/$(echo $docker_image | sed -e 's?/?-?' -e 's?:?_?').tar | $CONTAINER_STATION_DIR/bin/system-docker load
            fi
        done
    fi
}

_proxy_reload() {
    /etc/init.d/thttpd.sh reload
    /etc/init.d/stunnel.sh reload
}

_proxy_start() {
	cat > $QPKG_PROXY_FILE << EOF
ProxyRequests off
ProxyPass /owncloud http://127.0.0.1:11409
ProxyPassReverse /owncloud http://127.0.0.1:11409
EOF
    proxy_reload
}

_proxy_stop() {
    rm -f $QPKG_PROXY_FILE
    proxy_reload
}

_register_license() {
    qlicense_tool register -a $QPKG_NAME -v $(/sbin/getcfg $QPKG_NAME Version -f $QPKG_CONF) -c "$OWNCLOUD_ROOT/owncloud.sh"
}

case "$1" in
    start)
        if ! qts_qpkg_is_enabled $QPKG_NAME; then
            qts_error_exit "$QPKG_DISPLAY_NAME is disabled."
        fi
        _register_license
        $0 get-licenses
        _load_images
        
        $CONTAINER_STATION_DIR/bin/system-docker-compose up -d --remove-orphans
        
        grep -qF "$CRON_JOB" "$CRON_FILE"  || echo "$CRON_JOB" | tee -a "$CRON_FILE"
        crontab $CRON_FILE
        
        _proxy_start
        _proxy_reload
    ;;
    
    stop)
        $CONTAINER_STATION_DIR/bin/system-docker-compose down --remove-orphans
        
        _proxy_stop
        _proxy_reload
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
    ;;
    
    get-licenses)
        mkdir -p $OWNCLOUD_ROOT/licenses
        qlicense_tool installed_list -n -d -a $QPKG_NAME > $OWNCLOUD_ROOT/licenses/owncloud.json
    ;;
    
    callback_success)
        echo '{"code": "0", "message": "", "info": "", "result": []}'
    ;;
    
    before_buy)
        $0 callback_success
    ;;
    
    before_buy_variant)
        $0 callback_success
    ;;
    
    before_activate)
        $0 callback_success
    ;;
    
    before_deactivate)
        $0 callback_success
    ;;
    
    after_activate)
        $0 callback_success
    ;;
    
    after_deactivate)
        $0 callback_success
    ;;
    
    after_expired)
        $0 callback_success
    ;;
    
    after_extend)
        $0 callback_success
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
