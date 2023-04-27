-- local completion = require "cc.completion"
jsonParser = dofile("/programs/jsonParser.lua")
monitor = { setup = monitor_setup };
tasks = { counter = 0 };
listLoc = "list.json";
stop = false;

function read_file(path)
	local file = io.open(path, "r") -- r read mode and b binary mode
	if not file then return nil end
	local content = file:read "*a" -- *a or *all reads the whole file
	file:close()
	return content
end

function write_file(path, content)
	local file = io.open(path, "w");
	if not file then return false end
	file:write(content);
	file:close()
	return true
end

function monitor_setup()
	monitor = peripheral.find("monitor");
	monitor.setup = monitor_setup;
	local size = { monitor.getSize() };
	monitor.size = { width = size[1], height = size[2] }
	monitor.setTextScale(0.5);
	monitor.setCursorPos(1, 1);
	monitor.setBackgroundColor(colors.black);
	monitor.setTextColor(colors.white);
	monitor.cls = function()
		peripheral.find("screen");
		local motd = "-=TODO=-"
		monitor.clear();
		monitor.setCursorPos(math.ceil((monitor.size.width - #motd) / 2), 1)
		monitor.write(motd);
		monitor.setCursorPos(1, 2)
	end
	monitor.println = function(line)
		local x, y = monitor.getCursorPos();
		monitor.write(line);
		monitor.setCursorPos(1, y + 1);
	end
	monitor.cls()
end

function reload_taskList()
	tasks = read_file(listLoc);
	if tasks ~= nil then
		tasks = jsonParser.parse(tasks);
		tasks.counter = tasks.tasks[#tasks.tasks].id + 1;
	else
		tasks = {};
	end
	tasks.add = function(_name, _status, _priority, _creator, _assignees)
		local task = {
			id = tasks.counter,
			creator = _creator or "31ck",
			["created time"] = os.date("%D %T"),
			["edited time"] = os.date("%D %T"),
			assignees = _assignees or {},
			name = _name,
			status = _status or "backlog",
			priority = _priority or 0
		}
		table.insert(tasks.tasks, task);
		tasks.counter = tasks.counter + 1;
	end
	tasks.remove = function(id)
		for i = 1, #tasks.tasks, 1 do
			local task = tasks.tasks[i];
			if task.id == id then
				table.remove(tasks.tasks, i);
			end
		end
		tasks.reprint();
	end
	tasks.edit = function(id,change)
		for i = 1, #tasks.tasks, 1 do
			local task = tasks.tasks[i];
			if task.id == id then
				tasks.tasks[i] = {
					id = task.id,
					creator = task.creator,
					["created time"] = task["created time"],
					["edited time"] = os.date("%D %T"),
					assignees = change.assignees or task.assignees,
					name = change.name or task.name,
					status = change.status or task.status,
					priority = change.priority or task.priority
				}
			end
		end
		tasks.reprint();
	end
	tasks.reprint = function()
		tasks.save();
		monitor.cls()
		for null, task, i in ipairs(tasks.tasks) do
			monitor.println("[] " .. task.name);
		end
	end
	tasks.save = function ()
		write_file(listLoc, "{\"tasks\":" .. jsonParser.stringify(tasks.tasks) .. "}");
	end
	tasks.reprint();
end

function setup()
	os.setComputerLabel("TODOListServer");
	monitor.setup();
	reload_taskList();
end

function loop()
	repeat
		parallel.waitForAny(
			function()
				local inp = read(nil, nil, function(text) return completion.choice(text, tasks) end);
				if inp == "stop" then
					stop = true;
				end
			end,
			function()
				while true do
					event, key = os.pullEvent("key")
				end
			end
		);
	until stop
end

setup()
-- loop()
