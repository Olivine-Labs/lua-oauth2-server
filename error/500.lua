context.log("Server Error: "..context.request.url, "error")
if not context.output then context.output = {} end
context.output.error = {}

for _, error in pairs(context.error) do
  --Build stack trace
  local trace = {}
  local headerRemoved = false
  for line in error.trace:gmatch("[^\r\n]+") do
    if headerRemoved then
      line = line:gsub("^%s*", "")
      if string.sub(line, 1, 1) ~= '[' then
        trace[#trace+1]=line
      end
    else
      headerRemoved = true
    end
  end

  local message = error.message
  if type(message) == "table" then
    message = message[1]
  end

  context.output.error[#context.output.error+1] = {
    message = message,
    trace = trace,
  }
end

context.output.status = context.response.status
