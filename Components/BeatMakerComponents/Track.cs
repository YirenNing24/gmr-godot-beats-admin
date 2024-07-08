using Godot;
using Godot.Collections;
using System.Linq;
using Array = Godot.Collections.Array;



	public partial class Track : Control
	{	
		//** NODE VARIABLES
		public Control barsContainer;
		public Control editor;
		public PackedScene barScene;
		public Color color = Utilities.Constants.DefaultColor;
		public Array<Bar> bars;
		public Array<Dictionary> barsData;
		public int barsCount = 0;
		public Vector2 realSize;
		public int startPos = 0	;
		public float currentScale = (float)1.2;
		public int trackIndex;
		public bool sizeUpdated = false;
		public bool startPositionUpdated = true;	
		public bool isActive = false;
		public override void _Ready()
		{
			SpawnBars();
			SetProcess(true);
		}
		public override void _Process(double delta)
		{
		}

		public void SpawnBars()
		{
			// ClearBars()
			int x = 0;
			if (barsData.Count > 0)
			{
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

		public void UpdateScale(int value)
		{
			currentScale = value;
			foreach(Bar bar in bars)
			{
				bar.UpdateScale(value);

			}
			float barsContainerY = barsContainer.Position.Y;
			barsContainer.Position = new Vector2(startPos * value, barsContainerY);
		}


		public Dictionary GetData()
		{
			var barsData = new Array<Dictionary>();
			foreach (Bar bar in bars)
			{
				var barData = new Dictionary
				{
					{ "index", bar.index },
					{ "quarters_count", bar.quartersCount },
					{ "notes", bar.GetNotesData() }
				};
				barsData.Add(barData);
			}
			var data = new Dictionary
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

            _ = bars.Append<Node2D>(bar);
			barsContainer.CallDeferred("AddChild", bar);

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

    internal void UpdateScale(float scaleRatio)
    {
        throw new System.NotImplementedException();
    }
}
