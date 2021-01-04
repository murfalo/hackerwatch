namespace Materials
{
	enum Category
	{
		None,

		Skin,
		Hair,
		Cloth,
		Metal,
		Leather,
		Wood
	}

	string GetCategoryName(Category cat)
	{
		switch (cat)
		{
			case Category::Skin: return Resources::GetString(".materials.skin");
			case Category::Hair: return Resources::GetString(".materials.hair");
			case Category::Cloth: return Resources::GetString(".materials.cloth");
			case Category::Metal: return Resources::GetString(".materials.metal");
			case Category::Leather: return Resources::GetString(".materials.leather");
			case Category::Wood: return Resources::GetString(".materials.wood");
		}
		return "";
	}

	Category GetCategoryValue(string cat)
	{
		     if (cat == "skin") return Category::Skin;
		else if (cat == "hair") return Category::Hair;
		else if (cat == "cloth") return Category::Cloth;
		else if (cat == "metal") return Category::Metal;
		else if (cat == "leather") return Category::Leather;
		else if (cat == "wood") return Category::Wood;
		return Category::None;
	}
}
