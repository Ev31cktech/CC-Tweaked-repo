local drawer = peripheral.wrap("back");
minimum = 64

function drawer_getAmount() 
	if(drawer.list() == nil) then
		return 0;
	end
	return drawer.list()[2].count
end
drawer.getAmount = drawer_getAmount;

while true do
	local value = drawer.getAmount() > 64
	for i, side in pairs(redstone.getSides()) do
		redstone.setOutput(side , value);
	end
end