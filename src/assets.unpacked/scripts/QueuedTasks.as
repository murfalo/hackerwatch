namespace QueuedTasks
{
	abstract class QueuedTask
	{
		QueuedTask() { m_time = 0; m_queued = false; }
		void Execute() {}
		
		uint m_time;
		bool m_queued;
	}

	
	array<QueuedTask@> g_queuedTasks;
	
	void Initialize()
	{
	}

	void Queue(int delay, QueuedTask@ task)
	{
		if (task is null)
			return;
	
		if (delay <= 0)
		{
			task.Execute();
			return;
		}
	
		if (task.m_queued)
		{
			PrintError("A task cannot be queued twice");
			return;
		}
		else
			task.m_queued = true;
	
		task.m_time = delay + g_scene.GetTime();
		uint time = task.m_time;
		
		for (uint i = 0; i < g_queuedTasks.length(); i++)
		{
			if (g_queuedTasks[i].m_time > time)
			{
				g_queuedTasks.insertAt(i, task);
				return;
			}
		}

		g_queuedTasks.insertLast(task);
	}
	
	void Update(int ms)
	{
		uint time = g_scene.GetTime();
		uint sit = 0;
		for (; sit < g_queuedTasks.length(); sit++)
		{
			if (g_queuedTasks[sit].m_time <= time)
				g_queuedTasks[sit].Execute();
			else
				break;
		}

		if (sit > 0)
			g_queuedTasks.removeRange(0, sit);
	}
	
	void Save(SValueBuilder& builder)
	{
		/*
		if (g_queuedTasks.length() <= 0)
			return;
	
		builder.PushArray("queued-tasks");
		
		for (uint i = 0; i < g_queuedTasks.length(); i++)
		{
			g_queuedTasks.Save(builder);
		}
		
		
		builder.PopArray();
		*/
	}
	
	void Load(SValue@ save)
	{
/*
		auto tasksData = save.GetDictionaryEntry("queued-tasks");
		if (tasksData !is null && tasksData.GetType() == SValueType::Array)
		{
			
		}
*/
	}
}