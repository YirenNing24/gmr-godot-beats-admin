using System;
using System.Linq;
using Godot;
using Godot.Collections;
using Array = Godot.Collections.Array;

public partial class Bar : Node2D
{	

	public PackedScene noteScene = GD.Load<PackedScene>("res://Components/BeatMakerComponents/note.tscn");

	public Node2D grid;
	public Label indexLabel;
	public Control control;
	public Track track;
	public Main.BeatMaker editor;
	public VBoxContainer editorContainer;

	// Convert Godot variables to C# variables
	public int quartersCount = Utilities.Constants.QuartersCount;  // Assuming you have a Constants class with QUARTERS_COUNT defined
	public int index = 0;
	public int trackIndex;
	public Array filledCells;
	public Array<Note> notes;
	public int xPos = 0;
	public bool isPressed = false;
	public bool isActive = false;
	public bool holdCtrl = false;
	public bool holdShift = false;

	public override void _Ready()
	{
		indexLabel.Text = index.ToString();
		control.CustomMinimumSize = new Vector2(GetWidth(), GetHeight());
		control.GuiInput += OnControlGuiInput;

	}



    public int GetWidth()
	{
		return GetCellsCount() * Utilities.Constants.CellWidth;
	}

	public  int GetHeight()
	{
		return GetCellsCount() * Utilities.Constants.CellHeight;
	}

	public int GetCellsCount()
	{
		return quartersCount * Utilities.Constants.CellsInQuarterCount;
	}

	public void SetXPosition(int value)
	{
		xPos = value;
		Position = new Vector2(xPos, 0);
	}

	public void UpdateScale(int value)
	{
		Scale = new Vector2(value, 1);
		Position = new Vector2(xPos, Position.Y);
		indexLabel.SetScale(new Vector2(1 / value, 1));
		foreach(Note note in notes)
		{
			note.UpdateScale(value);
		}
	}

	public Note AddNote(int x)
	{
		_ = filledCells.Append(x);
		Note note = noteScene.Instantiate<Note>();
		note.Position = new Vector2(x, 0);
        _ = notes.Append(note);
		AddChild(note);
		SortNotes();
		UpdateNotesWidth();
		return note;
	}

		public Note AddSwipeNote(int x)
	{
		_ = filledCells.Append(x);
		SwipeNote swipeNote = (SwipeNote)noteScene.Instantiate();
		swipeNote.Position = new Vector2(x, 0);
		notes.Append(swipeNote);
		AddChild(swipeNote);
		SortNotes();
		UpdateNotesWidth();
		return swipeNote;
	}

	public void ClearNotes()
	{
		foreach(Note note in notes)
		{
			RemoveChild(note);
		}
		notes.Clear();
		filledCells.Clear();
	}

	public void SetNotesData(Array notesData)
	{
		foreach(Dictionary data in notesData.Select(v => (Dictionary)v))
		{
			int dataPos = (int)data["pos"];
			int x = dataPos / Utilities.Constants.CellExportScale;
			Note note = AddNote(x);
            string dataLength = (string)data["len"];
			note.SetWidth(dataLength.ToInt() / Utilities.Constants.CellExportScale);
        }
	}

	public Array GetNotesData()
	{
		var notesData = new Array();

		foreach (Note note in notes)
		{
			 Dictionary noteData = new()
             {
				{ "pos", note.Position.X * Utilities.Constants.CellExportScale },
				{ "len", note.GetWidth() * Utilities.Constants.CellExportScale },
				{ "member", note.member },
				{ "swipe", note.isSwipe }
			};

			notesData.Add(noteData);
		}

		return notesData;
	}

	public void SortNotes()
	{
		for (int i = notes.Count - 1; i >= 0; i--)
		{
			for (int j = 1; j <= i; j++)
			{
				if (notes[j - 1].Position.X > notes[j].Position.X)
				{
					Note t = notes[j - 1];
					notes[j - 1] = notes[j];
					notes[j] = t;
				}
			}
		}
	}

	public bool IsCellEmptyAt(int x)
	{
		if (filledCells.Contains(x))
		{
			return false;
		}
		foreach (Note note in notes)
		{
			if (x >= note.Position.X && x < note.Position.X + note.GetWidth())
			{
				return false;
			}	
		}
		return true;
	}

	public void UpdateNotesWidth()
	{
		foreach (Note note in notes)
		{
			note.maxWidth = CalcNoteMaxWidth((int)note.Position.X);
		}
	}

	public int CalcNoteMaxWidth(int noteX)
	{
		int endNoteX = noteX + Utilities.Constants.CellWidth;
		int maxNoteWidth = GetWidth() - noteX;
		for (int x = endNoteX; x < GetWidth(); x += Utilities.Constants.CellWidth)
		{
			if (filledCells.Contains(x))
			{
				GD.Print("filled cells has", x);
				maxNoteWidth = x - noteX;
				break;
			}
		}
		return maxNoteWidth;
	}

	public void DeleteNote(Note note)
	{
		filledCells.Remove(note.Position.X);
		UpdateNotesWidth();
		RemoveChild(note);
		notes.Remove(note);
		editor.UnsetActiveNote();
		GD.Print("delete note begin", filledCells);
	}

	public Note GetFirstNote()
	{
		if (notes.Count == 0)
		{
			return null;
		}

		Note first = notes[0];
		foreach (Note note in notes)
		{
			if (note.Position.X < first.Position.X)
			{
				first = note;
			}
		}
		return first;

	}

	public Bar GetNextBar()
	{
		if (track.bars.Count > index + 1)
		{
			return track.bars[index + 1];
		}
		else
		{
			return null;
		}
	}

	public Note GetNoteAfter (int xPosition)
	{
		if (notes.Count > 0)
		{
			Array next = new();
			foreach (Note note in notes)
			{
				if (note.Position.X > xPosition)
				{
					next.Append(note);

				}
			}
			if (next.Count > 0)
			{
				Note first = (Note)next[0];
				foreach (Note nextNote in next.Select(v => (Note)v))
				{
					if (nextNote.Position.X < first.Position.X)
						{
							first = nextNote;
		
						}
				}
				return first;
			}
		}
		return null;
	}



// func update_scale(val: int) -> void:
// 	scale = Vector2(val, 1)
// 	position = Vector2(x_pos * val, position.y)
// 	index_label.set_scale(Vector2(1.0 / val, 1))
// 	for note: StaticBody2D in notes:
// 		note.update_scale(val)

    private void OnControlGuiInput(InputEvent @event)
    {
		if (@event is InputEventMouseButton mouseEvent && mouseEvent.ButtonIndex == MouseButton.Left && mouseEvent.Pressed)
		{
			if (holdShift)
			{
				float noteX = mouseEvent.Position.X;
				int cellIndex = (int)MathF.Floor(noteX / Utilities.Constants.CellWidth);
				if (IsCellEmptyAt(cellIndex * Utilities.Constants.CellWidth))
				{
					GD.Print("Swipe note added at cell index:", cellIndex);
				}

				SwipeNote swipeNote = (SwipeNote)AddSwipeNote(cellIndex * Utilities.Constants.CellWidth);

				// Find the index of the note in the filled_cells array
				int noteIndex = filledCells.IndexOf(swipeNote.Position.X);
				GD.Print("filled: ", filledCells);
 				GD.Print("Note index in filled_cells:", noteIndex);

				editor.SetActiveNote(swipeNote);
            }
			else
			{
				GD.Print("Bar " + index.ToString() + " Clicked at", mouseEvent.Position);
				// Calculate the index of the cell based on the note's x position
				float noteX = mouseEvent.Position.X;
				int cellIndex = (int)Math.Floor(noteX / Utilities.Constants.CellWidth);
				if (IsCellEmptyAt(cellIndex * Utilities.Constants.CellWidth))
				{
					GD.Print("Note added at cell index:", cellIndex);

					// Add the note at the cell index
					Note note = AddNote(cellIndex * Utilities.Constants.CellWidth);

					//Find the index of the ntoe in the filled cells array
					int noteIndex = filledCells.IndexOf(note.Position.X);

				 	GD.Print("filled: ", filledCells);
 					GD.Print("Note index in filled_cells:", noteIndex);

				}
				else
				{
					GD.Print("Cell is not empty, cannot add note");
				}


			}

		}


    }
}
