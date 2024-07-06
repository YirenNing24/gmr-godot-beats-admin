using Godot;
using Godot.Collections;
using System;
using System.Linq;



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
					Bar bar = (Bar)AddBar(x, dataIndex.ToInt(), dataQuartersCount.ToInt());
					bar.SetNotesData(data["notes"]);
					x += bar.getWidth();

                }
			
			} else 
			{
				foreach (int i in Enumerable.Range(0, barsCount))
				{
					Bar bar = (Bar)AddBar(x, i, Utilities.Constants.QuartersCount);
					x += bar.GetWidth();
				}
			}
		}


		public void SetUp(int barCount, bool updateExisting)
		{
			barsCount = barCount;
			if (updateExisting)
			{
				RespawnBars();
			}

		}


		public Node2D AddBar(int x, int index, int quartersCount)
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
				int x = bars[currentBarsCount - 1];
			}
		}
	
	}




