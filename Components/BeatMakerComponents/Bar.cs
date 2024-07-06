using System;
using System.Linq;
using Godot;
using Godot.Collections;
using Array = Godot.Collections.Array;

public partial class Bar : Node2D
{
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
		Note note = noteScene.Instantiate();
		note.Position = new Vector2(x, 0);
		notes.Append(note);
		AddChild(note);
		SortNotes();
		UpdateNotesWidth();
		return note;
	}

		public Note AddSwipeNote(int x)
	{
		_ = filledCells.Append(x);
		SwipeNote swipeNote = swipeNoteScene.Instantiate();
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
		var notesData = new Godot.Collections.Array();

		foreach (Note note in notes)
		{
			 Dictionary noteData = new()
             {
				{ "pos", note.Position.X * Utilities.Constants.CellExportScale },
				{ "len", note.GetWidth() * Utilities.Constants.CellExportScale },
				{ "member", note.Member },
				{ "layer", note.LayerNumber },
				{ "slanted", note.Slanted },
				{ "swipe", note.IsSwipe }
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
			if (x >= note.Position.X || x < note.Position.X + note.GetWidth())
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
			note.MaxWidth = CalcNoteMaxWidth(note.Position.X);
		}
	}

	public int CalcNoteMaxWidth(int noteX)
	{
		int endNoteX = noteX + Utilities.Constants.CellWidth;
		int maxNoteWidth = GetWidth() - noteX;
		foreach (int x in Enumerable.Range(end_note_x, GetWidth(), Utilities.Constants.CellWidth))
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



func delete_note(note: StaticBody2D) -> void:
	print("delete note begin", filled_cells)
	filled_cells.erase(int(note.position.x))
	update_notes_width()
	remove_child(note)
	notes.erase(note)
	editor.unset_active_note()
	print("deleted!", filled_cells)





}
