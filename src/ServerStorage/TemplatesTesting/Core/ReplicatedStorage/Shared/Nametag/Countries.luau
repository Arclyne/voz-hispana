local countryFlags = {

	-- Africa
	DZ = "🇩🇿", -- Algeria
	EG = "🇪🇬", -- Egypt
	NG = "🇳🇬", -- Nigeria
	ZA = "🇿🇦", -- South Africa
	KE = "🇰🇪", -- Kenya
	MA = "🇲🇦", -- Morocco
	TN = "🇹🇳", -- Tunisia
	GH = "🇬🇭", -- Ghana
	ET = "🇪🇹", -- Ethiopia
	AO = "🇦🇴", -- Angola
	BF = "🇧🇫", -- Burkina Faso
	BI = "🇧🇮", -- Burundi
	BJ = "🇧🇯", -- Benin
	BW = "🇧🇼", -- Botswana
	CD = "🇨🇩", -- DR Congo
	CG = "🇨🇬", -- Republic of the Congo
	CI = "🇨🇮", -- Ivory Coast
	CM = "🇨🇲", -- Cameroon
	DJ = "🇩🇯", -- Djibouti
	ER = "🇪🇷", -- Eritrea
	GA = "🇬🇦", -- Gabon
	GM = "🇬🇲", -- Gambia
	GN = "🇬🇳", -- Guinea
	GW = "🇬🇼", -- Guinea-Bissau
	LS = "🇱🇸", -- Lesotho
	LR = "🇱🇷", -- Liberia
	LY = "🇱🇾", -- Libya
	MG = "🇲🇬", -- Madagascar
	ML = "🇲🇱", -- Mali
	MR = "🇲🇷", -- Mauritania
	MW = "🇲🇼", -- Malawi
	MZ = "🇲🇿", -- Mozambique
	NA = "🇳🇦", -- Namibia
	NE = "🇳🇪", -- Niger
	RW = "🇷🇼", -- Rwanda
	SC = "🇸🇨", -- Seychelles
	SD = "🇸🇩", -- Sudan
	SL = "🇸🇱", -- Sierra Leone
	SN = "🇸🇳", -- Senegal
	SO = "🇸🇴", -- Somalia
	SS = "🇸🇸", -- South Sudan
	SZ = "🇸🇿", -- Eswatini
	TG = "🇹🇬", -- Togo
	TZ = "🇹🇿", -- Tanzania
	UG = "🇺🇬", -- Uganda
	ZM = "🇿🇲", -- Zambia
	ZW = "🇿🇼", -- Zimbabwe

	-- Americas
	US = "🇺🇸", -- United States
	CA = "🇨🇦", -- Canada
	MX = "🇲🇽", -- Mexico
	BR = "🇧🇷", -- Brazil
	AR = "🇦🇷", -- Argentina
	CO = "🇨🇴", -- Colombia
	CL = "🇨🇱", -- Chile
	PE = "🇵🇪", -- Peru
	VE = "🇻🇪", -- Venezuela
	BO = "🇧🇴", -- Bolivia
	PY = "🇵🇾", -- Paraguay
	UY = "🇺🇾", -- Uruguay
	EC = "🇪🇨", -- Ecuador
	GY = "🇬🇾", -- Guyana
	SR = "🇸🇷", -- Suriname
	BZ = "🇧🇿", -- Belize
	GT = "🇬🇹", -- Guatemala
	HN = "🇭🇳", -- Honduras
	SV = "🇸🇻", -- El Salvador
	NI = "🇳🇮", -- Nicaragua
	CR = "🇨🇷", -- Costa Rica
	PA = "🇵🇦", -- Panama
	HT = "🇭🇹", -- Haiti
	TT = "🇹🇹", -- Trinidad and Tobago
	BS = "🇧🇸", -- Bahamas
	BB = "🇧🇧", -- Barbados

	-- Asia
	CN = "🇨🇳", -- China
	JP = "🇯🇵", -- Japan
	IN = "🇮🇳", -- India
	KR = "🇰🇷", -- South Korea
	SA = "🇸🇦", -- Saudi Arabia
	TR = "🇹🇷", -- Turkey
	VN = "🇻🇳", -- Vietnam
	ID = "🇮🇩", -- Indonesia
	IR = "🇮🇷", -- Iran
	AF = "🇦🇫", -- Afghanistan
	AM = "🇦🇲", -- Armenia
	AZ = "🇦🇿", -- Azerbaijan
	BH = "🇧🇭", -- Bahrain
	BT = "🇧🇹", -- Bhutan
	BN = "🇧🇳", -- Brunei
	GE = "🇬🇪", -- Georgia
	IQ = "🇮🇶", -- Iraq
	KH = "🇰🇭", -- Cambodia
	KP = "🇰🇵", -- North Korea
	LA = "🇱🇦", -- Laos
	LK = "🇱🇰", -- Sri Lanka
	MM = "🇲🇲", -- Myanmar
	MN = "🇲🇳", -- Mongolia
	MV = "🇲🇻", -- Maldives
	NP = "🇳🇵", -- Nepal
	SY = "🇸🇾", -- Syria
	TJ = "🇹🇯", -- Tajikistan
	TL = "🇹🇱", -- Timor-Leste
	YE = "🇾🇪", -- Yemen

	-- Europe
	GB = "🇬🇧", -- United Kingdom
	FR = "🇫🇷", -- France
	DE = "🇩🇪", -- Germany
	IT = "🇮🇹", -- Italy
	ES = "🇪🇸", -- Spain
	PL = "🇵🇱", -- Poland
	NL = "🇳🇱", -- Netherlands
	SE = "🇸🇪", -- Sweden
	RU = "🇷🇺", -- Russia
	AL = "🇦🇱", -- Albania
	AD = "🇦🇩", -- Andorra
	BA = "🇧🇦", -- Bosnia and Herzegovina
	BY = "🇧🇾", -- Belarus
	CY = "🇨🇾", -- Cyprus
	LI = "🇱🇮", -- Liechtenstein
	LU = "🇱🇺", -- Luxembourg
	MC = "🇲🇨", -- Monaco
	MD = "🇲🇩", -- Moldova
	ME = "🇲🇪", -- Montenegro
	MK = "🇲🇰", -- North Macedonia
	MT = "🇲🇹", -- Malta
	SM = "🇸🇲", -- San Marino
	VA = "🇻🇦", -- Vatican City
	XK = "🇽🇰", -- Kosovo

	-- Oceania
	AU = "🇦🇺", -- Australia
	NZ = "🇳🇿", -- New Zealand
	FJ = "🇫🇯", -- Fiji
	PG = "🇵🇬", -- Papua New Guinea
	SB = "🇸🇧", -- Solomon Islands
	TO = "🇹🇴", -- Tonga
	TV = "🇹🇻", -- Tuvalu
	VU = "🇻🇺", -- Vanuatu
	WS = "🇼🇸", -- Samoa
	KI = "🇰🇮", -- Kiribati
	NR = "🇳🇷", -- Nauru
	PW = "🇵🇼", -- Palau
	MH = "🇲🇭", -- Marshall Islands
	FM = "🇫🇲", -- Micronesia

	-- Middle East
	AE = "🇦🇪", -- United Arab Emirates
	QA = "🇶🇦", -- Qatar
	IL = "🇮🇱", -- Israel
	OM = "🇴🇲", -- Oman
	KW = "🇰🇼", -- Kuwait
	LB = "🇱🇧", -- Lebanon
	JO = "🇯🇴", -- Jordan

	-- Central Asia
	KZ = "🇰🇿", -- Kazakhstan
	UZ = "🇺🇿", -- Uzbekistan
	TM = "🇹🇲", -- Turkmenistan

	-- Caribbean
	CU = "🇨🇺", -- Cuba
	DO = "🇩🇴", -- Dominican Republic
	JM = "🇯🇲", -- Jamaica

	-- Scandinavia
	DK = "🇩🇰", -- Denmark
	NO = "🇳🇴", -- Norway
	FI = "🇫🇮", -- Finland
	IS = "🇮🇸", -- Iceland

	-- Balkans
	GR = "🇬🇷", -- Greece
	RS = "🇷🇸", -- Serbia
	BG = "🇧🇬", -- Bulgaria
	RO = "🇷🇴", -- Romania
	HR = "🇭🇷", -- Croatia

	-- Others
	TH = "🇹🇭", -- Thailand
	MY = "🇲🇾", -- Malaysia
	SG = "🇸🇬", -- Singapore
	PK = "🇵🇰", -- Pakistan
	BD = "🇧🇩", -- Bangladesh
	PH = "🇵🇭", -- Philippines
	TW = "🇹🇼", -- Taiwan
	HK = "🇭🇰", -- Hong Kong
	UA = "🇺🇦", -- Ukraine
	CZ = "🇨🇿", -- Czechia
	HU = "🇭🇺", -- Hungary
	SK = "🇸🇰", -- Slovakia
	CH = "🇨🇭", -- Switzerland
	AT = "🇦🇹", -- Austria
	PT = "🇵🇹", -- Portugal
	BE = "🇧🇪", -- Belgium
	IE = "🇮🇪", -- Ireland
	SI = "🇸🇮", -- Slovenia
	LT = "🇱🇹", -- Lithuania
	LV = "🇱🇻", -- Latvia
	EE = "🇪🇪", -- Estonia
}

return countryFlags