require("mysqloo");
-- https://github.com/FredyH/MySQLOO/releases

-- mysql -P 3306 -h 45.80.69.209 -u admin_gmod -p admin_gmod
-- GRANT ALL PRIVILEGES ON `admin_gmod`.* TO 'admin_gmod'@'%' IDENTIFIED BY 'wflLMAanoe'; 

local DATABASE_HOST = "45.80.69.209";
local DATABASE_PORT = 3306;
local DATABASE_NAME = "admin_gmod";
local DATABASE_USERNAME = "admin_gmod";
local DATABASE_PASSWORD = "wflLMAanoe";

databaseObject = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT);
databaseObject:setAutoReconnect( true );
databaseObject.onConnected = function() 
	databaseObject:setCharacterSet( 'utf8' );
	msg("[green DATABASE CONNECT SUCCESS]");
end
databaseObject.onConnectionFailed = function() 
	msg("[red Failed to connect to the database.]");
end
databaseObject:connect();



timer.Remove("CheckConnectDBStatus");
timer.Create( "CheckConnectDBStatus", 2, 0, function() 
	if (!databaseObject:ping()) then
		msg("[yellow DATABASE RECONNECT...]");
		databaseObject = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT);
		databaseObject:connect();
	end
end );