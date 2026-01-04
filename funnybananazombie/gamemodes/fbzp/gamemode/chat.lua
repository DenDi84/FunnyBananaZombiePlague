CHAT = {};

function CHAT:OnMessage( ply, text, team )
	if ( #text >= 4 and string.sub( string.lower( text ), 1, 4 ) == "/cam" ) then
		ply:ToogleView();
	end
	if ( #text >= 6 and string.sub( string.lower( text ), 1, 6 ) == "/stuck" ) then
		ply:Unstuck();
	end
	if ( #text >= 6 and string.sub( string.lower( text ), 1, 6 ) == "!stuck" ) then
		ply:Unstuck();
	end
	return text;
end

-- Обработка сообщений в чат:
-- hook.Add( "PlayerSay", "PlayerSayExample", function( ply, text, team )
-- 	text = text:gsub("\"", "");
-- 	text = text:gsub("'", "");
-- 	local typemessage = 0;
-- 	if (team) then typemessage = 1; end
-- 	if ( string.sub( string.lower( text ), 1, 4 ) == "/all" ) then
-- 		toClient("global", { ply:GetNomer(), ply:GetNWString("name"), ply:GetNWString("group_name"), string.sub( text, 5 ) });
-- 		typemessage = 3;
-- 	elseif ( string.sub( string.lower( text ), 1, 3 ) == "/gl" ) then
-- 		toClient("global", { ply:GetNomer(), ply:GetNWString("name"), ply:GetNWString("group_name"), string.sub( text, 4 ) });
-- 		typemessage = 3;
-- 	else
-- 		return
-- 	end
-- 	saveChatMessage(ply:SteamID64(), text, typemessage);
-- 	return "";
-- end )