local function randomize ()
  local fl = io.open("/dev/urandom");
  local res = 0;
  for f = 1, 4 do res = res*256+(fl:read(1)):byte(1, 1); end;
  fl:close();
  math.randomseed(res);
end;
randomize()
