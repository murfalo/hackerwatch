%if TOOLKIT
namespace Toolkits
{
	// Source: https://love2d.org/forums/viewtopic.php?t=80560
	class Camera
	{
		float scale = 1.0f;
		float _scale = 1.0f;

		vec2 _offset;

		vec2 target;
		vec2 targetPrev;
		vec2 targetNow;

		Camera() { MoveTo(vec2()); }
		Camera(const vec2 &in pos) { MoveTo(pos); }
		Camera(const vec2 &in pos, const vec2 &in t) { MoveTo(pos, t); }

		void Save(SValueBuilder@ builder)
		{
			builder.PushFloat("scale", scale);
			builder.PushFloat("_scale", _scale);

			builder.PushVector2("_offset", _offset);

			builder.PushVector2("target", target);
			builder.PushVector2("target-prev", targetPrev);
			builder.PushVector2("target-now", targetNow);
		}

		void Load(SValue@ data)
		{
			scale = GetParamFloat(UnitPtr(), data, "scale", false, scale);
			_scale = GetParamFloat(UnitPtr(), data, "_scale", false, _scale);

			_offset = GetParamVec2(UnitPtr(), data, "_offset", false, _offset);

			target = GetParamVec2(UnitPtr(), data, "target", false, target);
			targetPrev = GetParamVec2(UnitPtr(), data, "target-prev", false, targetPrev);
			targetNow = GetParamVec2(UnitPtr(), data, "target-now", false, targetNow);
		}

		void MoveTo(const vec2 &in pos)
		{
			vec2 t = Window::GetWindowSize() / 2.0f;
			MoveTo(pos, t);
		}

		void MoveTo(const vec2 &in pos, vec2 t)
		{
			_offset = pos - t / _scale;
			_offset.x = floor(_offset.x);
			_offset.y = floor(_offset.y);

			t.x = floor(t.x);
			t.y = floor(t.y);
			target = targetPrev = t;
		}

		void SetTarget(const vec2 &in t, bool reset)
		{
			target = t;
			if (reset)
				targetPrev = t;
		}

		vec2 GetWorldPos(const vec2 &in pos)
		{
			return _offset + pos / _scale;
		}

		vec2 GetScreenPos(const vec2 &in pos)
		{
			return (pos - _offset) * _scale;
		}

		vec2 GetMidpoint()
		{
			return GetWorldPos(Window::GetWindowSize() / 2.0f);
		}

		void Set()
		{
			targetNow = GetWorldPos(targetPrev);
			targetPrev = target;
			_scale = scale;

			vec2 offset = GetWorldPos(target);
			_offset -= offset - targetNow;
		}

		float GetScale()
		{
			return _scale;
		}

		mat4 GetTransform()
		{
			mat4 ret;
			ret = mat::scale(ret, _scale);
			ret = mat::translate(ret, xyz(_offset * -1.0f));
			return ret;
		}
	}
}
