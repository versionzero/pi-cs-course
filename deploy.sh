#!/bin/sh

SITE_HOME=/home/www/pi.versionzero.org/

scp -r www/* www:${SITE_HOME}
ssh www "find ${SITE_HOME} -type d -exec chmod -v 755 {} \; && find ${SITE_HOME} -type f -exec chmod -v 644 {} \;"
