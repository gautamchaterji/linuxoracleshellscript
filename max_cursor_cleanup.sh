#!/bin/bash

export ORACLE_SID=BANP
export NLS_DATE_FORMAT=yyyy-mm-dd:hh24:mi:ss
#export PATH=/u01/app/oracle/product/19.3.0/dbhome_1/bin:/usr/kerberos/bin:/usr/local/bin:/bin:/usr/bin:/home/oracle/bin
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_HOME=/u01/app/oracle/product/19.3.0/dbhome_1
export LOGFILE=/home/oracle/scripts/gautam/max_cursor_cleanup.log
#echo $ORACLE_SID
. $HOME/.bash_profile
#
#date
sqlplus -s / as sysdba <<EOF >> $LOGFILE
set echo on;
set serveroutput on;
set linesize 151
set pagesize 999
set feedback off
DECLARE
    sqlcommand VARCHAR2(2000) := '';
    CURSOR c1 IS
  SELECT a.VALUE,
         s.osuser,
         s.machine,
         s.username,
         s.sid,
         s.serial#
    FROM v\$sesstat a, v\$statname b, v\$session s
   WHERE     a.statistic# = b.statistic#
         AND s.sid = a.sid
         AND b.name = 'opened cursors current'
         AND osuser IN ('StudentRegistrationSsb', 'StudentSelfService')
         AND s.status = 'INACTIVE'
         AND a.VALUE >= 500
ORDER BY a.VALUE DESC;
BEGIN
    FOR rec IN c1 LOOP
        DBMS_OUTPUT.PUT_LINE(SYSTIMESTAMP||' | '||rec.sid||' | '||rec.serial#||' | '||rec.osuser||' | '||rec.machine||' | '||rec.username);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''
                      || rec.sid
                      || ','
                      || rec.serial#
                      || '''';
    END LOOP;
END;
/
EXIT
EOF
