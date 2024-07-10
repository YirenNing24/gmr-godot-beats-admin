using System;
using Godot;

public partial class SwipeNote : Note
{
	public bool IsSwipe = true;

	public override void _Ready()
	{
		SetProcess(true);
		LoadNodes();
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
}
