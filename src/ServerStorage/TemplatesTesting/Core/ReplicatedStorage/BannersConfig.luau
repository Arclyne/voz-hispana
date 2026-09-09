local BannersConfig = {}

BannersConfig.Order = {
	"CasasEnOferta",
	"BailesEnOferta",
	"Destacado",
}

BannersConfig.SecondsPerBanner = 7
BannersConfig.SecondsBeforeHighlight = 0.45
-- Sube a 2.2 para que quepa el baile completo (tres brincos, ~1.15 s) y al
-- brillo le quede un momento de reposo antes de apagarse.
BannersConfig.HighlightSeconds = 2.2

BannersConfig.SlideSpring = { tension = 190, friction = 28 }
BannersConfig.DotShapeSpring = { tension = 320, friction = 24 }
BannersConfig.ActiveDotAspectRatio = 3.4

BannersConfig.Automatic = {
	CasasEnOferta = {
		Category = "Houses",
		InfoModule = "HousesInfo",
		TitleSingular = "OFERTA DE CASA",
		TitlePlural = "OFERTAS DE CASAS",
		OffersPerBanner = 2,
		MaxOffers = 4,
		Section = "Shop",
	},

	BailesEnOferta = {
		Category = "Dances",
		InfoModule = "DancesInfo",
		TitleSingular = "OFERTA DE BAILE",
		TitlePlural = "OFERTAS DE BAILES",
		OffersPerBanner = 2,
		MaxOffers = 4,
		Section = "Shop",
		AnimatedRigs = true,
	},
}

BannersConfig.Manual = {
	Destacado = {
		OnClick = {
			Section = "Shop",
			ScrollCategory = "ToolBox",
		},
	},
}

return BannersConfig
