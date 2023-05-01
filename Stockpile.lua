local drawer = peripheral.wrap("back");
drawer.getAmount = drawer_getAmount;
minimum = 64

function drawer_getAmount() 
	return drawer.list()[2].count
end

while true do
	local value = drawer.getAmount() > 64
	for side in redstone.getSides() do
		redstone.setOutput(side , value);
	end
end