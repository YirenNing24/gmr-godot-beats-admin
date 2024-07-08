using Godot;
using Godot.Collections;
using Main;
using System.Linq;
using Array = Godot.Collections.Array;



	public partial class Track : Control
	{	
	//** NODE VARIABLES
	public Control barsContainer;
	public BeatMaker editor;
	public PackedScene barScene = GD.Load<PackedScene>("res://Components/BeatMakerComponents/bar.tscn");
	public Color color = Utilities.Constants.DefaultColor;
	public Array<Bar> bars = new();
	public Array<Dictionary> barsData = new();
	public int barsCount = 0;
	public Vector2 realSize = Vector2.Zero;
	public int startPos = 0	;
	public float currentScale = (float)1.2;
	public int trackIndex;
	public bool sizeUpdated = false;
	public bool startPositionUpdated = true;	
	public bool isActive = false;


	public override void _Ready()
		{	
			LoadNodes();
			SpawnBars();
			SetProcess(true);
		}

    public override void _Process(double delta)
    {
		if (realSize != new Vector2() && !sizeUpdated)
		{
			UpdateSize();
			sizeUpdated = true;
		}

		if (!startPositionUpdated)
		{
			UpdateStartPosition();
			startPositionUpdated = true;
		}

    }

    private void UpdateStartPosition()
    {
		barsContainer.Position = new Vector2(startPos * currentScale, barsContainer.Position.Y);
    }

    private void UpdateSize()
    {
		CustomMinimumSize = realSize;
		barsContainer.Visible = true;
    }

	public void UpdateHeight()
	{
		CustomMinimumSize = new Vector2(Size.X, GetHeight());
		editor.UpdateCursorLength();
	}



// func update_height() -> void:
// 	custom_minimum_size = Vector2(size.x, get_height())
// 	editor.update_cursor_length()



    private void LoadNodes()
    {
		barsContainer = GetNode<Control>("./BarsContainer");
		editor = GetNode<BeatMaker>("/root/BeatMaker");
    }

	public void SpawnBars()
		{
			int x = 0;
			if (barsData.Count > 0)
			
			{
				GD.Print("bars counttsssss: ", barsData.Count);
				foreach (Dictionary data in barsData)
				{
                    string dataIndex = (string)data["index"];
                    string dataQuartersCount = (string)data["quarters_count"];
					Bar bar = AddBar(x, dataIndex.ToInt(), dataQuartersCount.ToInt());
					bar.SetNotesData((Array)data["notes"]);
					x += bar.GetWidth();
                }
			} else 
			{
				foreach (int i in Enumerable.Range(0, barsCount))
				{
					Bar bar = AddBar(x, i, Utilities.Constants.QuartersCount);
					x += bar.GetWidth();
				}
			}
		}

    private void ClearBars()
    {
		if (barsContainer.GetChildren().Count == 0)
		{
			return;
		}

		foreach(Bar bar in barsContainer.GetChildren().Cast<Bar>())
		{
			barsContainer.RemoveChild(bar);
		}
    }

    public void SetUp(int barCount, bool updateExisting = false)
		{
			barsCount = barCount;
			if (updateExisting)
			{
				RespawnBars();
			}

		}

	public void SetStartPosition(int value)
	{
		startPos = value;
		startPositionUpdated = false;
	}

	public void SetActive(bool value)
	{
		isActive = value;
	}

	public void SetData(Dictionary trackData)
	{
		Color trackDataColor = (Color)trackData["color"];
		color = new Color(trackDataColor);
		barsData = (Array<Dictionary>)trackData["bars"];
	}

	public int GetHeight()
	{
		return Utilities.Constants.TrackDistance + GetMaxBarHeight();
	}

	public int GetMaxBarHeight()
	{
		int maxHeight = 0;
		foreach(Bar bar in bars)
		{
			int height = bar.GetHeight();
			if (height > maxHeight)
			{
				maxHeight = height;
			}
		}
		return maxHeight;
	}

	public Dictionary GetData()
	{
		Array<Dictionary> barsData = new();
		foreach (Bar bar in bars)
		{
			Dictionary barData = new()
			{
				{ "index", bar.index },
				{ "quarters_count", bar.quartersCount },
				{ "notes", bar.GetNotesData() }
			};
			barsData.Add(barData);
		}
		Dictionary data = new()
		{
			{ "color", color.ToHtml() },
			{ "bars", barsData }
		};

		return data;
	}

	public Bar AddBar(int x, int index, int quartersCount)
	{
		Bar bar = barScene.Instantiate<Bar>();
		bar.trackIndex = trackIndex;
		bar.index = index;
		bar.quartersCount = quartersCount;
		bar.SetXPosition(x);
		barsContainer.AddChild(bar);
		_ = bars.Append(bar);
		

		return bar;
	}

	public void RespawnBars()
	{	
		int currentBarsCount = bars.Count();
		if (currentBarsCount < barsCount)
		{
			int x = (int)bars[currentBarsCount - 1].Position.X + bars[currentBarsCount - 1].GetWidth();
			foreach (int i in Enumerable.Range(0, barsCount))
			{
				if (i > currentBarsCount)
				{
					Bar bar = AddBar(x, i, Utilities.Constants.QuartersCount);
					x += bar.GetWidth();						
				}
			}
			GD.Print("curr_bars_count < bars_count", " bars count:", bars.Count());

		}
		else if (currentBarsCount > barsCount)
		{
			foreach (int i in Enumerable.Range(0, barsCount))
			{
				Bar barsNode = bars[i];
				if (i >= barsCount) 
				{
					barsContainer.RemoveChild(barsNode);
				}
			}
			bars.Resize(barsCount);
			GD.Print("curr_bars_count < bars_count", " bars count:", bars.Count());
		}
	}

	public void SetInfo()
	{
		color = new Color(1, (float)0.752941, (float)0.796078, 1);
		realSize = CustomMinimumSize;
	}

    public void UpdateScale(float value)
    {
		currentScale = value;
		foreach(Bar bar in bars)
		{
			bar.UpdateScale(value);
		}
		float barsContainerY = barsContainer.Position.Y;
		barsContainer.Position = new Vector2(startPos * value, barsContainerY);
    }

}
