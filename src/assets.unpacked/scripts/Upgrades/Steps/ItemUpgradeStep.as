namespace Upgrades
{
	class ItemUpgradeStep : UpgradeStep
	{
		ActorItem@ m_item;

		ItemUpgradeStep(ActorItem@ item, Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			@m_item = item;

			m_costGold = m_item.cost;
		}

		string GetTooltipTitle() override
		{
			return "\\c" + GetItemQualityColorString(m_item.quality) + UpgradeStep::GetTooltipTitle();
		}

		string GetTooltipDescription() override
		{
			string ret = UpgradeStep::GetTooltipDescription();

			if (m_item.set !is null)
			{
				ret += "\n\n";
				ret += GetItemSetColorString(GetLocalPlayerRecord(), m_item);
			}

			return ret;
		}

		void DrawShopIcon(Widget@ widget, SpriteBatch& sb, vec2 pos, vec2 size, vec4 color) override
		{
			Sprite@ spriteItemDot = null;
			Sprite@ spriteItemPlus = null;

			auto wButton = cast<ShopButtonWidget>(widget);
			if (wButton !is null)
			{
				@spriteItemDot = wButton.m_itemDot;
				@spriteItemPlus = wButton.m_itemPlus;
			}
			else
			{
				auto wIcon = cast<UpgradeIconWidget>(widget);
				if (wIcon !is null)
				{
					@spriteItemDot = wIcon.m_itemDot;
					@spriteItemPlus = wIcon.m_itemPlus;
				}
			}

			if (m_item.icon !is null)
			{
				int iconWidth = m_item.icon.GetWidth();
				int iconHeight = m_item.icon.GetHeight();

				m_item.icon.Draw(sb, vec2(
					pos.x + size.x / 2 - iconWidth / 2,
					pos.y + size.y / 2 - iconHeight / 2
				), g_menuTime, color);
			}

			int dotX = int(size.x - spriteItemDot.GetWidth());
			int dotY = int(size.y - spriteItemDot.GetHeight());

			if (m_item.quality != ActorItemQuality::Common)
			{
				vec4 colorDot = GetItemQualityColor(m_item.quality);
				vec2 dotPos = pos + vec2(dotX, dotY);
				sb.DrawSprite(dotPos, spriteItemDot, g_menuTime, colorDot);
				dotX -= spriteItemDot.GetWidth();
			}

			if (m_item.set !is null)
			{
				vec4 colorDot = ParseColorRGBA("#" + SetItemColorString + "FF");
				vec2 dotPos = pos + vec2(dotX, dotY);
				sb.DrawSprite(dotPos, spriteItemDot, g_menuTime, colorDot);
				dotX -= spriteItemDot.GetWidth();
			}

			auto record = GetLocalPlayerRecord();
			if (record.itemForgeAttuned.find(m_item.idHash) != -1)
				sb.DrawSprite(pos, spriteItemPlus, g_menuTime);
		}

		float PayScale(PlayerRecord@ record) override
		{
			return record.GetModifiers().ShopCostMul(cast<PlayerBase>(record.actor), this);
		}

		void PayForUpgrade(PlayerRecord@ record) override
		{
			if (CanAfford(record))
			{
				Stats::Add("items-bought", 1, record);
				Stats::Add("items-bought-" + GetItemQualityName(m_item.quality), 1, record);

				record.itemsBought.insertLast(m_item.id);
			}

			UpgradeStep::PayForUpgrade(record);
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			return false;
		}

		bool IsRestricted() override
		{
			auto record = GetLocalPlayerRecord();

			if (record.items.find(m_item.id) != -1)
				return true;

%if HARDCORE
			if (cast<Town>(g_gameMode) !is null && (record.GetTitleIndex() + 2) < int(m_item.quality))
				return true;
%endif

			return UpgradeStep::IsRestricted();
		}

		string GetRestrictionReason() override
		{
			string ret = "";

%if HARDCORE
			auto record = GetLocalPlayerRecord();
			if (cast<Town>(g_gameMode) !is null && (record.GetTitleIndex() + 2) < int(m_item.quality))
			{
				auto titleRequired = record.GetTitleList().GetTitle(int(m_item.quality) - 1);
				ret = Resources::GetString(".shop.menu.restriction.player-title", {
					{ "title", Resources::GetString(titleRequired.m_name) }
				}) + "\n";
			}
%endif

			return UpgradeStep::GetRestrictionReason() + ret;
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			auto player = cast<Player>(record.actor);
			if (player is null)
				return false;

			cast<ItemUpgrade>(m_upgrade).SetApplied(record);

			player.AddItem(m_item);
			return true;
		}
	}
}
