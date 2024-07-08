using Godot;

public partial class CursorPlayback : Node2D
{
	const int DEFAULT_LENGTH_OFFSET = 18;
	public Color STATIC_COLOR = new("cfaa38");
	public Color PLAYBACK_COLOR = new("FF03BC");

	public int speed = 0;
	public int speedScale = 1;
	public int currSpeed = 0;
	public bool isStatic = false;
	public int length = (int)(Utilities.Constants.WaveformHeight * 5.5);
	public int lengthOffset = 10;

	public override void _Ready()
	{
		SetProcess(true);
	}

	public void Start()
	{
		currSpeed = speed;
	}


	public void Stop()
	{
		currSpeed = 0;
	}

	public override void _Process(double delta)
	{
	}

	public void SetLengthOffset(int value)
	{
		lengthOffset = value;
	}

	public override void _Draw()
		{
			if (isStatic)
			{
				var pointer = new Vector2[] { new(5, 0), new Vector2(-5, 0), new Vector2(0, 5) };
				DrawColoredPolygon(pointer, STATIC_COLOR);
				DrawLine(new Vector2(0, 0), new Vector2(0, length + lengthOffset + DEFAULT_LENGTH_OFFSET), STATIC_COLOR, 1);
			}
			else
			{
				DrawLine(new Vector2(0, 0), new Vector2(0, length + lengthOffset + DEFAULT_LENGTH_OFFSET), PLAYBACK_COLOR, 1);
			}
		}

}
