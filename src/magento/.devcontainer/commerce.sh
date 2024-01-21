#!/bin/bash

# install magento cloud

: ${PORT:=8080}
: ${BASEURL:="http://localhost:$PORT/"}
: ${DEPLOY_MODE:="developer"}
: ${COMMERCE_EDITION:="magento/project-enterprise-edition"}
: ${SKIP_SETUP:="false"}
: ${SECURE:="0"}


CHECKSUM=$(sha256sum composer.lock)

if [ "$SKIP_SETUP" != "true" ]
then

    if [ ! -f composer.json ]
    then
        composer create-project --repository=https://repo.magento.com/ $COMMERCE_EDITION .
    else
        composer install
    fi

    if [ ! -f app/etc/env.php ]
    then
        INSTALL="true"
        bin/magento setup:install \
            --backend-frontname=backend \
            --amqp-host=db \
            --amqp-port=5672 \
            --amqp-user=guest \
            --amqp-password=guest \
            --db-host=db \
            --db-user=magento \
            --db-password=magento \
            --db-name=magento \
            --search-engine=elasticsearch7 \
            --elasticsearch-host=db \
            --elasticsearch-port=9200 \
            --elasticsearch-index-prefix=magento2 \
            --elasticsearch-enable-auth=0 \
            --elasticsearch-timeout=15 \
            --session-save=redis \
            --session-save-redis-host=db \
            --session-save-redis-port=6379 \
            --session-save-redis-db=2 \
            --session-save-redis-max-concurrency=20 \
            --cache-backend=redis \
            --cache-backend-redis-server=db \
            --cache-backend-redis-db=0 \
            --cache-backend-redis-port=6379 \
            --page-cache=redis \
            --page-cache-redis-server=db \
            --page-cache-redis-db=1 \
            --page-cache-redis-port=6379

        ## Configure Application

        bin/magento config:set --lock-env web/secure/use_in_frontend $SECURE
        bin/magento config:set --lock-env web/secure/use_in_adminhtml $SECURE
        bin/magento config:set --lock-env web/seo/use_rewrites 1
        bin/magento config:set --lock-env system/full_page_cache/caching_application 2
        bin/magento config:set --lock-env system/full_page_cache/ttl 604800
        bin/magento config:set --lock-env catalog/search/enable_eav_indexer 1
        bin/magento config:set --lock-env dev/static/sign 0

        # bin/magento admin:adobe-ims:enable \
        #                 --organization-id=$IMS_ORG_ID \
        #                 --client-id=IMS_CLIENT_ID \
        #                 --client-secret=$IMS_CLIENT_SECRET \
        #                 --2fa=$IMS_2FA_ENABLED

        bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth
        bin/magento module:disable Magento_TwoFactorAuth

        bin/magento cache:enable block_html full_page

        bin/magento admin:user:create --admin-user admin --admin-password admin123 --admin-firstname demo --admin-lastname user --admin-email noreply@blueacornici.com
    fi

    INSTALL="true"

    if [ "$INSTALL" == "true" ] || [ "$(sha256sum composer.lock)" != "$CHECKSUM" ]
    then

        bin/magento config:set --lock-env web/unsecure/base_url "$BASEURL"
        bin/magento config:set --lock-env web/secure/base_url "$BASEURL"

        bin/magento setup:upgrade
        bin/magento indexer:reindex
        bin/magento deploy:mode:set $DEPLOY_MODE
        bin/magento cache:flush
    fi
fi


php -S 127.0.0.1:$PORT -t ./pub/ ./phpserver/router.php
# php-fpm8.1 --allow-to-run-as-root --nodaemonize%   
# sleep infinity