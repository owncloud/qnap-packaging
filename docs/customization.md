# examples for custom config

## crontab


edit the `custom/user-crontab` file in the ownCloud app root (eg. `/share/CACHEDEV1_DATA/.qpkg/ownCloud`):

```
*/1  *  *  *  * www-data /bin/bash -c "echo $(date) >> /tmp/custom-crontab"
```

# user.config.php

edit the `custom/user.config.php` file in the ownCloud app root (eg. `/share/CACHEDEV1_DATA/.qpkg/ownCloud`):


```php
<?php
$CONFIG = array(
    'integrity.ignore.missing.app.signature' =>
    [
        0 => 'qnap',
        1 => 'theme-qnap',
    ]
);

```
