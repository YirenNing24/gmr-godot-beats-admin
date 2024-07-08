using System;
using Godot;

public partial class Note : Node2D
{
	public Bar bar;
	public Control control;
	public Main.BeatMaker editor;
	public VBoxContainer editorContainer;
	public Panel assignColor;


	public const int BORDER_LINE_W = 1;
	public const float CELL_SCALE_MIN = 0.5f;

	public bool isPressed = false;
	public bool isDeleted = false;
	public bool playing = false;
	public bool isActive = false;
	public int widthScale = 1;
	public int maxWidth = Utilities.Constants.CellWidth;
	public int updatedScale = 1;
	public string member = "";
	public bool slanted = false;
	public bool selected = false;
	public bool isSwipe = false;

	public override void _Ready()
	{
		SetProcess(true);
		LoadNodes();
		
	}

	public void LoadNodes()
	{
		bar = GetNode<Bar>("../");
		control = GetNode<Control>("Control");
		editor = GetNode<Main.BeatMaker>("/root/BeatMaker");
		editorContainer = GetNode<VBoxContainer>("/root/BeatMaker/EditorContainer");
		assignColor = GetNode<Panel>("AssignColor");

		control.GuiInput += OnGuiInputEvent;
	}

    public override void _Process(double delta)
	{
		if (editor.IsInsideTree() && editor.memoryVariables.isPlaying)
		{
			float noteX = GlobalPosition.X;
			float cursorX = editor.nodeVariables.cursorPlayback.GlobalPosition.X;
			if (cursorX >= noteX && cursorX <= noteX + maxWidth * bar.Scale.X)
			{
				if (!playing)
				{
					playing = true;
					QueueRedraw();
				}
			}
			else if (playing)
			{
				playing = false;
				QueueRedraw();
			}
		}
		else if (playing)
		{
			playing = false;
			QueueRedraw();
		}
	}

	public Color GetBorderColor()
	{
		return GetNoteColor();
	}

	public Color GetNoteColor()
	{
		return (isActive || playing) ? bar.track.color : Colors.Aquamarine;
	}

	public void SetActive(bool value)
	{
		isActive = value;
		QueueRedraw();
	}

	public float GetWidth()
	{
		return Utilities.Constants.CellWidth * widthScale;
	}

	public void SetWidth(float value)
	{
		widthScale = (int)(value / Utilities.Constants.CellWidth);
		QueueRedraw();
	}


    public override void _Draw()
    {
		float width = GetWidth();
		float height = Utilities.Constants.CellHeight;
		Rect2 rect2 = new(BORDER_LINE_W, BORDER_LINE_W, width - BORDER_LINE_W * 2, height - BORDER_LINE_W * 2);
		DrawRect(rect2, GetBorderColor());
		Rect2 rect = new(BORDER_LINE_W, BORDER_LINE_W, width - BORDER_LINE_W * 3, height - BORDER_LINE_W * 3);
		DrawRect(rect, GetNoteColor());
		control.Size = new Vector2(width, height);

		assignColor.Size = new Vector2(width, height);

    }

	public void UpdateScale(float value)
	{
		updatedScale = (int)value;
	}

	private void OnGuiInputEvent(InputEvent @event)
	{
		if (@event is InputEventMouseButton mouseEvent)
		{
			if (mouseEvent.ButtonIndex == MouseButton.Left)
			{
				isPressed = mouseEvent.Pressed;
				if (isPressed)
				{
					if (!isActive)
					{
						editor.SetActiveNote(this);
					}
					else
					{
						Position = new Vector2(Position.X, 0);
					}
				}
			}
			else if (mouseEvent.ButtonIndex == MouseButton.Right)
			{
				Delete();
			}
		}
		else if(@event is InputEventMouseMotion mouseMotion && isPressed)
		{
			float width = mouseMotion.Position.X;
			float s = (float)(Math.Round(width / Utilities.Constants.CellWidth / CELL_SCALE_MIN) * CELL_SCALE_MIN);
			if (s >= CELL_SCALE_MIN && s * Utilities.Constants.CellWidth <= maxWidth)
			{
				widthScale = (int)s;
				QueueRedraw();
			}
		}
	}

	public void Delete()
	{
		if (!isDeleted)
		{
			isDeleted = true;
			bar.DeleteNote(this);
			UpdateScale(updatedScale);
		}

	}
}
