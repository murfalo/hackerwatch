%if MINES
	%replace VALUE_HP 200
	%replace VALUE_ARMOR 20
	%replace VALUE_RESISTANCE 20
%elif PRISON
	%replace VALUE_HP 500
	%replace VALUE_ARMOR 40
	%replace VALUE_RESISTANCE 40
%elif ARMORY
	%replace VALUE_HP 900
	%replace VALUE_ARMOR 60
	%replace VALUE_RESISTANCE 60
%elif ARCHIVES
	%replace VALUE_HP 1400
	%replace VALUE_ARMOR 80
	%replace VALUE_RESISTANCE 80
%endif