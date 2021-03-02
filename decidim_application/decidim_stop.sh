PID=$(ps -ef | grep decidim_application | grep -v grep | awk {'print $2'})
kill -9 $PID
