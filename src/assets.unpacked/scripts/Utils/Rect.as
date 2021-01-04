class Rect
{
	float left, right;
	float top, bottom;

	Rect() { }
	Rect(float lt, float tp, float rt, float bt)
	{
		left = lt; right = rt;
		top = tp; bottom = bt;
	}

	bool Contains(float x, float y)
	{
		return x >= left and x < right and y >= top and y < bottom;
	}

	bool Contains(vec2 p)
	{
		return Contains(p.x, p.y);
	}

	bool Contains(Rect& r)
	{
		return Contains(r.left, r.top) and Contains(r.right, r.bottom);
	}

	bool Contains(Rect& r, vec3 offset)
	{
		return Contains(r.left + offset.x, r.top + offset.y + offset.z) and Contains(r.right + offset.x, r.bottom + offset.y);
	}

	bool IntersectsWith(Rect& r)
	{
		return !(r.left > right or r.right < left or r.top > bottom or r.bottom < top);
	}

	bool IntersectsWith(Rect& r, float xOffset, float yOffset)
	{
		return !(r.left + xOffset > right or r.right + xOffset < left or r.top + yOffset > bottom or r.bottom + yOffset < top);
	}

	bool IntersectsWith(Rect& r, float xOffset, float yOffset, float zOffset)
	{
		return !(r.left + xOffset > right or r.right + xOffset < left or r.top + yOffset + zOffset > bottom or r.bottom + yOffset < top);
	}

	vec2 GetCenter()
	{
		return vec2((left + right) / 2.0, (top + bottom) / 2.0);
	}

	void Add(vec2 pos)
	{
		left += pos.x; right += pos.y;
		top += pos.y; bottom += pos.y;
	}

	vec4 GetVec4()
	{
		return vec4(
			left,
			top,
			right - left,
			bottom - top
		);
	}
}
