// Usage:
//   1. Make a .mas file, and add `%include "scripts/SValueObjects.inc"` to the top
//   2. Make a `void Execute()` that calls this API:
//        void AddWithId(const string &in className, bool unpack = false)
//        void Add(const string &in className, bool hasId = false, bool unpack = false)
//   3. Which will generate this API:
//        Loader "ClassName::LoadSingle"
//        Loader "ClassName::LoadMultiple"
//        ClassName::Instances[i]
//   4. If you inherited from SVO and used AddWithId, you also have:
//        ClassName::Get(const string &in id)
//        ClassName::Get(uint idHash)
//
// Example:
//   %include "scripts/SValueObjects.inc"
//
//   void Execute()
//   {
//     AddWithId("MyObject");
//   }
//

class NamespaceScope
{
	array<string> m_stack;
	string m_className;

	NamespaceScope(const string &in name)
	{
		auto parse = name.split("::");
		for (uint i = 0; i < parse.length() - 1; i++)
			m_stack.insertLast(parse[i]);
		m_className = parse[parse.length() - 1];
	}

	void WriteStart(StringBuilder &sb)
	{
		for (uint i = 0; i < m_stack.length(); i++)
			sb += "namespace " + m_stack[i] + " {\n";
		sb += "\n";
	}

	void WriteEnd(StringBuilder &sb)
	{
		for (uint i = 0; i < m_stack.length(); i++)
			sb += "}\n";
		sb += "\n";
	}

	string GetClassName() { return m_className; }
}

void AddWithId(const string &in className, bool unpack = false)
{
	Add(className, true, unpack);
}

void Add(const string &in fullName, bool hasId = false, bool unpack = false)
{
	NamespaceScope ns(fullName);

	string className = ns.GetClassName();

	auto sb = StringBuilder();

	ns.WriteStart(sb);

	sb += "namespace " + className + " {\n";
	sb += "  array<" + className + "@> Instances;\n";

	sb += "  void LoadSingle(SValue@ sv) {\n";
	sb += "    " + className + "@ obj = null;\n";
	sb += "    if (sv.GetType() == SValueType::Dictionary) {\n";
	sb += "      auto svClassName = sv.GetDictionaryEntry(\"class\");\n";
	sb += "      string className = \"" + className + "\";\n";
	sb += "      if (svClassName !is null && svClassName.GetType() == SValueType::String) {\n";
	sb += "        className = svClassName.GetString();\n";
	sb += "      }\n";
	sb += "      @obj = cast<" + className + ">(InstantiateClass(className, sv));\n";
	sb += "      if (obj is null) {\n";
	sb += "        PrintError(\"Unable to instantiate class '\" + className + \"'. Did you forget to inherit from " + className + "?\");\n";
	sb += "        return;\n";
	sb += "      }\n";
	sb += "    }\n";
	sb += "    if (obj is null) {\n";
	sb += "      @obj = " + className + "(sv);\n";
	sb += "    }\n";
	if (unpack)
		sb += "    Reflect::UnpackObject(@obj, sv, true);\n";
	sb += "    Instances.insertLast(obj);\n";
	sb += "  }\n";

	sb += "  void LoadMultiple(SValue@ sv) {\n";
	sb += "    if (sv.GetType() != SValueType::Array) {\n";
	sb += "      PrintError(\"SValue must be an array!\");\n";
	sb += "      return;\n";
	sb += "    }\n";
	sb += "    auto arr = sv.GetArray();\n";
	sb += "    for (uint i = 0; i < arr.length(); i++) {\n";
	sb += "      LoadSingle(arr[i]);\n";
	sb += "    }\n";
	sb += "  }\n";

	if (hasId)
	{
		sb += "  " + className + "@ Get(const string &in id) {\n";
		sb += "    return Get(HashString(id));\n";
		sb += "  }\n";

		sb += "  " + className + "@ Get(uint idHash) {\n";
		sb += "    for (uint i = 0; i < Instances.length(); i++) {\n";
		sb += "      auto obj = Instances[i];\n";
		sb += "      if (obj.m_idHash == idHash) {\n";
		sb += "        return obj;\n";
		sb += "      }\n";
		sb += "    }\n";
		sb += "    return null;\n";
		sb += "  }\n";
	}

	sb += "}\n"; // namespace className

	ns.WriteEnd(sb);

	Resources::AddGeneratedFile("generated/SVO_" + fullName.replace("::", "_") + ".as", sb.String());
}
