# Start CLI as superuser
sudo su postgres
psql

# As another user
psql -d dbname -U username -W

# Create user
CREATE USER username WITH SUPERUSER PASSWORD '...';
ALTER USER username WITH PASSWORD 'newpassword';
ALTER ROLE username CREATEDB;

# Delete user
drop user username;

# List users
\du

# Get connection info eg. You are connected to database "bittrex" as user "username" via socket in "/var/run/postgresql" at port "5432".
\conninfo

# Create a database
CREATE DATABASE dbname;
GRANT ALL PRIVILEGES ON DATABASE dbname TO username;

\l: list all databases
\dt: list all tables in the current database
\connect database_name: to switch to database

\q: to quit

# To be able to switch users 
sudo nano  /etc/postgresql/9.5/main/pg_hba.conf
change:
local   all             postgres                                peer
to
local   all             postgres                                md5

and do: sudo service postgresql restart

# Backup/Restore
pg_dump --column-inserts --data-only dbname > filename.dump
psql dbname < filename.dump


# OSX
To have launchd start postgresql now and restart at login:
  brew services start postgresql
Or, if you don't want/need a background service you can just run:
  postgres -D /usr/local/var/postgres